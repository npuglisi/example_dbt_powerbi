### Nathália Puglisi

## Instructions BigQuery
First of all, the CSV file needs some fixes. When I uploaded this file to my database, all the booleans columns came with a null value.
That means all the columns have TRUE or FALSE information, which had to be changed to a checkbox on Google Sheets

<img src="https://user-images.githubusercontent.com/39974597/175441609-d959b0d6-e2e8-4c62-80a7-55de6ebe1aa6.png" width="600">

That will guarantee the column will have a boolean type of column.

After that, I create a new database on my BigQuery, the steps are:

#### Click on create a table

<img src="https://user-images.githubusercontent.com/39974597/175444486-8fda870b-7a2c-4b5b-b8b2-c6238fbc37f6.png" width="600">


#### Choose the Upload option

<img src="https://user-images.githubusercontent.com/39974597/175444631-71eac7a3-b671-4b99-a9d0-84e6c5acdf92.png" width="600">


#### Browse it

<img src="https://user-images.githubusercontent.com/39974597/175444728-dcee3de9-c2a4-463e-8039-bc452f0d9821.png" width="600">


#### Give it a name, and then Create

<img src="https://user-images.githubusercontent.com/39974597/175444919-832972de-afe5-480a-8e65-dae737657c1f.png" width="600">


#### Done that, I started to create my queries:


#### It's a query with aggregate information about the Equipment
```
SELECT equipment_type, 
AVG(mileage) AS avg_miles, 
max(mileage) as max_miles,
count(distinct loadsmart_id) as amount_ship,
avg(book_price) as avg_price, 
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour,
count(distinct carrier_name) as amount_carrier
FROM loadsmart-354023.bd_loadsmart.table_test
where equipment_type is not null
group by equipment_type
```

#### It's a query with aggregate information about the carrier. The Lifetime per travel is a calculation with the amount of travel and the time the carrier is on the platform, using the first and the last travel. That way, I can know how this carrier travels per day.
```
SELECT carrier_name, 
count(distinct loadsmart_id) / CASE WHEN (DATE_DIFF(MAX(pickup_date), MIN(pickup_date),DAY)) = 0 THEN 1 ELSE DATE_DIFF(MAX(pickup_date), MIN(pickup_date),DAY) END as travel_per_lifetime,
count(distinct loadsmart_id) as amount_ship,
AVG(mileage) AS avg_miles, 
max(mileage) as max_miles,
sum(mileage) AS sum_miles, 
sum(book_price) as sum_price, 
avg(book_price) as avg_price, 
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour,
sum(TIMESTAMP_DIFF(delivery_date, pickup_date, hour)) as sum_diff_hour,
sum(case when carrier_on_time_overall is true then 1 else 0 end) as ontime,
sum(case when carrier_on_time_overall is false then 1 else 0 end) as not_ontime
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by carrier_name
```

#### It's a query about the rank of Carrier for each Lane that will help the Shippers choose which Carrier is faster
```
with query as (
SELECT equipment_type, carrier_name, lane, avg(TIMESTAMP_DIFF(delivery_date, pickup_date, hour)) as avg_diff_hour
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by equipment_type, carrier_name, lane
)

select query.lane, DENSE_RANK() OVER (PARTITION BY query.lane ORDER BY query.avg_diff_hour asc ) AS rank, query.carrier_name
from query
inner join (select lane, count(lane) as amount from query group by 1 having count(lane) > 1) lanes on lanes.lane = query.lane 
order by 2 asc, 3
```

#### It's a query about with aggregate information about the lane. 
```
SELECT lane, count(distinct carrier_name) as amount_carrier, avg(mileage) as avg_mile, avg(book_price) as avg_price, sum(book_price) as sum_price
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by lane
```

## Instructions DBT

In DBT, for each query, I create a model for them. 
I think the good idea is to have one model for each context to keep the context and codes organized.

#### agg_equipment
```
{{config(
    materialized='table'
)}}

SELECT equipment_type, 
AVG(mileage) AS avg_miles, 
max(mileage) as max_miles,
count(distinct loadsmart_id) as amount_ship,
avg(book_price) as avg_price, 
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour,
count(distinct carrier_name) as amount_carrier
FROM loadsmart-354023.bd_loadsmart.table_test
where equipment_type is not null
group by equipment_type
```

#### agg_carrier
```
{{config(
    materialized='table'
)}}

SELECT carrier_name, 
count(distinct loadsmart_id) / CASE WHEN (DATE_DIFF(MAX(pickup_date), MIN(pickup_date),DAY)) = 0 THEN 1 ELSE DATE_DIFF(MAX(pickup_date), MIN(pickup_date),DAY) END as travel_per_lifetime,
count(distinct loadsmart_id) as amount_ship,
AVG(mileage) AS avg_miles, 
max(mileage) as max_miles,
sum(mileage) AS sum_miles, 
sum(book_price) as sum_price, 
avg(book_price) as avg_price, 
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour,
sum(TIMESTAMP_DIFF(delivery_date, pickup_date, hour)) as sum_diff_hour,
sum(case when carrier_on_time_overall is true then 1 else 0 end) as ontime,
sum(case when carrier_on_time_overall is false then 1 else 0 end) as not_ontime
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by carrier_name
```


#### rank_carrier
```
{{config(
    materialized='table'
)}}

with query as (
SELECT equipment_type, carrier_name, lane, avg(TIMESTAMP_DIFF(delivery_date, pickup_date, hour)) as avg_diff_hour
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by equipment_type, carrier_name, lane
)

select query.lane, DENSE_RANK() OVER (PARTITION BY query.lane ORDER BY query.avg_diff_hour asc ) AS rank, query.carrier_name
from query
inner join (select lane, count(lane) as amount from query group by 1 having count(lane) > 1) lanes on lanes.lane = query.lane 
order by 2 asc, 3
```

#### agg_lane
```
{{config(
    materialized='table'
)}}

SELECT lane, count(distinct carrier_name) as amount_carrier, avg(mileage) as avg_mile, avg(book_price) as avg_price, sum(book_price) as sum_price
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by lane
```


#### After creating all my models, I have to run and compile them
<img src="https://user-images.githubusercontent.com/39974597/175447259-68c94d1c-d8fa-4614-8232-3d0346a24506.png" width="600">


#### Now I have all my new tables on my BigQuery, and they are ready to be used in an Analytical Tool.
<img src="https://user-images.githubusercontent.com/39974597/175447556-3b94f999-358e-4a50-a401-56a700226455.png" width="300">



## POWERBI
#### I pivot the dashboard in context as I did in queries.

### Lane - The idea is to understand the behavior of the carriers for each Lane.
#### The List shows the rank of the best Carrier for each Lane, which means there are different performances between lanes, so not only is the price a helper decision, but the execution is too.
#### Carrier by Lane - Indicating which lane had more carriers, there is a way to notice what lane is more searched. I think that is an excellent thing to recommend for new carriers, showing them what the lane more searched for the shippers is.
#### AVG Price and Mile by Lane - The idea is to show each Lane's average mile and average price. In this analysis, I want to see if exists a difference between mile and price for some Lane, but as we can see in the visualization, the average mile follows the average price at the same proportions

<img src="https://user-images.githubusercontent.com/39974597/176062206-6b674ddd-1f31-4a0d-9ac3-12139052af39.png" width="300">


### Equipment - The idea is to understand the behavior behind each equipment and how the carriers are using them.
#### AVG Price and Mile by Equipment - That analysis shows some equipment had more average price than average miles, that means the RFR equipment costs more and has more miles, but doesn't mean that it is the most used, probably is an equipment used for long travels. Furthermore, we can tell the average price and average miles are proportional.
#### Amount Travel by Equipment - This visualization shows what equipment is most popular and is probably used for quick travels.
#### Amount Carrier by Equipment - This visualization shows which equipment is more used for carriers.

<img src="https://user-images.githubusercontent.com/39974597/176062175-141a6137-55cb-47c8-aec1-b60eab657c19.png" width="300">


### Carrier - My favorite one! This visualization is to understand the behavior behind Carriers. The most exciting thing to do in this dash is to choose one Carrier and then look where it is from each different card view.
#### The list view is to understand how the carrier is with better performance and see which delivered on time and which one didn't. Also, I compare the performance with the lifetime per travel from each carrier. That way, I can tell how many deliveries each carrier does per day and how is their performance of them.

#### AVG Price and AVG Mile by Carrier - This visualization shows how the average price is, compared to average miles, but the result that I get is there is some Carrier that cost more than others, even with similar miles.

#### Traver per Lifetime and AVG Miles by Carrier - The idea is to understand how many miles each carrier has compared to how much travel they did per day. That way, I could see some carriers with a lot of miles but with a small lifetime, which means this carrier usually travels long.

#### Sum Miler per Carrier - This visualization shows what carrier has more miles accumulated

<img src="https://user-images.githubusercontent.com/39974597/176063141-5fbc50ff-b852-4d56-92a0-ca9f3a4d5422.png" width="300">

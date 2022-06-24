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


#### It's a query with all information necessary to create a General dashboard with almost all information about the product.
```
SELECT quote_date, equipment_type, carrier_name, pickup_date, pickup_appointment_time, delivery_date, 
delivery_appointment_time, mileage, book_price, TIMESTAMP_DIFF(delivery_date, pickup_date, hour) as diff_hour
FROM 'loadsmart-354023.bd_loadsmart.table_test' ;
```

#### It's a query with aggregate information about the Equipment
```
SELECT equipment_type, 
AVG(mileage) AS avg_miles, 
max(mileage) as max_miles,
count(distinct loadsmart_id) as amount_ship,
avg(book_price) as avg_price, 
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour
FROM 'loadsmart-354023.bd_loadsmart.table_test' 
group by equipment_type;
```

#### It's a query with aggregate information about the Carrier
```
SELECT carrier_name, 
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
FROM 'loadsmart-354023.bd_loadsmart.table_test' 
where carrier_name is not null
group by carrier_name;
```

#### It's a query about the rank of Carrier for each Lane that will help the Shippers choose which Carrier is faster
```
with query as (
SELECT equipment_type, carrier_name, lane, avg(TIMESTAMP_DIFF(delivery_date, pickup_date, hour)) as avg_diff_hour
FROM 'loadsmart-354023.bd_loadsmart.table_test'
where carrier_name is not null
group by equipment_type, carrier_name, lane
)

select query.lane, DENSE_RANK() OVER (PARTITION BY query.lane ORDER BY query.avg_diff_hour asc ) AS rank, query.carrier_name, query.avg_diff_hour
from query
inner join (select lane, count(lane) as amount from query group by 1 having count(lane) > 1) lanes on lanes.lane = query.lane 
order by 2 asc, 3
```


## Instructions DBT

In DBT, for each query, I create a model for them. 
I think the good idea is to have one model for each context to keep the context and codes organized.

#### base
```
{{config(
    materialized='table'
)}}

SELECT quote_date, equipment_type, carrier_name, pickup_date, pickup_appointment_time, delivery_date, 
delivery_appointment_time, mileage, book_price, TIMESTAMP_DIFF(delivery_date, pickup_date, hour) as diff_hour
FROM 'loadsmart-354023.bd_loadsmart.table_test'
```

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
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour
FROM 'loadsmart-354023.bd_loadsmart.table_test' 
group by equipment_type
```

#### agg_carrier
```
{{config(
    materialized='table'
)}}

SELECT carrier_name, 
count(distinct loadsmart_id) as amount_trip,
AVG(mileage) AS avg_miles, 
max(mileage) as max_miles,
sum(mileage) AS sum_miles, 
sum(book_price) as sum_price, 
avg(book_price) as avg_price, 
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour,
sum(TIMESTAMP_DIFF(delivery_date, pickup_date, hour)) as sum_diff_hour,
sum(case when carrier_on_time_overall is true then 1 else 0 end) as ontime,
sum(case when carrier_on_time_overall is false then 1 else 0 end) as not_ontime
FROM 'loadsmart-354023.bd_loadsmart.table_test' 
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
FROM 'loadsmart-354023.bd_loadsmart.table_test'
where carrier_name is not null
group by equipment_type, carrier_name, lane
)

select query.lane, DENSE_RANK() OVER (PARTITION BY query.lane ORDER BY query.avg_diff_hour asc ) AS rank, query.carrier_name, query.avg_diff_hour
from query
inner join (select lane, count(lane) as amount from query group by 1 having count(lane) > 1) lanes on lanes.lane = query.lane 
order by 2 asc, 3
```


#### After creating all my models, I have to run and compile them
<img src="https://user-images.githubusercontent.com/39974597/175447259-68c94d1c-d8fa-4614-8232-3d0346a24506.png" width="600">

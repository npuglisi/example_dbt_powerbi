

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
FROM `loadsmart-354023.bd_loadsmart.table_test` 
where carrier_name is not null
group by carrier_name
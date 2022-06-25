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
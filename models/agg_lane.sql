{{config(
    materialized='table'
)}}

SELECT equipment_type, carrier_name, lane, avg(mileage) as avg_mile, avg(book_price) as avg_price, sum(book_price) as sum_price
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by equipment_type, carrier_name, lane
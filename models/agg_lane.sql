{{config(
    materialized='table'
)}}

SELECT lane, count(distinct carrier_name) as amount_carrier, avg(mileage) as avg_mile, avg(book_price) as avg_price, sum(book_price) as sum_price
FROM loadsmart-354023.bd_loadsmart.table_test
where carrier_name is not null
group by lane
{{config(
    materialized='table'
)}}

SELECT quote_date, equipment_type, carrier_name, pickup_date, pickup_appointment_time, delivery_date, delivery_appointment_time, mileage, book_price, TIMESTAMP_DIFF(delivery_date, pickup_date, hour) as diff_hour
FROM 'loadsmart-354023.bd_loadsmart.table_test'
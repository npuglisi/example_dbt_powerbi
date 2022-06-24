

  create or replace table `loadsmart-354023`.`dbt_loadsmart`.`agg_equipment`
  
  
  OPTIONS()
  as (
    

SELECT equipment_type, 
AVG(mileage) AS avg_miles, 
max(mileage) as max_miles,
count(distinct loadsmart_id) as amount_ship,
avg(book_price) as avg_price, 
avg(TIMESTAMP_DIFF(pickup_date, delivery_date, hour)) as avg_diff_hour
FROM `loadsmart-354023.bd_loadsmart.table_test` 
group by equipment_type
  );
  
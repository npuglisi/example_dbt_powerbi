

  create or replace view `loadsmart-354023`.`dbt_loadsmart`.`my_second_dbt_model`
  OPTIONS()
  as -- Use the `ref` function to select from other models

select *
from `loadsmart-354023`.`dbt_loadsmart`.`my_first_dbt_model`
where id = 1;


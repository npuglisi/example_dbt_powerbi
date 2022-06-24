

with query as (
SELECT equipment_type, carrier_name, lane, avg(TIMESTAMP_DIFF(delivery_date, pickup_date, hour)) as avg_diff_hour
FROM `loadsmart-354023.bd_loadsmart.table_test`
where carrier_name is not null
group by equipment_type, carrier_name, lane
)

select query.lane, DENSE_RANK() OVER (PARTITION BY query.lane ORDER BY query.avg_diff_hour asc ) AS rank, query.carrier_name, query.avg_diff_hour
from query
inner join (select lane, count(lane) as amount from query group by 1 having count(lane) > 1) lanes on lanes.lane = query.lane 
order by 2 asc, 3
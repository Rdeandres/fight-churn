with 
date_range as (    
	select  'FRYR-MM-DD'::TIMESTAMP as start_date,    
		'TOYR-MM-DD'::TIMESTAMP as end_date,    
		interval 'MAX_INACTIVE' as max_inactive
), 
start_accounts as     
(
	select distinct account_id
	from event e inner join date_range d on
		e.event_time + max_inactive > start_date    
),
start_count as (    
	select 	count(start_accounts.*) as n_start from start_accounts
), 
end_accounts as    
(
	select distinct account_id
	from event e inner join date_range d on
		e.event_time + max_inactive > end_date    
), 
end_count as (    
	select 	count(end_accounts.*) as n_end from end_accounts
), 
churned_accounts as 
(
	select distinct s.account_id
	from start_accounts s 
	left outer join end_accounts e on 
		s.account_id=e.account_id
	where e.account_id is null
),
churn_count as (
	select 	count(churned_accounts.*) as n_churn from churned_accounts
)
select 
	n_churn::float/n_start::float as churn_rate, 
	1.0-n_churn::float/n_start::float as retention_rate, 
	n_start, 
	N_churn 
from start_count, end_count, churn_count

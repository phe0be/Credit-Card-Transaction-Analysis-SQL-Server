
--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

select  top 5 city, round((sum(amount)/(select sum(amount) from cct)),2) as per_contri
from cct
group by city
order by per_contri desc

--2- write a query to print highest spend month and amount spent in that month for each card type

select card_type, Month, Year, total from 
(select card_type, datename(Year, transaction_date) as [Year], datename(Month, transaction_date) as [Month], sum(amount) as total,
ROW_NUMBER() over(partition by card_type order by sum(amount) desc) as row_num
from cct
group by card_type, datename(Year, transaction_date),  datename(Month, transaction_date))t
where row_num =1

--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

with cte as (
select *,sum(amount) over(partition by card_type order by transaction_date,transaction_id) as total_spend
from cct)
select * from (select *, rank() over(partition by card_type order by total_spend) as rn  
from cte where total_spend >= 1000000) a where rn=1

--4 write a query to find city which had lowest percentage spend for gold card type
select top 1 city, round((sum(amount)/(select sum(amount) from cct)),2) as per_contri
from cct
where card_type = 'Gold'
group by city
having round((sum(amount)/(select sum(amount) from cct)),2) !=0
order by per_contri 

-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

select *
from 
(select  city,
FIRST_VALUE(exp_type) over (partition by city order by sum(amount) desc) as highest_expense_type,
FIRST_VALUE(exp_type) over (partition by city order by sum(amount) asc) as lowest_expense_type
from cct
group by city, exp_type)t
group by city, highest_expense_type, lowest_expense_type

--6- write a query to find percentage contribution of spends by females for each expense type

select exp_type,
round(sum(case when gender='F' then amount else 0 end)*1.0/sum(amount),2) as per_contri
from cct
group by exp_type
order by per_contri desc

--7- which card and expense type combination saw highest month over month growth in Jan-2014

select  top 1 *, (total-prev_mont_spend) as mom_growth
from
(select card_type, exp_type, datepart(year,transaction_date) as [year], datepart(month,transaction_date) as [Month], sum(amount) as total,
lag(sum(amount),1) over(partition by card_type,exp_type order by datepart(year,transaction_date), datepart(month,transaction_date)) as prev_mont_spend
from cct
group by card_type, exp_type,transaction_date, datepart(year,transaction_date), datename(Month, transaction_date), amount)t 
where prev_mont_spend is not null and year=2014 and Month=1

order by mom_growth desc;

--8- during weekends which city has highest total spend to total no of transcations ratio 
select top 1 city , sum(amount)*1.0/count(*) as ratio
from cct
where datepart(weekday,transaction_date) in (1,7)
group by city
order by ratio desc;


--9- which city took least number of days to reach its 500th transaction after the first transaction in that city;

with cte as (
select *
,row_number() over(partition by city order by transaction_date,transaction_id) as rn
from cct)
select top 1 city,datediff(day,min(transaction_date),max(transaction_date)) as datediff1
from cte
where rn=1 or rn=500
group by city
having count(*)=2
order by datediff1 










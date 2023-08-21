CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
delete from activity;
insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');


--select * from activity


--Q1 (find the total active users (installed or purchased) each day)
select event_date, count(distinct user_id) as total_active_users
from activity
group by event_date

--Q2 (find the total active users for each week)
select week_numbers, count(distinct user_id) as total_active_users
from (
select *, datepart(week, event_date) as week_numbers
from activity) A
group by week_numbers

--Q3 (for each date, find the total number of users who made the purchase same day they installed the app)
with cte1 as (
select a1.event_date as date_1, a2.event_date as date_2
from activity a1
inner join activity a2 on a1.user_id = a2.user_id and a1.event_name < a2.event_name)
, cte2 as (
select date_1 as date, count(*) as cnt
from cte1
where date_1 = date_2
group by date_1)

select event_date, max(case when cnt is null then 0 else cnt end) as no_of_users
from activity a
left join cte2 c on a.event_date = c.date
group by event_date

--Q4 (percentage of paid users in india, usa and others (other are the other countries other than india and usa))
with cte as (
select *, 
case when country in ('India', 'USA') then country else 'others' end as with_others
from activity
where (event_name = 'app-purchase'))
, cte2 as (
select *, 
count(*) over(partition by with_others) * 1.0 / (count(*) over()) * 100 as perc
from cte)

select with_others, perc
from cte2
group by with_others, perc

--Q5 (among all users who installed the app on a given day, how many purchased an app on the very next day)
select * from activity

with cte as (
select a2.event_date, 
case when (datepart(day, a2.event_date) - datepart(day, a1.event_date)) = 1 then 1 else 0 end as next_day
from activity a1
inner join activity a2 on a1.user_id = a2.user_id and a1.event_name = 'app-installed' and a2.event_name = 'app-purchase')

select a.event_date, 
max(case when next_day is null then 0 else next_day end) as cnt_users
from activity a
left join cte c on a.event_date = c.event_date
group by a.event_date
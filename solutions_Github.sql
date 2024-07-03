
/* 1. You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries 
who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD */

select distinct company_location as remote from salaries
where remote_ratio = 100 
and salary_in_usd > 90000
and job_title like '%Manager%';

/* 2.	AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ 
clients IN large tech firms. you're tasked WITH Identifying top 5 Country Having greatest count of 
large (company size) number of companies. */

select company_location, count(company_size) as 'cnt' from salaries 
where experience_level = 'EN'
and company_size = 'L'
group by company_location
order by cnt desc
limit 5;

/* 3.	Picture yourself AS a data scientist Working for a workforce management platform. 
Your objective is to calculate the percentage of employees. Who enjoy fully remote roles 
WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying 
remote positions IN today's job market. */

set @all_ = (select count(*) from salaries
where salary_in_usd > 100000);

set @remote_100 = (select count(*) from salaries 
where remote_ratio = 100
and salary_in_usd > 100000 );

set @perc = (round((select @remote_100/@all_) * 100,2));
select @perc as total_percentage;

/* 4.	Imagine you're a data analyst Working for a global recruitment agency. Your Task 
is to identify the Locations where entry-level average salaries exceed the average salary 
for that job title IN market for entry level, helping your agency guide candidates towards 
lucrative opportunities. */

select company_location, b.job_title, EL_avg, avg_sal from
(
select job_title, avg(salary_in_usd) as EL_avg from salaries
where experience_level = 'EN'
group by job_title ) as t
inner join
(select company_location, job_title, avg(salary_in_usd) as avg_sal from salaries
group by company_location, job_title ) as b 
on t.job_title = b.job_title
where EL_avg < avg_sal;

/* 5.	You've been hired by a big HR Consultancy to look at how much people get paid 
IN different Countries. Your job is to Find out for each job title which. Country pays 
the maximum average salary. This helps you to place your candidates IN those countries. */

select * from 
(
select *, dense_rank() over(partition by job_title order by salary desc) as rank_ from
(
select job_title, company_location , avg(salary_in_usd) as salary from salaries
group by job_title, company_location
)t
)b
where rank_ = 1;

/* 6.	AS a data-driven Business consultant, you've been hired by a multinational corporation 
to analyze salary trends across different company Locations. Your goal is to Pinpoint Locations 
WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data 
is available for 3 years Only(present year and past two years) providing Insights into Locations 
experiencing Sustained salary growth. */

with table1 as 
(
	select * from salaries where company_location in
	(select company_location from
	(
	select * from
	(
	select *, dense_rank() over(partition by company_location order by work_year) as cnt_work from
	(
	select company_location, work_year, avg(salary_in_usd) as average_salary from salaries
	where work_year > year(current_date()) - 3
	group by company_location, work_year
	)t
	)b
	where cnt_work = 3)a
	)
)

select * from 
(
select company_location, 
max(case when work_year = 2022 then sal_avg end) as year_2022,
max(case when work_year = 2023 then sal_avg end) as year_2023,
max(case when work_year = 2024 then sal_avg end) as year_2024
from
(select company_location, work_year, avg(salary_in_usd) sal_avg 
from salaries
group by company_location, work_year
)r
group by company_location
)c
where year_2022 < year_2023
and year_2023 < year_2024;

/*Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission 
is to Determine the percentage of fully remote work for each experience level IN 2021 and compare 
it WITH the corresponding figures for 2024, Highlighting any significant Increases or decreases IN 
remote work Adoption over the years. */

select g.experience_level, count_2021, total_2021, per_remote_2021, count_2024, total_2024, per_remote_2024 from 
(
select *, round((count_2021/total_2021) * 100,2) as per_remote_2021 from
(select t.experience_level, count_2021, total_2021 from
(select experience_level, count(remote_ratio) as count_2021
from salaries
where work_year = 2021
and remote_ratio = 100
group by experience_level)t
inner join
(select experience_level, count(remote_ratio) as total_2021
from salaries
where work_year = 2021
group by experience_level)b
on t.experience_level = b.experience_level
)c
)g
inner join
(
select *, round((count_2024/total_2024) * 100,2) as per_remote_2024 from
(select d.experience_level, count_2024, total_2024 from
(select experience_level, count(remote_ratio) as count_2024
from salaries
where work_year = 2024
and remote_ratio = 100
group by experience_level)d
inner join
(select experience_level, count(remote_ratio) as total_2024
from salaries
where work_year = 2024
group by experience_level)e
on d.experience_level = e.experience_level
)f
)h
on g.experience_level = h.experience_level;

/* 8.AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary 
trends over time. Your objective is to calculate the average salary increase percentage for each 
experience level and job title between the years 2023 and 2024, helping the company stay competitive 
IN the talent market.*/

select *, round(((avg_sal_2024 - avg_sal_2023)/avg_sal_2023 * 100),2) as total_change_in_percentage from
(
select t.experience_level, t.job_title, avg_sal_2023, avg_sal_2024 from
(
select experience_level, job_title, round(avg(salary_in_usd),2) as avg_sal_2023
from salaries
where work_year = 2023
group by experience_level, job_title
)t
inner join
(
select experience_level, job_title, round(avg(salary_in_usd),2) as avg_sal_2024
from salaries
where work_year = 2024
group by experience_level, job_title
)b
on t.experience_level = b.experience_level
and t.job_title = b.job_title
)c

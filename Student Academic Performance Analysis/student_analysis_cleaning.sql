select * from bi;

## audit the table
##1. count total row
select count(*) total_row from bi;


##2. count total column
select count(*) as total_column from 
information_schema.columns
where table_schema  = 'education_analysis'
and table_name = 'bi';

##3. check for columns data types
select 
	column_name,
    data_type
from information_schema.columns
where table_schema  = 'education_analysis'
and table_name = 'bi';

## clean data

select trim(fName), trim(lName) from bi;

select distinct gender from bi;

update bi
set gender = 'Male'
where gender = 'M';

update bi
set gender = 'Female'
where gender = 'F';

select distinct country from bi;

update bi
set country = 'Norway'
where country = 'Norge';

update bi
set country = 'South Africa'
where country = 'Rsa';

update bi
set country = 'United Kingdom'
where country = 'UK';

select distinct residence from bi;

update bi
set residence  = 'BI Residence'
where residence = 'BI-Residence' or residence = 'BIResidence' or residence = 'BI_Residence';

select distinct prevEducation from bi;

update bi
set prevEducation = 'High School'
where prevEducation = 'HighSchool';

update bi
set prevEducation = 'Bachelors'
where prevEducation = 'Barrrchelors';

update bi
set prevEducation = 'Diploma'
where prevEducation = 'Diplomaaa';

## update missing value of python column using mean since only two row is missing
select * from bi
where Python = '';

select Python from bi;

with mean as (select format(avg(Python), 2) as average from bi
where Python != '')

update bi
set Python = (select average from mean)
where Python = '';

select * from bi
where DB = '';


##check for duplicate
select fNAME, count(*) as duplicate_id from bi
group by fNAME, lNAME, Age, gender
having duplicate_id > 1;

## no duplicate found


## add possible column to be use in visualization

## add table id
alter table bi
add column id int auto_increment primary key;

## add category for python, DB and age
alter table bi
add column Python_performance varchar(50);

alter table bi
add column DB_performance  varchar(50);

with performance as (select python, id,
case
	true
    when Python <= 75 then 'low'
    when Python <= 84 then 'average'
    when Python >=85 then 'high'
    else 'N/A'
end as Python_performance
from bi)

update bi b
inner join  performance p
	on b.id = p.id
set b.Python_performance = p.Python_performance;

with performance as (select DB, id,
case
	true
    when DB <= 75 then 'low'
    when DB <= 84 then 'average'
    when DB >=85 then 'high'
    else 'N/A'
end as DB_performance
from bi)

update bi b
inner join  performance p
	on b.id = p.id
set b.DB_performance = p.DB_performance;

alter table bi
add column age_category varchar(50);

with category as (select age, id,
case 
	true
    when age <= 24 then 'Young Adult'
    when age <= 39 then 'Adult'
    when age <= 59 then 'Middle Aged'
    when age >= 60 then 'Senior'
    else 'N/A'
end as age_category
from bi)

update bi b
inner join category c
	on b.id = c.id
set b.age_category = c.age_category;



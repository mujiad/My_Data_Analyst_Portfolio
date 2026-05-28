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

alter table bi
add column id int auto_increment primary key;





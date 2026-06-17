select * from marketing_campaign_data_messy;

## creating new table for staging
CREATE TABLE marketing_campaign AS
SELECT * FROM marketing_campaign_data_messy;

select * from marketing_campaign;

## data exploration
select count(*) from marketing_campaign;
## total row is 1820

select count(*) as total_column from 
information_schema.columns
where table_schema  = 'campain'
and table_name = 'marketing_campaign';

select 
	column_name,
    data_type
from information_schema.columns
where table_schema  = 'campain'
and table_name = 'marketing_campaign';

select * from marketing_campaign
where Campaign_ID is null;

select Campaign_ID, count(Campaign_ID) as ref from marketing_campaign
group by Campaign_ID
having ref > 1;

select * from marketing_campaign
where Campaign_ID = 'CMP-01118';

## Campain_Name

select * from marketing_campaign
where Campaign_Name is null;

## Start_date

select * from marketing_campaign
where Start_Date is null;

select distinct Start_Date from marketing_campaign;

select Start_Date from marketing_campaign
where Start_Date not like '%00:00:00' and Start_Date not like '%-%-%' and Start_Date not like '%/%/%';

select 
	sum(Start_Date like '%/%/%') as slash,
    sum(Start_Date like '%-%-%') as dash,
    sum(Start_Date not like '%-%-%' and Start_Date not like '%/%/%') as unknown
from marketing_campaign;

## dash, slash and this format '2023-11-24 00:00:00' are the only Start_Date format

with date_ref as (select Start_Date, 
case
	when Start_Date like '%-%-%' then date(Start_Date)
    when Start_Date like '%/%/%' then str_to_date(Start_Date, '%d/%m/%Y')
    else null
    end as Start_Date_cleaned
from marketing_campaign)

select Start_Date_cleaned from date_ref
where Start_Date_cleaned is null;

## update start date

alter table marketing_campaign
drop column Start_Date_cleaned;

update marketing_campaign
set Start_Date = case
	when Start_Date like '%-%-%' then date(Start_Date)
    when Start_Date like '%/%/%' then str_to_date(Start_Date, '%d/%m/%Y')
    else null
    end;

## checking 
select Start_Date, Start_Date_cleaned from marketing_campaign;

## cleaned start date match the original start date

## checkng end date

select End_Date from marketing_campaign
where End_Date is null;

## no null value found
## check for date formating

select 
	sum(End_Date like '%/%/%') as slash,
    sum(End_Date like '%-%-%') as dash,
    sum(End_Date not like '%-%-%' and End_Date not like '%/%/%') as unknown
from marketing_campaign;

## dash only format

select End_Date from marketing_campaign;

## check for if there are two types of date format (Y/m/d) or (d/m/Y)

with date_ref as (select Campaign_ID, End_Date, 
case
	when End_Date like '%-%-%' then str_to_date(End_Date, '%Y-%m-%d' )
    else null
    end as End_Date_cleaned
from marketing_campaign)

select End_Date_cleaned from date_ref
where End_Date_cleaned is null ;

## no null value only (Y/m/d) format exist
## no cleaning needed
##change data types to date and create new column

## check channel column

select distinct Channel from marketing_campaign;

update marketing_campaign 
set  Channel = 'TikTok'
where Channel = 'Tik_Tok';

update marketing_campaign 
set  Channel = 'Facebook'
where Channel = 'Facebok';

update marketing_campaign 
set  Channel = 'Email'
where Channel = 'E-mail';

update marketing_campaign 
set  Channel = 'Instagram'
where Channel = 'Insta_gram';

update marketing_campaign 
set  Channel = 'Google Ads'
where Channel = 'Gogle';

select * from marketing_campaign
where Channel = 'N/A' ;

select count(Channel) from marketing_campaign
where Channel = 'N/A' ;


## impresion 

select * from  marketing_campaign
where Impressions is null;

## no null values


## spend
select distinct(Spend) from marketing_campaign;

select * from marketing_campaign
where spend is null or spend = '' or spend = 'N/A';

## no null, empty or N/A value

select Spend from marketing_campaign
where Spend like '%$%'; 

select Spend, regexp_replace(Spend, '[^0-9.]', '') as cleaned from marketing_campaign;

## remove dollar sign

update marketing_campaign
set Spend = regexp_replace(Spend, '[^0-9.]', '');

select Spend, Spend_cleaned from marketing_campaign;

select Spend_cleaned from marketing_campaign
where Spend_cleaned is null or Spend_cleaned = '';

## conversion 

select distinct(Conversions) from marketing_campaign;

select * from marketing_campaign
where Conversions is null;

## Active

select distinct(Active) from marketing_campaign;

update marketing_campaign
set Active = 'Yes'
where Active = 'True' or Active = '1' or Active = 'Y';

update marketing_campaign
set Active = 'No'
where Active = 'False' or Active = '0';	 

##clicked_0

select distinct `Clicks_[0]` from marketing_campaign;

select * from marketing_campaign
where `Clicks_[0]` is null or `Clicks_[0]` = '';

select count(`Clicks_[0]`) from marketing_campaign
where `Clicks_[0]` is null or `Clicks_[0]` = '';

## 1783 row missing so almost 98% of the rows is missing and i cant find any pattern to fill in the missing rows 
## so its better to drop it

alter table marketing_campaign
drop column `Clicks_[0]`;

## Campaign tag
select distinct Campaign_Tag from marketing_campaign;

## TI(Tiktok), FA(Facebook), EM(email), IN(unsatagram) GO(google ad)
## some with channels but listed as invalid or xxx in campaign tag

update marketing_campaign
set Campaign_Tag = 'TI'
where Channel = 'TikTok';

update marketing_campaign
set Campaign_Tag = 'FA'
where Channel = 'Facebook';

update marketing_campaign
set Campaign_Tag = 'EM'
where Channel = 'Email';

update marketing_campaign
set Campaign_Tag = 'IN'
where Channel = 'Instagram';

update marketing_campaign
set Campaign_Tag = 'GO'
where Channel = 'Google Ads';

select sum((Campaign_Tag = 'XX' or Campaign_Tag = 'INVALID') and Channel = 'N/A') as undefined_val from marketing_campaign;

## 93 rows with N/A chanel and XX or invalid capaign tag
## these consitute to 5% of the total rows and cannot contribute much to final analysis 
## drop these row

select * from marketing_campaign
where Campaign_Tag = 'XX' or Campaign_Tag = 'INVALID';

delete from marketing_campaign
where (Campaign_Tag = 'XX' or Campaign_Tag = 'INVALID') and Channel = 'N/A';

## check Campaign_Tag and Channel
select * from marketing_campaign
where Channel = 'N/A' ;

## Campaign_Tag and Channel with xxx, invalid and N/A value deleted 

select count(*) from marketing_campaign;
## remaining row 1727

with total_duplicate as (select count(*) as duplicate_number from marketing_campaign
group by Campaign_ID, Campaign_Name, Start_Date, End_Date, Channel
having duplicate_number > 1)

select count(duplicate_number) from total_duplicate;

## there are 19 duplicate

create table Marketing_Campain_Final
as select distinct * from marketing_campaign;

select count(*)  from marketing_campain_final;




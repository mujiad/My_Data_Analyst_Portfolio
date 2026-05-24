select * from messy_clinic_appointments;

# check for duplicate
with duplicate as (select *, row_number() over( partition by patient_id, patient_name, age, gender, appointment_date, booking_date, doctor, department, billing_amount, follow_up_required) 
as ref_num from messy_clinic_appointments)

select * from duplicate 
where ref_num >1;
# no duplicate

# duplicate table for safe data cleaning

CREATE TABLE `appointments_cleaning` (
  `patient_id` int DEFAULT NULL,
  `patient_name` text,
  `age` int DEFAULT NULL,
  `gender` text,
  `appointment_date` text,
  `booking_date` text,
  `doctor` text,
  `department` text,
  `billing_amount` text,
  `follow_up_required` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# insert * row from original table
insert into appointments_cleaning
select * from messy_clinic_appointments;

select * from appointments_cleaning;

# look for inconsisticy in the columns value then update
select distinct gender from appointments_cleaning;

#gender

select distinct gender from appointments_cleaning;

select *, gender from appointments_cleaning
where gender = '0' or gender = '' or gender = '1' or gender = '';

update appointments_cleaning
set gender = 'F'
where gender = 'female';

update appointments_cleaning
set gender = 'M'
where gender = 'male';

select * from appointments_cleaning
where gender = 'N/A';

select patient_name, count(*) as ID
from appointments_cleaning
group by patient_name
having ID > 1;

select gender, age, patient_name from appointments_cleaning
where patient_name like 'Kyle Jones%';

# when checking the previous value of 1, 0 and empty value there is no pattern i can follow to know the gender of the patient
# i want to update gender manually since there are no othe columns i can use to base the gender exept the name.
# however when i check the name column with its gender, similar name like Christopher or Benjamin which sound like a Male have gender that are female
# so i conclude that patient_name is not relaibale to base the gender of the patient.
# final decision is to set empty, 1 and 0 value of gender to N/A


update appointments_cleaning
set gender = 'N/A'
where gender = '0' or gender = '' or gender = '1' or gender = '';

# appointment date
SELECT 
  patient_id,
  appointment_date,
  CASE
    -- format: 2026/03/07
    WHEN appointment_date LIKE '____/%/%' THEN STR_TO_DATE(appointment_date, '%Y/%m/%d')
    WHEN appointment_date LIKE '__/__/____'  THEN STR_TO_DATE(appointment_date, '%m/%d/%Y')

    -- format: September 26, 25
    WHEN appointment_date LIKE '%,%' THEN STR_TO_DATE(appointment_date, '%M %d, %y')
    
    when appointment_date Like '%-%-%' THEN STR_TO_DATE(appointment_date, '%d-%b-%Y')

  END AS cleaned_date
FROM appointments_cleaning;

# next is to update appointment date using patient_id
select patient_id, count(patient_id) as ref_num from appointments_cleaning
group by patient_id
having ref_num >1;

# patient id have many duplicate (patient can have many appointment)

select patient_id, patient_name from appointments_cleaning
where patient_id = 1080;

# patient id unreliable (same patient id have different patient names)
# update patient_id with new unique values

select patient_name, count(patient_name) as ref_num from appointments_cleaning
group by patient_name
having ref_num >1;

select * from appointments_cleaning
where patient_name = 'Tiffany Burke';

# similar patient name have different age and gender
# similar name doesnt mean similar patient

select * from appointments_cleaning
where patient_id = 1006;

# use patient_name, age and gender for generating unique id

select patient_name, count(*) over(partition by patient_name, age, gender) as ID
from appointments_cleaning;

# check for duplicate
select	patient_name, age, gender, count(*) as ref_num from appointments_cleaning
group by patient_name, age, gender
having ref_num>1;

select * from appointments_cleaning;

alter table appointments_cleaning
add column ID_clean INT;


with unique_id as (select patient_name, age, gender, dense_rank() over(order by patient_name, age, gender) as ID_clean
from appointments_cleaning)

update appointments_cleaning ac
join unique_id ud
 on ac.patient_name = ud.patient_name
 and ac.age =  ud.age
 and ac.gender = ud.gender
set ac.ID_clean = ud.ID_clean ;

# clean appointmet date

alter table appointments_cleaning
 add column appointment_date_cleaned DATE;

with update_date as (
SELECT 
  ID_clean,
  appointment_date,
  CASE
	WHEN appointment_date LIKE '____/%/%' THEN STR_TO_DATE(appointment_date, '%Y/%m/%d')
    WHEN appointment_date LIKE '__/__/____'  THEN STR_TO_DATE(appointment_date, '%m/%d/%Y')
    WHEN appointment_date LIKE '%,%' THEN STR_TO_DATE(appointment_date, '%M %d, %y')
    when appointment_date Like '%-%-%' THEN STR_TO_DATE(appointment_date, '%d-%b-%Y')
    else null
  END AS cleaned_date
FROM appointments_cleaning)

update appointments_cleaning ac
join update_date ud
 on ac.ID_clean = ud.ID_clean
set ac.appointment_date_cleaned = ud.cleaned_date;

alter table appointments_cleaning
add column booking_date_cleaned date;


with cleaned_booking as (
SELECT 
ID_clean,
  booking_date,
  CASE

    WHEN booking_date LIKE '____/%/%' THEN STR_TO_DATE(booking_date, '%Y/%m/%d')
    WHEN booking_date LIKE '__/__/____'  THEN STR_TO_DATE(booking_date, '%m/%d/%Y')
    WHEN booking_date LIKE '%,%' THEN STR_TO_DATE(booking_date, '%M %d, %y')
    when booking_date Like '%-%-%' THEN STR_TO_DATE(booking_date, '%d-%b-%Y')
    else null
  END AS cleaned_date
FROM appointments_cleaning)

update appointments_cleaning ac
join cleaned_booking cb
 on ac.ID_clean = cb.ID_clean
set ac.booking_date_cleaned = cb.cleaned_date;

select * from appointments_cleaning;

select distinct follow_up_required from appointments_cleaning;

update appointments_cleaning
set  follow_up_required = 'No'
where follow_up_required = '0' or follow_up_required = 'N';

update appointments_cleaning
set  follow_up_required = 'Yes'
where follow_up_required = '1' or follow_up_required = 'Y';

alter table appointments_cleaning
 add column billing_amount_cleaned decimal(10,2);

alter table appointments_cleaning
 add column currency varchar(3);

with bill_cleaning as (SELECT
  billing_amount,
  ID_clean,

  CASE
    WHEN billing_amount REGEXP '£|Â£' THEN 'GBP'
    WHEN billing_amount REGEXP '€|â‚¬' THEN 'EUR'
    WHEN billing_amount REGEXP '\\$' THEN 'USD'
    WHEN billing_amount REGEXP 'Rs' THEN 'INR'
    ELSE 'N/A'
  END AS currency,

cast(regexp_replace(billing_amount, '[^0-9.]', '') as decimal(10,2)) as cleaned_bill
FROM appointments_cleaning)

update appointments_cleaning ac
join bill_cleaning bc
	on ac.ID_clean = bc.ID_clean
set ac.currency = bc.currency,
	ac.billing_amount_cleaned = bc.cleaned_bill;

select billing_amount, billing_amount_cleaned, currency  from appointments_cleaning;

select * from appointments_cleaning;

alter table appointments_cleaning
add column billing_in_USD decimal(10, 2);

with convert_bill as (select billing_amount_cleaned, currency, ID_clean,
round(case
	when currency = 'GBP' then  (billing_amount_cleaned * 1.25)
    when currency = 'EUR' then  (billing_amount_cleaned * 1.08)
    when currency = 'USD' then  billing_amount_cleaned 
    when currency = 'INR' then  (billing_amount_cleaned * 0.012)
    else null
    
end, 2) as billing_in_USD
from appointments_cleaning)

update appointments_cleaning ac
join convert_bill cb
	on ac.ID_clean = cb.ID_clean
set ac.billing_in_USD = cb.billing_in_USD;


create or replace view clinic_appointments as
select 
ID_clean as patient_id,
patient_name,
age,
gender,
appointment_date_cleaned as appointment_date,
booking_date_cleaned as booking_date,
doctor,
department,
billing_amount_cleaned as billing_amount,
currency,
billing_in_USD,
follow_up_required
from appointments_cleaning;

select * from clinic_appointments;



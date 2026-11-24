CREATE DATABASE noshowguard; 
USE noshowguard;
-- ------------------------------------------- ------------------------------------------- -------------------------------------------

--Task 2.1 — Build and load the database

CREATE TABLE clinics(
clinic_id VARCHAR(5) PRIMARY KEY,
clinic_name VARCHAR(40) NOT NULL,
city VARCHAR(20) NOT NULL,
tier VARCHAR(10),
latitude DECIMAL(8,4),
longitude DECIMAL (8,4),
temp_c DECIMAL(5,1));

CREATE TABLE appointments(
appointment_id VARCHAR(8) PRIMARY KEY,
patient_id VARCHAR(8) NOT NULL,
clinic_id VARCHAR(5) NOT NULL,
booked_on DATE,
appt_date DATE,
age INT, 
gender VARCHAR(1),
distance_km DECIMAL(5,1),
fee_inr INT,
booking_channel VARCHAR(10),
visit_type VARCHAR(12),
reminder_sent VARCHAR(3), 
prior_no_shows INT,
status VARCHAR(10), 
lead_days INT, 
no_show INT,
FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id));

--check count and sum:
SELECT 
	(SELECT count(*) FROM clinics) AS total_clinics,
	count(*) AS total_appointments,
	SUM(no_show) AS total_no_show
FROM appointments;

--Identify duplicate entry :
INSERT INTO appointments (appointment_id, patient_id, clinic_id) 
VALUES ('A0001', 'P999', 'C01');

--========================================================
-- Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '--Identify duplicate entry :
-- INSERT INTO appointments (appointment_id, patient_i' at line 1	0.000 sec
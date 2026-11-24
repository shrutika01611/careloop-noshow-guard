-- ============================================================
-- Task 2.1 / Duplicate-Key Error Test (Commented Error Text)
-- ============================================================
 INSERT INTO appointments (appointment_id, patient_id, clinic_id) 
 VALUES ('A0001', 'P999', 'C01')

	
Error Code: 1064. You have an error in your SQL syntax; check the manual 
that corresponds to your MySQL server version for the right syntax to use 
near '--Identify duplicate entry :
 INSERT INTO appointments (appointment_id, patient_i' at line 1	0.000 sec

-- ============================================================
-- Task 2.2: Clinic-wise total appointments, no-shows & no-show rate
-- ============================================================
--with HAVING clause
SELECT 
c.clinic_name,
c.city,
COUNT(a.appointment_id) AS appointments,
sum(a.no_show) AS no_shows,
ROUND(100.0 * SUM(a.no_show)/COUNT(a.appointment_id), 1) AS no_show_pct
FROM clinics c
JOIN appointments a ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
Having COUNT(a.appointment_id) >= 95
ORDER BY no_show_pct DESC;

--without HAVING clause
SELECT 
c.clinic_name,
c.city,
COUNT(a.appointment_id) AS appointments,
sum(a.no_show) AS no_shows,
ROUND(100.0 * SUM(a.no_show)/COUNT(a.appointment_id), 1) AS no_show_pct
FROM clinics c
JOIN appointments a ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
ORDER BY no_show_pct DESC;
-- ============================================================
-- Task 2.3: Lead-time / reminder / slot-wise breakdown query
-- ============================================================
SELECT
CASE 
	WHEN lead_days BETWEEN 1 AND 7 THEN '1-7'
	WHEN lead_days BETWEEN 8 AND 14 THEN '8-14'
	WHEN lead_days BETWEEN 15 AND 30 THEN '15-30'
	ELSE '+31'
END AS lead_band,
COUNT(*) AS appointments,
SUM(no_show) AS no_shows,
ROUND(100.0 * SUM(no_show)/ COUNT(*),1) AS no_show
FROM appointments
GROUP BY lead_band
ORDER BY MIN(lead_days);
 
-- ============================================================
-- Task 2.4: Patient history / high-risk segment query
-- ============================================================

WITH monthly AS (
    SELECT 
        SUBSTR(appt_date, 1, 7) AS month,
        COUNT(*) AS appointments,
        ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
    FROM appointments
    GROUP BY month
)
SELECT 
    month,
    appointments,
    no_show_pct,
    ROUND(no_show_pct - LAG(no_show_pct, 1) OVER (ORDER BY month), 1) AS pct_point_change
FROM monthly;
-- ============================================================
-- Task 2.5: Weather / temperature impact or advanced SQL query
-- ============================================================

WITH clinic_rates AS (
	SELECT
		c.clinic_name AS clinic,
        c.city,
        ROUND(100.0 * SUM(a.no_show) / COUNT(a.appointment_id), 1) AS no_show_pct
    FROM clinics c
    JOIN appointments a ON c.clinic_id = a.clinic_id
    GROUP BY c.clinic_id, c.clinic_name, c.city
)    
     SELECT
		clinic,
		city,
		no_show_pct,
        RANK() OVER(PARTITION BY city ORDER BY no_show_pct DESC) AS rank_in_city,
        (SELECT ROUND(100.0 * SUM(no_show) / COUNT(*), 2) FROM appointments) AS overall_rate,
        CASE
			WHEN no_show_pct > (SELECT ROUND(100.0* SUM(no_show) / COUNT(*),2) FROM appointments) THEN 'above'
            WHEN no_show_pct < (SELECT ROUND(100.0* SUM(no_show) / COUNT(*),2) FROM appointments) THEN 'below'
            ELSE 'equal'
		END AS vs_overall
	FROM clinic_rates
	ORDER BY city, rank_in_city;
    
                                        -- Because of Having(>=95) clause it show 7 rows 
  					-- when run a code without having clause then it gives 8 rows.		
 ------------------------------------------- -----------



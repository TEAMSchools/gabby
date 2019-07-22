USE gabby;
GO

CREATE OR ALTER VIEW tableau.compliance_staff_attrition AS

WITH roster AS (
  SELECT sub.df_employee_number
        ,sub.preferred_first_name
        ,sub.preferred_last_name
        ,sub.primary_ethnicity
        ,sub.original_hire_date
        ,sub.rehire_date
        ,sub.position_start_date
        ,sub.termination_date
        ,sub.status_reason
        ,gabby.utilities.DATE_TO_SY(sub.position_start_date) AS start_academic_year
        ,COALESCE(gabby.utilities.DATE_TO_SY(sub.termination_date), gabby.utilities.GLOBAL_ACADEMIC_YEAR()) AS end_academic_year
  FROM (
        SELECT r.df_employee_number
              ,r.preferred_first_name
              ,r.preferred_last_name
              ,r.primary_ethnicity
              ,r.original_hire_date
              ,r.rehire_date
              ,COALESCE(r.rehire_date, r.original_hire_date) AS position_start_date
              ,CONVERT(DATE, COALESCE(CONVERT(DATETIME2, t.effective_start), r.termination_date)) AS termination_date
              ,COALESCE(t.status_reason_description, r.status_reason) AS status_reason
        FROM gabby.dayforce.staff_roster r
        LEFT JOIN gabby.dayforce.employee_status t /* final termination record */
          ON r.df_employee_number = t.number
         AND t.status = 'Terminated'
         AND t.effective_end IS NULL
       ) sub
 )

,years AS (
  SELECT n AS academic_year
        ,DATEFROMPARTS((n + 1), 4, 30) AS effective_date
  FROM gabby.utilities.row_generator
  WHERE n BETWEEN 2010 AND (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
 )

,scaffold AS (
  SELECT sub.df_employee_number
        ,sub.preferred_first_name
        ,sub.preferred_last_name
        ,sub.primary_ethnicity
        ,sub.original_hire_date
        ,sub.rehire_date
        ,sub.academic_year
        ,sub.termination_date
        ,sub.status_reason
        ,sub.academic_year_entrydate
        ,sub.academic_year_exitdate
      
        ,w.legal_entity_name
        ,w.job_name
        ,w.physical_location_name
        ,w.job_family_name
        ,w.department_name

        ,scw.school_level
        ,scw.reporting_school_id
  FROM (
        SELECT r.df_employee_number
              ,r.preferred_first_name
              ,r.preferred_last_name
              ,r.primary_ethnicity
              ,r.original_hire_date
              ,r.rehire_date
              ,r.status_reason
              ,CASE
                WHEN r.end_academic_year = y.academic_year THEN r.termination_date
               END AS termination_date
            
              ,y.academic_year
              ,y.effective_date

              ,CASE
                WHEN r.start_academic_year = y.academic_year THEN r.position_start_date
                ELSE DATEFROMPARTS(y.academic_year, 7, 1)
               END AS academic_year_entrydate
              ,COALESCE(CASE WHEN r.end_academic_year = y.academic_year THEN r.termination_date END
                       ,DATEFROMPARTS((y.academic_year + 1), 6, 30)) AS academic_year_exitdate
        FROM roster r
        JOIN years y
          ON y.academic_year BETWEEN r.start_academic_year AND r.end_academic_year
       ) sub
  LEFT JOIN gabby.dayforce.work_assignment_status w 
    ON sub.df_employee_number= w.df_employee_id
   AND sub.effective_date BETWEEN w.effective_start_date AND w.effective_end_date
  LEFT JOIN gabby.people.school_crosswalk scw
    ON w.physical_location_name = scw.site_name
   AND scw._fivetran_deleted = 0
 )

SELECT d.df_employee_number
      ,d.preferred_first_name
      ,d.preferred_last_name
      ,d.primary_ethnicity
      ,d.academic_year
      ,d.academic_year_entrydate
      ,d.academic_year_exitdate
      ,d.original_hire_date
      ,d.rehire_date
      ,d.termination_date
      ,d.status_reason
      ,d.job_name AS primary_job
      ,d.department_name AS primary_on_site_department
      ,d.physical_location_name AS primary_site
      ,d.legal_entity_name
      ,d.job_family_name AS job_family
      ,d.reporting_school_id AS primary_site_reporting_schoolid
      ,d.school_level AS primary_site_school_level
      ,CASE
        WHEN DATEDIFF(DAY, d.academic_year_entrydate, d.academic_year_exitdate) <= 0 THEN 0
        WHEN d.academic_year_exitdate >= DATEFROMPARTS(d.academic_year, 9, 1)
         AND d.academic_year_entrydate <= DATEFROMPARTS((d.academic_year + 1), 4, 30) THEN 1
        ELSE 0
       END AS is_denominator
      ,CASE
        WHEN COALESCE(d.rehire_date, d.original_hire_date) > COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30))
               THEN ROUND(DATEDIFF(DAY,d.original_hire_date,COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)))/365,0)
        ELSE ROUND(DATEDIFF(DAY,COALESCE(d.rehire_date, d.original_hire_date),COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)))/365,0)
       END AS years_at_kipp

      ,n.academic_year_exitdate AS next_academic_year_exitdate

      ,COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS((d.academic_year + 2), 6, 30)) AS attrition_exitdate
      ,CASE
        WHEN COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS((d.academic_year + 2), 6, 30)) < DATEFROMPARTS((d.academic_year + 1), 9, 1) THEN 1
        ELSE 0
       END AS is_attrition
FROM scaffold d
LEFT JOIN scaffold n
  ON d.df_employee_number = n.df_employee_number
 AND d.academic_year = (n.academic_year - 1)
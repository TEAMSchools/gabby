USE gabby
GO

CREATE OR ALTER VIEW people.manager_history AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.reports_to_associate_id
      ,sub.reports_to_effective_date
      ,sub.source_system
      ,COALESCE(
           sub.reports_to_effective_end_date
          ,DATEADD(DAY, -1, LEAD(sub.reports_to_effective_date, 1) OVER(PARTITION BY sub.associate_id ORDER BY sub.reports_to_effective_date))
         ) AS reports_to_effective_end_date
      ,COALESCE(sub.reports_to_effective_end_date
               ,DATEADD(DAY, -1, LEAD(sub.reports_to_effective_date, 1) OVER(PARTITION BY sub.associate_id ORDER BY sub.reports_to_effective_date))
               ,DATEFROMPARTS(CASE
                               WHEN DATEPART(YEAR, sub.reports_to_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH, sub.reports_to_effective_date) >= 7
                                    THEN DATEPART(YEAR, sub.reports_to_effective_date) + 1
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS reports_to_effective_end_date_eoy
FROM
    (
     SELECT mh.associate_id
           ,mh.position_id
           ,mh.reports_to_associate_id
           ,CASE 
             WHEN CONVERT(DATE, mh.reports_to_effective_date) > '2021-01-01' THEN CONVERT(DATE, mh.reports_to_effective_date)
             ELSE '2021-01-01'
            END AS reports_to_effective_date
           ,CONVERT(DATE, mh.reports_to_effective_end_date) AS reports_to_effective_end_date

           ,sr.file_number AS employee_number

           ,'ADP' AS source_system
     FROM gabby.adp.manager_history mh
     JOIN gabby.adp.employees_all sr
       ON mh.associate_id = sr.associate_id
     WHERE '2021-01-01' BETWEEN CONVERT(DATE, mh.reports_to_effective_date) AND COALESCE(CONVERT(DATE, mh.reports_to_effective_end_date), GETDATE())
        OR CONVERT(DATE, mh.reports_to_effective_date) > '2021-01-01'

     UNION ALL

     SELECT sub.associate_id
           ,CONVERT(NVARCHAR(256), sub.employee_number) AS position_id
           ,sub.reports_to_associate_id
           ,sub.reports_to_effective_date 
           ,COALESCE(DATEADD(DAY, -1, sub.effective_start_next), '2020-12-31') AS reports_to_effective_end_date
           ,sub.employee_number
           ,sub.source_system
     FROM
         (
          SELECT dm.employee_reference_code AS employee_number
                ,CONVERT(DATE, dm.manager_effective_start) AS reports_to_effective_date
                ,LEAD(CONVERT(DATE, dm.manager_effective_start), 1) OVER(
                   PARTITION BY dm.employee_reference_code
                     ORDER BY CONVERT(DATETIME2, dm.manager_effective_start)) AS effective_start_next
                ,ROW_NUMBER() OVER(
                   PARTITION BY dm.employee_reference_code, dm.manager_effective_start 
                     ORDER BY COALESCE(CONVERT(DATE, dm.manager_effective_end), '2020-12-31') DESC) AS rn_start
                ,ROW_NUMBER() OVER(
                   PARTITION BY dm.employee_reference_code, dm.manager_effective_end 
                     ORDER BY COALESCE(CONVERT(DATE, dm.manager_effective_start), '2020-12-31') DESC) AS rn_end

                ,sre.associate_id AS associate_id

                ,srm.associate_id AS reports_to_associate_id

                ,'DF' AS source_system
          FROM gabby.dayforce.employee_manager dm
          JOIN gabby.adp.employees_all sre
            ON dm.employee_reference_code = sre.file_number
          JOIN gabby.adp.employees_all srm
            ON dm.manager_employee_number = srm.file_number
          WHERE dm.manager_derived_method = 'Direct Report'
            AND CONVERT(DATE, dm.manager_effective_start) <= '2020-12-31'
         ) sub
     WHERE sub.rn_start = 1
       AND sub.rn_end = 1
    ) sub

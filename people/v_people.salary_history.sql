USE gabby
GO

CREATE OR ALTER VIEW people.salary_history AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.annual_salary
      ,sub.regular_pay_rate_amount
      ,sub.compensation_change_reason_description
      ,sub.regular_pay_effective_date
      ,sub.source_system
      ,COALESCE(
           sub.regular_pay_effective_end_date
          ,DATEADD(DAY, -1, LEAD(sub.regular_pay_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.regular_pay_effective_date))
         ) AS regular_pay_effective_end_date
      ,COALESCE(sub.regular_pay_effective_end_date
               ,DATEADD(DAY, -1, LEAD(sub.regular_pay_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.regular_pay_effective_date))
               ,DATEFROMPARTS(CASE
                               WHEN DATEPART(YEAR, sub.regular_pay_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH, sub.regular_pay_effective_date) >= 7
                                    THEN DATEPART(YEAR, sub.regular_pay_effective_date) + 1
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS regular_pay_effective_end_date_eoy
FROM
    (
     SELECT sh.associate_id
           ,sh.position_id
           ,CASE 
             WHEN CONVERT(DATE, sh.regular_pay_effective_date) > '2021-01-01' THEN CONVERT(DATE, sh.regular_pay_effective_date)
             ELSE '2021-01-01'
            END AS regular_pay_effective_date
           ,CONVERT(DATE, sh.regular_pay_effective_end_date) AS regular_pay_effective_end_date
           ,CONVERT(MONEY, sh.annual_salary) AS annual_salary
           ,CONVERT(MONEY, sh.regular_pay_rate_amount) AS regular_pay_rate_amount
           ,sh.compensation_change_reason_description

           ,sr.file_number AS employee_number

           ,'ADP' AS source_system
     FROM gabby.adp.salary_history sh
     JOIN gabby.adp.employees_all sr
       ON sh.associate_id = sr.associate_id
     WHERE CONVERT(DATE, sh.regular_pay_effective_date) < COALESCE(CONVERT(DATE, sh.regular_pay_effective_end_date), GETDATE())
       AND ('2021-01-01' BETWEEN CONVERT(DATE, sh.regular_pay_effective_date) AND COALESCE(CONVERT(DATE, sh.regular_pay_effective_end_date), GETDATE())
              OR CONVERT(DATE, sh.regular_pay_effective_date) > '2021-01-01')

     UNION ALL

     SELECT sub.associate_id
           ,sub.position_id
           ,sub.regular_pay_effective_date
           ,COALESCE(DATEADD(DAY, -1, sub.effective_start_next), '2020-12-31') AS regular_pay_effective_end_date
           ,sub.annual_salary
           ,sub.regular_pay_rate_amount
           ,sub.compensation_change_reason_description
           ,sub.employee_number
           ,sub.source_system
     FROM
         (
          SELECT sr.associate_id
                ,CONVERT(NVARCHAR(256), ds.number) AS position_id
                ,CONVERT(DATE, ds.effective_start) AS regular_pay_effective_date
                ,CONVERT(MONEY, ds.base_salary) AS annual_salary
                ,NULL AS regular_pay_rate_amount
                ,ds.status_reason_description AS compensation_change_reason_description
                ,LEAD(CONVERT(DATE, ds.effective_start), 1) OVER(PARTITION BY ds.number ORDER BY CONVERT(DATETIME2, ds.effective_start)) AS effective_start_next

                ,sr.file_number AS employee_number

                ,'DF' AS source_system
          FROM gabby.dayforce.employee_status ds
          JOIN gabby.adp.employees_all sr
            ON ds.number = sr.file_number
          WHERE CONVERT(DATE, ds.effective_start) <= '2020-12-31'
         ) sub
    ) sub
WHERE sub.annual_salary > 0

USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_teachers AS

SELECT CONVERT(VARCHAR(25), df.primary_site_schoolid) AS [School_id]
      ,COALESCE(df.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [Teacher_id]
      ,COALESCE(df.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [Teacher_number]
      ,CONVERT(VARCHAR(25),df.df_employee_number) AS [State_teacher_id]
      ,df.userprincipalname AS [Teacher_email]
      ,df.preferred_first_name AS [First_name]
      ,NULL AS [Middle_name]
      ,df.preferred_last_name AS [Last_name]
      ,df.position_title AS [Title]
      ,df.samaccountname AS [Username]
      ,NULL AS [Password]
FROM gabby.people.staff_crosswalk_static df
WHERE df.[status] != 'TERMINATED'

UNION ALL

/* testing account */
SELECT '73253' AS [School_id]
      ,'data_test' AS [Teacher_id]
      ,'data_test' AS [Teacher_number]
      ,'data_test' AS [State_teacher_id]
      ,'data_test@kippnj.org' AS [Teacher_email]
      ,'Demo_Test' AS [First_name]
      ,NULL AS [Middle_name]
      ,'Data_Test' AS [Last_name]
      ,'Teacher' AS [Title]
      ,'data_test' AS [Username]
      ,NULL AS [Password]

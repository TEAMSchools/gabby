USE gabby
GO

CREATE OR ALTER VIEW extracts.clever_schools AS

SELECT CONVERT(VARCHAR(25), school_number) AS [School_id]
      ,[name] AS [School_name]
      ,CONVERT(VARCHAR(25), school_number) AS [School_number]
      ,NULL AS [State_id]
      ,CASE
        WHEN low_grade = 0 THEN 'Kindergarten'
        ELSE CONVERT(VARCHAR(5), low_grade)
       END AS [Low_grade]
      ,high_grade AS [High_grade]
      ,principal AS [Principal]
      ,principalemail AS [Principal_email]
      ,schooladdress AS [School_address]
      ,schoolcity AS [School_city]
      ,schoolstate AS [School_state]
      ,schoolzip AS [School_zip]
      ,NULL AS [School_phone]
FROM gabby.powerschool.schools
WHERE state_excludefromreporting = 0 /* filter out summer school and graduated students */

UNION ALL

SELECT CONVERT(VARCHAR(25), 0) AS [School_id]
      ,'District Office' AS [School_name]
      ,CONVERT(VARCHAR(25), 0) AS [School_number]
      ,NULL AS [State_id]
      ,'Kindergarten' AS [Low_grade]
      ,'12' AS [High_grade]
      ,'Ryan Hill' AS [Principal]
      ,'rhill@kippnj.org' AS [Principal_email]
      ,'60 Park Place, Suite 802' AS [School_address]
      ,'Newark' AS [School_city]
      ,'NJ' AS [School_state]
      ,'07102' AS [School_zip]
      ,NULL AS [School_phone]

CREATE OR ALTER VIEW powerschool.ps_attendance_daily_current AS 

SELECT att.id
      ,att.studentid
      ,att.schoolid
      ,att.att_date
      ,att.attendance_codeid
      ,att.att_mode_code
      ,att.calendar_dayid
      ,att.programid
      ,att.total_minutes

      ,CASE WHEN ac.att_code = 'true' THEN 'T' ELSE CONVERT(VARCHAR(5),ac.att_code) END AS att_code 
      ,CONVERT(INT,ac.calculate_ada_yn) AS count_for_ada
      ,CONVERT(VARCHAR(25),ac.presence_status_cd) AS presence_status_cd
      ,CONVERT(INT,ac.calculate_adm_yn) AS count_for_adm

      ,CONVERT(INT,cd.a) AS a
      ,CONVERT(INT,cd.b) AS b
      ,CONVERT(INT,cd.c) AS c
      ,CONVERT(INT,cd.d) AS d
      ,CONVERT(INT,cd.e) AS e
      ,CONVERT(INT,cd.f) AS f
      ,CONVERT(INT,cd.insession) AS insession
      ,CONVERT(INT,cd.cycle_day_id) AS cycle_day_id
  
      ,CASE 
        WHEN cy.abbreviation = 'false' THEN 'F' 
        WHEN cy.abbreviation = 'true' THEN 'T' 
        ELSE CONVERT(VARCHAR(25),cy.abbreviation) 
       END AS abbreviation
FROM powerschool.attendance_clean_current att 
JOIN powerschool.attendance_code ac
  ON att.attendance_codeid = ac.id
JOIN powerschool.calendar_day cd
  ON att.calendar_dayid = cd.id
JOIN powerschool.cycle_day cy
  ON cd.cycle_day_id = cy.id
WHERE att.att_mode_code = 'ATT_ModeDaily'
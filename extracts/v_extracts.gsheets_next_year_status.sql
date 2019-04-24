USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_next_year_status AS

SELECT student_number
      ,state_studentnumber
      ,lastfirst
      ,academic_year
      ,region
      ,schoolid
      ,school_name
      ,grade_level
      ,iep_status
      ,cohort
      ,is_retained_ever
      ,enroll_status
      ,next_school
      ,sched_nextyeargrade
      ,promo_status
FROM gabby.tableau.next_year_status
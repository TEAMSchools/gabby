USE gabby
GO

ALTER VIEW extracts.gsheets_student_contact_info AS

SELECT co.student_number
      ,co.newark_enrollment_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.schoolid
      ,co.school_name
      ,CASE WHEN co.grade_level = 0 THEN 'K' ELSE CONVERT(NVARCHAR,co.grade_level) END AS grade_level      
      ,co.team
      ,co.advisor_name
      ,co.home_phone
      ,co.mother_cell
      ,co.father_cell
      ,co.mother
      ,co.father      
      ,co.gender      
      ,co.street
      ,co.city      
      ,co.state
      ,CONCAT('''', co.zip) AS zip
      ,co.guardianemail      
      ,CONVERT(MONEY,co.lunch_balance) AS lunch_balance
      ,CONVERT(NVARCHAR,co.dob) AS dob

      ,aa.student_web_id
      ,aa.student_web_password
      ,aa.web_id AS family_web_id
      ,aa.web_password AS family_web_password      
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN gabby.extracts.powerschool_autocomm_students_accessaccounts aa
  ON co.student_number = aa.student_number
WHERE co.enroll_status = 0
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
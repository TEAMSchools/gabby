USE gabby
GO

CREATE OR ALTER VIEW alumni.taf_roster AS 

WITH hs_grads AS (
  SELECT student_number        
  FROM gabby.powerschool.cohort_identifiers_static
  WHERE grade_level = 12
    AND exitcode = 'G1'               
 ) 

,ms_grads AS (
  SELECT co.studentid
        ,co.student_number
        ,co.first_name
        ,co.last_name
        ,co.lastfirst        
        ,co.dob
        ,co.schoolid        
        ,co.school_name
        ,co.grade_level                                
        ,co.exitdate
        ,co.cohort
        ,co.highest_achieved        
        ,co.guardianemail
        ,co.iep_status
        ,co.specialed_classification
        ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - co.academic_year) + co.grade_level AS curr_grade_level

        ,ROW_NUMBER() OVER(
           PARTITION BY co.student_number
             ORDER BY co.exitdate DESC) AS rn
  FROM gabby.powerschool.cohort_identifiers_static co
  WHERE co.grade_level = 8
    AND co.exitcode IN ('G1','T2')    
    AND co.rn_year = 1
    AND co.enroll_status != 0
    AND co.student_number NOT IN (SELECT student_number FROM hs_grads)
    --AND co.student_number NOT IN (2026,3049,3012)
 )

,transfers AS (
  SELECT sub.studentid
        ,sub.student_number
        ,sub.first_name
        ,sub.last_name
        ,sub.lastfirst                
        ,sub.DOB
        ,sub.curr_grade_level
        ,sub.cohort
        ,sub.highest_achieved        
        ,sub.final_exitdate
        ,sub.guardianemail

        ,CASE WHEN s.graduated_schoolid = 0 THEN s.schoolid ELSE s.graduated_schoolid END AS schoolid       
        ,CASE WHEN s.graduated_schoolid = 0 THEN sch2.abbreviation ELSE sch.abbreviation END AS school_name                         
  FROM
      (
       SELECT co.studentid             
             ,co.student_number
             ,co.first_name
             ,co.last_name
             ,co.lastfirst
             ,co.dob             
             ,co.highest_achieved             
             ,MAX(co.cohort) AS cohort
             ,MAX(co.guardianemail) AS guardianemail
             ,MIN(co.entrydate) AS orig_entrydate
             ,MAX(co.exitdate) AS final_exitdate
             ,DATEDIFF(YEAR, MIN(co.entrydate), MAX(co.exitdate)) AS years_enrolled             
             ,DATEPART(YEAR,MAX(co.exitdate)) AS year_final_exitdate             
             ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - MAX(co.academic_year)) + MAX(co.grade_level) AS curr_grade_level
       FROM gabby.powerschool.cohort_identifiers_static co
       WHERE co.grade_level >= 9
         AND co.enroll_status NOT IN (0, 3)
         AND co.studentid NOT IN (SELECT studentid FROM ms_grads) 
       GROUP BY co.studentid
               ,co.student_number
               ,co.lastfirst
               ,co.first_name
               ,co.last_name
               ,co.highest_achieved
               ,co.dob
      ) sub
  LEFT OUTER JOIN gabby.powerschool.students s
    ON sub.student_number = s.student_number
  LEFT OUTER JOIN gabby.powerschool.schools sch
    ON s.graduated_schoolid = sch.school_number
  LEFT OUTER JOIN gabby.powerschool.schools sch2 
    ON s.schoolid = sch2.school_number
  WHERE sub.cohort >= 2018 
    AND ((years_enrolled = 1 AND final_exitdate >= DATEFROMPARTS(year_final_exitdate, 10, 1)) OR (years_enrolled > 1))
 )

,enrollments AS (
  SELECT s.id AS salesforce_contact_id
        ,s.school_specific_id_c AS student_number        
        ,s.mobile_phone AS sf_mobile_phone
        ,s.home_phone AS sf_home_phone
        ,s.other_phone AS sf_other_phone
        ,s.email AS sf_email
        ,s.kipp_hs_class_c
        ,s.expected_hs_graduation_c
        
        ,u.id AS contact_owner_id
        ,u.name AS ktc_counselor
        
        ,enr.type_c AS enrollment_type
        ,enr.status_c AS enrollment_status
        ,enr.name AS enrollment_name        
        
        ,ROW_NUMBER() OVER(
          PARTITION BY s.school_specific_id_c
            ORDER BY enr.start_date_c DESC) AS rn
  FROM gabby.alumni.contact s
  JOIN gabby.alumni.[user] u
    ON s.owner_id = u.id
  JOIN gabby.alumni.enrollment_c enr
    ON s.id = enr.student_c
  WHERE s.is_deleted = 0
    AND s.school_specific_id_c IS NOT NULL
 )

SELECT r.student_number
      ,r.lastfirst
      --,r.schoolid
      ,r.school_name
      ,r.curr_grade_level AS approx_grade_level
      ,r.first_name
      ,r.last_name
      ,r.dob
      ,r.exitdate      
      ,CASE WHEN r.highest_achieved = 99 THEN 1 ELSE 0 END AS is_grad

      ,enr.kipp_hs_class_c AS cohort
      --,enr.contact_owner_id
      --,enr.salesforce_contact_id
      ,enr.expected_hs_graduation_c AS expected_hs_graduation_date
      ,enr.ktc_counselor
      ,enr.enrollment_type
      ,enr.enrollment_name
      ,enr.enrollment_status
      ,enr.sf_home_phone
      ,enr.sf_mobile_phone
      ,enr.sf_other_phone
      ,enr.sf_email

      ,r.guardianemail AS ps_email
      ,s.home_phone AS ps_home_phone
      ,s.mother AS ps_mother
      ,scf.mother_home_phone AS ps_mother_home
      ,suf.mother_cell AS ps_mother_cell
      ,suf.parent_motherdayphone AS ps_mother_day      
      ,s.father AS ps_father
      ,scf.father_home_phone AS ps_father_home
      ,suf.father_cell AS ps_father_cell
      ,suf.parent_fatherdayphone AS ps_father_day      
      ,s.doctor_name AS ps_doctor_name
      ,s.doctor_phone AS ps_doctor_phone
      ,s.emerg_contact_1 AS ps_emerg_contact_1
      ,scf.emerg_1_rel AS ps_emerg_1_rel
      ,s.emerg_phone_1 AS ps_emerg_phone_1
      ,s.emerg_contact_2 AS ps_emerg_contact_2
      ,scf.emerg_2_rel AS ps_emerg_2_rel
      ,s.emerg_phone_2 AS ps_emerg_phone_2
      ,scf.emerg_contact_3 AS ps_emerg_contact_3
      ,scf.emerg_3_rel AS ps_emerg_3_rel
      ,scf.emerg_3_phone AS ps_emerg_3_phone
      ,suf.emerg_4_name AS ps_emerg_4_name
      ,suf.emerg_4_rel AS ps_emerg_4_rel
      ,suf.emerg_4_phone AS ps_emerg_4_phone
      ,suf.emerg_5_name AS ps_emerg_5_name
      ,suf.emerg_5_rel AS ps_emerg_5_rel
      ,suf.emerg_5_phone AS ps_emerg_5_phone
      ,suf.release_1_name AS ps_release_1_name
      ,suf.release_1_phone AS ps_release_1_phone
      ,suf.release_1_relation AS ps_release_1_relation
      ,suf.release_2_name AS ps_release_2_name
      ,suf.release_2_phone AS ps_release_2_phone
      ,suf.release_2_relation AS ps_release_2_relation
      ,suf.release_3_name AS ps_release_3_name
      ,suf.release_3_phone AS ps_release_3_phone
      ,suf.release_3_relation AS ps_release_3_relation
      ,suf.release_4_name AS ps_release_4_name
      ,suf.release_4_phone AS ps_release_4_phone
      ,suf.release_4_relation AS ps_release_4_relation
      ,suf.release_5_name AS ps_release_5_name
      ,suf.release_5_phone AS ps_release_5_phone
      ,suf.release_5_relation AS ps_release_5_relation
FROM
    (
     SELECT studentid
           ,student_number
           ,first_name
           ,last_name
           ,lastfirst
           ,dob
           ,exitdate
           ,schoolid
           ,school_name
           ,curr_grade_level
           ,cohort
           ,highest_achieved        
           ,guardianemail
     FROM ms_grads  

     UNION  

     SELECT studentid
           ,student_number
           ,first_name
           ,last_name           
           ,lastfirst
           ,dob
           ,final_exitdate
           ,schoolid
           ,school_name
           ,curr_grade_level
           ,cohort
           ,highest_achieved        
           ,guardianemail
     FROM transfers    
    ) r
LEFT OUTER JOIN enrollments enr
  ON r.student_number = enr.student_number
 AND enr.rn = 1
LEFT OUTER JOIN gabby.powerschool.students s
  ON r.student_number = s.student_number
LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
LEFT OUTER JOIN gabby.powerschool.studentcorefields scf
  ON s.dcid = scf.studentsdcid
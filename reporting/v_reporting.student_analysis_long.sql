USE gabby 
GO

--CREATE OR ALTER VIEW gabby.reporting.student_analysis_long AS

WITH scaffold AS (
  SELECT co.student_number
        ,co.studentid
        ,co.[db_name]
        ,co.lastfirst
        ,co.academic_year
        ,co.region
        ,co.schoolid
        ,co.grade_level
        ,co.is_pathways
        ,co.lep_status
        ,co.boy_status
        ,co.eoy_status
        ,CASE WHEN co.iep_status != 'No IEP' THEN 1 ELSE 0 END AS is_sped
        ,enr.credittype
        ,enr.course_number
        ,enr.course_name
        ,enr.illuminate_subject
        ,enr.teachernumber
        ,st.df_employee_number AS teacher_df_number
        ,st.preferred_name AS teacher_preferred_name
        ,CASE WHEN enr.illuminate_subject = 'Text Study' THEN CONCAT('ELA0',co.grade_level) 
            WHEN enr.illuminate_subject = 'English 100' THEN 'ELA09'
            WHEN enr.illuminate_subject = 'English 200' THEN 'ELA10'
            WHEN enr.illuminate_subject IN ('English 300','AP Language')  THEN 'ELA11'
            WHEN enr.illuminate_subject = 'Algebra I' THEN 'ALG01'
            WHEN enr.illuminate_subject = 'Geometry' THEN 'GEO01'
            WHEN enr.illuminate_subject = 'Algebra II' THEN 'ALG02'
            WHEN enr.illuminate_subject = 'Mathematics' AND co.school_level <> 'HS' THEN CONCAT('MAT0',co.grade_level)
            ELSE NULL END AS nj_test_code
  FROM gabby.powerschool.cohort_identifiers_static co
  JOIN gabby.powerschool.course_enrollments_static enr
    ON co.student_number = enr.student_number
   AND co.academic_year = enr.academic_year
   AND enr.course_enroll_status = 0
   AND enr.section_enroll_status = 0
   AND enr.course_number NOT IN ('HR')
   AND enr.illuminate_subject IS NOT NULL
  JOIN gabby.people.staff_crosswalk_static st
    ON enr.teachernumber = st.ps_teachernumber COLLATE Latin1_General_BIN
  WHERE co.rn_year = 1
    AND co.grade_level != 99
    AND co.academic_year = 2018 /*do we try to remove this at some point?*/
    --AND enr.credittype IN ('MATH','ENG') /*This would remove a lot of folks...it that what we want to do?*/
 )

,student_attendance AS (
  SELECT psa.studentid
        ,psa.db_name
        ,psa.yearid + 1990 AS academic_year
        ,ROUND(AVG(CAST(psa.attendancevalue AS FLOAT)), 3) AS ada
  FROM gabby.powerschool.ps_adaadm_daily_ctod psa
  WHERE psa.membershipvalue = 1
    AND psa.calendardate <= CAST(SYSDATETIME() AS DATE)
  GROUP BY psa.studentid
          ,psa.yearid
          ,psa.db_name
  )

,words_read AS (
  SELECT student_number
        ,academic_year
        ,words
  FROM renaissance.ar_progress_to_goals
  WHERE reporting_term = 'ARY'
  AND words > 0
  )

,act AS (
SELECT student_number
      ,academic_year
      ,MAX(scale_score) AS act_max_composite
FROM tableau.act_prep_scores act
WHERE subject_area = 'Composite'
  AND ACT_type = 'REAL'
GROUP BY student_number
        ,academic_year
  )

,stored_grades AS (

  SELECT studentid
        ,db_name
        ,academic_year
        ,course_number
        ,[percent] AS grade_percent
  FROM powerschool.storedgrades
  WHERE storecode = 'Y1'
   )

SELECT s.student_number
      ,s.studentid
      ,s.[db_name]
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'Internal Assessments' AS domain
      ,LOWER(d.module_number) + '_pct_correct' AS metric_name
      ,d.percent_correct AS metric_value
FROM scaffold s
JOIN gabby.illuminate_dna_assessments.agg_student_responses_all d
  ON s.student_number = d.local_student_id
 AND s.academic_year = d.academic_year
 AND s.illuminate_subject = d.subject_area COLLATE Latin1_General_BIN
 AND d.is_normed_scope = 1
 AND d.response_type = 'O'
 AND d.module_type IN ('QA')

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.[db_name]
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'Internal Assessments' AS domain
      ,LOWER(d.module_number) + '_performance_band' AS metric_name
      ,d.performance_band_number AS metric_value
FROM scaffold s
JOIN gabby.illuminate_dna_assessments.agg_student_responses_all d
  ON s.student_number = d.local_student_id
 AND s.academic_year = d.academic_year
 AND s.illuminate_subject = d.subject_area COLLATE Latin1_General_BIN
 AND d.is_normed_scope = 1
 AND d.response_type = 'O'
 AND d.module_type IN ('QA')

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'ETR' AS domain
      ,'EOY_ETR' AS metric_name
      ,d.etr_score AS metric_value
FROM scaffold s
JOIN gabby.pm.teacher_goals_overall_scores d
  ON s.teacher_df_number = d.df_employee_number
 AND s.academic_year = d.academic_year
 AND d.pm_term = 'PM4'

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'Self_and_Others' AS domain
      ,'EOY_SO' AS metric_name
      ,d.so_score AS metric_value
FROM scaffold s
JOIN gabby.pm.teacher_goals_overall_scores d
  ON s.teacher_df_number = d.df_employee_number
 AND s.academic_year = d.academic_year
 AND d.pm_term = 'PM4'

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'overall_pm_score' AS domain
      ,o.pm_term COLLATE Latin1_General_BIN AS metric_name
      ,o.overall_score AS metric_value
FROM scaffold s
JOIN gabby.pm.teacher_goals_overall_scores o
  ON s.teacher_df_number = o.df_employee_number
 AND s.academic_year = o.academic_year
 AND o.pm_term = 'PM4'

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'student_attendance' AS domain
      ,'EOY_attendance' AS metric_name
      ,a.ada AS metric_value
FROM scaffold s
JOIN student_attendance a
  ON s.academic_year = a.academic_year
 AND s.studentid = a.studentid
 AND s.db_name = a.db_name

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'student_gpa' AS domain
      ,'gpa' AS metric_name
      ,g.gpa_y1 AS metric_value
FROM scaffold s
JOIN gabby.powerschool.gpa_detail g 
  ON s.academic_year = g.academic_year
 AND s.student_number = g.student_number
 AND g.is_curterm = 1

 UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'student_fails' AS domain
      ,'classes_failed' AS metric_name
      ,f.n_failing_y1 AS metric_value
FROM scaffold s
JOIN gabby.powerschool.gpa_detail f 
  ON s.academic_year = f.academic_year
 AND s.student_number = f.student_number
 AND f.is_curterm = 1

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'Literacy' AS domain
      ,'Distance from Goal - EOY' AS metric_name
      ,lit.lvl_num - lit.goal_num AS metric_value
FROM scaffold s
JOIN gabby.lit.achieved_by_round_static lit
  ON s.academic_year = lit.academic_year
 AND s.student_number = lit.student_number
 AND lit.is_curterm = 1

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'state_testing' AS domain
      ,'njsla_scale_score' AS metric_name
      ,par.test_scale_score AS metric_value
FROM scaffold s
JOIN parcc.summative_record_file_clean par
  ON s.nj_test_code = par.test_code
 AND s.student_number = par.local_student_identifier
 AND s.academic_year = par.academic_year

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'state_testing' AS domain
      ,'njsla_performance_level' AS metric_name
      ,par.test_performance_level AS metric_value
FROM scaffold s
JOIN parcc.summative_record_file_clean par
  ON s.nj_test_code = par.test_code
 AND s.student_number = par.local_student_identifier
 AND s.academic_year = par.academic_year

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'Literacy' AS domain
      ,'words_read' AS metric_name
      ,w.words AS metric_value
FROM scaffold s
JOIN words_read w
  ON s.academic_year = w.academic_year
 AND s.student_number = w.student_number

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'act' AS domain
      ,'act_max_composite_score' AS metric_name
      ,a.act_max_composite AS metric_value
FROM scaffold s
JOIN act a
  ON s.academic_year = a.academic_year
 AND s.student_number = a.student_number

UNION ALL

SELECT s.student_number
      ,s.studentid
      ,s.db_name
      ,s.lastfirst
      ,s.academic_year
      ,s.region
      ,s.schoolid
      ,s.grade_level
      ,s.is_pathways
      ,s.lep_status
      ,s.is_sped
      ,s.credittype
      ,s.course_number
      ,s.course_name
      ,s.illuminate_subject
      ,s.teachernumber
      ,s.teacher_df_number
      ,s.teacher_preferred_name
      ,s.boy_status
      ,s.eoy_status
      ,'course_grade' AS domain
      ,'eoy_grade' AS metric_name
      ,g.grade_percent AS metric_value
FROM scaffold s
JOIN stored_grades g
  ON s.academic_year = g.academic_year
 AND s.studentid = g.studentid
 AND s.db_name = g.db_name
 AND s.course_number = g.course_number
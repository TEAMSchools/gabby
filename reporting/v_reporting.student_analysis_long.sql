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
        ,CASE WHEN co.iep_status != 'No IEP' THEN 1 ELSE 0 END AS is_sped
        ,enr.credittype
        ,enr.course_number
        ,enr.course_name
        ,enr.illuminate_subject
        ,enr.teachernumber
        ,st.df_employee_number AS teacher_df_number
        ,st.preferred_name AS teacher_preferred_name
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
    AND co.academic_year = 2018
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
      
      ,'Literacy' AS domain
      ,'Distance from Goal - EOY' AS metric_name
      ,lit.lvl_num - lit.goal_num AS metric_value
FROM scaffold s
JOIN gabby.lit.achieved_by_round_static lit
  ON s.academic_year = lit.academic_year
 AND s.student_number = lit.student_number
 AND lit.is_curterm = 1
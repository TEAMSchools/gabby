USE gabby
GO

CREATE OR ALTER VIEW tableau.act_prep_scores AS

WITH real_act AS (
  SELECT student_number      
        ,test_date
        ,scale_score
        ,CONCAT(LEFT(DATENAME(MONTH,test_date),3), ' ''', RIGHT(DATEPART(YEAR,test_date),2)) AS administration_round        
        ,CASE WHEN act_subject = 'math' THEN 'Mathematics' ELSE act_subject END AS act_subject        
  FROM gabby.naviance.act_scores_clean
  UNPIVOT(
    scale_score
    FOR act_subject IN (English
                       ,Math
                       ,Reading
                       ,Science
                       ,Composite)
   ) u
 )

,real_tests AS (
  SELECT student_number
        ,administration_round
        ,test_date
        ,act_subject
        ,scale_score
        ,is_converted_sat

        ,ROW_NUMBER() OVER(
           PARTITION BY student_number
             ORDER BY scale_score DESC) AS rn_highest             
  FROM
      (
       SELECT student_number
             ,administration_round
             ,test_date        
             ,act_subject
             ,scale_score
             ,0 AS is_converted_sat
       FROM real_act
       WHERE act_subject = 'Composite'

       UNION ALL

       SELECT student_number
             ,CONCAT(LEFT(DATENAME(MONTH,test_date),3), ' ''', RIGHT(DATEPART(YEAR,test_date),2)) AS administration_round
             ,test_date        
             ,act_subject
             ,scale_score
             ,1 AS is_converted_sat
       FROM gabby.naviance.sat_act_conversion
      ) sub
 )

,ms_grad AS (
  SELECT student_number
        ,ms_attended
  FROM
      (
       SELECT student_number
             ,school_name AS ms_attended
             ,ROW_NUMBER() OVER(
                PARTITION BY student_number
                  ORDER BY exitdate DESC) AS rn
       FROM gabby.powerschool.cohort_identifiers_static
       WHERE school_level = 'MS'
      ) sub
  WHERE rn = 1
 )

SELECT co.academic_year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.cohort
      ,co.iep_status
      ,co.enroll_status
      ,co.advisor_name
      ,co.region

      ,'PREP' AS ACT_type
      ,act.assessment_id
      ,act.assessment_title      
      ,act.administration_round
      ,act.administered_at AS test_date
      ,act.subject_area
      ,act.overall_percent_correct
      ,act.overall_number_correct
      ,act.number_of_questions
      ,act.scale_score      
      ,act.prev_scale_score
      ,act.pretest_scale_score
      ,act.growth_from_pretest
      ,act.overall_performance_band
      ,act.standard_strand      
      ,act.standard_code
      ,act.standard_description
      ,act.standard_percent_correct      
      ,act.standard_mastered      
      ,act.rn_dupe AS rn_assessment /* 1 row per student, per test (overall) */      
      
      ,ms.ms_attended

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.academic_year, act.administration_round, act.subject_area, act.standard_code
           ORDER BY act.student_number) AS rn_assessment_standard /* 1 row per student, per test (by standard) */      
      ,NULL AS rn_highest
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT JOIN gabby.act.test_prep_scores act 
  ON co.student_number = act.student_number
 AND co.academic_year = act.academic_year 
LEFT JOIN ms_grad ms
  ON co.student_number = ms.student_number
WHERE co.rn_year = 1
  AND co.school_level = 'HS'
  AND co.academic_year >= 2015 /* 1st year with ACT prep */  

UNION ALL

SELECT co.academic_year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.cohort
      ,co.iep_status
      ,co.enroll_status
      ,co.advisor_name
      ,co.region
      ,'REAL' AS ACT_type
      ,NULL AS assessment_id
      ,NULL AS assessment_title
      ,CONVERT(VARCHAR,co.cohort) AS administration_round

      ,r.test_date
      ,r.act_subject AS subject_area
      ,NULL AS overall_percent_correct
      ,NULL AS overall_number_correct
      ,NULL AS number_of_questions
      ,r.scale_score
      ,NULL AS prev_scale_score
      ,NULL AS pretest_scale_score
      ,NULL AS growth_from_pretest
      ,NULL AS overall_performance_band
      ,NULL AS standard_strand
      ,NULL AS standard_code
      ,NULL AS standard_description
      ,NULL AS standard_percent_correct      
      ,NULL AS standard_mastered      
      ,1 AS rn_assessment

      ,ms.ms_attended

      ,1 AS rn_assessment_standard
      ,r.rn_highest
FROM gabby.powerschool.cohort_identifiers_static co
JOIN real_tests r
  ON co.student_number = r.student_number
 AND r.test_date BETWEEN co.entrydate AND co.exitdate
LEFT JOIN ms_grad ms
  ON co.student_number = ms.student_number
WHERE co.rn_year = 1
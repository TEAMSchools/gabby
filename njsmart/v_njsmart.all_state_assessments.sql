USE gabby
GO

CREATE OR ALTER VIEW njsmart.all_state_assessments AS

WITH combined_unpivot AS (
  SELECT local_student_id        
        ,academic_year
        ,test_type
        ,field
        ,value
  FROM
      (
       SELECT CONVERT(INT,local_student_id) AS local_student_id
             ,CONVERT(INT, SUBSTRING(_file, PATINDEX('%- [0-9][0-9][0-9][0-9]%', _file) + 2, 4)) AS academic_year
             ,'NJASK' AS test_type
      
             ,CONVERT(VARCHAR(50),scaled_score_lal) AS scaled_score_lal
             ,CONVERT(VARCHAR(50),performance_level_lal) AS performance_level_lal
             ,CONVERT(VARCHAR(50),invalid_scale_score_reason_lal) AS invalid_scale_score_reason_lal
             ,CONVERT(VARCHAR(50),void_reason_lal) AS void_reason_lal

             ,CONVERT(VARCHAR(50),scaled_score_math) AS scaled_score_math
             ,CONVERT(VARCHAR(50),performance_level_math) AS performance_level_math
             ,CONVERT(VARCHAR(50),invalid_scale_score_reason_math) AS invalid_scale_score_reason_math
             ,CONVERT(VARCHAR(50),void_reason_math) AS void_reason_math

             ,CONVERT(VARCHAR(50),scaled_score_science) AS scaled_score_science
             ,CONVERT(VARCHAR(50),performance_level_science) AS performance_level_science
             ,CONVERT(VARCHAR(50),invalid_scale_score_reason_science) AS invalid_scale_score_reason_science
             ,CONVERT(VARCHAR(50),void_reason_science) AS void_reason_science
       FROM gabby.njsmart.njask_archive

       UNION ALL

       SELECT CONVERT(INT,local_student_id) AS local_student_id
             ,CONVERT(INT,(testing_year - 1)) AS academic_year
             ,'NJASK' AS test_type
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,NULL
             ,CONVERT(VARCHAR(50),science_scale_score) AS science_scale_score
             ,CONVERT(VARCHAR(50),science_proficiency_level) AS science_proficiency_level
             ,CONVERT(VARCHAR(50),CASE WHEN science_invalid_scale_score_reason = '' THEN NULL ELSE science_invalid_scale_score_reason END) AS science_invalid_scale_score_reason
             ,CONVERT(VARCHAR(50),CASE WHEN void_reason_science = '' THEN NULL ELSE void_reason_science END) AS void_reason_science
       FROM gabby.njsmart.njask

       UNION ALL

       SELECT CONVERT(INT,local_student_id) AS local_student_id
             ,CONVERT(INT,(testing_year - 1)) AS academic_year
             ,'NJBCT' AS test_type
      
             ,NULL AS scaled_score_lal
             ,NULL AS performance_level_lal
             ,NULL AS invalid_scale_score_reason_lal
             ,NULL AS void_reason_lal

             ,NULL AS scaled_score_math
             ,NULL AS performance_level_math
             ,NULL AS invalid_scale_score_reason_math
             ,NULL AS void_reason_math

             ,CONVERT(VARCHAR(50),scale_score ) AS scaled_score_science
             ,CONVERT(VARCHAR(50),proficiency_level) AS performance_level_science
             ,NULL AS invalid_scale_score_reason
             ,CONVERT(VARCHAR(50),CASE WHEN void_reason = '' THEN NULL ELSE void_reason END) AS void_reason_science
       FROM gabby.njsmart.njbct n

       UNION ALL

       SELECT CONVERT(BIGINT,CONVERT(FLOAT,REPLACE(local_student_id, ' ', ''))) AS local_student_id
             ,CONVERT(INT, SUBSTRING(_file, PATINDEX('%- [0-9][0-9][0-9][0-9]%', _file) + 2, 4)) AS academic_year
             ,'HSPA' AS test_type
      
             ,CONVERT(VARCHAR(50),scaled_score_lal) AS scaled_score_lal
             ,CONVERT(VARCHAR(50),performance_level_lal) AS performance_level_lal
             ,CONVERT(VARCHAR(50),invalid_scale_score_reason_lal) AS invalid_scale_score_reason_lal
             ,CONVERT(VARCHAR(50),void_reason_lal) AS void_reason_lal

             ,CONVERT(VARCHAR(50),scaled_score_math) AS scaled_score_math
             ,CONVERT(VARCHAR(50),performance_level_math) AS performance_level_math
             ,CONVERT(VARCHAR(50),invalid_scale_score_reason_math) AS invalid_scale_score_reason_math
             ,CONVERT(VARCHAR(50),void_reason_math) AS void_reason_math

             ,NULL AS scaled_score_science
             ,NULL AS performance_level_science
             ,NULL AS invalid_scale_score_reason_science
             ,NULL AS void_reason_science
       FROM gabby.njsmart.hspa

       UNION ALL

       SELECT CONVERT(INT,local_student_id) AS local_student_id
             ,CONVERT(INT, SUBSTRING(_file, PATINDEX('%- [0-9][0-9][0-9][0-9]%', _file) + 2, 4)) AS academic_year
             ,'GEPA' AS test_type
      
             ,CONVERT(VARCHAR(50),scaled_score_lang) AS scaled_score_lal
             ,CONVERT(VARCHAR(50),performance_level_lang) AS performance_level_lal
             ,NULL AS invalid_scale_score_reason_lal
             ,CONVERT(VARCHAR(50),void_reason_lang) AS void_reason_lal

             ,CONVERT(VARCHAR(50),scaled_score_math) AS scaled_score_math
             ,CONVERT(VARCHAR(50),performance_level_math) AS performance_level_math
             ,NULL AS invalid_scale_score_reason_math
             ,CONVERT(VARCHAR(50),void_reason_math) AS void_reason_math

             ,CONVERT(VARCHAR(50),scaled_score_science) AS scaled_score_science
             ,CONVERT(VARCHAR(50),performance_level_science) AS performance_level_science
             ,NULL AS invalid_scale_score_reason_science
             ,CONVERT(VARCHAR(50),void_reason_science) AS void_reason_science
       FROM gabby.njsmart.gepa
      ) sub
  UNPIVOT(
    value
    FOR field IN (scaled_score_lal
                 ,performance_level_lal
                 ,invalid_scale_score_reason_lal
                 ,void_reason_lal
                 ,scaled_score_math
                 ,performance_level_math
                 ,invalid_scale_score_reason_math
                 ,void_reason_math
                 ,scaled_score_science
                 ,performance_level_science
                 ,invalid_scale_score_reason_science
                 ,void_reason_science)
   ) u
 )

,combined_repivot AS (
  SELECT local_student_id
        ,academic_year
        ,test_type
        ,CONVERT(VARCHAR(250),subject) AS subject
        ,CONVERT(FLOAT,scaled_score) AS scaled_score
        ,performance_level
        ,invalid_scale_score_reason
        ,void_reason
  FROM
      (
       SELECT local_student_id             
             ,academic_year
             ,test_type
             ,value
             ,UPPER(REVERSE(LEFT(REVERSE(field), (CHARINDEX('_', REVERSE(field)) - 1)))) AS subject
             ,REVERSE(SUBSTRING(REVERSE(field), (CHARINDEX('_', REVERSE(field)) + 1), LEN(field))) AS field      
       FROM combined_unpivot
      ) sub
  PIVOT(
    MAX(value)
    FOR field IN (scaled_score
                 ,performance_level
                 ,invalid_scale_score_reason
                 ,void_reason)
   ) p
 )

SELECT local_student_id
      ,academic_year
      ,test_type
      ,subject
      ,scaled_score
      ,performance_level
FROM
    (
     SELECT local_student_id
           ,academic_year
           ,test_type
           ,CASE WHEN subject = 'LAL' THEN 'ELA' ELSE subject END AS subject
           ,CASE WHEN scaled_score = 0 THEN NULL ELSE scaled_score END AS scaled_score
           ,CASE
             WHEN performance_level = '3' THEN 'Partially Proficient'
             WHEN performance_level = '2' THEN 'Proficient'
             WHEN performance_level = '1' THEN 'Advanced Proficient'
             ELSE performance_level
            END AS performance_level

           ,ROW_NUMBER() OVER(
              PARTITION BY local_student_id, test_type, subject, academic_year
                ORDER BY scaled_score DESC) AS rn_highscore_yr
     FROM combined_repivot
     WHERE ISNULL(invalid_scale_score_reason, 'No') = 'No'
       AND ISNULL(void_reason, 'No') = 'No'
    ) sub
WHERE rn_highscore_yr = 1
SELECT s.local_student_id AS student_number        
      ,CONVERT(DATE,sub.[Date Administered]) AS date_administered
      ,CONVERT(FLOAT,sub.[About the Text]) AS about_the_text
      ,CONVERT(FLOAT,sub.[Beyond the Text]) AS beyond_the_text
      ,CONVERT(FLOAT,sub.[Within the Text]) AS within_the_text
      ,CONVERT(FLOAT,sub.Accuracy) AS accuracy
      ,CONVERT(FLOAT,sub.Fluency) AS fluency
      ,CONVERT(FLOAT,sub.[Reading Rate (wpm)]) AS reading_rate_wpm
        
      ,sub.[Instructional Level Tested] AS instructional_level_tested
      ,CONVERT(NVARCHAR,sub.[Rate Proficiency]) AS rate_proficiency
      ,sub.[Key Lever] AS key_lever
      ,sub.[Fiction/ Nonfiction] AS fiction_nonfiction
      ,sub.[Test Administered By] AS test_administered_by
      ,sub.[Academic Year] AS academic_year        
      ,CONCAT('IL', sub.repository_id, sub.repository_row_id) AS unique_id        
      ,sub.[Test Round] AS test_round
      ,CASE
        WHEN LTRIM(RTRIM(sub.[Status])) LIKE '%Did Not Achieve%' THEN 'Did Not Achieve'
        WHEN LTRIM(RTRIM(sub.[Status])) LIKE '%Achieved%' THEN 'Achieved'
        ELSE LTRIM(RTRIM(sub.[Status]))
       END AS [status]
      ,COALESCE(sub.[Achieved Independent Level]
               ,CASE WHEN sub.[Status] LIKE '%Achieved%' THEN sub.[Instructional Level Tested] END) AS achieved_independent_level
FROM
    (
     SELECT 126 AS repository_id  
           ,repository_row_id  
           ,student_id  
           ,field_about_the_text AS [About the Text]
           ,LEFT(CONVERT(INT,field_academic_year), 4) AS [Academic Year]
           ,field_accuracy_1 AS [Accuracy]
           ,field_level_tested AS [Achieved Independent Level]
           ,field_beyond_the_text AS [Beyond the Text]
           ,field_date_administered AS [Date Administered]
           ,field_fiction_nonfiction AS [Fiction/ Nonfiction]
           ,field_fluency_1 AS [Fluency]
           ,field_text_familiarity AS [Instructional Level Tested]
           ,field_key_lever AS [Key Lever]
           ,field_rate_proficiency AS [Rate Proficiency]
           ,field_reading_rate_wpm AS [Reading Rate (wpm)]           
           ,'Mixed' AS [Status]
           ,field_test_administered_by AS [Test Administered By]
           ,field_test_round AS [Test Round]
           ,field_within_the_text AS [Within the Text]
     FROM gabby.illuminate_dna_repositories.repository_126  
     
     UNION ALL 
     
     SELECT 169 AS repository_id  
           ,repository_row_id  
           ,student_id  
           ,field_about_the_text AS [About the Text]
           ,field_academic_year AS [Academic Year]
           ,field_accuracy_1 AS [Accuracy]
           ,NULL AS [Achieved Independent Level]
           ,field_beyond_the_text AS [Beyond the Text]
           ,field_date_administered AS [Date Administered]
           ,field_fiction_nonfiction AS [Fiction/ Nonfiction]
           ,field_fluency_1 AS [Fluency]
           ,field_text_familiarity AS [Instructional Level Tested]
           ,field_key_lever AS [Key Lever]
           ,field_rate_proficiency AS [Rate Proficiency]
           ,field_reading_rate_wpm AS [Reading Rate (wpm)]
           ,field_level_tested AS [Status]           
           ,field_test_administered_by AS [Test Administered By]
           ,field_test_round AS [Test Round]
           ,field_within_the_text AS [Within the Text]
     FROM gabby.illuminate_dna_repositories.repository_169  
     
     UNION ALL 

     SELECT 170 AS repository_id  
           ,repository_row_id  
           ,student_id  
           ,field_about_the_text AS [About the Text]
           ,field_academic_year AS [Academic Year]
           ,field_accuracy_1 AS [Accuracy]
           ,NULL AS [Achieved Independent Level]
           ,field_beyond_the_text AS [Beyond the Text]
           ,field_date_administered AS [Date Administered]
           ,field_fiction_nonfiction AS [Fiction/ Nonfiction]
           ,field_fluency_1 AS [Fluency]
           ,field_text_familiarity AS [Instructional Level Tested]
           ,field_key_lever AS [Key Lever]
           ,field_rate_proficiency AS [Rate Proficiency]
           ,field_reading_rate_wpm AS [Reading Rate (wpm)]
           ,field_level_tested AS [Status]
           ,field_test_administered_by AS [Test Administered By]
           ,field_test_round AS [Test Round]
           ,field_within_the_text AS [Within the Text]
     FROM gabby.illuminate_dna_repositories.repository_170       
    ) sub
JOIN gabby.illuminate_public.students s
  ON sub.student_id = s.student_id
WHERE CONCAT(repository_id, '_', repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)
ORDER BY unique_id
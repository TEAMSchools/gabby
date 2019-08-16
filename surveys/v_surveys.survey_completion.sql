USE gabby
GO

CREATE OR ALTER VIEW surveys.survey_completion AS

WITH survey_feed AS (
  SELECT _created AS date_created
        ,CONVERT(DATETIME2,survey_timestamp) AS date_submitted
        ,subject_name
        ,LOWER(email) AS responder_email
        ,gabby.utilities.DATE_TO_SY(_created) AS academic_year
        ,CASE
          WHEN MONTH(_created) IN (8, 9, 10) THEN 'SO1'
          WHEN MONTH(_created) IN (11, 12, 1, 2, 3) THEN 'SO2'
          WHEN MONTH(_created) IN (4, 5, 6, 7) THEN 'SO3'
         END AS reporting_term
        ,'Self & Others' AS survey_type
        ,is_manager
  FROM gabby.surveys.self_and_others_survey
  WHERE subject_name IS NOT NULL
    AND _created IS NOT NULL

  UNION ALL

  SELECT _created AS date_created
        ,CONVERT(DATETIME2,survey_timestamp) AS date_submitted
        ,subject_name
        ,LOWER(responder_name) AS responder_email
        ,gabby.utilities.DATE_TO_SY(_created) AS academic_year
        ,CASE
          WHEN MONTH(_created) IN (8, 9, 10) THEN 'MGR1'
          WHEN MONTH(_created) IN (11, 12, 1) THEN 'MGR2'
          WHEN MONTH(_created) IN (2, 3, 4) THEN 'MGR3'
          WHEN MONTH(_created) IN (5, 6, 7) THEN 'MGR4'
         END AS reporting_term
        ,'Manager' AS survey_type
        ,NULL AS is_manager
  FROM gabby.surveys.manager_survey
  WHERE subject_name IS NOT NULL
    AND _created IS NOT NULL
    AND subject_name IS NOT NULL
    AND q_1 IS NOT NULL

  UNION ALL

  SELECT _created AS date_created
        ,CONVERT(DATETIME2,survey_timestamp) AS date_submitted
        ,'R9/Engagement' AS subject_name
        ,LOWER(email) AS responder_email
        ,gabby.utilities.DATE_TO_SY(_created) AS academic_year
        ,CASE
          WHEN MONTH(_created) >= 7 THEN 'R9S1'
          WHEN MONTH(_created) < 7 THEN 'R9S2'
         END AS reporting_term
        ,'R9/Engagement' AS survey
        ,NULL AS is_manager
  FROM gabby.surveys.r_9_engagement_survey
  WHERE email IS NOT NULL
 )

,teacher_scaffold AS (
  SELECT sr.df_employee_number
        ,sr.preferred_first_name AS preferred_first
        ,sr.preferred_last_name AS preferred_last
        ,sr.preferred_name
        ,sr.primary_site AS location_custom
        ,sr.primary_job AS job_title_description
        ,CASE WHEN sr.status IN ('INACTIVE', 'ADMIN_LEAVE') THEN 'LEAVE' ELSE sr.status END AS position_status
        ,LOWER(sr.userprincipalname) as email1
        ,CASE 
          WHEN LOWER(REPLACE(sr.userprincipalname, '-', '')) = LOWER(sr.userprincipalname) THEN NULL
          ELSE LOWER(REPLACE(sr.userprincipalname, '-', ''))
         END AS email2
        ,CASE
          WHEN LOWER(sr.mail) = LOWER(sr.userprincipalname) THEN NULL
          ELSE LOWER(sr.mail)
         END AS email3

        ,'Self & Others' AS survey_type
        ,ss.value AS reporting_term
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
  FROM gabby.people.staff_crosswalk_static sr
  CROSS JOIN STRING_SPLIT('SO1,SO2,SO3', ',') ss
  WHERE sr.status NOT IN ('TERMINATED', 'PRESTART')

  UNION ALL

  SELECT sr.df_employee_number
        ,sr.preferred_first_name AS preferred_first
        ,sr.preferred_last_name AS preferred_last
        ,sr.preferred_name
        ,sr.primary_site AS location_custom
        ,sr.primary_job AS job_title_description                  
        ,CASE WHEN sr.status IN ('INACTIVE', 'ADMIN_LEAVE') THEN 'LEAVE' ELSE sr.status END AS position_status
        ,LOWER(sr.userprincipalname) as email1
        ,CASE 
          WHEN LOWER(REPLACE(sr.userprincipalname, '-', '')) = LOWER(sr.userprincipalname) THEN NULL
          ELSE LOWER(REPLACE(sr.userprincipalname, '-', ''))
         END AS email2
        ,CASE
          WHEN LOWER(sr.mail) = LOWER(sr.userprincipalname) THEN NULL
          ELSE LOWER(sr.mail)
         END AS email3

        ,'R9/Engagement' AS survey_type
        ,ss.value AS reporting_term
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
  FROM gabby.people.staff_crosswalk_static sr
  CROSS JOIN STRING_SPLIT('R9S1,R9S2,R9S3,R9S4', ',') ss
  WHERE sr.status NOT IN ('TERMINATED', 'PRESTART')

  UNION ALL

  SELECT sr.df_employee_number
        ,sr.preferred_first_name AS preferred_first
        ,sr.preferred_last_name AS preferred_last
        ,sr.preferred_name
        ,sr.primary_site AS location_custom
        ,sr.primary_job AS job_title_description                  
        ,CASE WHEN sr.status IN ('INACTIVE', 'ADMIN_LEAVE') THEN 'LEAVE' ELSE sr.status END AS position_status        
        
        ,LOWER(sr.userprincipalname) as email1
        ,CASE 
          WHEN LOWER(REPLACE(sr.userprincipalname, '-', '')) = LOWER(sr.userprincipalname) THEN NULL
          ELSE LOWER(REPLACE(sr.userprincipalname, '-', ''))
         END AS email2
        ,CASE
          WHEN LOWER(sr.mail) = LOWER(sr.userprincipalname) THEN NULL
          ELSE LOWER(sr.mail)
         END AS email3

        ,'Manager' AS survey_type
        ,ss.value AS reporting_term
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
  FROM gabby.people.staff_crosswalk_static sr
  CROSS JOIN STRING_SPLIT('MGR1,MGR2,MGR3,MGR4', ',') ss
  WHERE sr.status NOT IN ('TERMINATED', 'PRESTART')
 )

SELECT s.df_employee_number AS df_employee_number
      ,s.preferred_first AS survey_taker_first
      ,s.preferred_last AS survey_taker_last
      ,s.preferred_name AS survey_taker_name
      ,s.location_custom AS location_custom
      ,s.job_title_description
      ,s.position_status

      ,COALESCE(f1.date_created, f2.date_created, f3.date_created) AS date_created
      ,COALESCE(f1.date_submitted, f2.date_submitted, f3.date_submitted) AS date_submitted
      ,COALESCE(f1.responder_email, f2.responder_email, f3.responder_email, email1) AS responder_email   
      ,COALESCE(f1.subject_name, f2.subject_name, f3.subject_name) AS subject_name
      ,COALESCE(s.academic_year,f1.academic_year, f2.academic_year, f3.academic_year) AS academic_year
      ,COALESCE(s.reporting_term,f1.reporting_term, f2.reporting_term, f3.reporting_term) AS reporting_term
      ,COALESCE(s.survey_type, f1.survey_type, f2.survey_type, f3.survey_type) AS survey_type
      ,COALESCE(f1.is_manager,f2.is_manager,f3.is_manager) AS is_manager
FROM teacher_scaffold s
LEFT JOIN survey_feed f1
  ON s.email1 = f1.responder_email
 AND s.survey_type = f1.survey_type
 AND s.academic_year = f1.academic_year
 AND s.reporting_term = f1.reporting_term
LEFT JOIN survey_feed f2
  ON s.email2 = f2.responder_email
 AND s.survey_type = f2.survey_type
 AND s.academic_year = f2.academic_year
 AND s.reporting_term = f2.reporting_term
LEFT JOIN survey_feed f3
  ON s.email3 = f3.responder_email
 AND s.survey_type = f3.survey_type
 AND s.academic_year = f3.academic_year
 AND s.reporting_term = f3.reporting_term
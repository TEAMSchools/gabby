USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_detail AS

SELECT s.survey_id
      ,s.title AS survey_title

      ,sq.shortname AS question_shortname
      ,sq.title_clean AS question_title
      ,sq.[type] AS question_type
      ,sq.is_open_ended

      ,sri.survey_response_id
      ,sri.contact_id
      ,sri.date_started
      ,sri.date_submitted
      ,sri.response_time
      ,sri.campaign_academic_year
      ,sri.campaign_name
      ,sri.campaign_reporting_term
      ,sri.respondent_df_employee_number
      ,sri.respondent_preferred_name
      ,sri.respondent_adp_associate_id
      ,sri.respondent_userprincipalname
      ,sri.respondent_mail
      ,sri.respondent_samaccountname
      ,sri.respondent_legal_entity_name
      ,sri.respondent_primary_site
      ,sri.respondent_department_name
      ,sri.respondent_primary_job
      ,sri.respondent_primary_site_schoolid
      ,sri.respondent_primary_site_school_level
      ,sri.respondent_manager_df_employee_number
      ,sri.respondent_manager_name
      ,sri.respondent_manager_mail
      ,sri.respondent_manager_userprincipalname
      ,sri.respondent_manager_samaccountname
      ,sri.subject_df_employee_number
      ,sri.subject_preferred_name
      ,sri.subject_adp_associate_id
      ,sri.subject_userprincipalname
      ,sri.subject_mail
      ,sri.subject_samaccountname
      ,sri.subject_legal_entity_name
      ,sri.subject_primary_site
      ,sri.subject_department_name
      ,sri.subject_primary_job
      ,sri.subject_primary_site_schoolid
      ,sri.subject_primary_site_school_level
      ,sri.subject_manager_df_employee_number
      ,sri.subject_manager_name
      ,sri.subject_manager_mail
      ,sri.subject_manager_userprincipalname
      ,sri.subject_manager_samaccountname
      ,sri.is_manager
      ,sri.rn_respondent_subject

      ,COALESCE(qo.option_title_english, srd.answer) AS answer

      ,CASE WHEN ISNUMERIC(qo.option_value) = 0 THEN NULL ELSE qo.option_value END AS answer_value
FROM gabby.surveygizmo.survey_clean s
JOIN gabby.surveygizmo.survey_question_clean_static sq
  ON s.survey_id = sq.survey_id
 AND sq.base_type = 'Question'
 AND sq.is_identifier_question = 0
 AND sq.[type] IN ('RADIO', 'ESSAY', 'TEXTBOX')
JOIN gabby.surveygizmo.survey_response_identifiers_static sri
  ON s.survey_id = sri.survey_id
 AND sri.[status] = 'Complete'
LEFT JOIN gabby.surveygizmo.survey_response_data_static srd
  ON sri.survey_id = srd.survey_id
 AND sri.survey_response_id = srd.survey_response_id
 AND sq.survey_question_id = srd.question_id
LEFT JOIN gabby.surveygizmo.survey_question_options_static qo
  ON sri.survey_id = qo.survey_id
 AND sq.survey_question_id = qo.question_id
 AND srd.answer_id = qo.option_id

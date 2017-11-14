USE gabby
GO

CREATE OR ALTER VIEW renaissance.ar_studentpractice_identifiers AS

SELECT student_number
      ,ch_fiction_non_fiction
      ,d_percent_correct
      ,d_points_earned
      ,dt_taken
      ,fl_lexile_calc
      ,i_lexile 
      ,i_questions_correct
      ,i_questions_presented
      ,i_quiz_number           
      ,i_student_practice_id
      ,i_user_id
      ,i_word_count      
      ,ti_book_rating
      ,ti_passed
      ,vch_content_title
      ,vch_lexile_display      

      ,gabby.utilities.DATE_TO_SY(dt_taken) AS academic_year

      ,CASE
        /* for failing attempts, valid row should be most recent */
        WHEN ti_passed = 0 THEN ROW_NUMBER() OVER(
                                  PARTITION BY student_number, i_quiz_number, ti_passed
                                    ORDER BY i_retake_count DESC) 
        /* for passing attempts, valid row should be first */
        WHEN ti_passed = 1 THEN ROW_NUMBER() OVER(
                                  PARTITION BY student_number, i_quiz_number, ti_passed
                                    ORDER BY dt_taken_original ASC) 
       END AS rn_quiz
FROM
    (
     SELECT ar.ch_fiction_non_fiction
           ,ar.d_percent_correct
           ,ar.d_points_earned
           ,ar.dt_taken
           ,ar.dt_taken_original            
           ,ar.fl_lexile_calc
           ,ar.i_lexile 
           ,ar.i_questions_correct
           ,ar.i_questions_presented
           ,ar.i_quiz_number                 
           ,ar.i_retake_count
           ,ar.i_student_practice_id                      
           ,ar.i_user_id
           ,ar.i_word_count           
           ,ar.ti_book_rating
           ,ar.ti_passed           
           ,ar.vch_content_title
           ,ar.vch_lexile_display      
           /*
           ,ar.ch_content_version      
           ,ar.ch_status
           ,ar.ch_twi
           ,ar.d_alternate_book_level_1
           ,ar.d_book_level
           ,ar.d_passing_percentage
           ,ar.d_points_possible      
           ,ar.device_applet_id
           ,ar.device_type
           ,ar.device_unique_id      
           ,ar.dt_edit_date
           ,ar.dt_insert_date                 
           ,ar.i_alternate_book_level_2
           ,ar.i_class_id
           ,ar.i_content_type_id
           ,ar.i_edit_by_id
           ,ar.i_insert_by_id
           ,ar.i_questions_correct
           ,ar.i_questions_presented                 
           ,ar.i_rlid
           ,ar.i_school_id      
           ,ar.i_teacher_user_id
           ,ar.i_user_id      
           ,ar.s_data_origination      
           ,ar.ti_book_rating
           ,ar.ti_csimport_version      
           ,ar.ti_practice_detail
           ,ar.ti_row_status
           ,ar.ti_teacher_modified
           ,ar.ti_used_audio      
           ,ar.vch_author
           ,ar.vch_content_language      
           ,ar.vch_interest_level      
           ,ar.vch_second_try_author
           ,ar.vch_second_try_title
           ,ar.vch_sort_title
           */

           ,u.vch_previous_idnum AS student_number                
     FROM gabby.renaissance.ar_studentpractice ar
     JOIN gabby.renaissance.rl_user u
       ON ar.i_user_id = u.i_user_id
      AND ISNUMERIC(u.vch_previous_idnum) = 1
     WHERE ar.i_content_type_id = 31
       AND ar.ch_status != 'U'
       AND ar.ti_row_status = 1
    ) sub
USE [gabby]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER TRIGGER [illuminate_dna_assessments].[TR_students_assessments_cleanup_AI]
   ON  [illuminate_dna_assessments].[students_assessments_archive]
   AFTER INSERT
AS 

BEGIN	
	 SET NOCOUNT ON;
 
  IF (EXISTS(SELECT 1 FROM INSERTED))
  BEGIN

    DELETE FROM [illuminate_dna_assessments].[students_assessments]
    WHERE [students_assessments].[student_assessment_id] IN (SELECT student_assessment_id FROM INSERTED);

    DELETE FROM [illuminate_dna_assessments].[agg_student_responses]
    WHERE [agg_student_responses].[student_assessment_id] IN (SELECT student_assessment_id FROM INSERTED);

    DELETE FROM [illuminate_dna_assessments].[agg_student_responses_standard]
    WHERE [agg_student_responses_standard].[student_assessment_id] IN (SELECT student_assessment_id FROM INSERTED);

    DELETE FROM [illuminate_dna_assessments].[agg_student_responses_group]
    WHERE [agg_student_responses_group].[student_assessment_id] IN (SELECT student_assessment_id FROM INSERTED);

  END;
END

USE gabby
GO

CREATE OR ALTER VIEW extracts.gclassroom_sections AS

SELECT CONCAT(s.schoolid, '-'
             ,s.course_number, '-'
             ,s.id, '-'
             ,s.termid) AS class_alias

      ,CONCAT(c.course_name
             ,' (' + c.course_number_clean + ') - '
             ,s.section_number + ' - '
             ,gabby.utilities.GLOBAL_ACADEMIC_YEAR(), '-'
             ,RIGHT(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 2) + 1) AS class_name
      
      ,s.id AS sectionid
      ,s.[db_name]
      ,s.section_number
      ,s.external_expression AS [period]
      ,s.schoolid
      ,s.termid

      ,CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS teacher_gsuite_email
FROM gabby.powerschool.sections s
JOIN gabby.powerschool.courses c
  ON s.course_number_clean = c.course_number_clean
 AND s.[db_name] = c.[db_name] 
 AND c.credittype <> 'LOG'
JOIN gabby.powerschool.teachers_static t
  ON s.teacher = t.id
 AND s.schoolid = t.schoolid
 AND s.[db_name] = t.[db_name]
JOIN gabby.people.staff_crosswalk_static scw
  ON t.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
WHERE s.no_of_students > 0
  AND s.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)
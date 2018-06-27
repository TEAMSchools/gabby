CREATE OR ALTER VIEW powerschool.gradebook_setup AS

WITH default_gfs AS (
  SELECT gfs.gradeformulasetid	        
        ,gfs.yearid  
        ,gct.abbreviation
        ,gct.storecode
        ,gct.gradecalculationtypeid
        ,gct.type
        
        ,sch.school_number
  FROM gabby.powerschool.gradeformulaset gfs WITH(NOLOCK)
  JOIN gabby.powerschool.gradecalculationtype gct WITH(NOLOCK)
    ON gfs.gradeformulasetid = gct.gradeformulasetid
  JOIN gabby.powerschool.gradecalcschoolassoc gcsa WITH(NOLOCK)
    ON gct.gradecalculationtypeid = gcsa.gradecalculationtypeid
  JOIN gabby.powerschool.schools sch WITH(NOLOCK)
    ON gcsa.schoolsdcid = sch.dcid
  WHERE gfs.sectionsdcid IS NULL
    AND gfs.name != 'DELETE'
 )
    
SELECT sectionsdcid
      ,sectionsdcid AS psm_sectionid                
      ,ISNULL(gradeformulasetid, 0) AS finalgradesetupid
      ,gct_type AS finalgradesetuptype        
      ,gradecalculationtypeid AS fg_reportingtermid
      ,storecode AS reportingterm_name
      ,date_1 AS startdate
      ,date_2 AS enddate
      ,ISNULL(gradecalcformulaweightid, gradecalculationtypeid)AS gradingformulaid
      ,ISNULL(gcfw_type, gct_type) AS gradingformulaweightingtype
      ,weight AS weighting
                
      ,COALESCE(districtteachercategoryid, teachercategoryid, gradecalculationtypeid) AS assignmentcategoryid
      ,COALESCE(dtc_name, tc_name, gct_type) AS category_name
      ,COALESCE(dtc_name, tc_name, gct_type) AS category_abbreviation
      ,COALESCE(dtc_defaultscoretype, tc_defaultscoretype) AS defaultscoretype
      ,COALESCE(dtc_isinfinalgrades, tc_isinfinalgrades, 1) AS includeinfinalgrades
FROM
    (
     SELECT sec.dcid AS sectionsdcid        
           ,tb.storecode
           ,tb.date_1
           ,tb.date_2

           ,COALESCE(gfs.gradeformulasetid, d.gradeformulasetid) AS gradeformulasetid
           ,COALESCE(gct.gradecalculationtypeid, d.gradecalculationtypeid) AS gradecalculationtypeid
           ,COALESCE(gct.type, d.type) AS gct_type       

           ,gcfw.gradecalcformulaweightid
           ,gcfw.teachercategoryid
           ,gcfw.districtteachercategoryid
           ,gcfw.weight
           ,gcfw.type AS gcfw_type        
        
           ,tc.teachermodified
           ,tc.name AS tc_name
           ,tc.defaultscoretype AS tc_defaultscoretype
           ,tc.isinfinalgrades AS tc_isinfinalgrades

           ,dtc.name AS dtc_name
           ,dtc.defaultscoretype AS dtc_defaultscoretype
           ,dtc.isinfinalgrades AS dtc_isinfinalgrades                
     FROM gabby.powerschool.sections sec WITH(NOLOCK)
     JOIN gabby.powerschool.termbins tb WITH(NOLOCK)
       ON sec.schoolid = tb.schoolid
      AND sec.termid = tb.termid   
     JOIN gabby.powerschool.terms rt WITH(NOLOCK)
       ON tb.termid = rt.id
      AND sec.schoolid = rt.schoolid
     JOIN default_gfs d
       ON sec.schoolid = d.school_number
      AND sec.yearid = d.yearid
      AND tb.storecode = d.storecode
      AND rt.abbreviation = d.abbreviation
     LEFT OUTER JOIN gabby.powerschool.gradeformulaset gfs WITH(NOLOCK)
       ON sec.dcid = gfs.sectionsdcid         
     LEFT OUTER JOIN gabby.powerschool.gradecalculationtype gct WITH(NOLOCK)
       ON gfs.gradeformulasetid = gct.gradeformulasetid    
      AND tb.storecode = gct.storecode 
     LEFT OUTER JOIN gabby.powerschool.gradecalcformulaweight gcfw WITH(NOLOCK)
       ON COALESCE(gct.gradecalculationtypeid, d.gradecalculationtypeid) = gcfw.gradecalculationtypeid
     LEFT OUTER JOIN gabby.powerschool.teachercategory tc WITH(NOLOCK)
       ON gcfw.teachercategoryid = tc.teachercategoryid 
     LEFT OUTER JOIN gabby.powerschool.districtteachercategory dtc WITH(NOLOCK)
       ON gcfw.districtteachercategoryid = dtc.districtteachercategoryid
     WHERE sec.termid >= 2500           
       AND sec.gradebooktype = 2    
    ) sub
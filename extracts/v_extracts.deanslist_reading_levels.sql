USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_reading_levels AS

SELECT student_number
      ,academic_year
      ,test_round
      ,read_lvl
      ,goal_lvl
      ,lvl_num AS read_lvl_num
      ,goal_num AS goal_lvl_num
      ,goal_status AS met_goal
      ,ISNULL(lvl_num - MAX(CASE WHEN rn_round_asc = 1 THEN lvl_num END) OVER(PARTITION BY student_number, academic_year), 0) AS lvl_growth_ytd
FROM gabby.lit.achieved_by_round_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()  
  AND achv_unique_id LIKE 'FPBAS%'

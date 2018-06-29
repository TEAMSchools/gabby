USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.calendar_day AS

SELECT 'kippcamden' AS [db_name]
      ,[a]
      ,[b]
      ,[bell_schedule_id]
      ,[c]
      ,[cycle_day_id]
      ,[d]
      ,[date_value]
      ,[dcid]
      ,[e]
      ,[f]
      ,[id]
      ,[insession]
      ,[membershipvalue]
      ,[note]
      ,[scheduleid]
      ,[schoolid]
      ,[type]
      ,[week_num]
FROM kippcamden.powerschool.calendar_day
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[a]
      ,[b]
      ,[bell_schedule_id]
      ,[c]
      ,[cycle_day_id]
      ,[d]
      ,[date_value]
      ,[dcid]
      ,[e]
      ,[f]
      ,[id]
      ,[insession]
      ,[membershipvalue]
      ,[note]
      ,[scheduleid]
      ,[schoolid]
      ,[type]
      ,[week_num]
FROM kippmiami.powerschool.calendar_day
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[a]
      ,[b]
      ,[bell_schedule_id]
      ,[c]
      ,[cycle_day_id]
      ,[d]
      ,[date_value]
      ,[dcid]
      ,[e]
      ,[f]
      ,[id]
      ,[insession]
      ,[membershipvalue]
      ,[note]
      ,[scheduleid]
      ,[schoolid]
      ,[type]
      ,[week_num]
FROM kippnewark.powerschool.calendar_day;
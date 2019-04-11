USE gabby;
GO

CREATE OR ALTER VIEW utilities.fivetran_audit AS

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM alumni.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM illuminate_groups.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM illuminate_standards.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM illuminate_dna_assessments.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM illuminate_public.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM illuminate_codes.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM illuminate_dna_repositories.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM recruiting.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM newarkenrolls.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM nwea.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM asana.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM zendesk.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM deanslist.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM naviance.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM steptool.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM reporting.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM stmath.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM caredox.fivetran_audit

UNION
SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM easyiep.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM renaissance.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM finance.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM lit.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM enrollment.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM adp.fivetran_audit

UNION

SELECT id
      ,[schema]
      ,[table]
      ,status
      ,message
      ,update_id
      ,update_started
      ,start
      ,done
      ,rows_updated_or_inserted
      ,progress
FROM lexia.fivetran_audit;
USE gabby
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION utilities.DATE_TO_SY(@date DATE)
    RETURNS INT
  AS

BEGIN
  RETURN CASE WHEN DATEPART(MONTH,@date) < 7 THEN (DATEPART(YEAR,@date) - 1) ELSE DATEPART(YEAR,@date) END;
END

GO
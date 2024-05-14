SET TERM ^ ;

CREATE OR ALTER FUNCTION ULTIMODIAMES (
    I_DT_ATUAL DOM_DATE)
RETURNS DOM_DATE
AS
BEGIN
   IF (I_DT_ATUAL IS NULL) THEN
      RETURN NULL;
   ELSE
      RETURN (DATEADD(MONTH, 1, CAST('01.'||EXTRACT(MONTH FROM :I_DT_ATUAL)||'.'||EXTRACT(YEAR FROM :I_DT_ATUAL) AS DATE))) - 1;
END^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON FUNCTION ULTIMODIAMES TO SYSDBA;
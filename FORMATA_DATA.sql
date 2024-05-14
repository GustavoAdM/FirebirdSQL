SET TERM ^ ;

CREATE OR ALTER FUNCTION FORMATA_DATA (
    I_DT_ATUAL DOM_TIMESTAMP,
    I_DS_MASCARA DOM_VARCHAR100 = '%D/%M/%Y')
RETURNS DOM_VARCHAR100
AS
DECLARE VARIABLE V_DT_FORMATADA DOM_VARCHAR100;
BEGIN
   /*
   D - DIA
   M - MES
   Y - ANO COM 4 DIGITOS
   A - ANO SOMENTE DOIS ULTIMOS DIGITOS
   H - HORA
   T - MINUTO
   S - SEGUNDO
*/

   IF (I_DT_ATUAL IS NULL) THEN
      V_DT_FORMATADA = NULL;
   ELSE
   BEGIN
      I_DS_MASCARA = UPPER(I_DS_MASCARA);

      I_DS_MASCARA = REPLACE(I_DS_MASCARA, '%D', LPAD(EXTRACT(DAY FROM :I_DT_ATUAL), 2, '0'));
      I_DS_MASCARA = REPLACE(I_DS_MASCARA, '%M', LPAD(EXTRACT(MONTH FROM :I_DT_ATUAL), 2, '0'));
      I_DS_MASCARA = REPLACE(I_DS_MASCARA, '%Y', LPAD(EXTRACT(YEAR FROM :I_DT_ATUAL), 4, '0'));
      I_DS_MASCARA = REPLACE(I_DS_MASCARA, '%A', SUBSTRING(LPAD(EXTRACT(YEAR FROM :I_DT_ATUAL), 4, '0') FROM 3 FOR 2));
      I_DS_MASCARA = REPLACE(I_DS_MASCARA, '%H', LPAD(EXTRACT(HOUR FROM :I_DT_ATUAL), 2, '0'));
      I_DS_MASCARA = REPLACE(I_DS_MASCARA, '%T', LPAD(EXTRACT(MINUTE FROM :I_DT_ATUAL), 2, '0'));
      I_DS_MASCARA = REPLACE(I_DS_MASCARA, '%S', LPAD(EXTRACT(SECOND FROM :I_DT_ATUAL), 2, '0'));
      V_DT_FORMATADA = I_DS_MASCARA;
   END

   RETURN V_DT_FORMATADA;
END^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON FUNCTION FORMATA_DATA TO SYSDBA;
WITH DIAS_UTEIS
AS (SELECT
       SUM(IIF(EXTRACT(WEEKDAY FROM RD.O_DATA) IN (1, 2, 3, 4, 5), 1, 0)) DIAS_UTE,
       SUM(IIF((RD.O_DATA BETWEEN FIRSTDAYMONTH(CURRENT_DATE) AND CURRENT_DATE) AND EXTRACT(WEEKDAY FROM RD.O_DATA) IN (1, 2, 3, 4, 5), 1, 0)) DIAS_TRAB,
       SUM(IIF((RD.O_DATA BETWEEN CURRENT_DATE +1 AND LASTDAYMONTH(CURRENT_DATE)) AND EXTRACT(WEEKDAY FROM RD.O_DATA) IN (1, 2, 3, 4, 5), 1, 0)) FALT_DIAS_TRAB
    FROM RETORNA_DIAS(FIRSTDAYMONTH(CURRENT_DATE), LASTDAYMONTH(CURRENT_DATE)) RD
    WHERE DATETOSTR(RD.O_DATA, '%d.%m') NOT IN ('25.12', '01.01') --N�O CONTA FERIADOS

),

META_VENDEDOR
AS (SELECT
       V.CD_VENDEDOR, SUM(MV.QT_META) QT_META, SUM(MV.VL_META) VL_META
    FROM VENDEDOR V
    INNER JOIN METAVENDEDOR MV ON (MV.CD_VENDEDOR = V.CD_VENDEDOR)
    WHERE MV.DT_META BETWEEN FIRSTDAYMONTH(CURRENT_DATE) AND LASTDAYMONTH(CURRENT_DATE)
    GROUP BY V.CD_VENDEDOR

),

CADASTRO_NOVO
AS (SELECT
       COUNT(DISTINCT P.CD_PESSOA) QT_CADAS_NOVO, V.CD_VENDEDOR
    FROM VENDEDOR V
    LEFT JOIN ENDERECOPESSOA EP ON (EP.CD_VENDEDOR = V.CD_VENDEDOR
                                AND EP.CD_ENDERECO = 1)
    LEFT JOIN PESSOA P ON (P.CD_PESSOA = EP.CD_PESSOA
                       AND P.DT_CADASTRO BETWEEN FIRSTDAYMONTH(CURRENT_DATE) AND LASTDAYMONTH(CURRENT_DATE))
    GROUP BY V.CD_VENDEDOR

)
SELECT
   P.NM_PESSOA NM_VENDEDOR, SUM(IT.QT_ITEMNOTA) QT_ITEM, SUM(IT.VL_LIQUIDO) VL_LIQUIDO, MV.QT_META, MV.VL_META,
   ((SUM(IT.VL_LIQUIDO) / COALESCE(NULLIF(DU.DIAS_TRAB, 0), 1)) * COALESCE(NULLIF(FALT_DIAS_TRAB, 0), 1) + SUM(IT.VL_LIQUIDO)) PROJECAOVALOR,
   ((SUM(IT.QT_ITEMNOTA) / COALESCE(NULLIF(DU.DIAS_TRAB, 0), 1)) * COALESCE(NULLIF(FALT_DIAS_TRAB, 0), 1) + SUM(QT_ITEMNOTA)) PROJECAOQNTD,
   CN.QT_CADAS_NOVO, SUM(COALESCE(NULLIF(IT.VL_LIQUIDO, 0), 1)) / SUM(COALESCE(NULLIF(IT.QT_ITEMNOTA, 0), 1)) PRECO_MEDIO

FROM NOTA N
INNER JOIN ITEMNOTA IT ON (IT.CD_EMPRESA = N.CD_EMPRESA
                       AND IT.NR_LANCAMENTO = N.NR_LANCAMENTO
                       AND IT.TP_NOTA = N.TP_NOTA
                       AND IT.CD_SERIE = N.CD_SERIE)
LEFT JOIN ITEMNOTAVENDEDOR ITV ON (ITV.CD_EMPRESA = IT.CD_EMPRESA
                                 AND ITV.NR_LANCAMENTO = IT.NR_LANCAMENTO
                                 AND ITV.TP_NOTA = IT.TP_NOTA
                                 AND ITV.CD_SERIE = IT.CD_SERIE
                                 AND ITV.CD_ITEM = IT.CD_ITEM
                                 AND ITV.CD_TIPO = 1)
INNER JOIN MOVIMENTACAO MOV ON (MOV.CD_MOVIMENTACAO = IT.CD_MOVIMENTACAO)
INNER JOIN ITEM I ON (I.CD_ITEM = IT.CD_ITEM)
INNER JOIN PESSOA P ON (P.CD_PESSOA = N.CD_VENDEDOR)
INNER JOIN DIAS_UTEIS DU ON (1 = 1)
LEFT JOIN META_VENDEDOR MV ON (MV.CD_VENDEDOR = N.CD_VENDEDOR)
INNER JOIN CADASTRO_NOVO CN ON (CN.CD_VENDEDOR = N.CD_VENDEDOR)
WHERE N.ST_NOTA = 'V'
  AND N.CD_EMPRESA = 1
  AND N.DT_EMISSAO BETWEEN FIRSTDAYMONTH(CURRENT_DATE) AND LASTDAYMONTH(CURRENT_DATE)
  AND N.TP_NOTA = 'S'
  AND MOV.CD_TIPOCONTA IS NOT NULL
  AND MOV.CD_OPERACAO IS NOT NULL
  AND MOV.ST_RECEITA = 'S'
  AND I.CD_GRUPO = 3
GROUP BY NM_VENDEDOR, MV.QT_META, MV.VL_META, DU.DIAS_TRAB, DU.FALT_DIAS_TRAB, CN.QT_CADAS_NOVO
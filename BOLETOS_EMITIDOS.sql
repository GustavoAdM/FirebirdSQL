SELECT DISTINCT
    P.CD_PESSOA, P.NM_PESSOA, C.ST_CONTAS, DATETOSTR(C.DT_VENCIMENTO, '%d/%m/%Y') DT_VENC,
    C.NR_DOCUMENTO||'/'||C.NR_PARCELA NR_DOC, 'R$ '||C.VL_SALDO VL_TOTAL,
    C.NR_PARCELA||'/'|| MAX((SELECT MAX(CM.NR_PARCELA)
                            FROM CONTAS CM
                            WHERE CM.CD_EMPRESA = C.CD_EMPRESA
                                AND CM.NR_LANCAMENTO = C.NR_LANCAMENTO
                                AND CM.CD_PESSOA = C.CD_PESSOA
                                AND CM.CD_TIPOCONTA = C.CD_TIPOCONTA)) DS_PARCELA,
    LIST(DISTINCT 'N� '||N.NR_NOTAFISCAL||'-'||N.CD_SERIE, ', ') DS_NOTAS,
    LIST(DISTINCT DATETOSTR(N.DT_EMISSAO, '%d/%m/%Y'), ', ') DS_EMISSAONOTAS,
    BI.NR_SEQUENCIA, BI.CD_EMPRESA, BI.NR_LANCAMENTO, BI.NR_PARCELA, BI.CD_BANCO, BI.DS_CODIGOBANCO, BI.DS_BANCO,
    BI.DS_LOCALPAGAMENTO, BI.DT_VENCIMENTO, BI.NM_CEDENTE, BI.DS_ENDERECOCEDENTE, BI.NR_CNPJCPFCEDENTE,
    BI.DS_AGENCIACODIGOCEDENTE, BI.DT_DOCUMENTO, BI.NR_DOCUMENTO, BI.DS_ESPECIE, BI.TP_ACEITE,
    BI.DT_PROCESSAMENTO, BI.NR_NOSSONUMERO, BI.DS_USOBANCO, BI.NR_CARTEIRA, BI.DS_MOEDA, BI.QT_MOEDA,
    BI.VL_MOEDA, BI.VL_DOCUMENTO, BI.DS_INSTRUCAO, BI.VL_DESCONTOABATIMENTO, BI.VL_DEDUCAO, BI.VL_MULTAJURO,
    BI.VL_ACRESCIMO, BI.VL_COBRADO, BI.NM_SACADO, BI.NR_CNPJCPFSACADO, BI.DS_ENDERECOSACADO, BI.DS_CEPCIDADESACADO,
    BI.DS_LINHADIGITAVEL, BI.DS_CODIGOBARRA, BI.BI_CODIGOBARRA, BI.CD_VENDEDOR, BI.NM_VENDEDOR, BI.DS_PARCELAS,
    BI.NR_DOCUMENTOPARC, BI.NR_DOCSERIEPARC, BI.CD_SACADO, BI.NM_SACADOCODIGO, BI.NM_AVALISTA, BI.NR_CNPJCPFAVALISTA,
    C.CD_FORMAPAGTO, C.CD_EMPRESA C_EMPRESA

FROM CONTAS C
INNER JOIN BOLETOIMPRESSO BI ON (BI.CD_EMPRESA = C.CD_EMPRESA
                            AND BI.NR_LANCAMENTO = C.NR_LANCAMENTO
                            AND BI.NR_PARCELA = C.NR_PARCELA
                            AND BI.NR_SEQUENCIA = (SELECT FIRST 1 BI2.NR_SEQUENCIA FROM BOLETOIMPRESSO BI2
                                                   WHERE BI2.CD_EMPRESA = C.CD_EMPRESA
                                                       AND BI2.NR_LANCAMENTO = C.NR_LANCAMENTO
                                                       AND BI2.NR_PARCELA = C.NR_PARCELA
                                                   ORDER BY BI2.NR_SEQUENCIA DESC))
INNER JOIN PESSOA P ON (P.CD_PESSOA = C.CD_PESSOA)
LEFT JOIN DESTINOREPARCELAMENTO D ON (D.CD_EMPRCONTAS = C.CD_EMPRESA
                                  AND D.NR_LANCAMENTO = C.NR_LANCAMENTO
                                  AND D.CD_PESSOA = C.CD_PESSOA
                                  AND D.CD_TIPOCONTA = C.CD_TIPOCONTA
                                  AND D.NR_PARCELA = C.NR_PARCELA)
LEFT JOIN ORIGEMREPARCELAMENTO O ON (O.CD_EMPRESA = D.CD_EMPRESA
                                 AND O.NR_REPARCELAMENTO = D.NR_REPARCELAMENTO)
LEFT JOIN CONTAS CO ON (CO.CD_EMPRESA = O.CD_EMPRESA
                    AND CO.NR_LANCAMENTO = O.NR_LANCAMENTO
                    AND CO.CD_PESSOA = O.CD_PESSOA
                    AND CO.CD_TIPOCONTA = O.CD_TIPOCONTA
                    AND CO.NR_PARCELA = O.NR_PARCELA)
INNER JOIN NOTA N ON (N.CD_EMPRESA = COALESCE(CO.CD_EMPRESA, C.CD_EMPRESA)
                  AND N.CD_PESSOA = COALESCE(CO.CD_PESSOA, C.CD_PESSOA)
                  AND N.NR_LANCAMENTO = COALESCE(CO.NR_LANCTONOTA, C.NR_LANCTONOTA)
                  AND N.TP_NOTA = COALESCE(CO.TP_CONTAS, C.TP_CONTAS))
WHERE C.ST_CONTAS NOT IN ('C','L','A')
    AND C.CD_FORMAPAGTO IN ('B1')
    AND C.DT_LANCAMENTO = CURRENT_DATE

GROUP BY P.CD_PESSOA, P.NM_PESSOA , C.ST_CONTAS ,DT_VENC, NR_DOC, C.NR_PARCELA, VL_TOTAL,
    BI.NR_SEQUENCIA, BI.CD_EMPRESA, BI.NR_LANCAMENTO, BI.NR_PARCELA, BI.CD_BANCO,
    BI.DS_CODIGOBANCO, BI.DS_BANCO, BI.DS_LOCALPAGAMENTO, BI.DT_VENCIMENTO, BI.NM_CEDENTE,
    BI.DS_ENDERECOCEDENTE, BI.NR_CNPJCPFCEDENTE, BI.DS_AGENCIACODIGOCEDENTE, BI.DT_DOCUMENTO,
    BI.NR_DOCUMENTO, BI.DS_ESPECIE, BI.TP_ACEITE, BI.DT_PROCESSAMENTO, BI.NR_NOSSONUMERO,
    BI.DS_USOBANCO, BI.NR_CARTEIRA, BI.DS_MOEDA, BI.QT_MOEDA, BI.VL_MOEDA, BI.VL_DOCUMENTO,
    BI.DS_INSTRUCAO, BI.VL_DESCONTOABATIMENTO, BI.VL_DEDUCAO, BI.VL_MULTAJURO, BI.VL_ACRESCIMO,
    BI.VL_COBRADO, BI.NM_SACADO, BI.NR_CNPJCPFSACADO, BI.DS_ENDERECOSACADO, BI.DS_CEPCIDADESACADO,
    BI.DS_LINHADIGITAVEL, BI.DS_CODIGOBARRA, BI.BI_CODIGOBARRA, BI.CD_VENDEDOR, BI.NM_VENDEDOR,
    BI.DS_PARCELAS, BI.NR_DOCUMENTOPARC, BI.NR_DOCSERIEPARC, BI.CD_SACADO, BI.NM_SACADOCODIGO, BI.NM_AVALISTA,
    BI.NR_CNPJCPFAVALISTA,C.CD_FORMAPAGTO, C_EMPRESA
ORDER BY P.CD_PESSOA, P.NM_PESSOA, NR_DOC, C.NR_PARCELA
;
CREATE OR REPLACE FUNCTION USRASSISTENTEFISCAL.FN_EXCEDENTE_ENT_MES(P_FILIAL IN VARCHAR2, P_DATA_GERADOR IN DATE)
RETURN USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
 IS
  V_RET USRASSISTENTEFISCAL.T_EXCEDENTE_ENT;

 BEGIN
   SELECT CAST (
           MULTISET (
                  SELECT
                   ID,
                   DOF_SEQUENCE,
                   DOF_NUMERO,
                   DOF_IMPORT_NUMERO,
                   EDOF_CODIGO,
                   MDOF_CODIGO,
                   serie,
                   FILIAL,
                   INFORMANTE_EST_CODIGO,
                   CPF_CGC,
                   CNPJ_FORNECEDOR,
                   DT_FATO_GERADOR_IMPOSTO,
                   dh_emissao,
                   CFOP_CODIGO,
                   OPERACAO,
                   DENTRO_ESTADO,
                   STC_CODIGO,
                   COD_BARRA,
                   NBM_CODIGO,
                   MERC_CODIGO,
                   DESCRICAO,
                   IDF_NUM,
                   MOV,
                   VL_Unit,
                   EMBALAGEM,
                   QUANTIDADE,
                   ROUND((NVL(EMBALAGEM,0)  *  NVL(QUANTIDADE,0)),4) AS VOLUME,
                   ROUND((NVL(EMBALAGEM,0)  *  NVL(QUANTIDADE,0)),4) AS ESTOQUE,
                   ENTSAI_UNI_CODIGO,
                   ESTOQUE_UNI_CODIGO,
                   PRECO_TOTAL,
                   VL_CONTABIL,
                   VL_AJUSTE_PRECO_TOTAL,
                   VL_BASE_ICMS,
                   aliq_icms,
                   VL_ICMS,
                   CASE WHEN NVL(VL_ST,0) > 0 THEN vl_base_st ELSE 0 END vl_base_st, -- INCLUIDO REGRA NO DIA 01-06-2013 COM KARINA.
                   VL_ST,
                   aliq_stf,
                   VL_IPI,
                   STATUS,
                   MES_ANO_ARQUIVO,
                   ATUALIZAR_ESTOQUE
                FROM
                (
                  SELECT
                     -1 ID,
                     NFE.DOF_SEQUENCE,        -- CAMPO INDICA A ORDEM QUE A NOTA FOI GERADA
                     NFE.NUMERO DOF_NUMERO,
                     NFE.DOF_IMPORT_NUMERO,
                     NFE.EDOF_CODIGO,
                     NFE.MDOF_CODIGO,
                     NFE.SERIE_SUBSERIE serie,
                     F.FILIAL,
                     NFE.INFORMANTE_EST_CODIGO,
                     PV.CPF_CGC,
                     regexp_replace(PV.CPF_CGC,'[^[:digit:]]') CNPJ_FORNECEDOR,
                     NFE.DT_FATO_GERADOR_IMPOSTO,
                     NFE.dh_emissao,
                     NEI.CFOP_CODIGO,
                     C.OPERACAO,
                     CASE WHEN SUBSTR(NEI.CFOP_CODIGO,1,1) = '6' THEN 'N' ELSE 'S' END DENTRO_ESTADO,
                     NEI.STC_CODIGO,
                     ME.COD_BARRA,
                     NEI.NBM_CODIGO,
                     NEI.MERC_CODIGO,
                     ME.DESCRICAO,
                     NEI.IDF_NUM,
                     NFE.IND_ENTRADA_SAIDA MOV,
                     NEI.preco_unitario VL_Unit,
                     USRASSISTENTEFISCAL.FN_EXCEDENTE_FATORCONVERSAO(ME.MERC_CODIGO, NEI.ENTSAI_UNI_CODIGO, NFE.DT_FATO_GERADOR_IMPOSTO) EMBALAGEM, --NVL(MU.FAT_CONV_UNI_BAS_MERC,0) AS EMBALAGEM,
                     NEI.qtd QUANTIDADE,
                     NEI.ENTSAI_UNI_CODIGO,
                     NEI.ESTOQUE_UNI_CODIGO,
                     NEI.PRECO_TOTAL,
                     NEI.VL_CONTABIL,
                     NEI.VL_AJUSTE_PRECO_TOTAL,
                     CASE WHEN NVL(NEI.VL_ICMS,0) > 0 AND NVL(NEI.VL_OUTROS_ICMS,0) = 0 THEN NVL(NEI.VL_BASE_ICMS,0) ELSE NVL(NEI.VL_OUTROS_ICMS,0) END VL_BASE_ICMS,-- Foi trocado o campo após E-MAIL 09/05/2022 com Karina
                     NEI.aliq_icms,
                     NVL(NEI.VL_ICMS,0) VL_ICMS,
                     CASE WHEN  NVL(NEI.vl_base_stf,0) = 0 THEN NVL(NEI.vl_base_stf_fronteira,0) ELSE NVL(NEI.vl_base_stf,0) END AS vl_base_st,
                     CASE WHEN  NVL(NEI.VL_STF,0)    = 0 THEN NVL(NEI.VL_STF_FRONTEIRA,0) ELSE NVL(NEI.VL_STF,0)           END AS VL_ST,
                     NEI.aliq_stf,
                     NEI.VL_IPI,
                     CASE
                      WHEN  NFE.CTRL_SITUACAO_DOF = 'N' THEN 'AUTORIZADA'
                      WHEN  NFE.CTRL_SITUACAO_DOF = 'S' THEN 'CANCELADA'
                      WHEN  NFE.CTRL_SITUACAO_DOF = 'I' THEN 'INUTILIZADA'
                      WHEN  NFE.CTRL_SITUACAO_DOF = 'D' THEN 'DENEGADA'
                     END AS STATUS,
                     TO_CHAR(NFE.DT_FATO_GERADOR_IMPOSTO,'MMYYYY') MES_ANO_ARQUIVO,
                     0 AS ATUALIZAR_ESTOQUE
                  FROM SYNCHRO.COR_DOF NFE
                  INNER JOIN SYNCHRO.COR_IDF NEI                             ON   NEI.DOF_ID   = NFE.ID
                  INNER JOIN SYNCHRO.TBFILIAL F                              ON  (F.EST_CODIGO = NFE.INFORMANTE_EST_CODIGO  OR F.FILIAL = NFE.INFORMANTE_EST_CODIGO)
                  INNER JOIN USRASSISTENTEFISCAL.Excedente_MG_MERC D         ON   NEI.MERC_CODIGO = D.MERC_CODIGO AND F.FILIAL = D.FILIAL
                  LEFT  JOIN USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET U  ON   NFE.DOF_IMPORT_NUMERO = U.DOF_IMPORT_NUMERO AND NEI.MERC_CODIGO = U.MERC_CODIGO AND NEI.IDF_NUM = U.IDF_NUM
                  LEFT  JOIN SYNCHRO.GBA_ASSIST_CFOP C                       ON   NEI.CFOP_CODIGO = C.CFOP
                  LEFT  JOIN SYNCHRO.COR_MERCADORIA ME                       ON  (NEI.MERC_CODIGO = ME.MERC_CODIGO)
                  LEFT  JOIN SYNCHRO.COR_PESSOA P                            ON   P.PFJ_CODIGO    = NFE.emitente_pfj_codigo
                  LEFT  JOIN SYNCHRO.COR_PESSOA_VIGENCIA PV                  ON  (P.PFJ_CODIGO    = PV.PFJ_CODIGO AND PV.DT_FIM IS NULL)
                  WHERE
                    F.FILIAL = P_FILIAL
                    AND D.DT_INICIO = to_date(extract(year from P_DATA_GERADOR)||'/'||extract(month from P_DATA_GERADOR)||'/01','yyyy/mm/dd')
                    AND NFE.DT_FATO_GERADOR_IMPOSTO BETWEEN to_date(extract(year from P_DATA_GERADOR)||'/'||extract(month from P_DATA_GERADOR)||'/01','yyyy/mm/dd') AND LAST_DAY(P_DATA_GERADOR)
                    AND NFE.CTRL_SITUACAO_DOF        IN ('N','B')
                    AND 1 =
                    (
                      CASE
                        WHEN NEI.CFOP_CODIGO = '1.403'                                                             THEN 1
                        WHEN NEI.CFOP_CODIGO = '1.910'                                                           THEN 1
                        WHEN NEI.CFOP_CODIGO = '1.949' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70')                    THEN 1
                        WHEN NEI.CFOP_CODIGO = '2.403'                                                           THEN 1
                        WHEN NEI.CFOP_CODIGO = '1.409'                                                           THEN 1
                        WHEN NEI.CFOP_CODIGO = '2.409' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70')                    THEN 1
                        WHEN NEI.CFOP_CODIGO = '2.910' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70')                    THEN 1
                        WHEN NEI.CFOP_CODIGO = '2.923' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70')                    THEN 1
                        WHEN NEI.CFOP_CODIGO = '2.949' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70')                    THEN 1
                        WHEN NEI.CFOP_CODIGO = '3.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70')                    THEN 1
                        WHEN NEI.CFOP_CODIGO = '2.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '60' OR NEI.STC_CODIGO = '70')  THEN 1
                        WHEN NEI.CFOP_CODIGO = '1.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '60' OR NEI.STC_CODIGO = '70')  THEN 1
                        ELSE 0
                      END
                    )
                    -- CONSIDERAR SOMENTE SE TIVER VALOR DE ST. -- INCLUIDO DIA 18/05/2023 APÓS CONVERSA COM KARINA. O RELATÓRIO ESTAVA TENDO NOTAS SEM VALOR DE ST.
                    AND 1 = CASE
                              WHEN (NEI.CFOP_CODIGO = '1.409' OR NEI.CFOP_CODIGO = '2.409')   THEN 1 -- incluido dia 01-06-2023. Essas notas não estavam indo para o relatório. Deve ir independente se teve valor de ST
                              WHEN (NVL(NEI.VL_STF,0) > 0 OR NVL(NEI.VL_STF_FRONTEIRA,0) > 0) THEN 1
                              ELSE 0
                            END
                    AND U.DOF_IMPORT_NUMERO IS NULL
           )
       UNION ALL


select  ID,
                   DOF_SEQUENCE,
                   DOF_NUMERO,
                   DOF_IMPORT_NUMERO,
                   EDOF_CODIGO,
                   MDOF_CODIGO,
                   serie,
                   FILIAL,
                   INFORMANTE_EST_CODIGO,
                   CPF_CGC,
                   CNPJ_FORNECEDOR,
                   DT_FATO_GERADOR_IMPOSTO,
                   dh_emissao,
                   CFOP_CODIGO,
                   OPERACAO,
                   DENTRO_ESTADO,
                   STC_CODIGO,
                   COD_BARRA,
                   NBM_CODIGO,
                   MERC_CODIGO,
                   DESCRICAO,
                   IDF_NUM,
                   MOV,
                   VL_Unit,
                   EMBALAGEM,
                   QUANTIDADE,
                   VOLUME,
                   ESTOQUE,
                   ENTSAI_UNI_CODIGO,
                   ESTOQUE_UNI_CODIGO,
                   PRECO_TOTAL,
                   VL_CONTABIL,
                   VL_AJUSTE_PRECO_TOTAL,
                   VL_BASE_ICMS,
                   aliq_icms,
                   VL_ICMS,
                   vl_base_st,
                   VL_ST,
                   aliq_stf,
                   VL_IPI,
                   STATUS,
                   MES_ANO_ARQUIVO,
                   0 AS ATUALIZAR_ESTOQUE
                   from USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET
                   where
                        DT_FATO_GERADOR_IMPOSTO BETWEEN to_date(extract(year from P_DATA_GERADOR)||'/'||extract(month from P_DATA_GERADOR)||'/01','yyyy/mm/dd') AND LAST_DAY(P_DATA_GERADOR)
                        and filial = P_FILIAL
       ) AS USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
   ) INTO V_RET FROM DUAL;

   RETURN V_RET;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;

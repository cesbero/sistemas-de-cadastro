CREATE OR REPLACE FUNCTION USRASSISTENTEFISCAL.FN_EXCEDENTE_ENT(P_FILIAL IN VARCHAR2, P_DATA_VENDA IN DATE, P_DATA_CORTE IN DATE, P_MERC_CODIGO IN VARCHAR)
RETURN USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
 IS
  V_RET USRASSISTENTEFISCAL.T_EXCEDENTE_ENT;

BEGIN
        SELECT CAST (
              MULTISET (
          SELECT *
          FROM
          (
            SELECT
              E.id, dof_sequence,dof_numero,dof_import_numero,EDOF_CODIGO,mdof_codigo,serie,filial,INFORMANTE_EST_CODIGO,cpf_cgc,cnpj_fornecedor,dt_fato_gerador_imposto,dh_emissao,cfop_codigo,operacao,DENTRO_ESTADO,stc_codigo,cod_barra,nbm_codigo,merc_codigo,descricao,idf_num,mov,vl_unit,embalagem,quantidade,volume,ESTOQUE,entsai_uni_codigo,estoque_uni_codigo,preco_total,vl_contabil,vl_ajuste_preco_total,vl_base_icms,aliq_icms,vl_icms,vl_base_st,vl_st,aliq_stf,vl_ipi,status,MES_ANO_ARQUIVO, 1 AS ATUALIZAR_ESTOQUE
            FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET E
            WHERE
              E.FILIAL                       = P_FILIAL
              AND E.MERC_CODIGO              = P_MERC_CODIGO
              AND E.DT_FATO_GERADOR_IMPOSTO <= P_DATA_VENDA
              AND E.ESTOQUE          > 0
            ORDER BY DT_FATO_GERADOR_IMPOSTO ASC
          )
          WHERE ROWNUM < 2

                ) AS USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
        ) INTO V_RET FROM DUAL;


    -- Tratar situacao onde a nota pode ter outros lancamentos com IDF_NUM diferente
    IF V_RET.COUNT <= 0
    THEN
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
                  FROM
                  (
                    SELECT
                      E.DT_FATO_GERADOR_IMPOSTO, dof_import_numero, merc_codigo
                    FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET E
                    WHERE
                      E.FILIAL                       = P_FILIAL
                      AND E.MERC_CODIGO              = P_MERC_CODIGO
                      AND E.DT_FATO_GERADOR_IMPOSTO <= P_DATA_VENDA
                      AND E.ativo = '1'
                  ) D
                  INNER JOIN SYNCHRO.COR_DOF NFE                 ON D.dof_import_numero = NFE.dof_import_numero
                  INNER JOIN SYNCHRO.COR_IDF NEI                             ON   NEI.DOF_ID   = NFE.ID AND D.MERC_CODIGO = NEI.MERC_CODIGO
                  INNER JOIN SYNCHRO.TBFILIAL F                              ON  (F.EST_CODIGO = NFE.INFORMANTE_EST_CODIGO  OR F.FILIAL = NFE.INFORMANTE_EST_CODIGO)
                  LEFT  JOIN USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET U  ON   NFE.DOF_IMPORT_NUMERO = U.DOF_IMPORT_NUMERO AND NEI.MERC_CODIGO = U.MERC_CODIGO AND NEI.IDF_NUM = U.IDF_NUM
                  LEFT  JOIN SYNCHRO.GBA_ASSIST_CFOP C                       ON   NEI.CFOP_CODIGO = C.CFOP
                  LEFT  JOIN SYNCHRO.COR_MERCADORIA ME                       ON  (NEI.MERC_CODIGO = ME.MERC_CODIGO)
                  LEFT  JOIN SYNCHRO.COR_PESSOA P                            ON   P.PFJ_CODIGO    = NFE.emitente_pfj_codigo
                  LEFT  JOIN SYNCHRO.COR_PESSOA_VIGENCIA PV                  ON  (P.PFJ_CODIGO    = PV.PFJ_CODIGO AND PV.DT_FIM IS NULL)
                  WHERE
                    U.DOF_IMPORT_NUMERO IS NULL
                   ORDER BY NFE.DT_FATO_GERADOR_IMPOSTO, NEI.IDF_NUM ASC
           ) WHERE ROWNUM < 2
        ) AS USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
      ) INTO V_RET FROM DUAL;

      END;
    END IF;

        IF V_RET.COUNT <= 0
        THEN
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
                     0 ID,
                     NFE.DOF_SEQUENCE,        -- CAMPO INDICA A ORDEM QUE A NOTA FOI GERADA
                     --SYNCHRO.GBA_FORMAT_NOTA_SINTEGRA(NFE.NUMERO) NOTA,
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
                     --ROUND((NVL(MU.FAT_CONV_UNI_BAS_MERC,0)  *  NVL(NEI.qtd,0)),4) AS VOLUME,
                     --ROUND((NVL(MU.FAT_CONV_UNI_BAS_MERC,0)  *  NVL(NEI.qtd,0)),4) AS ESTOQUE,
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
                  INNER JOIN SYNCHRO.COR_IDF NEI                           ON   NEI.DOF_ID   = NFE.ID
                  INNER JOIN SYNCHRO.TBFILIAL F                            ON  (F.EST_CODIGO = NFE.INFORMANTE_EST_CODIGO  OR F.FILIAL = NFE.INFORMANTE_EST_CODIGO)
                  LEFT JOIN USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET U ON   NFE.DOF_IMPORT_NUMERO = U.DOF_IMPORT_NUMERO AND NEI.MERC_CODIGO = U.MERC_CODIGO AND NEI.IDF_NUM = U.IDF_NUM
                  LEFT  JOIN SYNCHRO.GBA_ASSIST_CFOP C                     ON   NEI.CFOP_CODIGO = C.CFOP
                  LEFT  JOIN SYNCHRO.COR_MERCADORIA ME                     ON  (NEI.MERC_CODIGO = ME.MERC_CODIGO)
                  --LEFT  JOIN synchro.cor_unidade_mercadoria MU            ON  (ME.MERC_CODIGO  = MU.merc_codigo AND NEI.ENTSAI_UNI_CODIGO = MU.UNI_CODIGO)
                  LEFT  JOIN SYNCHRO.COR_PESSOA P                          ON   P.PFJ_CODIGO    = NFE.emitente_pfj_codigo
                  LEFT  JOIN SYNCHRO.COR_PESSOA_VIGENCIA PV                ON  (P.PFJ_CODIGO    = PV.PFJ_CODIGO AND PV.DT_FIM IS NULL)
                  WHERE
                    (NFE.DOF_IMPORT_NUMERO, NEI.MERC_CODIGO)   = (
                                            SELECT
                                              DOF_IMPORT_NUMERO, MERC_CODIGO
                                            FROM
                                            (
                                              SELECT
                                                NEI2.MERC_CODIGO,NFE2.DOF_IMPORT_NUMERO, MIN(NFE2.DT_FATO_GERADOR_IMPOSTO) MIN_DATA
                                              FROM SYNCHRO.COR_DOF NFE2
                                              INNER JOIN SYNCHRO.COR_IDF NEI2 ON   NEI2.DOF_ID   = NFE2.ID
                                              INNER JOIN SYNCHRO.TBFILIAL F2                            ON  (F2.EST_CODIGO = NFE2.INFORMANTE_EST_CODIGO  OR F2.FILIAL = NFE2.INFORMANTE_EST_CODIGO)
                                              LEFT JOIN USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET U2 ON   NFE2.DOF_IMPORT_NUMERO = U2.DOF_IMPORT_NUMERO AND NEI2.MERC_CODIGO = U2.MERC_CODIGO AND NEI2.IDF_NUM = U2.IDF_NUM
                                              WHERE
                                                  F2.FILIAL                         = P_FILIAL
                                                  AND NEI2.MERC_CODIGO              = P_MERC_CODIGO
                                                  AND NFE2.DT_FATO_GERADOR_IMPOSTO BETWEEN P_DATA_CORTE AND P_DATA_VENDA
                                                  AND NFE2.CTRL_SITUACAO_DOF        IN ('N','B')
                                                  AND 1 =
                                                  (
                                                    CASE
                                                      WHEN NEI2.CFOP_CODIGO = '1.403'                                                             THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '1.910'                                                           THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '1.949' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '70')                    THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '2.403'                                                           THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '1.409'                                                           THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '2.409' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '70')                    THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '2.910' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '70')                    THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '2.923' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '70')                    THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '2.949' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '70')                    THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '3.102' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '70')                    THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '2.102' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '60' OR NEI2.STC_CODIGO = '70')  THEN 1
                                                      WHEN NEI2.CFOP_CODIGO = '1.102' AND (NEI2.STC_CODIGO = '10' OR NEI2.STC_CODIGO = '60' OR NEI2.STC_CODIGO = '70')  THEN 1
                                                      ELSE 0
                                                    END
                                                  )

                                                 -- LIMITANDO A BUSCA À 2 ANOS. ALTERAÇÃO FEITA APÓS CONVERSA COM KARINA (16/09/2022)
                                                  AND 1 = CASE WHEN MONTHS_BETWEEN (P_DATA_VENDA, NFE2.DT_FATO_GERADOR_IMPOSTO) < 24 THEN 1 ELSE 0 END

                                                  -- CONSIDERAR SOMENTE SE TIVER VALOR DE ST. -- INCLUIDO DIA 18/05/2023 APÓS CONVERSA COM KARINA. O RELATÓRIO ESTAVA TENDO NOTAS SEM VALOR DE ST.
                                                  AND 1 =  CASE
                                                          WHEN (NEI2.CFOP_CODIGO = '1.409' OR NEI2.CFOP_CODIGO = '2.409')   THEN 1 -- incluido dia 01-06-2023. Essas notas não estavam indo para o relatório. Deve ir independente se teve valor de ST
                                                          WHEN (NVL(NEI2.VL_STF,0) > 0 OR NVL(NEI2.VL_STF_FRONTEIRA,0) > 0) THEN 1
                                                          ELSE 0
                                                       END

                                                AND U2.DOF_IMPORT_NUMERO IS NULL

                                                GROUP BY NEI2.MERC_CODIGO,NFE2.DOF_IMPORT_NUMERO
                                                ORDER BY MIN_DATA
                                            )WHERE ROWNUM < 2
                  )
                  AND U.DOF_IMPORT_NUMERO IS NULL
                   ORDER BY NFE.DT_FATO_GERADOR_IMPOSTO, NEI.IDF_NUM ASC
                ) WHERE ROWNUM < 2

      ) AS USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
        ) INTO V_RET FROM DUAL;
          END;
        END IF;


   RETURN V_RET;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;

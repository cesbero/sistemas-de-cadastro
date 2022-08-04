


CREATE OR REPLACE TYPE USRASSISTENTEFISCAL."T_TBEXCEDENTE_ENT" AS OBJECT (
  dof_sequence            NUMBER(15),  
  dof_numero              VARCHAR2(60),
  dof_import_numero       VARCHAR2(40),
  EDOF_CODIGO             VARCHAR2(10),
  mdof_codigo             VARCHAR2(2),
  serie               VARCHAR2(6),
  filial                  VARCHAR2(3),
  INFORMANTE_EST_CODIGO   VARCHAR2(20),
  cpf_cgc                 VARCHAR2(19),
  cnpj_fornecedor         VARCHAR2(19),
  dt_fato_gerador_imposto DATE,
  dh_emissao        DATE,
  cfop_codigo             VARCHAR2(8),
  operacao          VARCHAR2(100),  
  DENTRO_ESTADO           VARCHAR2(1),
  stc_codigo              VARCHAR2(2),
  cod_barra               VARCHAR2(255),  
  nbm_codigo              VARCHAR2(20),
  merc_codigo             VARCHAR2(60),
  descricao               VARCHAR2(255),
  idf_num                 NUMBER(6),
  mov                     VARCHAR2(1),
  vl_unit                 NUMBER,
  embalagem               NUMBER(19,2),
  quantidade              NUMBER(19,2),
  volume                  NUMBER(19,2),
  estoque                 NUMBER(19,2),
  entsai_uni_codigo       VARCHAR2(6),
  estoque_uni_codigo      VARCHAR2(6),
  preco_total             NUMBER(19,2),
  vl_contabil             NUMBER(19,2),
  vl_ajuste_preco_total   NUMBER(19,2),
  vl_base_icms            NUMBER(19,2),
  aliq_icms               NUMBER(15,4),
  vl_icms                 NUMBER(19,2),
  vl_base_st              NUMBER(19,2),
  vl_st                   NUMBER(19,2),
  aliq_stf                NUMBER(15,4),
  vl_ipi                  NUMBER(19,2),
  status                  VARCHAR2(11),
  MES_ANO_ARQUIVO     	  VARCHAR2(6),
  ATUALIZAR_ESTOQUE       INT
);

CREATE OR REPLACE TYPE USRASSISTENTEFISCAL.T_EXCEDENTE_ENT  AS TABLE OF USRASSISTENTEFISCAL.T_TBEXCEDENTE_ENT;



CREATE OR REPLACE FUNCTION USRASSISTENTEFISCAL.FN_EXCEDENTE_ENT(P_FILIAL IN VARCHAR2, P_DATA IN DATE, P_MERC_CODIGO IN VARCHAR)
RETURN USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
 IS
  V_RET USRASSISTENTEFISCAL.T_EXCEDENTE_ENT;  

BEGIN			 
        SELECT CAST (
              MULTISET (
                    SELECT
                      dof_sequence,dof_numero,dof_import_numero,EDOF_CODIGO,mdof_codigo,serie,filial,INFORMANTE_EST_CODIGO,cpf_cgc,cnpj_fornecedor,dt_fato_gerador_imposto,dh_emissao,cfop_codigo,operacao,DENTRO_ESTADO,stc_codigo,cod_barra,nbm_codigo,merc_codigo,descricao,idf_num,mov,vl_unit,embalagem,quantidade,volume,ESTOQUE,entsai_uni_codigo,estoque_uni_codigo,preco_total,vl_contabil,vl_ajuste_preco_total,vl_base_icms,aliq_icms,vl_icms,vl_base_st,vl_st,aliq_stf,vl_ipi,status,MES_ANO_ARQUIVO, 1 AS ATUALIZAR_ESTOQUE
                    FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET E
                    WHERE
                      E.FILIAL                       = P_FILIAL
                      AND E.MERC_CODIGO              = P_MERC_CODIGO
                      AND E.DT_FATO_GERADOR_IMPOSTO <= P_DATA
                      AND E.ESTOQUE 				 > 0
                ) AS USRASSISTENTEFISCAL.T_EXCEDENTE_ENT
        ) INTO V_RET FROM DUAL;

        IF V_RET.COUNT <= 0
        THEN
          BEGIN
            SELECT CAST (
						 MULTISET (
									SELECT * 
									FROM
									(
									  SELECT
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
										   NVL(MU.FAT_CONV_UNI_BAS_MERC,0) AS EMBALAGEM,
										   NEI.qtd QUANTIDADE,
										   ROUND((NVL(MU.FAT_CONV_UNI_BAS_MERC,0)  *  NVL(NEI.qtd,0)),4) AS VOLUME,
										   ROUND((NVL(MU.FAT_CONV_UNI_BAS_MERC,0)  *  NVL(NEI.qtd,0)),4) AS ESTOQUE,
										   NEI.ENTSAI_UNI_CODIGO,
										   NEI.ESTOQUE_UNI_CODIGO,
										   NEI.PRECO_TOTAL,
										   NEI.VL_CONTABIL,
										   NEI.VL_AJUSTE_PRECO_TOTAL,
										   CASE WHEN NVL(NEI.VL_ICMS,0) > 0 AND NVL(NEI.VL_OUTROS_ICMS,0) = 0 THEN NVL(NEI.VL_BASE_ICMS,0) ELSE NVL(NEI.VL_OUTROS_ICMS,0) END VL_BASE_ICMS,-- Foi trocado o campo após E-MAIL 09/05/2022 com Karina
										   NEI.aliq_icms,
										   NVL(NEI.VL_ICMS,0) VL_ICMS,
										   CASE WHEN  NVL(NEI.vl_base_stf,0) = 0 THEN NVL(NEI.vl_base_stf_fronteira,0) ELSE NVL(NEI.vl_base_stf,0) END AS vl_base_st,
										   CASE WHEN  NVL(NEI.VL_STF,0) = 0 THEN NVL(NEI.VL_STF_FRONTEIRA,0) ELSE NVL(NEI.VL_STF,0)          END AS VL_ST,
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
									  INNER JOIN SYNCHRO.COR_IDF NEI                       		ON   NEI.DOF_ID   = NFE.ID
									  INNER JOIN SYNCHRO.TBFILIAL F                        		ON  (F.EST_CODIGO = NFE.INFORMANTE_EST_CODIGO  OR F.FILIAL = NFE.INFORMANTE_EST_CODIGO)
									  LEFT JOIN USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET U 	ON   NFE.DOF_IMPORT_NUMERO = U.DOF_IMPORT_NUMERO AND NEI.MERC_CODIGO = U.MERC_CODIGO AND NEI.IDF_NUM = U.IDF_NUM
									  LEFT  JOIN SYNCHRO.GBA_ASSIST_CFOP C                 		ON   NEI.CFOP_CODIGO = C.CFOP
									  LEFT  JOIN SYNCHRO.COR_MERCADORIA ME                 		ON  (NEI.MERC_CODIGO = ME.MERC_CODIGO)
									  LEFT  JOIN synchro.cor_unidade_mercadoria MU         		ON  (ME.MERC_CODIGO  = MU.merc_codigo AND NEI.ENTSAI_UNI_CODIGO = MU.UNI_CODIGO)
									  LEFT  JOIN SYNCHRO.COR_PESSOA P                      		ON   P.PFJ_CODIGO 	 = NFE.emitente_pfj_codigo
									  LEFT  JOIN SYNCHRO.COR_PESSOA_VIGENCIA PV            		ON  (P.PFJ_CODIGO 	 = PV.PFJ_CODIGO AND PV.DT_FIM IS NULL)
									  WHERE						  
									  F.FILIAL                		   = P_FILIAL
									  AND NFE.DT_FATO_GERADOR_IMPOSTO <= P_DATA
									  AND NEI.MERC_CODIGO       	   = P_MERC_CODIGO						  
									  AND NFE.CTRL_SITUACAO_DOF 	   = 'N'      
									  AND 1 = 
										  (
											  CASE 
											  WHEN NEI.CFOP_CODIGO = '1.403' 													  							THEN 1                
											  WHEN NEI.CFOP_CODIGO = '1.910' 													 							THEN 1  
											  WHEN NEI.CFOP_CODIGO = '1.949' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') 							THEN 1  
											  WHEN NEI.CFOP_CODIGO = '2.403' 																				THEN 1     
											  WHEN NEI.CFOP_CODIGO = '2.409' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') 							THEN 1                 
											  WHEN NEI.CFOP_CODIGO = '2.910' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') 							THEN 1      
											  WHEN NEI.CFOP_CODIGO = '2.923' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') 							THEN 1        
											  WHEN NEI.CFOP_CODIGO = '2.949' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') 							THEN 1          
											  WHEN NEI.CFOP_CODIGO = '3.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') 							THEN 1
											  WHEN NEI.CFOP_CODIGO = '2.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '60' OR NEI.STC_CODIGO = '70') 	THEN 1        
											  WHEN NEI.CFOP_CODIGO = '1.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '60' OR NEI.STC_CODIGO = '70') 	THEN 1
											  ELSE 0
											  END
										  )
									 AND U.DOF_IMPORT_NUMERO IS NULL
									 ORDER BY NFE.DT_FATO_GERADOR_IMPOSTO DESC
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




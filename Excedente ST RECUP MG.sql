
ECF  - LOJA DATA PDV
NFCE - LOJA DATA (DT_EMISSAO) PDV NUMERO NFCE (NUM_ORDEM_DOC)

NFCE MIGROU 2017


TRUNCATE TABLE USRASSISTENTEFISCAL.Excedente_MG_MERC; 
TRUNCATE TABLE USRASSISTENTEFISCAL.EXCEDENTE_MG_SAIDA_DET;
TRUNCATE TABLE USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET;  
TRUNCATE TABLE USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT;
TRUNCATE TABLE USRASSISTENTEFISCAL.Excedente_MG_LOG;

-- Create table
create table USRASSISTENTEFISCAL.GBA_RECUP_ST_saida_Exc_Temp
(
  empresa           VARCHAR2(10),
  uf                VARCHAR2(2),
  filial            VARCHAR2(4),
  est_codigo        VARCHAR2(20),
  data              DATE,
  mov               CHAR(1),
  dof_numero        VARCHAR2(30),
  dof_import_numero VARCHAR2(23),
  serie             VARCHAR2(3),
  stc_codigo        VARCHAR2(2),
  modelo            VARCHAR2(2),
  sit_tribut        VARCHAR2(4),
  merc_codigo       VARCHAR2(60),
  descricao         VARCHAR2(255),
  num_item          NUMBER(3),
  cfop_codigo       VARCHAR2(8),
  uni_codigo        VARCHAR2(6),  
  qtd               NUMBER(15,4),
  vl_unitario       NUMBER(19,2),
  fat_conversao     NUMBER(19,2),
  volume            NUMBER(15,4),
  vl_contabil       NUMBER(19,2),  
  status            VARCHAR2(11),
  chave_acesso      VARCHAR2(44),  
  mes_ano_arquivo   VARCHAR2(6)
);

create table USRASSISTENTEFISCAL.Excedente_MG_LOG
(  
  REC_ID            NUMBER,
  DET_ID            NUMBER,
  ID_ENTRADA 		NUMBER,
  PASSO        		VARCHAR2(30),
  filial            VARCHAR2(4),   
  merc_codigo       VARCHAR2(60),
  data              DATE,
  volume_ENT        NUMBER(19,2),
  volume_SAIDA      NUMBER(19,2),
  SALDO_SAIDA       NUMBER(19,2),
  ESTOQUE           NUMBER(19,2),
  ATUALIZAR_ESTOQUE NUMBER
)
tablespace syndata nologging;


-- Create table

create table USRASSISTENTEFISCAL.GBA_RECUP_ST_SAIDA_EXCEDENTE
(
  empresa           VARCHAR2(10),
  uf                VARCHAR2(2),
  filial            VARCHAR2(4),
  est_codigo        VARCHAR2(14),
  data              DATE,
  mov               VARCHAR2(1),
  dof_numero        VARCHAR2(60),
  dof_import_numero VARCHAR2(23),
  serie             VARCHAR2(6),
  stc_codigo        VARCHAR2(2),
  modelo            VARCHAR2(2),
  sit_tribut        CHAR(1),
  merc_codigo       VARCHAR2(60),
  descricao         VARCHAR2(255),
  num_item          NUMBER(6),
  cfop_codigo       VARCHAR2(8),
  uni_codigo        VARCHAR2(6),
  qtd               NUMBER,
  vl_unitario       NUMBER,
  fat_conversao     NUMBER,
  volume            NUMBER,
  vl_contabil       NUMBER(19,2),
  status            VARCHAR2(11),
  chave_acesso      VARCHAR2(50),
  mes_ano_arquivo   VARCHAR2(6)
)
tablespace SYNDATA nologging;

create index USRASSISTENTEFISCAL.I_RECUP_ST_SAIDA_EX1 on USRASSISTENTEFISCAL.GBA_RECUP_ST_SAIDA_EXCEDENTE (FILIAL, DATA);
create index USRASSISTENTEFISCAL.I_RECUP_ST_SAIDA_EX2 on USRASSISTENTEFISCAL.GBA_RECUP_ST_SAIDA_EXCEDENTE (FILIAL, MERC_CODIGO);
  

create table USRASSISTENTEFISCAL.Excedente_MG_MERC
(
  rec_id          INTEGER primary key,  
  filial          INTEGER 		not null,  
  DT_INICIO  	  DATE 			not null,
  DT_TERMINO 	  DATE 			not null,
  merc_codigo     VARCHAR2(60) 	not null,
  VL_MEDIA        NUMBER(19,2),
  estoque_inicial NUMBER(19,2),
  estoque_final   NUMBER(19,2),
  DT_REGISTRO 	  DATE
)
tablespace SYNDATA NOLOGGING;
-- Create/Recreate indexes 
create index USRASSISTENTEFISCAL.I_Excedente_MG_MERC1 on USRASSISTENTEFISCAL.Excedente_MG_MERC (merc_codigo);
create index USRASSISTENTEFISCAL.I_Excedente_MG_MERC2 on USRASSISTENTEFISCAL.Excedente_MG_MERC (DT_INICIO);
create index USRASSISTENTEFISCAL.I_Excedente_MG_MERC3 on USRASSISTENTEFISCAL.Excedente_MG_MERC (filial);
create index USRASSISTENTEFISCAL.I_Excedente_MG_MERC4 on USRASSISTENTEFISCAL.Excedente_MG_MERC (filial,merc_codigo,DT_INICIO);


create table USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT
(  
  REC_ID            NUMBER,
  DET_ID            NUMBER,
  ID_ENTRADA 		NUMBER,
  filial            VARCHAR2(4),   
  volume            NUMBER(19,2),
  VL_BC_ST          NUMBER(19,2),
  VL_BC_ST_UNIT		NUMBER(19,2),
  DT_FATO_GERADOR   DATE,
  DT_REGISTRO 		DATE
)
tablespace syndata nologging;




create table USRASSISTENTEFISCAL.EXCEDENTE_MG_SAIDA_DET
(
  REC_ID            NUMBER,
  DET_ID            NUMBER,
  empresa           VARCHAR2(10),
  uf                VARCHAR2(2),
  filial            VARCHAR2(4),
  data              DATE,
  dof_numero        VARCHAR2(9),
  dof_import_numero VARCHAR2(23),
  merc_codigo       VARCHAR2(60),
  descricao         VARCHAR2(255),
  num_item          NUMBER(3),
  cfop_codigo       VARCHAR2(8),
  qtd               NUMBER(19,2),
  vl_unitario       NUMBER(19,2),
  volume            NUMBER(19,2),
  vl_contabil       NUMBER(19,2),
  VL_BASE_ST_UNIT	NUMBER(19,2),
  VL_BASE_ST_VENDA	NUMBER(19,2),
  VL_DIF_BASE		NUMBER(19,2),
  VL_CREDITO		NUMBER(19,2),
  status            VARCHAR2(11),
  DT_REGISTRO 		DATE
)
tablespace SYNDATA nologging;

create table USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET
(
  id                      NUMBER,
  dof_sequence            NUMBER(15) not null,
  dof_numero              VARCHAR2(60),
  dof_import_numero       VARCHAR2(23) not null,
  edof_codigo             VARCHAR2(10),
  mdof_codigo             VARCHAR2(2),
  serie                   VARCHAR2(6) not null,
  filial                  VARCHAR2(3),
  informante_est_codigo   VARCHAR2(20),
  cpf_cgc                 VARCHAR2(19),
  cnpj_fornecedor         VARCHAR2(19),
  dt_fato_gerador_imposto DATE,
  dh_emissao              DATE,
  cfop_codigo             VARCHAR2(8),
  operacao                VARCHAR2(100),
  dentro_estado           VARCHAR2(1),
  stc_codigo              VARCHAR2(2),
  cod_barra               VARCHAR2(255),
  nbm_codigo              VARCHAR2(20),
  merc_codigo             VARCHAR2(60),
  descricao               VARCHAR2(255),
  idf_num                 NUMBER(6) not null,
  mov                     VARCHAR2(1) not null,
  vl_unit                 NUMBER not null,
  embalagem               NUMBER(19,2),
  quantidade              NUMBER(19,2) not null,
  volume                  NUMBER(19,2),
  estoque                 NUMBER(19,2),
  entsai_uni_codigo       VARCHAR2(6),
  estoque_uni_codigo      VARCHAR2(6),
  preco_total             NUMBER(19,2) not null,
  vl_contabil             NUMBER(19,2) not null,
  vl_ajuste_preco_total   NUMBER(19,2) not null,
  vl_base_icms            NUMBER(19,2) not null,
  aliq_icms               NUMBER(15,4) not null,
  vl_icms                 NUMBER(19,2) not null,
  vl_base_st              NUMBER(19,2),
  vl_st                   NUMBER(19,2),
  aliq_stf                NUMBER(15,4) not null,
  vl_ipi                  NUMBER(19,2) not null,
  vl_BC_ST_UNIT           NUMBER(19,2) not null,  
  status                  VARCHAR2(11),
  mes_ano_arquivo         VARCHAR2(6) not null,
  DT_REGISTRO 			  DATE
)
tablespace SYNDATA  nologging;

create index USRASSISTENTEFISCAL.I_EXCEDENTE_MG_ENTRADA_DET1 on USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET (FILIAL, DT_FATO_GERADOR_IMPOSTO, MERC_CODIGO);
create index USRASSISTENTEFISCAL.I_EXCEDENTE_MG_ENTRADA_DET2 on USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET (DOF_IMPORT_NUMERO, MERC_CODIGO, IDF_NUM);  




-- Entrada
TRUNCATE TABLE USRASSISTENTEFISCAL.RecupExcedenteMG_ENT

DECLARE
  V_DATA_FINAL   DATE;
  V_DATA_INICIAL DATE;
  V_FILIAL VARCHAR2(4);
     
BEGIN
  V_DATA_INICIAL   := TO_DATE('2016/12/01','YYYY/MM/DD');
  V_DATA_FINAL     := TO_DATE('2016/12/31','YYYY/MM/DD');  
  V_FILIAL         := '535';
  
  WHILE V_DATA_INICIAL <= V_DATA_FINAL
  LOOP    
      Begin 
     INSERT INTO USRASSISTENTEFISCAL.RecupExcedenteMG_ENT
     SELECT     
         NFE.DOF_SEQUENCE,        -- CAMPO INDICA A ORDEM QUE A NOTA FOI GERADA        
         --SYNCHRO.GBA_FORMAT_NOTA_SINTEGRA(NFE.NUMERO) NOTA,
         NFE.NUMERO DOF_NUMERO,    
         NFE.DOF_IMPORT_NUMERO,
         NFE.EDOF_CODIGO,
         NFE.MDOF_CODIGO,
         NFE.SERIE_SUBSERIE,
         
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
              
         NEI.ENTSAI_UNI_CODIGO, 
         NEI.ESTOQUE_UNI_CODIGO,

         NEI.PRECO_TOTAL,
         NEI.VL_CONTABIL,
         NEI.VL_AJUSTE_PRECO_TOTAL,
		 CASE WHEN NVL(NEI.VL_ICMS,0) > 0 AND NVL(NEI.VL_OUTROS_ICMS,0) = 0 THEN NVL(NEI.VL_BASE_ICMS,0) ELSE NVL(NEI.VL_OUTROS_ICMS,0) END VL_BASE_ICMS,-- Foi trocado o campo após E-MAIL 09/05/2022 com Karina
         NEI.aliq_icms, 
         NVL(NEI.VL_ICMS,0) VL_ICMS,    
         CASE WHEN  NVL(NEI.vl_base_stf,0) = 0 THEN NVL(NEI.vl_base_stf_fronteira,0) ELSE NVL(NEI.vl_base_stf,0) END AS vl_base_st,    
         CASE WHEN  NVL(NEI.VL_STF,0) = 0 THEN NVL(NEI.VL_STF_FRONTEIRA,0) ELSE NVL(NEI.VL_STF,0) 				 END AS VL_ST,
         NEI.aliq_stf,
         NEI.VL_IPI,     
         CASE
          WHEN  NFE.CTRL_SITUACAO_DOF = 'N' THEN 'AUTORIZADA'
          WHEN  NFE.CTRL_SITUACAO_DOF = 'S' THEN 'CANCELADA'
          WHEN  NFE.CTRL_SITUACAO_DOF = 'I' THEN 'INUTILIZADA'
          WHEN  NFE.CTRL_SITUACAO_DOF = 'D' THEN 'DENEGADA'
         END AS STATUS,
		 TO_CHAR(NFE.DT_FATO_GERADOR_IMPOSTO,'MMYYYY') MES_ANO_ARQUIVO
    FROM
    SYNCHRO.COR_DOF NFE
    INNER JOIN SYNCHRO.COR_IDF NEI                   ON   NEI.DOF_ID = NFE.ID
  --INNER JOIN USRASSISTENTEFISCAL.gba_merc G     ON  NEI.MERC_CODIGO = G.MERC
    INNER JOIN SYNCHRO.TBFILIAL F                    ON  (F.EST_CODIGO = NFE.INFORMANTE_EST_CODIGO  OR F.FILIAL = NFE.INFORMANTE_EST_CODIGO)
	LEFT JOIN SYNCHRO.GBA_ASSIST_CFOP C				 ON   NEI.CFOP_CODIGO = C.CFOP
    LEFT  JOIN SYNCHRO.COR_MERCADORIA ME             ON  (NEI.MERC_CODIGO  = ME.MERC_CODIGO)
    LEFT  JOIN synchro.cor_unidade_mercadoria MU     ON  (ME.MERC_CODIGO = MU.merc_codigo AND NEI.ENTSAI_UNI_CODIGO = MU.UNI_CODIGO)
    LEFT  JOIN SYNCHRO.GBA_RECUP_MERC_LEGADOXSAP X   ON  (NEI.MERC_CODIGO = X.COD_PRODUTO_SAP_R)
    LEFT  JOIN SYNCHRO.COR_PESSOA P                  ON   P.PFJ_CODIGO = NFE.emitente_pfj_codigo
    LEFT  JOIN SYNCHRO.COR_PESSOA_VIGENCIA PV        ON  (P.PFJ_CODIGO = PV.PFJ_CODIGO AND PV.DT_FIM IS NULL)
    WHERE
     NFE.DT_FATO_GERADOR_IMPOSTO = V_DATA_INICIAL
     AND F.FILIAL 				 = V_FILIAL
	 AND NFE.CTRL_SITUACAO_DOF   ='N'  -- Nota Autorizada        
     AND
        1 = 
        (
        CASE 
        WHEN NEI.CFOP_CODIGO = '1.403' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1                
        WHEN NEI.CFOP_CODIGO = '1.910' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1  
        WHEN NEI.CFOP_CODIGO = '1.949' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1  
        WHEN NEI.CFOP_CODIGO = '2.403' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1     
        WHEN NEI.CFOP_CODIGO = '2.409' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1                 
        WHEN NEI.CFOP_CODIGO = '2.910' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1      
        WHEN NEI.CFOP_CODIGO = '2.923' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1        
        WHEN NEI.CFOP_CODIGO = '2.949' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1          
        WHEN NEI.CFOP_CODIGO = '3.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '70') THEN 1
        WHEN NEI.CFOP_CODIGO = '2.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '60' OR NEI.STC_CODIGO = '70') THEN 1        
        WHEN NEI.CFOP_CODIGO = '1.102' AND (NEI.STC_CODIGO = '10' OR NEI.STC_CODIGO = '60' OR NEI.STC_CODIGO = '70') THEN 1
      ELSE 0
        END
        );
      
        COMMIT;
          
        EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
      END;
        
      V_DATA_INICIAL := V_DATA_INICIAL + 1;
    
  END LOOP;
END;






-- Saída
TRUNCATE TABLE  USRASSISTENTEFISCAL.GBA_RECUP_ST_SAIDA_EXCEDENTE;

DECLARE
  V_DATA_FINAL   DATE;
  V_DATA_INICIAL DATE;
  V_FILIAL       VARCHAR2(4);   
BEGIN
  V_DATA_INICIAL   := TO_DATE('2016/12/01','YYYY/MM/DD');
  V_DATA_FINAL     := TO_DATE('2016/12/31','YYYY/MM/DD');  
  V_FILIAL         := '535';
  WHILE V_DATA_INICIAL <= V_DATA_FINAL
  LOOP    
      Begin 
		 INSERT INTO USRASSISTENTEFISCAL.GBA_RECUP_ST_saida_EXCEDENTE
		 SELECT  			 
			F.EMPRESA,
			F.UF,        
			F.FILIAL,    
			F.EST_CODIGO,
			NFE.DT_FATO_GERADOR_IMPOSTO DATA,
			NFE.IND_ENTRADA_SAIDA MOV,
			NFE.NUMERO DOF_NUMERO,    
			NFE.DOF_IMPORT_NUMERO,
			NFE.SERIE_SUBSERIE SERIE,
			NEI.STC_CODIGO,     
			-- NFE.EDOF_CODIGO,
			NFE.MDOF_CODIGO MODELO,
			'F' SIT_TRIBUT,            			
			NEI.MERC_CODIGO,
			ME.DESCRICAO,   
			NEI.IDF_NUM NUM_ITEM,
			NEI.CFOP_CODIGO, 
			NEI.ENTSAI_UNI_CODIGO UNI_CODIGO, 
			NEI.qtd,
			NEI.preco_unitario VL_Unitario,
			NVL(MU.FAT_CONV_UNI_BAS_MERC,0) AS FAT_CONVERSAO,
			ROUND((NVL(MU.FAT_CONV_UNI_BAS_MERC,0)  *  NVL(NEI.qtd,0)),4) AS VOLUME,
			NEI.PRECO_TOTAL VL_CONTABIL, --NEI.VL_CONTABIL,     			                
			CASE
			WHEN  NFE.CTRL_SITUACAO_DOF = 'N' THEN 'AUTORIZADA'
			WHEN  NFE.CTRL_SITUACAO_DOF = 'S' THEN 'CANCELADA'
			WHEN  NFE.CTRL_SITUACAO_DOF = 'I' THEN 'INUTILIZADA'
			WHEN  NFE.CTRL_SITUACAO_DOF = 'D' THEN 'DENEGADA'
			END AS STATUS,
			NFE.NFE_LOCALIZADOR chave_acesso,
			TO_CHAR(NFE.DT_FATO_GERADOR_IMPOSTO,'MMYYYY') MES_ANO_ARQUIVO 
		FROM
		SYNCHRO.COR_DOF NFE
		INNER JOIN SYNCHRO.COR_IDF NEI                   ON   NEI.DOF_ID = NFE.ID
		INNER JOIN SYNCHRO.GBA_FILIAL F                  ON (F.EST_CODIGO =  NFE.INFORMANTE_EST_CODIGO OR F.FILIAL =  NFE.INFORMANTE_EST_CODIGO)
		LEFT  JOIN SYNCHRO.COR_MERCADORIA ME             ON  (NEI.MERC_CODIGO  = ME.MERC_CODIGO)
		LEFT  JOIN synchro.cor_unidade_mercadoria MU     ON  (ME.MERC_CODIGO = MU.merc_codigo AND NEI.ENTSAI_UNI_CODIGO = MU.UNI_CODIGO)		
		LEFT  JOIN SYNCHRO.COR_PESSOA P                  ON   P.PFJ_CODIGO = NFE.DESTINATARIO_PFJ_CODIGO
		LEFT  JOIN SYNCHRO.COR_PESSOA_VIGENCIA PV        ON  (P.PFJ_CODIGO = PV.PFJ_CODIGO AND PV.DT_FIM IS NULL)
		WHERE 
			 NFE.DT_FATO_GERADOR_IMPOSTO = V_DATA_INICIAL
			 AND F.FILIAL 				 = V_FILIAL   
			 AND NFE.CTRL_SITUACAO_DOF   ='N'
			 AND NEI.CFOP_CODIGO     	 = '5.405'
			 AND NEI.STC_CODIGO       	 IN('10','60','70')
			 AND NFE.MDOF_CODIGO 		 = '55';
      	  
		COMMIT;
          
        EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
      END;
        
      V_DATA_INICIAL := V_DATA_INICIAL + 1;
    
  END LOOP;
END;


TRUNCATE TABLE USRASSISTENTEFISCAL.GBA_RECUP_ST_saida_Exc_Temp;

DECLARE
  V_DATA_FINAL   DATE;
  V_DATA_INICIAL DATE;
  V_FILIAL       VARCHAR2(4);   
BEGIN
  V_DATA_INICIAL   := TO_DATE('2016/12/01','YYYY/MM/DD');
  V_DATA_FINAL     := TO_DATE('2016/12/31','YYYY/MM/DD');  
  V_FILIAL         := '535';
  WHILE V_DATA_INICIAL <= V_DATA_FINAL
  LOOP    
      Begin 
	  
		--ECF  - LOJA DATA PDV
		--NFCE - LOJA DATA (DT_EMISSAO) PDV NUMERO NFCE (NUM_ORDEM_DOC)

		 INSERT INTO USRASSISTENTEFISCAL.GBA_RECUP_ST_saida_Exc_Temp
		 SELECT			  
			  T.EMPRESA,
			  T.UF,
			  T.FILIAL,
			  E.est_codigo ,
			  E.dt_emissao  data,
			  'S' MOV,
			  E.NUM_ORDEM_DOC dof_numero,
			  (LPAD(T.FILIAL,4,'0')||LPAD(E.NUM_ORDEM_DOC,9,'0')||LPAD(E.num_serie,3,'0')||TO_CHAR(E.dt_emissao,'DDMMYYYY') ) DOF_IMPORT_NUMERO,
			  E.num_serie serie, 
			  E.stc_codigo,
			  E.mdof_codigo   modelo   ,
			  E.sit_tribut             ,
			  E.merc_codigo            ,
			  SYNCHRO.COR_MERCADORIA.DESCRICAO,   
			  E.num_item               , 
			  E.cfop_codigo            ,
			  E.uni_codigo             ,
			  E.qtd                    ,
			  E.vl_unitario            ,
			  0 FAT_CONVERSAO,
			  E.qtd VOLUME,  
			  (E.qtd * E.vl_unitario) vl_contabil,			  
			  CASE
				WHEN  E.ctrl_situacao = 'N' THEN 'AUTORIZADA'
				WHEN  E.ctrl_situacao = 'S' THEN 'CANCELADA'
				WHEN  E.ctrl_situacao = 'I' THEN 'INUTILIZADA'
				WHEN  E.ctrl_situacao = 'D' THEN 'DENEGADA'
			  END AS STATUS, 
			  E.chv_cfe chave_acesso,
			  TO_CHAR(E.dt_emissao,'MMYYYY') MES_ANO_ARQUIVO  
		 FROM  SYNCHRO.COR_ECF_ITEM E
		 INNER JOIN SYNCHRO.GBA_FILIAL T ON (T.EST_CODIGO = E.EST_CODIGO OR T.FILIAL = E.EST_CODIGO)
		 JOIN SYNCHRO.COR_EQUIPAMENTO    ON SYNCHRO.COR_EQUIPAMENTO.ID = E.EQP_ID
		 JOIN SYNCHRO.COR_MERCADORIA     ON SYNCHRO.COR_MERCADORIA.MERC_CODIGO = E.MERC_CODIGO
		 JOIN SYNCHRO.COR_PESSOA         ON SYNCHRO.COR_PESSOA.PFJ_CODIGO = E.EST_CODIGO		 
		 WHERE 
		 E.dt_emissao 				 = V_DATA_INICIAL
		 AND T.FILIAL 				 = V_FILIAL   
		 AND E.ctrl_situacao 		 ='N'
		 AND E.STC_CODIGO   		 IN('10','60','70')
		 AND E.CFOP_CODIGO  		 = '5.405';
      	  
		COMMIT;
          
        EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
      END;
        
      V_DATA_INICIAL := V_DATA_INICIAL + 1;
    
  END LOOP;
END;


BEGIN
	INSERT INTO USRASSISTENTEFISCAL.GBA_RECUP_ST_saida_EXCEDENTE
	SELECT 
	  EMPRESA,
	  UF,
	  FILIAL,
	  est_codigo ,
	  data,
	  MOV,
	  dof_numero,
	  DOF_IMPORT_NUMERO,
	  serie, 
	  stc_codigo,
	  modelo   ,
	  sit_tribut             ,	  
	  merc_codigo            ,
	  DESCRICAO,   
	  num_item               , 
	  cfop_codigo            ,
	  uni_codigo             ,
	  SUM(qtd) QTD           ,
	  vl_unitario            ,
	  FAT_CONVERSAO,
	  SUM(VOLUME) VOLUME,  
	  SUM(vl_contabil) vl_contabil,	  
	  STATUS, 
	  chave_acesso,
	  MES_ANO_ARQUIVO	
	FROM USRASSISTENTEFISCAL.GBA_RECUP_ST_saida_Exc_Temp
	GROUP BY 
		  EMPRESA,
		  UF,
		  FILIAL,
		  est_codigo ,
		  data,
		  MOV,
		  dof_numero,
		  DOF_IMPORT_NUMERO,
		  serie, 
		  stc_codigo,
		  modelo   ,
		  sit_tribut             ,		  
		  merc_codigo            ,
		  DESCRICAO,   
		  num_item               , 
		  cfop_codigo            ,
		  uni_codigo             ,
		  vl_unitario            ,		  
		  FAT_CONVERSAO,		  
		  STATUS, 
		  chave_acesso,
		  MES_ANO_ARQUIVO;
COMMIT;
END;



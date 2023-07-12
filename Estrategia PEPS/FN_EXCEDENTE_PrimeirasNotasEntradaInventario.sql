
/*
create table USRASSISTENTEFISCAL.GBA_EXCEDENTE_ENT_INVENTARIO
(
  uf            VARCHAR2(2),
  filial        VARCHAR2(3), 
  est_codigo    VARCHAR2(14),
  dt_lancamento DATE,
  dt_transacao  DATE,
  merc_codigo   VARCHAR2(60),
  inventario    NUMBER(19,6),
  estoque       NUMBER(19,6),
  DT_PARTIDA    DATE,
  DT_PRIMEIRA_NOTA DATE,
  dt_criacao    DATE,
  USUARIO       VARCHAR2(60)
)
tablespace SYNDATA
nologging;
*/
/*
-- Simulacao
	DECLARE
	  V_DATA NUMBER;
	  CURSOR CUR Is
				 select
					 1 id, dof_sequence,dof_numero,dof_import_numero,EDOF_CODIGO,mdof_codigo,serie,filial,INFORMANTE_EST_CODIGO,cpf_cgc,cnpj_fornecedor,dt_fato_gerador_imposto,dh_emissao,cfop_codigo,operacao,DENTRO_ESTADO,stc_codigo,cod_barra,nbm_codigo,merc_codigo,descricao,idf_num,mov,vl_unit,embalagem,quantidade,volume,volume estoque,entsai_uni_codigo,estoque_uni_codigo,preco_total,vl_contabil,vl_ajuste_preco_total,vl_base_icms,aliq_icms,vl_icms,vl_base_st,vl_base_st vl_base_st_original,vl_st,aliq_stf,vl_ipi, (VL_BASE_ST / VOLUME) V_VL_BC_ST_UNIT,status,MES_ANO_ARQUIVO
					 ,SYSDATE
					 ,'1' ativo 
				 from table(USRASSISTENTEFISCAL.FN_EXCEDENTE_ENT('535',TO_DATE('2016/11/18','YYYY/MM/DD'),'R00001099414'));
				
	  LINHA CUR%ROWTYPE;
	BEGIN
		Open CUR;
		LOOP Fetch CUR INTO LINHA; 
		  EXIT WHEN CUR%NOTFOUND;
		  Begin
			  INSERT INTO USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET VALUES(LINHA.id,LINHA.dof_sequence,LINHA.dof_numero,LINHA.dof_import_numero,LINHA.EDOF_CODIGO,LINHA.mdof_codigo,LINHA.serie,LINHA.filial,LINHA.INFORMANTE_EST_CODIGO,LINHA.cpf_cgc,LINHA.cnpj_fornecedor,LINHA.dt_fato_gerador_imposto,LINHA.dh_emissao,LINHA.cfop_codigo,LINHA.operacao,LINHA.DENTRO_ESTADO,LINHA.stc_codigo,LINHA.cod_barra,LINHA.nbm_codigo,LINHA.merc_codigo,LINHA.descricao,LINHA.idf_num,LINHA.mov,LINHA.vl_unit,LINHA.embalagem,LINHA.quantidade,LINHA.volume,LINHA.estoque,LINHA.entsai_uni_codigo,LINHA.estoque_uni_codigo,LINHA.preco_total,LINHA.vl_contabil,LINHA.vl_ajuste_preco_total,LINHA.vl_base_icms,LINHA.aliq_icms,LINHA.vl_icms,LINHA.vl_base_st,LINHA.vl_base_st_original,LINHA.vl_st,LINHA.aliq_stf,LINHA.vl_ipi,LINHA.V_VL_BC_ST_UNIT,LINHA.status,LINHA.MES_ANO_ARQUIVO,LINHA.SYSDATE,LINHA.ativo);
		  
			  COMMIT;
			  
			EXCEPTION
			  WHEN NO_DATA_FOUND THEN NULL;
		  END;
		END LOOP;
		Close CUR;
	END;

*/

--call USRASSISTENTEFISCAL.FN_EXCEDENTE_INVENTARIO('535','',to_date('2017/01/12','yyyy/mm/dd'));


CREATE OR REPLACE PROCEDURE USRASSISTENTEFISCAL.FN_EXCEDENTE_INVENTARIO(P_FILIAL IN VARCHAR2, P_MERCADORIA IN VARCHAR2, P_PERIODO_VENDA IN DATE)
AS
    CURSOR CUR_INVENTARIO IS
        SELECT
           F.UF,
           F.FILIAL,
           F.EST_CODIGO,
           I.dt_lancamento,
           I.dt_transacao,
           I.quantidade QTD_INVENTARIO,
           I.merc_codigo
        FROM synchro.fis_lancamento_inventario I
        LEFT JOIN USRASSISTENTEFISCAL.GBA_EXCEDENTE_ENT_INVENTARIO G ON I.EST_CODIGO = G.EST_CODIGO AND I.DT_LANCAMENTO = G.DT_LANCAMENTO AND I.MERC_CODIGO = G.MERC_CODIGO
        INNER JOIN SYNCHRO.TBFILIAL F ON (I.EST_CODIGO = F.FILIAL OR I.EST_CODIGO = F.EST_CODIGO)
            WHERE
            F.FILIAL            = P_FILIAL
            AND I.dt_lancamento = to_date(extract(year from P_PERIODO_VENDA)||'/'||extract(month from P_PERIODO_VENDA)||'/01','yyyy/mm/dd')
            AND I.MERC_CODIGO   = CASE WHEN NVL(P_MERCADORIA,'') = '' OR P_MERCADORIA IS NULL THEN I.MERC_CODIGO ELSE P_MERCADORIA END
            AND G.EST_CODIGO  IS NULL;
        
    INVENTARIO  CUR_INVENTARIO%ROWTYPE;
BEGIN
    
  OPEN CUR_INVENTARIO;
  LOOP
    FETCH CUR_INVENTARIO INTO INVENTARIO;
    EXIT WHEN CUR_INVENTARIO%NOTFOUND;
    BEGIN
    INSERT INTO USRASSISTENTEFISCAL.GBA_EXCEDENTE_ENT_INVENTARIO (UF, FILIAL,EST_CODIGO,DT_LANCAMENTO,DT_TRANSACAO,MERC_CODIGO,QTD_INVENTARIO,ESTOQUE,DT_CRIACAO) VALUES(INVENTARIO.UF,INVENTARIO.FILIAL,INVENTARIO.EST_CODIGO,INVENTARIO.DT_LANCAMENTO,INVENTARIO.DT_TRANSACAO,INVENTARIO.MERC_CODIGO,INVENTARIO.QTD_INVENTARIO,INVENTARIO.QTD_INVENTARIO,SYSDATE);
    COMMIT;
  END;
  END LOOP;
  CLOSE CUR_INVENTARIO;
END;
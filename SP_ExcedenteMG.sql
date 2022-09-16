
BEGIN
 USRASSISTENTEFISCAL.SP_ExcedenteMG('535','01/11/2016','DD/MM/YYYY');
END;

--select * from table(USRASSISTENTEFISCAL.FN_EXCEDENTE_ENT('535',TO_DATE('2016/11/05','YYYY/MM/DD'),'R00000268898'))

CREATE OR REPLACE PROCEDURE USRASSISTENTEFISCAL.SP_ExcedenteMG(P_FILIAL VARCHAR2, DT_INICIAL VARCHAR2, FORMATO VARCHAR2)
AS
    V_VL_BC_ST_UNIT               NUMBER(19,2) := 0;
    V_VL_BC_ST_ACORDO_VENDIDA     NUMBER(19,2) := 0;
    V_VL_DIFERENCA_ENTRE_BASE     NUMBER(19,2) := 0;
    V_VL_CREDITO                  NUMBER(19,2) := 0;
    V_VL_SALDO_SAIDA              NUMBER(19,2) := 0;
    V_VL_ESTOQUE                  NUMBER(19,2) := 0;

    V_DET_ID                      INT          := 0;
    V_REC_ID                      INT          := 0;
    V_ID_ENTRADA                  INT          := 0;

    V_ENCONTROU_ENTRADA           INT          := 0;
	V_BUSCA_ENTRADA               INT          := 0;

    V_VL_MEDIO                    NUMBER(19,2) := 0;
    V_VL_BASE_ACUMULADO           NUMBER(19,2) := 0;
    V_VL_QTD_ACUMULADO            NUMBER(19,2) := 0;
	V_ALIQ_ST                     NUMBER(15,4) := 0;

	V_VL_ESTOQUE_INICIAL          NUMBER(22,4) := 0;
    V_VL_ESTOQUE_ACUMULADO        NUMBER(22,4) := 0;
	
	V_DIF_MES_SAIDA_ULT_ENTRADA   INT := 0;
	V_DIF_CORTE_ULT_ENTRADA		  INT := 3;

    CURSOR CUR_MERCADORIA IS SELECT '535' AS FILIAL, MERC_CODIGO FROM USRASSISTENTEFISCAL.GBA_MERC_Excedente_MG ORDER BY MERC_CODIGO;
  /*
                SELECT
          DISTINCT  FILIAL, MERC_CODIGO
        FROM USRASSISTENTEFISCAL.GBA_RECUP_ST_SAIDA_EXCEDENTE
                WHERE
                  FILIAL = P_FILIAL AND DATA between to_date(DT_INICIAL, FORMATO) AND LAST_DAY(TO_DATE(DT_INICIAL, FORMATO));
    */

  MERCADORIA  CUR_MERCADORIA%ROWTYPE;

BEGIN

  -- Pegar o último REC_ID para manter a sequência
  SELECT
    MAX(REC_ID) INTO V_REC_ID
  FROM USRASSISTENTEFISCAL.Excedente_MG_MERC;

  SELECT
    MAX(ID) INTO V_ID_ENTRADA
  FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET;

  OPEN CUR_MERCADORIA;
  LOOP
    FETCH CUR_MERCADORIA INTO MERCADORIA;
    EXIT WHEN CUR_MERCADORIA%NOTFOUND;
    BEGIN
      V_REC_ID    	:= NVL(V_REC_ID,0) + 1;
      V_DET_ID  	:= 0;

      V_VL_ESTOQUE_ACUMULADO 	:= 0;
      V_VL_MEDIO       			:= 0;
      V_VL_BC_ST_UNIT    		:= 0;
      V_VL_QTD_ACUMULADO     	:= 0;
      V_VL_BASE_ACUMULADO    	:= 0;

      -- Verifica se a mercadoria possui referência no último mês.
      BEGIN
		  SELECT
			 ESTOQUE_FINAL INTO  V_VL_ESTOQUE_INICIAL
		  FROM (
				  SELECT
					S.*
				  FROM USRASSISTENTEFISCAL.Excedente_MG_MERC S
				  WHERE
					S.FILIAL          = MERCADORIA.FILIAL
					AND S.MERC_CODIGO = MERCADORIA.MERC_CODIGO
					AND S.DT_INICIO   < to_date(DT_INICIAL, FORMATO)
					ORDER BY S.DT_INICIO DESC
		  ) WHERE ROWNUM < 2;
		  
		  EXCEPTION
		  WHEN NO_DATA_FOUND THEN V_VL_ESTOQUE_INICIAL := 0;		  
      END;		 
		  
          -- Início Associando a Saída do Item a última entrada
          FOR NF_SAIDA IN ( SELECT * FROM USRASSISTENTEFISCAL.GBA_RECUP_ST_SAIDA_EXCEDENTE WHERE FILIAL = MERCADORIA.FILIAL AND MERC_CODIGO = MERCADORIA.MERC_CODIGO ORDER BY DATA DESC )
          LOOP
          BEGIN
				  V_DET_ID          	:= NVL(V_DET_ID,0) + 1;
				  V_VL_SALDO_SAIDA    	:= NF_SAIDA.VOLUME;
				  V_ENCONTROU_ENTRADA 	:= 0;
				  V_VL_ESTOQUE    		:= 0;

				  INSERT INTO USRASSISTENTEFISCAL.EXCEDENTE_MG_SAIDA_DET VALUES(V_REC_ID,V_DET_ID,NF_SAIDA.empresa,NF_SAIDA.uf,NF_SAIDA.filial,NF_SAIDA.data,NF_SAIDA.dof_numero,NF_SAIDA.dof_import_numero,NF_SAIDA.merc_codigo,NF_SAIDA.descricao,NF_SAIDA.num_item,NF_SAIDA.cfop_codigo,NF_SAIDA.qtd,NF_SAIDA.vl_unitario,NF_SAIDA.volume,NF_SAIDA.vl_contabil,null,null,null,null,NF_SAIDA.status,SYSDATE);

				  V_BUSCA_ENTRADA := 1;

				  -- INÍCIO BUSCA ÚLTIMA ENTRADA PARA LOJA
				  WHILE V_VL_SALDO_SAIDA > 0 AND V_BUSCA_ENTRADA = 1
				  LOOP
					BEGIN
					  V_BUSCA_ENTRADA := 0;
												
					  -- BUSCA ÚLTIMA ENTRADA NA LOJA
					  FOR NF_ENTRADA IN (select * from table(USRASSISTENTEFISCAL.FN_EXCEDENTE_ENT(NF_SAIDA.FILIAL, NF_SAIDA.DATA,NF_SAIDA.MERC_CODIGO)) )
					  LOOP
						BEGIN
							V_ENCONTROU_ENTRADA := 1;
							V_BUSCA_ENTRADA   	:= 1;
							
							V_DIF_MES_SAIDA_ULT_ENTRADA :=0;
							
							-- Considerando a última entrada para a mesma loja, somente se, a data de entrada não seja superior a 3 meses da data de saída
								SELECT ABS(months_between(NF_SAIDA.DATA, NF_ENTRADA.DT_FATO_GERADOR_IMPOSTO)) INTO V_DIF_MES_SAIDA_ULT_ENTRADA  FROM DUAL;
								
								IF V_DIF_MES_SAIDA_ULT_ENTRADA > V_DIF_CORTE_ULT_ENTRADA
								THEN 
									BEGIN
										V_BUSCA_ENTRADA := 0;
										EXIT;
									END;
								END IF;

							IF NF_ENTRADA.ESTOQUE >= V_VL_SALDO_SAIDA
							THEN
							  BEGIN
								V_VL_ESTOQUE     := NF_ENTRADA.ESTOQUE - V_VL_SALDO_SAIDA;
								V_VL_SALDO_SAIDA :=  0;
							  END;
							ELSE
							  BEGIN
								V_VL_ESTOQUE     := 0;
								V_VL_SALDO_SAIDA := V_VL_SALDO_SAIDA - NF_ENTRADA.ESTOQUE;
							  END;
							END IF;

							IF NF_ENTRADA.ATUALIZAR_ESTOQUE = 1
							THEN
							  BEGIN
							  UPDATE USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET
								SET ESTOQUE = V_VL_ESTOQUE
							  WHERE
								DOF_IMPORT_NUMERO = NF_ENTRADA.DOF_IMPORT_NUMERO
								AND MERC_CODIGO   = NF_ENTRADA.MERC_CODIGO
								AND idf_num       = NF_ENTRADA.idf_num;
								
								INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT(REC_ID,DET_ID,ID_ENTRADA,filial,volume,VL_BC_ST,VL_BC_ST_UNIT,DT_FATO_GERADOR,DT_REGISTRO,FAZ_PARTE_PEDIDO) VALUES(V_REC_ID,V_DET_ID,NF_ENTRADA.ID,NF_ENTRADA.FILIAL,NF_ENTRADA.VOLUME,NF_ENTRADA.vl_base_st,V_VL_BC_ST_UNIT,NF_ENTRADA.dt_fato_gerador_imposto,SYSDATE,'S');
								
								INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_LOG VALUES(V_REC_ID,V_DET_ID,NF_ENTRADA.ID,'LOJA PASSO UPDATE',NF_SAIDA.FILIAL,NF_SAIDA.MERC_CODIGO,NF_SAIDA.DATA,NF_ENTRADA.ESTOQUE,NF_SAIDA.VOLUME,V_VL_SALDO_SAIDA,V_VL_ESTOQUE,NF_ENTRADA.ATUALIZAR_ESTOQUE);
							 END;
							 ELSE
							   BEGIN
								   V_ID_ENTRADA    := NVL(V_ID_ENTRADA,0) + 1;

								   IF NVL(NF_ENTRADA.VOLUME,0) = 0 THEN V_VL_BC_ST_UNIT := 0; ELSE V_VL_BC_ST_UNIT := NF_ENTRADA.VL_BASE_ST / NF_ENTRADA.VOLUME; END IF;

								   V_VL_BASE_ACUMULADO := V_VL_BASE_ACUMULADO + V_VL_BC_ST_UNIT;
								   V_VL_QTD_ACUMULADO  := V_VL_QTD_ACUMULADO  + NF_ENTRADA.VOLUME;

								   INSERT INTO USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET VALUES(V_ID_ENTRADA,NF_ENTRADA.dof_sequence,NF_ENTRADA.dof_numero,NF_ENTRADA.dof_import_numero,NF_ENTRADA.EDOF_CODIGO,NF_ENTRADA.mdof_codigo,NF_ENTRADA.serie,NF_ENTRADA.filial,NF_ENTRADA.INFORMANTE_EST_CODIGO,NF_ENTRADA.cpf_cgc,NF_ENTRADA.cnpj_fornecedor,NF_ENTRADA.dt_fato_gerador_imposto,NF_ENTRADA.dh_emissao,NF_ENTRADA.cfop_codigo,NF_ENTRADA.operacao,NF_ENTRADA.DENTRO_ESTADO,NF_ENTRADA.stc_codigo,NF_ENTRADA.cod_barra,NF_ENTRADA.nbm_codigo,NF_ENTRADA.merc_codigo,NF_ENTRADA.descricao,NF_ENTRADA.idf_num,NF_ENTRADA.mov,NF_ENTRADA.vl_unit,NF_ENTRADA.embalagem,NF_ENTRADA.quantidade,NF_ENTRADA.volume,V_VL_ESTOQUE,NF_ENTRADA.entsai_uni_codigo,NF_ENTRADA.estoque_uni_codigo,NF_ENTRADA.preco_total,NF_ENTRADA.vl_contabil,NF_ENTRADA.vl_ajuste_preco_total,NF_ENTRADA.vl_base_icms,NF_ENTRADA.aliq_icms,NF_ENTRADA.vl_icms,NF_ENTRADA.vl_base_st,NF_ENTRADA.vl_st,NF_ENTRADA.aliq_stf,NF_ENTRADA.vl_ipi,V_VL_BC_ST_UNIT,NF_ENTRADA.status,NF_ENTRADA.MES_ANO_ARQUIVO,SYSDATE);
									
								   INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT(REC_ID,DET_ID,ID_ENTRADA,filial,volume,VL_BC_ST,VL_BC_ST_UNIT,DT_FATO_GERADOR,DT_REGISTRO,FAZ_PARTE_PEDIDO) VALUES(V_REC_ID,V_DET_ID,V_ID_ENTRADA,NF_ENTRADA.FILIAL,NF_ENTRADA.VOLUME,NF_ENTRADA.vl_base_st,V_VL_BC_ST_UNIT,NF_ENTRADA.dt_fato_gerador_imposto,SYSDATE,'S');
								   
								   INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_LOG VALUES(V_REC_ID,V_DET_ID,V_ID_ENTRADA,'LOJA PASSO NOVO',NF_SAIDA.FILIAL,NF_SAIDA.MERC_CODIGO,NF_SAIDA.DATA,NF_ENTRADA.ESTOQUE,NF_SAIDA.VOLUME,V_VL_SALDO_SAIDA,V_VL_ESTOQUE,NF_ENTRADA.ATUALIZAR_ESTOQUE);
								   END;
							END IF;
						

							EXIT WHEN NVL(V_VL_SALDO_SAIDA,0) = 0;
						END;
					  END LOOP; -- FIM BUSCA ÚLTIMA ENTRADA PARA LOJA
					  

					  IF V_VL_SALDO_SAIDA > 0 AND (V_ENCONTROU_ENTRADA = 0 OR V_BUSCA_ENTRADA = 0)
					  THEN
						BEGIN
						  -- BUSCA ÚLTIMA ENTRADA NO CD 607
						  FOR NF_ENTRADA IN (select * from table(USRASSISTENTEFISCAL.FN_EXCEDENTE_ENT('607', NF_SAIDA.DATA,NF_SAIDA.MERC_CODIGO)) )
						  LOOP
							BEGIN
								V_ENCONTROU_ENTRADA := 1;
								V_BUSCA_ENTRADA   := 1;

								IF NF_ENTRADA.ESTOQUE >= V_VL_SALDO_SAIDA
								THEN
								  BEGIN
									V_VL_ESTOQUE     := NF_ENTRADA.ESTOQUE - V_VL_SALDO_SAIDA;
									V_VL_SALDO_SAIDA :=  0;
								  END;
								ELSE
								  BEGIN
									V_VL_ESTOQUE     := 0;
									V_VL_SALDO_SAIDA := V_VL_SALDO_SAIDA - NF_ENTRADA.ESTOQUE;
								  END;
								END IF;


								IF NF_ENTRADA.ATUALIZAR_ESTOQUE = 1
								THEN
								  BEGIN
									  UPDATE USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET
										SET ESTOQUE = V_VL_ESTOQUE
									  WHERE
										DOF_IMPORT_NUMERO = NF_ENTRADA.DOF_IMPORT_NUMERO
										AND MERC_CODIGO   = NF_ENTRADA.MERC_CODIGO
										AND idf_num       = NF_ENTRADA.idf_num;

										INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT(REC_ID,DET_ID,ID_ENTRADA,filial,volume,VL_BC_ST,VL_BC_ST_UNIT,DT_FATO_GERADOR,DT_REGISTRO,FAZ_PARTE_PEDIDO) VALUES(V_REC_ID,V_DET_ID,NF_ENTRADA.ID,NF_ENTRADA.FILIAL,NF_ENTRADA.VOLUME,NF_ENTRADA.vl_base_st,V_VL_BC_ST_UNIT,NF_ENTRADA.dt_fato_gerador_imposto,SYSDATE,'S');
										
										INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_LOG VALUES(V_REC_ID,V_DET_ID,NF_ENTRADA.ID,'CD PASSO UPDATE',NF_SAIDA.FILIAL,NF_SAIDA.MERC_CODIGO,NF_SAIDA.DATA,NF_ENTRADA.ESTOQUE,NF_SAIDA.VOLUME,V_VL_SALDO_SAIDA,V_VL_ESTOQUE,NF_ENTRADA.ATUALIZAR_ESTOQUE);
								  END;
								 ELSE
								   BEGIN
								   V_ID_ENTRADA    := NVL(V_ID_ENTRADA,0) + 1;

								   IF NVL(NF_ENTRADA.VOLUME,0) = 0 THEN V_VL_BC_ST_UNIT := 0; ELSE V_VL_BC_ST_UNIT := NF_ENTRADA.VL_BASE_ST / NF_ENTRADA.VOLUME; END IF;

								   INSERT INTO USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET VALUES(V_ID_ENTRADA,NF_ENTRADA.dof_sequence,NF_ENTRADA.dof_numero,NF_ENTRADA.dof_import_numero,NF_ENTRADA.EDOF_CODIGO,NF_ENTRADA.mdof_codigo,NF_ENTRADA.serie,NF_ENTRADA.filial,NF_ENTRADA.INFORMANTE_EST_CODIGO,NF_ENTRADA.cpf_cgc,NF_ENTRADA.cnpj_fornecedor,NF_ENTRADA.dt_fato_gerador_imposto,NF_ENTRADA.dh_emissao,NF_ENTRADA.cfop_codigo,NF_ENTRADA.operacao,NF_ENTRADA.DENTRO_ESTADO,NF_ENTRADA.stc_codigo,NF_ENTRADA.cod_barra,NF_ENTRADA.nbm_codigo,NF_ENTRADA.merc_codigo,NF_ENTRADA.descricao,NF_ENTRADA.idf_num,NF_ENTRADA.mov,NF_ENTRADA.vl_unit,NF_ENTRADA.embalagem,NF_ENTRADA.quantidade,NF_ENTRADA.volume,V_VL_ESTOQUE,NF_ENTRADA.entsai_uni_codigo,NF_ENTRADA.estoque_uni_codigo,NF_ENTRADA.preco_total,NF_ENTRADA.vl_contabil,NF_ENTRADA.vl_ajuste_preco_total,NF_ENTRADA.vl_base_icms,NF_ENTRADA.aliq_icms,NF_ENTRADA.vl_icms,NF_ENTRADA.vl_base_st,NF_ENTRADA.vl_st,NF_ENTRADA.aliq_stf,NF_ENTRADA.vl_ipi,V_VL_BC_ST_UNIT,NF_ENTRADA.status,NF_ENTRADA.MES_ANO_ARQUIVO,SYSDATE);

								   INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT(REC_ID,DET_ID,ID_ENTRADA,filial,volume,VL_BC_ST,VL_BC_ST_UNIT,DT_FATO_GERADOR,DT_REGISTRO,FAZ_PARTE_PEDIDO) VALUES(V_REC_ID,V_DET_ID,V_ID_ENTRADA,NF_ENTRADA.FILIAL,NF_ENTRADA.VOLUME,NF_ENTRADA.vl_base_st,V_VL_BC_ST_UNIT,NF_ENTRADA.dt_fato_gerador_imposto,SYSDATE,'S');

								   INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_LOG VALUES(V_REC_ID,V_DET_ID,V_ID_ENTRADA,'CD PASSO NOVO',NF_SAIDA.FILIAL,NF_SAIDA.MERC_CODIGO,NF_SAIDA.DATA,NF_ENTRADA.ESTOQUE,NF_SAIDA.VOLUME,V_VL_SALDO_SAIDA,V_VL_ESTOQUE,NF_ENTRADA.ATUALIZAR_ESTOQUE);
								   END;
								END IF;
								

								EXIT WHEN NVL(V_VL_SALDO_SAIDA,0) = 0;
							END;
						  END LOOP; -- FIM BUSCA ÚLTIMA ENTRADA NO CD 607
						END;
					  END IF;

					END;
				 END LOOP; -- FIM WHILE

				IF NVL(V_ENCONTROU_ENTRADA,0) = 0 THEN INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT(REC_ID,DET_ID,DT_REGISTRO,FAZ_PARTE_PEDIDO) VALUES(V_REC_ID,V_DET_ID,SYSDATE,'N'); END IF;
          END;
        END LOOP; -- Fim Associando a Saída do Item a última entrada


        -- Calculando o valor médio com base nas entradas para o Item.
        BEGIN
          SELECT
            SUM(ESTOQUE), AVG(VL_BC_ST_UNIT) INTO V_VL_ESTOQUE_ACUMULADO, V_VL_MEDIO
          FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET 
		  where 
			MERC_CODIGO = MERCADORIA.MERC_CODIGO;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          BEGIN
            V_VL_MEDIO       	   := 0;
            V_VL_ESTOQUE_ACUMULADO := 0;
          END;
        END;

       -- Calculando a média
       --V_VL_MEDIO := 0;
       --IF NVL(V_VL_QTD_ACUMULADO,0) <> 0 THEN V_VL_MEDIO := V_VL_BASE_ACUMULADO / V_VL_QTD_ACUMULADO; END IF;

       V_ALIQ_ST := 0;

       -- Início Calculando valor a Creditar
       FOR NF_SAIDA IN (SELECT REC_ID, DET_ID, VL_CONTABIL, VOLUME FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_SAIDA_DET WHERE REC_ID = V_REC_ID ORDER BY DET_ID )
       LOOP
        BEGIN
          -- Buscando a ALIQ
          BEGIN
            SELECT
              MIN(B.ALIQ_STF) INTO V_ALIQ_ST -- Usando a menor ALIQ quando a saída tiver mais de uma entrada associada
            FROM USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT A
            INNER JOIN USRASSISTENTEFISCAL.EXCEDENTE_MG_ENTRADA_DET B ON A.ID_ENTRADA = B.ID
            WHERE
              A.REC_ID 	   = NF_SAIDA.REC_ID 
			  AND A.DET_ID = NF_SAIDA.DET_ID;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            BEGIN
              V_ALIQ_ST := 0;
            END;
          END;

          V_VL_BC_ST_ACORDO_VENDIDA := V_VL_MEDIO 				 *  NF_SAIDA.VOLUME;
          V_VL_DIFERENCA_ENTRE_BASE := V_VL_BC_ST_ACORDO_VENDIDA - NF_SAIDA.VL_CONTABIL;
          V_VL_CREDITO              := V_VL_DIFERENCA_ENTRE_BASE * (V_ALIQ_ST/100);

          UPDATE USRASSISTENTEFISCAL.EXCEDENTE_MG_SAIDA_DET
          SET
            VL_BASE_ST_UNIT  = V_VL_MEDIO,
            VL_BASE_ST_VENDA = V_VL_BC_ST_ACORDO_VENDIDA,
            VL_DIF_BASE    	 = V_VL_DIFERENCA_ENTRE_BASE,
            VL_CREDITO     	 = V_VL_CREDITO
          WHERE
            REC_ID 		= NF_SAIDA.REC_ID 
			AND DET_ID 	= NF_SAIDA.DET_ID;

        END;
       END LOOP; -- Fim Calculando valor a Creditar

	   
	   -- Início Removendo da composição as Saídas que deram Negativo no valor a recuperar
	   FOR NF_SAIDA IN (
					SELECT 
						DISTINCT A.REC_ID, A.DET_ID
					FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_SAIDA_DET A
					INNER JOIN 
					(
					  SELECT 
						  FILIAL, DATA, MERC_CODIGO, SUM(VL_CREDITO) TOTAL_CREDITO
					  FROM USRASSISTENTEFISCAL.EXCEDENTE_MG_SAIDA_DET 
					  WHERE 
						   REC_ID = V_REC_ID
					  GROUP BY 
							FILIAL, DATA, MERC_CODIGO
					  HAVING SUM(VL_CREDITO) < 0
					) B ON A.FILIAL = B.FILIAL AND A.MERC_CODIGO = B.MERC_CODIGO AND A.DATA = B.DATA
				)
		LOOP
			BEGIN
				UPDATE USRASSISTENTEFISCAL.Excedente_MG_SAIDAXENT 
					SET FAZ_PARTE_PEDIDO = 'N' 
				WHERE 
					REC_ID 	   = NF_SAIDA.REC_ID 
					AND DET_ID = NF_SAIDA.DET_ID;
			END;
		END LOOP; -- Fim Removendo da composição as Saídas que deram Negativo no valor a recuperar
	   
       INSERT INTO USRASSISTENTEFISCAL.Excedente_MG_MERC(rec_id,filial,DT_INICIO,DT_TERMINO,merc_codigo,VL_MEDIA,estoque_inicial,estoque_final,dt_registro) VALUES(V_REC_ID,P_FILIAL,to_date(DT_INICIAL, FORMATO),LAST_DAY(TO_DATE(DT_INICIAL, FORMATO)),MERCADORIA.MERC_CODIGO,V_VL_MEDIO,V_VL_ESTOQUE_INICIAL,V_VL_ESTOQUE_ACUMULADO,SYSDATE);


    COMMIT;

    END;
  END LOOP;
  CLOSE CUR_MERCADORIA;
END;
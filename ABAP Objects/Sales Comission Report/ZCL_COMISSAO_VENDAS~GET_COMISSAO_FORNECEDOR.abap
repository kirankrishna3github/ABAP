*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obter comiss�o do fornecedor                              *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_VBELN TYPE R_VBELN  N� do documento de vendas
*--> IMPORTING IM_LIFNR TYPE R_LIFNR  N� do Representante
*--> IMPORTING IM_ERDAT TYPE R_ERDAT  Data da cria��o
*--> IMPORTING IM_VKORG TYPE R_VKORG  Organiza��o de vendas
*--> IMPORTING IM_VTWEG TYPE R_VTWEG  Canal de distribui��o
*--> IMPORTING IM_SPART TYPE R_SPART  Setor de atividade
*--> IMPORTING IM_VKBUR TYPE R_VKBUR  Escrit�rio de vendas
*<-- RETURNING EX_T_COMISSAO TYPE TP_COMISSAO	Comiss�o

METHOD get_comissao_fornecedor.
*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_vbak       TYPE STANDARD TABLE OF ty_vbak      ,
    t_vbpa       TYPE STANDARD TABLE OF ty_vbpa      ,
    t_vbkd       TYPE STANDARD TABLE OF ty_vbkd      ,
    t_cond_parc  TYPE STANDARD TABLE OF ty_cond_parc ,
    t_konv_total TYPE STANDARD TABLE OF ty_konv_total,
    t_lfa1       TYPE STANDARD TABLE OF ty_lfa1      .

*----------------------------------------------------------------------*
* Ranges                                                               *
*----------------------------------------------------------------------*
  DATA:
    r_parvw TYPE RANGE OF parvw,
    r_kschl TYPE RANGE OF kschl.

*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_comissao LIKE LINE OF ex_t_comissao.

*----------------------------------------------------------------------*
* Vari�veis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE t100-text   ,
    v_qtd_reg  TYPE i           ,
    v_nro_reg  type zsdt033i-nrg,
    v_indice   TYPE sy-tabix    .

*----------------------------------------------------------------------*
* In�cio                                                               *
*----------------------------------------------------------------------*
  SELECT vbeln " Documento de vendas
         erdat " Data de cria��o do registro
         vkorg " Organiza��o de vendas
         vtweg " Canal de distribui��o
         spart " Setor de atividade
         vkbur " Escrit�rio de vendas
         knumv " N� condi��o do documento
         netwr " Valor l�quido da ordem
         bstnk " N� pedido do cliente
    FROM vbak  " Documento de vendas: dados de cabe�alho
    INTO TABLE t_vbak
    WHERE vbeln IN im_vbeln
      AND erdat IN im_erdat
      AND vkorg IN im_vkorg
      AND vtweg IN im_vtweg
      AND spart IN im_spart
      AND vkbur IN im_vkbur.

* Exclui as notas que j� foram registradas
  LOOP AT t_vbak ASSIGNING FIELD-SYMBOL(<f_w_vbak>).
    v_indice = sy-tabix.

    SELECT SINGLE nrg
     FROM zsdt033i
     INTO v_nro_reg
     WHERE vbeln = <f_w_vbak>-vbeln.

    IF sy-subrc = 0.
      SELECT COUNT( DISTINCT nrg )
       FROM zsdt033c
       INTO v_qtd_reg
       WHERE nrg = v_nro_reg
         AND lifnr <> space.

      IF v_qtd_reg <> 0.
        DELETE t_vbak INDEX v_indice.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF t_vbak IS INITIAL.
    MESSAGE e001(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  me->get_tipo_condicao_parceiro( EXPORTING im_tipo_parceiro = me->c_rep_externo
                                   CHANGING ex_r_kschl       = r_kschl
                                            ex_r_parvw       = r_parvw
                                            ex_t_cond_parc   = t_cond_parc ).

  SELECT vbeln " N� documento de vendas e distribui��o
         lifnr " N� conta do fornecedor
         pernr " N� pessoal
         parvw " Fun��o do parceiro
  FROM vbpa    " Documento SD: parceiro
  INTO TABLE t_vbpa
  FOR ALL ENTRIES IN t_vbak
   WHERE vbeln EQ t_vbak-vbeln
     AND parvw IN r_parvw
     AND lifnr IN im_lifnr.

  SORT t_vbpa BY lifnr ASCENDING.
  DELETE t_vbpa WHERE lifnr IS INITIAL.

  IF t_vbpa IS INITIAL.
*     N�o encontrou parceiros para as notas
    MESSAGE e003(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  SORT:
     t_vbak BY vbeln ASCENDING,
     t_vbpa BY vbeln ASCENDING.

  LOOP AT t_vbak ASSIGNING <f_w_vbak>.
    v_indice = sy-tabix.

    READ TABLE t_vbpa
    ASSIGNING FIELD-SYMBOL(<f_w_vbpa>)
    WITH KEY vbeln = <f_w_vbak>-vbeln
    BINARY SEARCH.

    IF sy-subrc <> 0.
      DELETE t_vbak INDEX v_indice.
    ENDIF.
  ENDLOOP.

  SELECT lifnr " N� conta do fornecedor
         name1 " Descri��o
  FROM lfa1    " Mestre de fornecedores (parte geral)
  INTO TABLE t_lfa1
  FOR ALL ENTRIES IN t_vbpa
   WHERE lifnr = t_vbpa-lifnr.

  SELECT vbeln " N� documento de vendas e distribui��o
         zterm " Chave de condi��es de pagamento
  FROM vbkd    " Documento de vendas: dados comerciais
  INTO TABLE t_vbkd
  FOR ALL ENTRIES IN t_vbak
   WHERE vbeln = t_vbak-vbeln.

  me->get_val_total_comissao( EXPORTING im_t_vbak       = t_vbak
                                        im_r_kschl      = r_kschl
                               CHANGING ex_t_konv_total = t_konv_total ).

  SORT:
     t_vbak       BY vbeln ASCENDING,
     t_vbpa       BY vbeln ASCENDING,
     t_vbkd       BY vbeln ASCENDING,
     t_lfa1       BY lifnr ASCENDING,
     t_konv_total BY knumv ASCENDING,
     t_cond_parc  BY parvw ASCENDING.

  LOOP AT t_vbak ASSIGNING <f_w_vbak>.
    CLEAR w_comissao.

    READ TABLE t_vbpa
    TRANSPORTING NO FIELDS
    WITH KEY vbeln = <f_w_vbak>-vbeln
    BINARY SEARCH.

    v_indice = sy-tabix.

    LOOP AT t_vbpa ASSIGNING <f_w_vbpa> FROM v_indice.
      IF <f_w_vbpa>-vbeln <> <f_w_vbak>-vbeln.
        EXIT.
      ENDIF.

      READ TABLE t_lfa1
      ASSIGNING FIELD-SYMBOL(<f_w_lfa1>)
      WITH KEY lifnr = <f_w_vbpa>-lifnr
      BINARY SEARCH.

      IF sy-subrc = 0.
        w_comissao-lifnr = <f_w_lfa1>-lifnr. " N� conta do fornecedor
        w_comissao-name1 = <f_w_lfa1>-name1. " Nome
      ENDIF.

      w_comissao-vbeln = <f_w_vbak>-vbeln. " Documento de vendas
      w_comissao-erdat = <f_w_vbak>-erdat. " Data de cria��o do registro
      w_comissao-bstnk = <f_w_vbak>-bstnk. " N� pedido do cliente

      READ TABLE t_vbkd
      ASSIGNING FIELD-SYMBOL(<f_w_vbkd>)
      WITH KEY vbeln = <f_w_vbak>-vbeln
      BINARY SEARCH.

      IF sy-subrc = 0.
        w_comissao-zterm = <f_w_vbkd>-zterm. " Chave de condi��es de pagamento
      ENDIF.

      w_comissao-vkorg = <f_w_vbak>-vkorg. " Organiza��o de vendas
      w_comissao-vtweg = <f_w_vbak>-vtweg. " Canal de distribui��o
      w_comissao-spart = <f_w_vbak>-spart. " Setor de atividade
      w_comissao-netwr = <f_w_vbak>-netwr. " Valor l�quido da ordem

*     Tipo de condi��o x Parceiro (ZF01 x F01)
      READ TABLE t_cond_parc
      ASSIGNING FIELD-SYMBOL(<f_w_cond_parc>)
      WITH KEY parvw = <f_w_vbpa>-parvw
      BINARY SEARCH.

      IF sy-subrc = 0.
        READ TABLE t_konv_total
        ASSIGNING FIELD-SYMBOL(<f_w_konv_total>)
        WITH KEY knumv = <f_w_vbak>-knumv
                 kschl = <f_w_cond_parc>-kschl
        BINARY SEARCH.

        IF sy-subrc = 0.
          w_comissao-vcom = <f_w_konv_total>-kwert. " Valor total da comiss�o
*         Valor total da comiss�o
          CHECK w_comissao-vcom IS NOT INITIAL.
          APPEND w_comissao TO ex_t_comissao.
        ENDIF.
      ENDIF.

    ENDLOOP. " LOOP AT t_vbpa ASSIGNING <f_w_vbpa>
  ENDLOOP. " LOOP AT t_vbak ASSIGNING <f_w_vbak>.

  me->get_val_compensado_financeiro( CHANGING im_t_comissao = ex_t_comissao ).

ENDMETHOD.

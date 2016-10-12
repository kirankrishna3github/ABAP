*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Salvar comiss�o do fornecedor                             *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_T_COMISSAO TYPE TP_COMISSAO

METHOD set_comissao.
*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
  TYPES:
   BEGIN OF ty_forn_cli     ,
     lifnr TYPE lfa1-lifnr  ,
     pernr TYPE pa0001-pernr,
   END OF ty_forn_cli       .

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_cv_cabec     TYPE STANDARD TABLE OF zsdt033c   ,
    t_cv_item      TYPE STANDARD TABLE OF zsdt033i   ,
    t_bseg         TYPE STANDARD TABLE OF ty_bseg    ,
    t_vbfa         TYPE STANDARD TABLE OF ty_vbfa    ,
    t_comissao_aux TYPE STANDARD TABLE OF ty_comissao,
    t_forn_cli     TYPE STANDARD TABLE OF ty_forn_cli.

*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_cv_cabec LIKE LINE OF t_cv_cabec,
    w_cv_item  LIKE LINE OF t_cv_item ,
    w_forn_cli LIKE LINE OF t_forn_cli.

*----------------------------------------------------------------------*
* Vari�veis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_sequencia   TYPE n LENGTH 10    ,
    v_return_code TYPE inri-returncode,
    v_msg_erro    TYPE t100-text      ,
    v_indice      TYPE sy-tabix       .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS:
    c_range_cv  TYPE inri-object    VALUE 'ZSD_COM',
    c_nro_range TYPE inri-nrrangenr VALUE '01'     .

*----------------------------------------------------------------------*
* In�cio                                                               *
*----------------------------------------------------------------------*

  APPEND LINES OF im_t_comissao TO t_comissao_aux.
  SORT t_comissao_aux BY conf ASCENDING.

  DELETE t_comissao_aux WHERE conf IS INITIAL.

  IF t_comissao_aux IS INITIAL.
*   Selecione as notas antes de registrar
    MESSAGE i005(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  SELECT vbelv   " Documento de vendas e distribui��o precedente
         vbeln   " N� documento de vendas e distribui��o
         vbtyp_n " Categoria de documento SD subseq�ente
         vbtyp_v " Ctg.documento de venda e distribui��o (SD) precedente
  FROM vbfa      " Fluxo de documentos de vendas e distribui��o
  INTO TABLE t_vbfa
   FOR ALL ENTRIES IN t_comissao_aux
   WHERE vbelv   = t_comissao_aux-vbeln
     AND vbtyp_n = me->c_fatura " M
     AND vbtyp_v = me->c_ordem. " C

  SELECT vbeln " N� documento de vendas e distribui��o
         buzei " N� linha de lan�amento no documento cont�bil
         augbl " N� documento de compensa��o
         koart " Tipo de conta
  FROM bseg    " Segmento do documento contabilidade financeira
  INTO TABLE t_bseg
  FOR ALL ENTRIES IN t_vbfa
  WHERE vbeln = t_vbfa-vbeln
    AND koart = me->c_conta_cliente " D
    AND augbl <> space.

  LOOP AT t_comissao_aux ASSIGNING FIELD-SYMBOL(<f_w_comissao_aux>).
    CLEAR: w_forn_cli.
    w_forn_cli-lifnr = <f_w_comissao_aux>-lifnr.
    w_forn_cli-pernr = <f_w_comissao_aux>-pernr.
    APPEND w_forn_cli TO t_forn_cli.
  ENDLOOP.

  SORT: t_bseg         BY vbeln ASCENDING,
        t_comissao_aux BY lifnr ASCENDING,
        t_forn_cli     BY lifnr pernr ASCENDING.

  DELETE ADJACENT DUPLICATES FROM: t_forn_cli.

  LOOP AT t_forn_cli INTO w_forn_cli.
    IF w_forn_cli-lifnr IS NOT INITIAL.
      READ TABLE t_comissao_aux
      TRANSPORTING NO FIELDS
      WITH KEY lifnr = w_forn_cli-lifnr.

      IF sy-subrc = 0.
        v_indice = sy-tabix.
      ELSE.
        READ TABLE t_comissao_aux
        TRANSPORTING NO FIELDS
        WITH KEY pernr = w_forn_cli-pernr.

        CHECK sy-subrc = 0.
        v_indice = sy-tabix.
      ENDIF.
    ENDIF.

    CLEAR: v_sequencia, v_return_code.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = c_nro_range
        object      = c_range_cv
        quantity    = 1
      IMPORTING
        number      = v_sequencia
        returncode  = v_return_code
      EXCEPTIONS
        OTHERS      = 8.

    LOOP AT t_comissao_aux ASSIGNING <f_w_comissao_aux> FROM v_indice.
      IF <f_w_comissao_aux>-lifnr <> w_forn_cli-lifnr
        OR <f_w_comissao_aux>-pernr <> w_forn_cli-pernr.
        EXIT.
      ENDIF.

      CLEAR: w_cv_item, w_cv_cabec.

      w_cv_cabec-mandt  = sy-mandt                .
      w_cv_cabec-nrg    = v_sequencia             . " N�mero de registro
      w_cv_cabec-erdat1 = sy-datum                . " Data de cria��o do registro
      w_cv_cabec-pernr  = <f_w_comissao_aux>-pernr. " N� pessoal
      w_cv_cabec-lifnr  = <f_w_comissao_aux>-lifnr. " N� conta do fornecedor
      w_cv_cabec-vkorg  = <f_w_comissao_aux>-vkorg. " Organiza��o de vendas
      w_cv_cabec-vtweg  = <f_w_comissao_aux>-vtweg. " Canal de distribui��o
      w_cv_cabec-spart  = <f_w_comissao_aux>-spart. " Setor de atividade
      APPEND w_cv_cabec TO t_cv_cabec             .

      w_cv_item-mandt = sy-mandt                  .
      w_cv_item-nrg   = v_sequencia               . " N�mero de registro
      w_cv_item-vbeln = <f_w_comissao_aux>-vbeln  . " Documento de vendas
      w_cv_item-ebeln = space                     . " N� do documento de compras
      w_cv_item-bstnk = <f_w_comissao_aux>-bstnk  . " N� pedido do cliente
      w_cv_item-netwr = <f_w_comissao_aux>-netwr  . " Valor l�quido do item
      w_cv_item-vcom  = <f_w_comissao_aux>-vcom   . " Valor total da comiss�o
      w_cv_item-vcomp = <f_w_comissao_aux>-vcomp  . " Valor � compensar
      w_cv_item-vcopd = <f_w_comissao_aux>-vcopd  . " Valor compensado

      READ TABLE t_vbfa
      ASSIGNING FIELD-SYMBOL(<f_w_vbfa>)
      WITH KEY vbelv = <f_w_comissao_aux>-vbeln.

      IF sy-subrc = 0.
        READ TABLE t_bseg
        ASSIGNING FIELD-SYMBOL(<f_w_bseg>)
        WITH KEY vbeln = <f_w_vbfa>-vbeln.

        IF sy-subrc = 0.
          w_cv_item-augbl = <f_w_bseg>-augbl. " N� documento de compensa��o
          APPEND w_cv_item TO t_cv_item.
        ENDIF.
      ENDIF.

      READ TABLE im_t_comissao
      TRANSPORTING NO FIELDS
      WITH KEY vbeln = <f_w_comissao_aux>-vbeln.

      IF sy-subrc = 0.
        DELETE im_t_comissao INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT t_cv_cabec BY nrg ASCENDING.
  DELETE ADJACENT DUPLICATES FROM t_cv_cabec.

  IF t_cv_cabec IS NOT INITIAL
    AND t_cv_item IS NOT INITIAL.

    MODIFY:
      zsdt033c FROM TABLE t_cv_cabec,  " Comiss�o de Vendas - Cabe�alho
      zsdt033i FROM TABLE t_cv_item .  " Comiss�o de Vendas - �tem

    LOOP AT t_cv_cabec INTO w_cv_cabec.
      me->exibir_rel_comissao_vendas( EXPORTING im_nr_registro = w_cv_cabec-nrg
                                       CHANGING im_t_comissao  = t_comissao_aux ).
    ENDLOOP.
  ENDIF.

ENDMETHOD.

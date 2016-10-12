*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Criar pedido de compras de servi�o (ME21N)                *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  10.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_APROV_COMISSAO TYPE TY_APROV_COMISSAO
*<-- CHANGING  EX_NRO_PEDIDO     TYPE VBAK-BSTNK
*<-- CHANGING  EX_BAPIRET2       TYPE TP_BAPIRET2

METHOD criar_pedido_compras.
*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_item             TYPE STANDARD TABLE OF bapimepoitem    , " Item do pedido
    t_itemx            TYPE STANDARD TABLE OF bapimepoitemx   , " Dados do item do pedido (barra de modifica��o)
    t_divisao_remessa  TYPE STANDARD TABLE OF bapimeposchedule, " Campos para divis�es de remessa do pedido
    t_divisao_remessax TYPE STANDARD TABLE OF bapimeposchedulx, " Campos p/divis�es de remessa do pedido (barra modifica��o)
    t_cl_contabil      TYPE STANDARD TABLE OF bapimepoaccount , " Campos de classifica��o cont�bil do pedido
    t_cl_contabilx     TYPE STANDARD TABLE OF bapimepoaccountx, " Campos de classif.cont�bil do pedido (barra modifica��o)
    t_limite           TYPE STANDARD TABLE OF bapiesuhc       , " Estrutura de comunica��o limites
    t_servico          TYPE STANDARD TABLE OF bapiesllc       , " Estrutura de comunica��o criar linha de servi�o
    t_cl_ctb_servico   TYPE STANDARD TABLE OF bapiesklc       , " Estrut.comunica��o criar distrib.class.cont.linha servi�o
    t_bapi_return      TYPE STANDARD TABLE OF bapiret2        . " Par�metro de retorno

*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_cabecalho        TYPE bapimepoheader            , " Pedido dds.cabe�alho
    w_cabecalhox       TYPE bapimepoheaderx           , " Dados do cabe�alho do pedido (barra de modifica��o)
    w_item             LIKE LINE OF t_item            ,
    w_itemx            LIKE LINE OF t_itemx           ,
    w_divisao_remessa  LIKE LINE OF t_divisao_remessa ,
    w_divisao_remessax LIKE LINE OF t_divisao_remessax,
    w_cl_contabil      LIKE LINE OF t_cl_contabil     ,
    w_cl_contabilx     LIKE LINE OF t_cl_contabilx    ,
    w_limite           LIKE LINE OF t_limite          ,
    w_servico          LIKE LINE OF t_servico         ,
    w_cl_ctb_servico   LIKE LINE OF t_cl_ctb_servico  ,
    w_bapi_return      LIKE LINE OF t_bapi_return     .

*----------------------------------------------------------------------*
* Vari�veis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_nro_pedido_compras TYPE bapimepoheader-po_number,
    v_nro_fornecedor     TYPE lfa1-lifnr              .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS:
    c_item                  TYPE ebelp       VALUE 00010               ,
    c_gnatus_matriz         TYPE t001w-werks VALUE '1000'              ,
    c_gnatus_empresa        TYPE t001-bukrs  VALUE '1000'              ,
    c_gnatus_grupo          TYPE t024e-ekorg VALUE '1000'              ,
    c_felipe_zimmerman      TYPE t024-ekgrp  VALUE '100'               ,
    c_centro_custos_ctag    TYPE csks-kostl  VALUE '0000104405'        ,
    c_br_real               TYPE tcurc-waers VALUE 'BRL'               ,
    c_custo_seguro_frete    TYPE tinc-inco1  VALUE 'CIF'               ,
    c_qtd_pedido            TYPE bstmg       VALUE 1                   ,
    c_unidade_medida_ua     TYPE t006-msehi  VALUE 'UA'                ,
*    c_preco_liquido         TYPE bapicurext  VALUE 1                   ,
    c_preco_bruto           TYPE bpueb       VALUE '1'                 ,
    c_iva_servico           TYPE t007a-mwskz VALUE 'SV'                ,
    c_centro_custos         TYPE t163k-knttp VALUE 'K'                 ,
    c_prestacao_servico     TYPE t163-pstyp  VALUE 'D'                 ,
    c_dsc_item              TYPE txz01       VALUE 'Comiss�o Vendas'   , "#EC NOTEXT
    c_dsc_servico           TYPE txz01       VALUE 'Servi�o 1'         , "#EC NOTEXT
    c_grp_merc_servicos     TYPE t023-matkl  VALUE 'YBSVS1'            ,
    c_pedido_normal         TYPE t161-bsart  VALUE 'NB'                ,
    c_comissao_sobre_vendas TYPE ska1-saknr  VALUE '0032207001'        ,
    c_servico_comissao      TYPE asmd-asnum  VALUE '000000000003000151',
    c_nro_pacote_l1         TYPE packno      VALUE '0000000001'        ,
    c_nro_pacote_l3         TYPE packno      VALUE '0000000003'        ,
    c_nro_linha_l1          TYPE srv_line_no VALUE '0000000001'        ,
    c_nro_linha_l2          TYPE srv_line_no VALUE '0000000002'        ,
    c_nro_subpacote_l1      TYPE sub_packno  VALUE '0000000003'        ,
    c_nro_seq_cl_ctb        TYPE dzekkn      VALUE 1                   ,
    c_nro_seq_linha_servico TYPE numkn       VALUE 1                   .

*----------------------------------------------------------------------*
* Pedido dds.cabe�alho
*----------------------------------------------------------------------*
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = im_aprov_comissao-lifnr
    IMPORTING
      output = v_nro_fornecedor.

  CLEAR w_cabecalho                            .
  w_cabecalho-doc_type   = c_pedido_normal     . " Tipo de documento de compras (NB)
  w_cabecalho-vendor     = v_nro_fornecedor    . " N� conta do fornecedor
  w_cabecalho-comp_code  = c_gnatus_empresa    . " Empresa (1000)
  w_cabecalho-purch_org  = c_gnatus_grupo      . " Organiza��o de compras (1000)
  w_cabecalho-pur_group  = c_felipe_zimmerman  . " Grupo de compradores (100)
  w_cabecalho-doc_date   = sy-datum            . " Data do documento de compra
  w_cabecalho-currency   = c_br_real           . " C�digo da moeda (BRL)
  w_cabecalho-incoterms1 = c_custo_seguro_frete. " Incoterms parte 1 (CIF)

*----------------------------------------------------------------------*
* Dados do cabe�alho do pedido (barra de modifica��o)
*----------------------------------------------------------------------*
  CLEAR w_cabecalhox                 .
  w_cabecalhox-doc_type   = abap_true.
  w_cabecalhox-doc_date   = abap_true.
  w_cabecalhox-incoterms1 = abap_true.
  w_cabecalhox-vendor     = abap_true.
  w_cabecalhox-currency   = abap_true.
  w_cabecalhox-comp_code  = abap_true.
  w_cabecalhox-purch_org  = abap_true.
  w_cabecalhox-pur_group  = abap_true.

*----------------------------------------------------------------------*
* Item do pedido
*----------------------------------------------------------------------*
  CLEAR w_item                               .
  w_item-po_item    = c_item                 . " N� item do documento de compra (10)
  w_item-plant      = c_gnatus_matriz        . " Centro (1000)
  w_item-quantity   = c_qtd_pedido           . " Quantidade do pedido (1)
  w_item-po_unit    = c_unidade_medida_ua    . " Unidade de Medida (UA)
  w_item-net_price  = im_aprov_comissao-vlpag. " Valor do pre�o l�quido (Valor da comiss�o)
  w_item-po_price   = c_preco_bruto          . " Transfer�ncia do pre�o (1)
  w_item-tax_code   = c_iva_servico          . " C�digo do IVA (SV)
  w_item-acctasscat = c_centro_custos        . " Categoria de classifica��o cont�bil (K)
  w_item-item_cat   = c_prestacao_servico    . " Ctg.item no documento compra (D)
  w_item-short_text = c_dsc_item             . " Texto Breve (COMISS�O VENDAS)
  w_item-matl_group = c_grp_merc_servicos    . " Grupo de mercadorias (YBSVS1).
  w_item-pckg_no    = c_nro_pacote_l1        . " N� pacote
  APPEND w_item TO t_item                    . " BAPIMEPOITEM

*----------------------------------------------------------------------*
* Dados do item do pedido (barra de modifica��o)
*----------------------------------------------------------------------*
  CLEAR w_itemx                 .
  w_itemx-po_item    = c_item   .
  w_itemx-plant      = abap_true.
  w_itemx-quantity   = abap_true.
  w_itemx-po_unit    = abap_true.
  w_itemx-net_price  = abap_true.
  w_itemx-po_price   = abap_true.
  w_itemx-tax_code   = abap_true.
  w_itemx-acctasscat = abap_true.
  w_itemx-item_cat   = abap_true.
  w_itemx-short_text = abap_true.
  w_itemx-matl_group = abap_true.
  w_itemx-pckg_no    = abap_true.
  APPEND w_itemx TO t_itemx     . " BAPIMEPOITEMX

*----------------------------------------------------------------------*
* Campos para divis�es de remessa do pedido
*----------------------------------------------------------------------*
  CLEAR w_divisao_remessa                      .
  w_divisao_remessa-po_item       = c_item     .
  w_divisao_remessa-delivery_date = sy-datum   .
  APPEND w_divisao_remessa TO t_divisao_remessa. " BAPIMEPOSCHEDULE

*----------------------------------------------------------------------*
* Campos p/divis�es de remessa do pedido (barra modifica��o)
*----------------------------------------------------------------------*
  CLEAR w_divisao_remessax                       .
  w_divisao_remessax-po_item       = c_item      .
  w_divisao_remessax-delivery_date = abap_true   .
  APPEND w_divisao_remessax TO t_divisao_remessax. " BAPIMEPOACCOUNT

*----------------------------------------------------------------------*
* Campos de classifica��o cont�bil do pedido
*----------------------------------------------------------------------*
  CLEAR w_cl_contabil                               .
  w_cl_contabil-po_item    = c_item                 . " N� item do documento de compra (10)
  w_cl_contabil-serial_no  = c_nro_seq_cl_ctb       . " N� seq�encial da classifica��o cont�bil (1)
  w_cl_contabil-creat_date = sy-datum               . " Data de cria��o do registro
  w_cl_contabil-quantity   = c_qtd_pedido           . " Quantidade (1)
  w_cl_contabil-gl_account = c_comissao_sobre_vendas. " N� conta do Raz�o (32207001)
  w_cl_contabil-costcenter = c_centro_custos_ctag   . " Centro de Custos (104405)
  APPEND w_cl_contabil TO t_cl_contabil             . " BAPIMEPOACCOUNT

*----------------------------------------------------------------------*
* Campos de classif.cont�bil do pedido (barra modifica��o)
*----------------------------------------------------------------------*
  CLEAR w_cl_contabilx                        .
  w_cl_contabilx-po_item    = c_item          .
  w_cl_contabilx-serial_no  = c_nro_seq_cl_ctb.
  w_cl_contabilx-creat_date = abap_true       .
  w_cl_contabilx-quantity   = abap_true       .
  w_cl_contabilx-gl_account = abap_true       .
  w_cl_contabilx-costcenter = abap_true       .
  APPEND w_cl_contabilx TO t_cl_contabilx     . " BAPIMEPOACCOUNTX

*----------------------------------------------------------------------*
* Estrutura de comunica��o limites
*----------------------------------------------------------------------*
  CLEAR w_limite                    .
  w_limite-pckg_no = c_nro_pacote_l1. " N� pacote (0000000001)
  APPEND w_limite TO t_limite       . " BAPIESUHC

*----------------------------------------------------------------------*
* Linha de servi�os
*----------------------------------------------------------------------*
  w_servico-pckg_no    = c_nro_pacote_l1    . " N� pacote (0000000001)
  w_servico-line_no    = c_nro_linha_l1     . " N� interno de linha (0000000001)
  w_servico-outl_ind   = abap_true          . " C�digo linha da estrutura hier�rquica
  w_servico-subpckg_no = c_nro_subpacote_l1 . " N� do subpacote (0000000003)
  w_servico-quantity   = c_qtd_pedido       . " Quantidade (1.00)
  w_servico-base_uom   = c_unidade_medida_ua. " Unidade de medida b�sica (UA)
  w_servico-price_unit = c_qtd_pedido       . " Unidade de pre�o (1)
  w_servico-gr_price   = c_preco_bruto      . " Pre�o bruto (1)
  APPEND w_servico TO t_servico             . " BAPIESLLC

  w_servico-pckg_no    = c_nro_pacote_l3    . " N� pacote (0000000003)
  w_servico-line_no    = c_nro_linha_l2     . " N� interno de linha (0000000002)
  w_servico-quantity   = c_qtd_pedido       . " Quantidade (1.00)
  w_servico-base_uom   = c_unidade_medida_ua. " Unidade de medida b�sica (UA)
  w_servico-price_unit = c_qtd_pedido       . " Unidade de pre�o (1.00)
  w_servico-gr_price   = c_preco_bruto      . " Pre�o bruto (1)
  w_servico-matl_group = c_grp_merc_servicos. " Grupo de mercadorias (YBSVS1)
  w_servico-service    = c_servico_comissao . " N� de servi�o do fornecedor (000000000003000151)
  APPEND w_servico TO t_servico             . " BAPIESLLC

*----------------------------------------------------------------------*
* Estrut.comunica��o criar distrib.class.cont.linha servi�o
*----------------------------------------------------------------------*
  CLEAR w_cl_ctb_servico                               .
  w_cl_ctb_servico-pckg_no    = c_nro_pacote_l3        . " N� pacote (0000000003)
  w_cl_ctb_servico-line_no    = c_nro_linha_l2         . " N� interno de linha (0000000002)
  w_cl_ctb_servico-serno_line = c_nro_seq_linha_servico. " N� sequencial atribui��o class.cont.linha de servi�o (01)
  w_cl_ctb_servico-serial_no  = c_nro_seq_cl_ctb       . " N� seq�encial da classifica��o cont�bil (01)
  w_cl_ctb_servico-quantity   = c_qtd_pedido           . " Quantidade (1.00)
  APPEND w_cl_ctb_servico TO t_cl_ctb_servico          . " BAPIESKLC

*----------------------------------------------------------------------*
* Criar pedido de compras - T-CODE ME21N
*----------------------------------------------------------------------*
  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader          = w_cabecalho          " Pedido dds.cabe�alho
      poheaderx         = w_cabecalhox         " Dados do cabe�alho do pedido (barra de modifica��o)
    IMPORTING
      exppurchaseorder  = v_nro_pedido_compras " N� do documento de compras
    TABLES
      return            = ex_t_bapiret2        " Par�metro de retorno
      poitem            = t_item               " Item do pedido
      poitemx           = t_itemx              " Dados do item do pedido (barra de modifica��o)
      poschedule        = t_divisao_remessa    " Campos para divis�es de remessa do pedido
      poschedulex       = t_divisao_remessax   " Campos p/divis�es de remessa do pedido (barra modifica��o)
      poaccount         = t_cl_contabil        " Campos de classifica��o cont�bil do pedido
      poaccountx        = t_cl_contabilx       " Campos de classif.cont�bil do pedido (barra modifica��o)
      polimits          = t_limite             " Estrutura de comunica��o limites
      poservices        = t_servico            " Estrutura de comunica��o criar linha de servi�o
      posrvaccessvalues = t_cl_ctb_servico.    " Estrut.comunica��o criar distrib.class.cont.linha servi�o

  IF v_nro_pedido_compras IS NOT INITIAL.
    ex_nro_pedido = v_nro_pedido_compras.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    DATA: w_ekpo TYPE ekpo.

    SELECT SINGLE * FROM ekpo
     INTO w_ekpo
     WHERE ebeln = ex_nro_pedido.

    IF sy-subrc = 0.
      w_ekpo-netpr = im_aprov_comissao-vlpag.
      MODIFY ekpo FROM w_ekpo.
    ENDIF.
  ENDIF.

ENDMETHOD.

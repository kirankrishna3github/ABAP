FUNCTION ysd_vk15.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(T946) TYPE  YCT_A946 OPTIONAL
*"     VALUE(T947) TYPE  YCT_A947 OPTIONAL
*"     VALUE(T960) TYPE  YCT_A960 OPTIONAL
*"     VALUE(T961) TYPE  YCT_A961 OPTIONAL
*"     VALUE(T962) TYPE  YCT_A962 OPTIONAL
*"     VALUE(T963) TYPE  YCT_A963 OPTIONAL
*"     VALUE(T968) TYPE  YCT_A968 OPTIONAL
*"     VALUE(T969) TYPE  YCT_A969 OPTIONAL
*"     VALUE(T972) TYPE  YCT_A972 OPTIONAL
*"  EXPORTING
*"     VALUE(T_RETORNO) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* M�dulo de Fun��o : YSD_VK15                                          *
* Grupo de Fun��es : YSD_CRIA_COND                                     *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Cria condi��o de pagamento na transa��o VK15 utilizando   *
*            a RFC existente de forma ass�ncrona                       *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  26.03.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_bapicondct  TYPE STANDARD TABLE OF bapicondct     , " Estrutura BAPI p/tabelas de condi��es (corresp. a COND_RECS)
    t_bapicondhd  TYPE STANDARD TABLE OF bapicondhd     , " Bapistructure of KONH with english field names
    t_bapicondit  TYPE STANDARD TABLE OF bapicondit     , " Bapistructure of KONP with english field names
    t_bapicondqs  TYPE STANDARD TABLE OF bapicondqs     , " Bapistructure of KONM with english field names
    t_bapicondvs  TYPE STANDARD TABLE OF bapicondvs     , " Bapistructure of KONW with english field names
    t_bapiret2    TYPE STANDARD TABLE OF bapiret2       , " Par�metro de retorno
    t_bapiknumhs  TYPE STANDARD TABLE OF bapiknumhs     , " Estrutura BAPI para a atribui��o de KNUMHs
    t_mem_initial TYPE STANDARD TABLE OF cnd_mem_initial. " Condi��es: buffer para transfer�ncia de dados inicial

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_bapicondct LIKE LINE OF t_bapicondct, " Estrutura BAPI p/tabelas de condi��es (corresp. a COND_RECS)
    w_bapicondhd LIKE LINE OF t_bapicondhd, " Bapistructure of KONW with english field names
    w_bapicondit LIKE LINE OF t_bapicondit, " Bapistructure of KONW with english field names
    w_bapicondqs LIKE LINE OF t_bapicondqs, " Bapistructure of KONW with english field names
    w_bapicondvs LIKE LINE OF t_bapicondvs, " Bapistructure of KONW with english field names
    w_bapiret2   LIKE LINE OF t_bapiret2  , " Par�metro de retorno
    w_bapiknumhs LIKE LINE OF t_bapiknumhs, " Estrutura BAPI para a atribui��o de KNUMHs
    w_946        LIKE LINE OF t946        , " Tabela A946 - EscrVendas/Cliente/Material/Lote/Tipo ped.
    w_947        LIKE LINE OF t947        , " Tabela A947 - EscrVendas/Cliente/Material/Tipo ped.
    w_960        LIKE LINE OF t960        , " Tabela A960 - EscrVendas/Cliente/Material
    w_961        LIKE LINE OF t961        , " Tabela A961 - EscrVendas/GrpClients/Grupo mat.
    w_962        LIKE LINE OF t962        , " Tabela A962 - EscrVendas/Material
    w_963        LIKE LINE OF t963        , " Tabela A963 - EscrVendas/Cliente/Grupo mat.
    w_968        LIKE LINE OF t968        , " Tabela A968 - EscrVendas/GrpClients/Grupo mat./Material
    w_969        LIKE LINE OF t969        , " Tabela A969 - EscrVendas/Regi�o/Grupo mat.
    w_972        LIKE LINE OF t972        . " Tabela A972 - EscrVendas/Regi�o/Material

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_data_inicial TYPE sy-datum  ,
    v_data_final   TYPE sy-datum  ,
    v_mont_char    TYPE char30    ,
    v_montante     TYPE bapicurext.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_aplicacao_sd        TYPE t681a-kappl VALUE 'V'   ,
    c_funcao_substituicao TYPE msgfn       VALUE '5'   ,
    c_desc_comercial      TYPE t685-kschl  VALUE 'YDEC',
    c_determinacao_preco  TYPE t681v-kvewe VALUE 'A'   ,
    c_br_real             TYPE tcurc-waers VALUE 'BRL' ,
    c_percentual          TYPE krech       VALUE 'A'   .

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  CLEAR w_963                     .
  w_963-escr_vendas = '5500'      .
  w_963-cliente     = '0000100923'.
  w_963-grupo_mat   = '14'        .                         "<---- 10
  w_963-montante    = '75,00'     .
  w_963-data1       = '01.03.2015'.
  w_963-data2       = '31.03.2015'.
  w_963-cond_pagto  = 'Y029'      .
  APPEND w_963 TO t963            .


*----------------------------------------------------------------------*
*EscrVendas/Cliente/Grupo mat.
*----------------------------------------------------------------------*
  LOOP AT t963 INTO w_963.
    CLEAR: v_data_inicial, v_mont_char, v_data_final, v_montante.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = w_963-data1
      IMPORTING
        date_internal            = v_data_inicial
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = w_963-data2
      IMPORTING
        date_internal            = v_data_final
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.

    v_mont_char =  w_963-montante.

    CALL FUNCTION 'C14DG_CHAR_NUMBER_CONVERSION'
      EXPORTING
        i_string                   = v_mont_char
      IMPORTING
        e_dec                      = v_montante
      EXCEPTIONS
        wrong_characters           = 1
        first_character_wrong      = 2
        arithmetic_sign            = 3
        multiple_decimal_separator = 4
        thousandsep_in_decimal     = 5
        thousand_separator         = 6
        number_too_big             = 7
        OTHERS                     = 8.

    CLEAR w_bapicondct.
    w_bapicondct-operation  = c_funcao_substituicao. " Original: primeira mensagem para opera��o
    w_bapicondct-applicatio = c_aplicacao_sd       . " Aplica��o
    w_bapicondct-cond_type  = c_desc_comercial     . " Tipo de condi��o
    w_bapicondct-table_no   = '963'                . " Tabela de condi��es
    w_bapicondct-cond_usage = c_determinacao_preco . " Utiliza��o da tabela de condi��es
    w_bapicondct-cond_no    = '$000000001'         . " N� registro de condi��o
    w_bapicondct-valid_from = v_data_inicial       . " Data in�cio validade
    w_bapicondct-valid_to   = v_data_final         . " Data de validade final

    CONCATENATE w_963-escr_vendas                 " Escrit�rio de vendas
                w_963-cliente                     " N� cliente
                w_963-grupo_mat                   " Grupo de condi��es material
           INTO w_bapicondct-varkey.

    APPEND w_bapicondct TO t_bapicondct.

    CLEAR w_bapicondhd                             .
    w_bapicondhd-operation  = c_funcao_substituicao. " Fun��o
    w_bapicondhd-applicatio = c_aplicacao_sd       . " Aplica��o
    w_bapicondhd-cond_type  = c_desc_comercial     . " Tipo de condi��o
    w_bapicondhd-table_no   = '963'                . " Tabela de condi��es
    w_bapicondhd-cond_usage = c_determinacao_preco . " Utiliza��o da tabela de condi��es
    w_bapicondhd-cond_no    = '$000000001'         . " N� registro de condi��o
    w_bapicondhd-created_by = sy-uname             . " Nome do respons�vel que adicionou o objeto
    w_bapicondhd-creat_date = sy-datum             . " Data de cria��o do registro
    w_bapicondhd-varkey     = w_bapicondct-varkey  . " Chave vari�vel
    w_bapicondhd-valid_from = v_data_inicial       . " Data in�cio validade
    w_bapicondhd-valid_to   = v_data_final         . " Data de validade final
    APPEND w_bapicondhd TO t_bapicondhd            .

    CLEAR w_bapicondit                             .
    w_bapicondit-operation  = c_funcao_substituicao. " Fun��o
    w_bapicondit-applicatio = c_aplicacao_sd       . " Aplica��o
    w_bapicondit-cond_type  = c_desc_comercial     . " Tipo de condi��o
    w_bapicondit-cond_no    = '$000000001'         . " N� registro de condi��o
    w_bapicondit-scaletype  = c_determinacao_preco . " Tipo de escala
    w_bapicondit-calctypcon = c_percentual         . " Regra de c�lculo de condi��o
    w_bapicondit-cond_count = sy-tabix             . " N� seq�encial da condi��o
    w_bapicondit-cond_value = v_montante           . " Montante em moeda para BAPIs (com 9 casas decimais)
    w_bapicondit-condcurr   = c_br_real            . " Unidade de condi��o (moeda ou porcentagem)
    w_bapicondit-pmnttrms   = w_963-cond_pagto     . " Chave de condi��es de pagamento
    w_bapicondit-conditidx = sy-tabix              .

    APPEND w_bapicondit TO t_bapicondit            .
  ENDLOOP.

*----------------------------------------------------------------------*
*EscrVendas/Cliente/Grupo mat.
*----------------------------------------------------------------------*
  IF t963 IS NOT INITIAL.
    CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
      EXPORTING
        pi_initialmode = 'X'
      TABLES
        ti_bapicondct  = t_bapicondct
        ti_bapicondhd  = t_bapicondhd
        ti_bapicondit  = t_bapicondit
        ti_bapicondqs  = t_bapicondqs
        ti_bapicondvs  = t_bapicondvs
        to_bapiret2    = t_bapiret2
        to_bapiknumhs  = t_bapiknumhs
        to_mem_initial = t_mem_initial
      EXCEPTIONS
        update_error   = 1
        OTHERS         = 2.

    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.

    APPEND LINES OF t_bapiret2 TO t_retorno.
  ENDIF.

ENDFUNCTION.
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obter tipo de condi��o x parceiro                         *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  29.09.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_TIPO_PARCEIRO	TYPE FEHGR
*<-- CHANGING EX_R_KSCHL        TYPE R_KSCHL Tipo de condi��o
*<-- CHANGING EX_R_PARVW        TYPE R_PARVW Fun��o do parceiro
*<-- CHANGING EX_T_COND_PARC    TYPE TP_COND_PARC Tipo de condi��o x Parceiro

METHOD get_tipo_condicao_parceiro.
*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_parvw LIKE LINE OF ex_r_parvw,
    w_kschl LIKE LINE OF ex_r_kschl.

*----------------------------------------------------------------------*
* Vari�veis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE t100-text.

*----------------------------------------------------------------------*
* In�cio                                                               *
*----------------------------------------------------------------------*
  SELECT kschl   " Tipo de condi��o
         parvw   " Parceiro
         fehgr   " Esquema de dados
   FROM zsdt033p " Comiss�o de Vendas - Tipo de condi��o x Parceiro
   INTO TABLE ex_t_cond_parc
   WHERE fehgr = im_tipo_parceiro.

  IF ex_t_cond_parc IS INITIAL.
*   N�o h� dados na tabela de condi��es x parceiros
    MESSAGE e002(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  LOOP AT ex_t_cond_parc ASSIGNING FIELD-SYMBOL(<f_w_cond_parc>).
    w_parvw-sign   = 'I'                  .                 "#EC NOTEXT
    w_parvw-option = 'EQ'                 .                 "#EC NOTEXT
    w_parvw-low    = <f_w_cond_parc>-parvw.
    APPEND w_parvw TO ex_r_parvw          .

    w_kschl-sign   = 'I'                  .                 "#EC NOTEXT
    w_kschl-option = 'EQ'                 .                 "#EC NOTEXT
    w_kschl-low    = <f_w_cond_parc>-kschl.
    APPEND w_kschl TO ex_r_kschl          .
  ENDLOOP.

ENDMETHOD.

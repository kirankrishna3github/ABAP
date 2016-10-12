*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* M�todo   : MODIFICAR_UM_PROPORCIONAL                                 *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Modificar aba "UM proporc./produto" dos dados adicionais  *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.09.2015  #118470 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD modificar_um_proporcional.
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
     o_bdc   TYPE REF TO ycl_bdc,
     v_subrc TYPE sy-subrc      .

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_bdc_msg TYPE tab_bdcmsgcoll.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_bapiret2    TYPE bapiret2              ,
     w_um_proporc  TYPE yach_l_um_proporc_prod,
     w_bdc_msg     LIKE LINE OF t_bdc_msg     .

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  IF im_t_um_proporc IS INITIAL.
    EXIT.
  ENDIF.

* Modificar cadastro de material
  o_bdc = ycl_bdc=>s_instantiate( im_bdc_type = 'CT'
                                  im_tcode    = 'MM02' ).

* Tela inicial
  o_bdc->add_screen( im_repid = 'SAPLMGMM'             im_dynnr = '0060'                 ).
  o_bdc->add_field( im_fld    = 'RMMG1-MATNR'          im_val   = im_material            ). " N� do material
  o_bdc->add_field( im_fld    = 'BDC_OKCODE'           im_val   = '=ENTR'                ).

* Sele��o de vis�es
  o_bdc->add_screen( im_repid = 'SAPLMGMM'             im_dynnr = '0070'                 ).
  o_bdc->add_field( im_fld    = 'BDC_CURSOR'           im_val   = 'MSICHTAUSW-DYTXT(01)' ). " Dados b�sicos 1
  o_bdc->add_field( im_fld    = 'MSICHTAUSW-KZSEL(01)' im_val   = 'X'                    ).
  o_bdc->add_field( im_fld    = 'BDC_OKCODE'           im_val   = '=ENTR'                ).

* Ir para Dados Adicionais
  o_bdc->add_screen( im_repid = 'SAPLMGMM'             im_dynnr = '4004'                 ).
  o_bdc->add_field( im_fld    = 'BDC_OKCODE'           im_val   = '=ZU01'                ).

* Selecionar a aba "UM proporc./produto" dentro dos Dados Adicionais
  o_bdc->add_screen( im_repid = 'SAPLMGMM'             im_dynnr = '4300'                 ).
  o_bdc->add_field( im_fld    = 'BDC_OKCODE'           im_val   = '=ZU09'                ).

  READ TABLE im_t_um_proporc
  INTO w_um_proporc
  INDEX 1.

  IF sy-subrc = 0.
*   Informar a utiliza��o/categorias de unidades de medida
    o_bdc->add_screen( im_repid = 'SAPLMGMM'             im_dynnr = '4300'               ).
    o_bdc->add_field( im_fld    = 'MARA-KZWSM'           im_val   = w_um_proporc-kzwsm   ). " Utiliza��o/categorias de unidades de medida
    o_bdc->add_field( im_fld    = 'BDC_OKCODE'           im_val   = '/00'                ).

*   Informar valor da utiliza��o/categorias de unidades de medida
    o_bdc->add_screen( im_repid = 'SAPLMGMM'             im_dynnr = '4300'               ).
    o_bdc->add_field( im_fld    = 'SMEINH_WS-ATNAM(01)'  im_val   = w_um_proporc-atnam   ). " Nome da caracter�stica
    o_bdc->add_field( im_fld    = 'SMEINH_WS-ATWRT(01)'  im_val   = w_um_proporc-atwrt   ). " Valor plan.para unid.medida (quota plan./convers�o)
    o_bdc->add_field( im_fld    = 'SMEINH_WS-WSMEI(01)'  im_val   = w_um_proporc-wsmei   ). " UM material espec�fica de lote (UM proporcional/produto)
    o_bdc->add_field( im_fld    = 'BDC_OKCODE'           im_val   = '=BU'                ).
  ENDIF.

  o_bdc->process( IMPORTING ex_subrc    = v_subrc
                            ex_messages = t_bdc_msg ).

  o_bdc->clear_bdc_data( ).

  o_bdc->s_free_instance( ).

* Retorna a mensagem de erro do Batch Input
  IF v_subrc <> 0.
    LOOP AT t_bdc_msg INTO w_bdc_msg.
      MESSAGE ID w_bdc_msg-msgid
            TYPE w_bdc_msg-msgtyp
          NUMBER w_bdc_msg-msgnr
            WITH w_bdc_msg-msgv1
                 w_bdc_msg-msgv2
                 w_bdc_msg-msgv3
                 w_bdc_msg-msgv4
            INTO w_bapiret2-message.

      w_bapiret2-type       = w_bdc_msg-msgtyp.
      w_bapiret2-id         = w_bdc_msg-msgid.
      w_bapiret2-number     = w_bdc_msg-msgnr.
      w_bapiret2-message_v1 = w_bdc_msg-msgv1.
      w_bapiret2-message_v2 = w_bdc_msg-msgv2.
      w_bapiret2-message_v3 = w_bdc_msg-msgv3.
      w_bapiret2-message_v4 = w_bdc_msg-msgv4.
      APPEND w_bapiret2 TO ex_t_bapiret2.
    ENDLOOP.
  ENDIF.

ENDMETHOD.
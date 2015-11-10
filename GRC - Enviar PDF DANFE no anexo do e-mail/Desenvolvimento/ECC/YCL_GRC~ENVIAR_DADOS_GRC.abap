*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_GRC                                                   *
* M�todo   : ENVIAR_DADOS_GRC                                          *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Enviar dados para GRC                                     *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  08.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD enviar_dados_grc.
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
     v_qtd_registros TYPE i              ,
     v_msg_erro      TYPE string         ,
     v_rfc_sap_grc   TYPE rs38l-name     ,
     v_group         TYPE rs38l-area     ,                  "#EC NEEDED
     v_include       TYPE rs38l-include  ,                  "#EC NEEDED
     v_namespace     TYPE rs38l-namespace,                  "#EC NEEDED
     v_str_area      TYPE rs38l-str_area .                  "#EC NEEDED

*----------------------------------------------------------------------*
* Vari�veis tipo refer�ncia
*----------------------------------------------------------------------*
  DATA:
     o_cx_root TYPE REF TO cx_root.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
     grc_rfc_destination  TYPE string VALUE 'NFE_IN'               ,
     rfc_grc_enviar_email TYPE string VALUE 'YNFE_ENVIAR_XML_EMAIL'.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

* Destino l�gico (indicado em chamada de fun��o)
  SELECT COUNT( DISTINCT rfcdest )
   FROM rfcdes
   INTO v_qtd_registros
   WHERE rfcdest = grc_rfc_destination.

  IF v_qtd_registros = 0.
*   A RFC destination n�o foi encontrada
    MESSAGE e004(ygrc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
  ENDIF.

* Testa a conex�o com o SAP GRC
  CALL FUNCTION 'RFC_PING'
    DESTINATION grc_rfc_destination
    EXCEPTIONS
      system_failure        = 1
      communication_failure = 2
      OTHERS                = 3.

  IF sy-subrc <> 0.
*   Erro na conex�o com o GRC
    MESSAGE e005(ygrc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
  ENDIF.

  v_rfc_sap_grc = rfc_grc_enviar_email.

  CALL FUNCTION 'FUNCTION_EXISTS'
    DESTINATION grc_rfc_destination
    EXPORTING
      funcname           = v_rfc_sap_grc
    IMPORTING
      group              = v_group
      include            = v_include
      namespace          = v_namespace
      str_area           = v_str_area
    EXCEPTIONS
      function_not_exist = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
*   M�dulo de fun��o n�o existe no SAP GRC
    MESSAGE e006(ygrc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
  ENDIF.

  TRY.
      CALL FUNCTION v_rfc_sap_grc       " YNFE_ENVIAR_XML_EMAIL
        DESTINATION grc_rfc_destination " NFE_IN
        EXPORTING
          chave_acesso          = im_chave_acesso
          t_pdf_binario         = im_t_pdf_danfe
          nro_pedido            = im_nro_pedido
          t_destinatario        = im_t_destinatario
        IMPORTING
          qtd_emails_enviados   = rt_qtd_email_enviado
        EXCEPTIONS
          erro_envio            = 1
          communication_failure = 2
          system_failure        = 3
          OTHERS                = 4.

      IF sy-subrc <> 0.
*       Erro na chamada da RFC do GRC
        MESSAGE e007(ygrc) INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
      ENDIF.

    CATCH cx_root INTO o_cx_root.                        "#EC CATCH_ALL
*     Erro na chamada da RFC do GRC
      v_msg_erro = o_cx_root->get_text( ).
      RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.
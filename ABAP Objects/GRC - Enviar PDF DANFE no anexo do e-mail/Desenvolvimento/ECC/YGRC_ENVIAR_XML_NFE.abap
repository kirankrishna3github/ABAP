FUNCTION ygrc_enviar_xml_nfe.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(DOCNUM) TYPE  J_1BDOCNUM
*"  EXPORTING
*"     VALUE(QTD_EMAILS_ENVIADOS) TYPE  SY-TABIX
*"  EXCEPTIONS
*"      ERRO_ENVIO
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* M�dulo de Fun��o : YGRC_ENVIAR_XML_NFE                               *
* Grupo de Fun��es : YGF_GRC_ECC                                       *
*----------------------------------------------------------------------*
* Descri��o: Enviar XML & DANFE por e-mail atrav�s do GRC              *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome       Data        Descri��o                                     *
* ACTHIAGO   07.10.2015  #109075 - Codifica��o inicial                 *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
     v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Vari�veis de refer�ncia
*----------------------------------------------------------------------*
  DATA:
     o_grc     TYPE REF TO ycl_grc,
     o_exp_grc TYPE REF TO ycx_grc.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  TRY.
      CREATE OBJECT o_grc TYPE ycl_grc.

      qtd_emails_enviados = o_grc->enviar_email_xml_danfe( docnum ).

    CATCH ycx_grc INTO o_exp_grc.
      v_msg_erro = o_exp_grc->msg.

      MESSAGE e398(00) WITH v_msg_erro RAISING erro_envio.
      EXIT.
  ENDTRY.

ENDFUNCTION.
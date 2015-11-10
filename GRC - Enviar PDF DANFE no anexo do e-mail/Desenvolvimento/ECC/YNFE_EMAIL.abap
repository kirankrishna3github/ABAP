FUNCTION ynfe_email.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(DOCNUM) TYPE  J_1BDOCNUM
*"     VALUE(RECEBEDOR) TYPE  CHAR1 OPTIONAL
*"     VALUE(TRANSPORTADORA) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(T_DESTINATARIO) TYPE  YNFE_EMAIL_CT
*"  EXCEPTIONS
*"      NAO_EXISTE
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* M�dulo de Fun��o : YNFE_EMAIL                                        *
* Grupo de Fun��es : YGF_GRC_ECC                                       *
*----------------------------------------------------------------------*
* Descri��o: Obter e-mail do parceiro e da transportadora da NF-e      *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome       Data        Descri��o                                     *
* ACTHIAGO   08.10.2015  #109075 - Codifica��o inicial                 *
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

      t_destinatario = o_grc->get_destinatario_email_nfe( im_nro_documento  = docnum
                                                          im_comprador      = recebedor
                                                          im_transportadora = transportadora ).

    CATCH ycx_grc INTO o_exp_grc.
      v_msg_erro = o_exp_grc->msg.

      MESSAGE e398(00) WITH v_msg_erro RAISING nao_existe.
      EXIT.
  ENDTRY.

ENDFUNCTION.
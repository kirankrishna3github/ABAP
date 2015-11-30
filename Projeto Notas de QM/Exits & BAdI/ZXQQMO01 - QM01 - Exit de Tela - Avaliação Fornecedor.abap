*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transa��o: QM01 / QM02 / QM03                                        *
* Projeto  : CMOD - YNQM                                               *
* Amplia��o: SMOD - QQMA0001 - Exit de Tela (SAPLIQS0)                 *
* Descri��o: QM/PM/SM: subtela do usu�rio para o cabe�alho da nota     *
*----------------------------------------------------------------------*
* Objetivo : Subtela - Tipo de RDF / Avalia��o de Fornecedor           *
* M�dulo   : QM                                                        *
* Projeto  : Notas de QM (N�o-conformidade no recebimento f�sico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data         Descri��o                                     *
* ACTHIAGO  27.01.2014  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZXQQMO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  CONSTANTS c_desabilitar_campo TYPE c LENGTH 01 VALUE '0'.

  CASE sy-tcode.
    WHEN 'QM01'.
      LOOP AT SCREEN.
        IF screen-group1 = 'Q2'.
          screen-active = c_desabilitar_campo.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN 'QM03'.
      LOOP AT SCREEN.
        IF screen-group1 = 'Q1'.
          screen-input = c_desabilitar_campo.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " STATUS_0100  OUTPUT
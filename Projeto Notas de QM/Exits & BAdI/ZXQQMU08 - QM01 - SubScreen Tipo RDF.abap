*&---------------------------------------------------------------------*
*&  Include           ZXQQMU08
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_VIQMEL) LIKE  VIQMEL STRUCTURE  VIQMEL
*"     VALUE(I_TABCD)  LIKE  TQTABS-TABCD      OPTIONAL
*"     VALUE(I_SUBNR)  TYPE  N                 OPTIONAL
*"     VALUE(I_USCR)   LIKE  TQ80-USERSCR1     OPTIONAL
*"  EXPORTING
*"     VALUE(E_VIQMEL) LIKE  VIQMEL STRUCTURE VIQMEL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                      xxxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transa��o: QM01                                                      *
* Projeto  : CMOD - YNQM                                               *
* Amplia��o: SMOD - QQMA0001 / SE37 - EXIT_SAPMIWO0_009                *
* Descri��o: QM/PM/SM: subtela do usu�rio para o cabe�alho da nota     *
*----------------------------------------------------------------------*
* Objetivo : Gravar o valor da subscreen 0100 'Tipo RDF' c/ RadioButton*
*            1 - Comunica��o (preenchido por padr�o)                   *
*            2 - Reprova��o                                            *
* M�dulo   : QM                                                        *
* Projeto  : Notas de QM (N�o-conformidade no recebimento f�sico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxxxxx                                   *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data         Descri��o                                     *
* ACTHIAGO  22.10.2013  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

e_viqmel-yycomunicacao = viqmel-yycomunicacao.
e_viqmel-yyreprovacao  = viqmel-yyreprovacao .

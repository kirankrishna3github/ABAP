*----------------------------------------------------------------------*
*                       ACH� LABORAT�RIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMYGED_AR                                               *
* Transa��o: YGED_AR                                                   *
* Tipo     : Module Pool (Online)                                      *
* M�dulo   : FI/AR (contas a pagar)                                    *
* Funcional: Uderson Luiz Fermino                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: Gerenciamento Eletr�nico de Documentos - sistema para     *
*            coletar, vincular e gerenciar tipos de documentos         *
*            espec�ficos no cadastro de clientes atrav�s do SAP DMS    *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  15.07.2013  #55263 - Desenvolvimento inicial               *
* ACTHIAGO  31.07.2013  #55263 - Inclus�o do bot�o de bloqueio         *
*----------------------------------------------------------------------*

INCLUDE: myged_ar_top, " Vari�veis globais
         myged_ar_lcl, " Classes locais
         myged_ar_o01, " Process Before Output
         myged_ar_i01, " Process After Input
         myged_ar_f01. " Rotinas
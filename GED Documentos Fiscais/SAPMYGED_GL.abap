*----------------------------------------------------------------------*
*                       ACH� LABORAT�RIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMYGED_GL                                               *
* Transa��o: YGED_GL                                                   *
* Tipo     : Module Pool (Online)                                      *
* M�dulo   : FI                                                        *
* Funcional: Uderson Luiz Fermino                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: Gerenciamento eletr�nico de documentos fiscais            *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  15.01.2014  #64292 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

INCLUDE: myged_gl_top, " Vari�veis globais
         myged_gl_lcl, " Classes locais
         myged_gl_pbo, " Process Before Output
         myged_gl_pai, " Process After Input
         myged_gl_f01. " Rotinas
*----------------------------------------------------------------------*
*                       ACH� LABORAT�RIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMY_NQM                                                 *
* Transa��o: YNQM_GNC                                                  *
* Tipo     : Module Pool (Online)                                      *
* M�dulo   : QM                                                        *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: Gerenciamento de notas de n�o conformidade (Notas de QM)  *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  12.12.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  06.01.2014  #63782 - Inclus�o do Fornecedor na visualiza��o*
*                                da A��o Imediata                      *
* ACTHIAGO  21.01.2014  #63782 - Bot�o criar nota de QM c/ base no lote*
* ACTHIAGO  23.01.2014  #63782 - Inclus�o do material, centro e lote   *
*                                na tela sele��o / relat�rio           *
* ACTHIAGO  30.01.2014  #63782 - Verificar lotes de sub-contrata��o    *
* ACTHIAGO  18.02.2014  #63782 - Verificar ordem de produ��o somente   *
*                                com movimento de entrada de mercadoria*
*----------------------------------------------------------------------*

INCLUDE: my_nqm_top, " Vari�veis globais
         my_nqm_pbo, " Process Before Output
         my_nqm_pai, " Process After Input
         my_nqm_lcl, " Classes Locais
         my_nqm_f01. " Sub-rotinas (Forms)
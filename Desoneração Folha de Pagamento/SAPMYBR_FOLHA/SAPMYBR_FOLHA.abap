*----------------------------------------------------------------------*
*                       ACH� LABORAT�RIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMYBR_FOLHA                                             *
* Transa��o: YBR_FOLHA                                                 *
* Tipo     : Module Pool (Online)                                      *
* M�dulo   : FI-AR (contas a receber)                                  *
* Funcional: Uderson Luiz Fermino                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: Plano Brasil Maior (PBM) - incentivos do governo federal  *
*            para o desenvolvimento da ind�stria e do com�rcio atrav�s *
*            da desonera��o (isen��o) de ICMS da folha de pagamento    *
*            utilizando-se de CFOPs e NCMs espec�ficos, onde � poss�vel*
*            obter at� 20% de desconto sobre o total das remunera��es  *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  26.09.2013  #57551 - Desenvolvimento inicial               *
* ACTHIAGO  03.12.2013  #57551 - Corre��o para evitar DUMP quando      *
*                                estiver selecionando da J_1BNFLIN     *
*                                com o range de NCM                    *
*----------------------------------------------------------------------*

INCLUDE: mybr_folha_top, " Vari�veis globais
         mybr_folha_lcl, " Classes locais
         mybr_folha_pbo, " Process Before Output
         mybr_folha_pai, " Process After Input
         mybr_folha_f01. " Sub-rotinas (Forms)
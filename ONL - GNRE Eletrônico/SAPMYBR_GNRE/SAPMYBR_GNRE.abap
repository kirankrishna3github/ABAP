*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Programa : SAPMYBR_GNRE                                              *
* Transa��o: YBR_GNRE                                                  *
* Tipo     : Module Pool (Online)                                      *
* M�dulo   : FI/AR (contas a receber)                                  *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: Gerar XML com dados das NF-e com ICMS ST para a GNRE - MS *
*            A Guia Nacional de Recolhimento de Tributos Estaduais -   *
*            GNRE, tem sido um documento de uso habitual por todos os  *
*            contribuintes que realizam opera��es de vendas            *
*            interestaduais sujeitas � substitui��o tribut�ria.        *
*            http://www.gnre.pe.gov.br   (produ��o)                    *
*            http://www.gnre-h.pe.gov.br (homologa��o)                 *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  06.08.2013  #58899 - Desenvolvimento inicial               *
* ACTHIAGO  28.08.2013  #61276 - Inser��o de mensagem quando salvar 2x *
* ACTHIAGO  25.09.2013  #63428 - Gera��o do XML em arquivos de 50 com  *
*                                base na data/hora da YBR_GNRE_PARAM   *
*----------------------------------------------------------------------*

INCLUDE: mybr_gnre_top, " Vari�veis globais
         mybr_gnre_lcl, " Classes
         mybr_gnre_pbo, " Process Before Output
         mybr_gnre_pai, " Process After Input
         mybr_gnre_f01. " Sub-rotinas
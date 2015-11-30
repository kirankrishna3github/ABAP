FUNCTION ynqm_imprimir_rdf.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_VIQMEL) LIKE  VIQMEL STRUCTURE  VIQMEL
*"     VALUE(I_CUSTOMIZING) LIKE  V_TQ85 STRUCTURE  V_TQ85
*"  TABLES
*"      TI_IVIQMFE STRUCTURE  WQMFE
*"      TI_IVIQMUR STRUCTURE  WQMUR
*"      TI_IVIQMSM STRUCTURE  WQMSM
*"      TI_IVIQMMA STRUCTURE  WQMMA
*"      TI_IHPA STRUCTURE  IHPA
*"  EXCEPTIONS
*"      ACTION_STOPPED
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxxx                             *
*----------------------------------------------------------------------*
* Transa��o: QM01                                                      *
* Fun��o definida dentro do Customizing                                *
*----------------------------------------------------------------------*
* SPRO > Administra��o de Qualidade > Nota QM > Processamento Notas >  *
*        Fun��es de nota adicionais > Definir Barra de Atividades      *
* Fun��o: 0051 - Imprimir Rel. Desvio Fornecedor                       *
* Tipo de Nota: Z1 - RNC Fornecedor                                    *
*----------------------------------------------------------------------*
* Objetivo : Preenchimento e impress�o do SmartForm da RDF             *
* M�dulo   : QM                                                        *
* Projeto  : Notas de QM (N�o-conformidade no recebimento f�sico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data         Descri��o                                     *
* ACTHIAGO  04.12.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  31.01.2013  #63782 - Radio Button para seleciona o idioma  *
*----------------------------------------------------------------------*
  DATA:
    t_rdl_idioma_rdf TYPE STANDARD TABLE OF spopli,
    w_rdl_idioma_rdf LIKE LINE OF t_rdl_idioma_rdf.

  DATA:
    v_fm_smartform   TYPE rs38l_fnam      ,
    v_formname       TYPE stxfadm-formname,
    v_resp_avaliacao TYPE c LENGTH 01     .

  CONSTANTS:
    c_rdf_portugues TYPE stxfadm-formname VALUE 'YQM_RDF'   ,
    c_rdf_ingles    TYPE stxfadm-formname VALUE 'YQM_RDF_EN'.

  FREE t_rdl_idioma_rdf.

  w_rdl_idioma_rdf-selflag   = space         .
  w_rdl_idioma_rdf-varoption = 'Portugu�s'   .
  APPEND w_rdl_idioma_rdf TO t_rdl_idioma_rdf.

  w_rdl_idioma_rdf-selflag   = space         .
  w_rdl_idioma_rdf-varoption = 'Ingl�s'      .
  APPEND w_rdl_idioma_rdf TO t_rdl_idioma_rdf.

* Monta um popup com Radio Buttons para o usu�rio escolher
* qual idioma de envio da RDF
  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
    EXPORTING
      mark_flag = space
      mark_max  = 1
      start_col = 25
      start_row = 10
      textline1 = 'Selecione o idioma de envio do Relat�rio de Desvio de Fornecedor (RDF)'
      titel     = 'Idioma RDF'
    IMPORTING
      answer    = v_resp_avaliacao
    TABLES
      t_spopli  = t_rdl_idioma_rdf
    EXCEPTIONS
      OTHERS    = 4.

  CASE v_resp_avaliacao.
    WHEN '1'. "  Portugu�s
      v_formname = c_rdf_portugues.
    WHEN '2'. " Ingl�s
      v_formname = c_rdf_ingles.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

* Obter o nome da fun��o do Smartform 'YQM_RDF'
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = v_formname
    IMPORTING
      fm_name  = v_fm_smartform
    EXCEPTIONS
      OTHERS   = 3.

  CHECK v_fm_smartform IS NOT INITIAL.

  CALL FUNCTION v_fm_smartform
    EXPORTING
      i_viqmel   = i_viqmel
    TABLES
      ti_iviqmfe = ti_iviqmfe " N�o Conformidades / Defeito (Desvio)
      ti_iviqmur = ti_iviqmur " Causa do Defeito (Desvio)
      ti_iviqmma = ti_iviqmma " Plano de A��es / A��es Corretivas
      ti_iviqmsm = ti_iviqmsm " A��o Imediata / Defini��o de Suprimentos
    EXCEPTIONS
      OTHERS     = 5.

ENDFUNCTION.
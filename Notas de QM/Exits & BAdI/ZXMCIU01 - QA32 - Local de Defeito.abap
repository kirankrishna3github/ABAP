*&---------------------------------------------------------------------*
*&  Include           ZXMCIU01
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_CONTROL) LIKE  MCCONTROL STRUCTURE  MCCONTROL
*"             VALUE(I_STAFO) LIKE  TMC2F-STAFO
*"             VALUE(I_ZEITP) LIKE  TMC5-ZEITP
*"             REFERENCE(O_VIQMEL) LIKE  VIQMEL STRUCTURE  VIQMEL
*"                             OPTIONAL
*"             REFERENCE(N_VIQMEL) LIKE  VIQMEL STRUCTURE  VIQMEL
*"                             OPTIONAL
*"       TABLES
*"              I_MCIPMB STRUCTURE  MCIPMB OPTIONAL
*"              I_MCIQFB STRUCTURE  MCIQFB OPTIONAL
*"              I_MCINF STRUCTURE  MCSOINF OPTIONAL
*"              N_IVIQMFE STRUCTURE  WQMFE OPTIONAL
*"              N_IVIQMMA STRUCTURE  WQMMA OPTIONAL
*"              N_IVIQMSM STRUCTURE  WQMSM OPTIONAL
*"              N_IVIQMUR STRUCTURE  WQMUR OPTIONAL
*"              O_IVIQMFE STRUCTURE  WQMFE OPTIONAL
*"              O_IVIQMMA STRUCTURE  WQMMA OPTIONAL
*"              O_IVIQMSM STRUCTURE  WQMSM OPTIONAL
*"              O_IVIQMUR STRUCTURE  WQMUR OPTIONAL
*"              N_PMCO STRUCTURE  PMCO OPTIONAL
*"              O_PMCO STRUCTURE  PMCO OPTIONAL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       ACH� LABORAT�RIOS                              *
*----------------------------------------------------------------------*
* Transa��o: QA32                                                      *
* Projeto  : CMOD - YNQM                                               *
* Amplia��o: SMOD - MCI10001 / SE37 - EXIT_SAPLMCI1_001                *
* Descri��o: MCI10001 MCI1: atualiza��o SIPM/SIQM                      *
*----------------------------------------------------------------------*
* Objetivo : N�o permitir mais de um local de defeito (N_IVIQMFE)      *
* M�dulo   : QM                                                        *
* Projeto  : Notas de QM (N�o-conformidade no recebimento f�sico)      *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data         Descri��o                                     *
* ACTHIAGO  05.02.2014  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Vari�veis                                                            *
*----------------------------------------------------------------------*
DATA:
  v_qtd_defeitos TYPE sy-tfill.

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_nota_qm TYPE tq80-qmart VALUE 'Z1'. " RNC - Fornecedor

CHECK sy-tcode = 'QF01'
   OR sy-tcode = 'QA32'.

CHECK n_viqmel-qmart = c_nota_qm.

DESCRIBE TABLE n_iviqmfe LINES v_qtd_defeitos.

IF v_qtd_defeitos > 1.
* Apenas um local de defeito � permitido!
  MESSAGE a012(ynqm).
ELSEIF v_qtd_defeitos = 0.
* Preencha o tipo de defeito
  MESSAGE a017(ynqm).
ENDIF.

READ TABLE n_iviqmfe
INTO n_iviqmfe
INDEX 1.

* Tipo de defeito
IF n_iviqmfe-fegrp IS INITIAL
  OR n_iviqmfe-fecod IS INITIAL.
* Preencha o tipo de defeito
  MESSAGE a017(ynqm).
ENDIF.

* Local de Defeito
IF n_iviqmfe-otgrp IS INITIAL
  OR n_iviqmfe-oteil IS INITIAL.
* Preencha o local de defeito
  MESSAGE a018(ynqm).
ENDIF.

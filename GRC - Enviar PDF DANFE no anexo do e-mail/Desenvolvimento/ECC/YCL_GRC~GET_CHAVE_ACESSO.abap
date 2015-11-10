*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_GRC                                                   *
* M�todo   : GET_CHAVE_ACESSO                                          *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obt�m a chave de acesso de acordo com o Nro do documento  *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  08.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_chave_acesso.
*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_j_1bnfe_active TYPE j_1bnfe_active.

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
     v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS
    c_nfe_autorizada TYPE j_1bnfedocstatus VALUE '1'.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  IF im_nro_documento IS INITIAL.
*   N�mero do documento n�o informado
    MESSAGE e002(ygrc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
  ENDIF.

* Tabela Status NFS
  SELECT SINGLE * FROM j_1bnfe_active
    INTO w_j_1bnfe_active
   WHERE docnum = im_nro_documento
     AND docsta = c_nfe_autorizada.

  IF w_j_1bnfe_active IS NOT INITIAL.
    CONCATENATE w_j_1bnfe_active-regio
                w_j_1bnfe_active-nfyear
                w_j_1bnfe_active-nfmonth
                w_j_1bnfe_active-stcd1
                w_j_1bnfe_active-model
                w_j_1bnfe_active-serie
                w_j_1bnfe_active-nfnum9
                w_j_1bnfe_active-docnum9
                w_j_1bnfe_active-cdv
           INTO rt_chave_acesso.
  ENDIF.

  IF rt_chave_acesso IS INITIAL.
*   Chave de acesso da NF-e n�o encontrada
    MESSAGE e003(ygrc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
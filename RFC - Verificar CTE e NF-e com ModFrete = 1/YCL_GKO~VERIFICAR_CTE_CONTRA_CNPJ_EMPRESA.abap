*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* M�todo   : VERIFICAR_CTE_CONTRA_CNPJ_EMPRESA                         *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Verifica se � um CT-e emitido contra o CNPJ do Ach�       *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  01.07.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD VERIFICAR_CTE_CONTRA_CNPJ_EMPRESA.
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_qtd_registros TYPE sy-tabix,
    v_msg_erro      TYPE string  .

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

* Verifica se � um CT-e contra a empresa
  SELECT COUNT( DISTINCT cnpj )
   FROM /xnfe/tcnpj
   INTO v_qtd_registros
   WHERE cnpj = im_cnpj.

  IF v_qtd_registros IS INITIAL.
*   N�o � um CT-e contra o Ach�
    MESSAGE e001(ygko) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
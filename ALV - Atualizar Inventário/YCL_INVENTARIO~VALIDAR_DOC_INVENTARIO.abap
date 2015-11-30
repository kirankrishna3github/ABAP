*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Classe   : YCL_INVENTARIO                                            *
* M�todo   : VALIDAR_DOC_INVENTARIO                                    *
*----------------------------------------------------------------------*
* Projeto  : Operador Log�stico                                        *
* M�dulo   : MM/WM                                                     *
* Funcional: xxxxxxxxxxxxxxxxxxxxxxxxx                                 *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Atualizar invent�rio LI11N                                *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  26.11.2014  #93085 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_DEPOSITO       TYPE LINV-LGNUM N� dep�sito/complexo de dep�sito
*--> IM_DOC_INVENTARIO TYPE LINV-IVNUM N� documento de invent�rio

METHOD validar_doc_inventario.
  DATA:
    v_qtd_registros TYPE i        ,
    v_msg_erro      TYPE t100-text.

  SELECT COUNT( DISTINCT lgnum )
   FROM linv
   INTO v_qtd_registros
   WHERE lgnum = im_deposito
     AND ivnum = im_doc_inventario.

  IF v_qtd_registros = 0.
*   Dep�sito e documento n�o encontrados
    MESSAGE e010(yol) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ol EXPORTING mensagem = v_msg_erro.
  ENDIF.

ENDMETHOD.
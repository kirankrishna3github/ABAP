*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : SET_T_OPERACAO                                            *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Preenche/atualiza a tabela com as opera��es               *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_T_OPERACAO  TYPE TP_OPERACAO

METHOD set_t_operacao.
  DATA:
    v_msg_erro TYPE string.

  IF im_t_operacao IS INITIAL.
*   N�o foram encontradas opera��es
    MESSAGE e009(yapo) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ELSE.
    FREE me->t_operacao.
    APPEND LINES OF im_t_operacao TO me->t_operacao.
  ENDIF.

ENDMETHOD.
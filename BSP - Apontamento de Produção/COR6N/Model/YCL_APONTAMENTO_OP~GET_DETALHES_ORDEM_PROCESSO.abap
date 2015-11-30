*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : GET_DETALHES_ORDEM_PROCESSO                               *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obter cabe�alho e opera��es da ordem de processo          *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- CHANGING EX_W_CABECALHO_OP TYPE TY_CABECALHO_OP OPTIONAL
*<-- CHANGING EX_T_OPERACAO     TYPE TP_OPERACAO OPTIONAL

METHOD get_detalhes_ordem_processo.

  TRY.
      DATA:
         v_ordem_processo TYPE afko-aufnr    ,
         v_msg_erro       TYPE string        ,
         o_cx_apo         TYPE REF TO ycx_apo.

      v_ordem_processo = me->get_ordem_processo( ).

      me->set_cabecalho_ordem_processo( v_ordem_processo ).
      me->set_operacoes_ordem_processo( v_ordem_processo ).
      me->set_permissao_modificacao_op( ).

      ex_w_cabecalho_op = me->get_cabecalho_ordem_processo( ).
      ex_t_operacao     = me->get_operacoes_ordem_processo( ).

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.
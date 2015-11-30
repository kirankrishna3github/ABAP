*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Super-classe: CL_BSP_CONTROLLER2                                     *
* Sub-classe  : YCL_CONTROLLER_APONTAMENTO_OP                          *
* M�todo      : DO_INIT                                                *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: M�todo redefinido para associar as Views                  *
*            s� entra no m�todo quando faz refresh na p�gina, ou quando*
*            carrega pela primeira vez                                 *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787  - Desenvolvimento inicial              *
* ACTHIAGO  30.11.2015  #135627 - Modifica��es                         *
*----------------------------------------------------------------------*

METHOD do_init.
*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
    w_login    TYPE yapt002                       ,
    w_msg_app  TYPE ycl_apontamento_op=>ty_msg_app.

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_json     TYPE string,
    v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Vari�veis tipo refer�ncia
*----------------------------------------------------------------------*
  DATA:
    o_apto_op  TYPE REF TO ycl_apontamento_op     ,
    o_cx_apo   TYPE REF TO ycx_apo                .

  view_index               = create_view( view_name = 'index'              ).
  view_inicial             = create_view( view_name = 'inicial'            ).
  view_operacoes           = create_view( view_name = 'operacoes'          ).
  view_apontar_confirmacao = create_view( view_name = 'apontarConfirmacao' ).
  view_logout              = create_view( view_name = 'logout'             ).
  view_mensagem            = create_view( view_name = 'msgApp'             ).

* Verifica se n�o houve a��o na tela (onInputProcessing = fun��o do JavaScript doInit.js)
* carrega a view "pesquisar" dentro da divConteudoView da view "inicial"
  CHECK request->get_form_field( 'onInputProcessing' ) IS INITIAL.

  TRY.
      ycl_apontamento_op=>set_hora_login_usuario( sy-uname ).

      o_apto_op = ycl_apontamento_op=>get_instance( ).

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.

      view_logout->set_attribute( name  = 'msg' value = v_msg_erro ).

      call_view( view_logout ).
      EXIT.
  ENDTRY.

  TRY.
      w_login = o_apto_op->get_hora_login_usuario( sy-uname ).

      view_inicial->set_attribute( name  = 'w_login' value = w_login ).

*      call_view( view_inicial ).
      call_view( view_index ).

    CATCH ycx_apo INTO o_cx_apo     .
      w_msg_app-tipo = 'error'      .
      w_msg_app-msg  = o_cx_apo->msg.

      v_json = ycl_apontamento_op=>converter_msg_json( w_msg_app ).

      view_mensagem->set_attribute( name  = 'json' value = v_json ).

      call_view( view_mensagem ).
  ENDTRY.

ENDMETHOD.                    "do_init
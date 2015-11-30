*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Super-classe: CL_BSP_CONTROLLER2                                     *
* Sub-classe  : YCL_CONTROLLER_APONTAMENTO_OP                          *
* M�todo      : DO_HANDLE_EVENT                                        *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: Esse m�todo � chamado ap�s alguma requisi��o ser enviada  *
*            para o servidor, por exemplo um click no bot�o salvar.    *
*            Antes daqui, passa no JavaScript primeiro e verifica qual *
*            foi a fun��o JavaScript do arquivo doInit.js              *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787  - Desenvolvimento inicial              *
* ACTHIAGO  30.11.2015  #135627 - Modifica��es                         *
*----------------------------------------------------------------------*

*--> IMPORTING EVENT           TYPE STRING
*--> IMPORTING HTMLB_EVENT     TYPE REF TO CL_HTMLB_EVENT
*--> IMPORTING HTMLB_EVENT_EX  TYPE REF TO IF_HTMLB_DATA
*--> IMPORTING GLOBAL_MESSAGES TYPE REF TO CL_BSP_MESSAGES
*<-- RETURNING GLOBAL_EVENT    TYPE STRING

METHOD do_handle_event.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_operacao TYPE STANDARD TABLE OF ycl_apontamento_op=>ty_operacao_op.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_apontamento  TYPE ycl_apontamento_op=>ty_apontamento     ,
    w_tela_apto    TYPE ycl_apontamento_op=>ty_tela_apontamento,
    w_cabecalho_op TYPE ycl_apontamento_op=>ty_cabecalho_op    ,
    w_msg_app      TYPE ycl_apontamento_op=>ty_msg_app         ,
    w_permissao    TYPE ycl_apontamento_op=>ty_permissao       ,
    w_login        TYPE yapt002                                .

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_ordem_processo TYPE caufv-aufnr,
    v_nome_tela      TYPE string     ,
    v_tipo_apto      TYPE string     ,
    v_json           TYPE string     .

*----------------------------------------------------------------------*
* Vari�veis de refer�ncia
*----------------------------------------------------------------------*
  DATA:
    o_apto_op TYPE REF TO ycl_apontamento_op,
    o_cx_root TYPE REF TO cx_root           ,
    o_cx_apo  TYPE REF TO ycx_apo           .

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*
  TRY.
*     Instancia a classe privada ap�s chamar o m�todo constructor
*     que verifica se o usu�rio tem permiss�o e se ele est� inativo h� mais de 20 minutos
      o_apto_op = ycl_apontamento_op=>get_instance( ).

*     Atualiza a data/hora da �ltima a��o da tela
      ycl_apontamento_op=>set_hora_login_usuario( sy-uname ).

    CATCH ycx_apo INTO o_cx_apo.
      w_msg_app-tipo = 'error'     .
      w_msg_app-msg  = o_cx_apo->msg.

      v_json = ycl_apontamento_op=>converter_msg_json( w_msg_app ).

      view_mensagem->set_attribute( name = 'json' value = v_json ).

      call_view( view_mensagem ).
      EXIT.
  ENDTRY.

* Verifica qual foi o evento JavaScript do arquivo doInit.js
  TRY.
      CASE event.
        WHEN ycl_apontamento_op=>c_pesquisar_op.

          FREE: t_operacao, w_cabecalho_op, w_permissao,
                v_ordem_processo, w_login.

*         data: { nro_op: $('#ipt_nro_op').val() }
          v_ordem_processo = request->get_form_field('nro_op').

          w_login = o_apto_op->get_hora_login_usuario( sy-uname ).

          o_apto_op->set_ordem_processo( v_ordem_processo ).

          o_apto_op->get_detalhes_ordem_processo( CHANGING ex_w_cabecalho_op = w_cabecalho_op
                                                           ex_t_operacao     = t_operacao
                                                           ex_w_permissoes   = w_permissao ).

          view_operacoes->set_attribute( name = 'w_cabecalho_op' value = w_cabecalho_op ).
          view_operacoes->set_attribute( name = 't_operacao'     value = t_operacao     ).
          view_operacoes->set_attribute( name = 'w_permissao'    value = w_permissao    ).

          call_view( view_operacoes ).

        WHEN ycl_apontamento_op=>c_confirmacao_final
          OR ycl_apontamento_op=>c_confirmacao_parcial.

          CLEAR: w_tela_apto, v_nome_tela, w_apontamento, w_permissao.

          w_tela_apto-ordem_processo = request->get_form_field('nro_op'). " Ordem de processo

          o_apto_op->get_detalhes_folha_tempos( EXPORTING im_ordem_processo = w_tela_apto-ordem_processo
                                                          im_nome_evento    = event
                                                 CHANGING ex_nome_tela      = v_nome_tela
                                                          ex_w_apontamento  = w_apontamento
                                                          ex_w_permissoes   = w_permissao ).

          view_apontar_confirmacao->set_attribute( name = 'nome_tela'     value = v_nome_tela   ).
          view_apontar_confirmacao->set_attribute( name = 'w_apontamento' value = w_apontamento ).
          view_apontar_confirmacao->set_attribute( name = 'w_permissao'   value = w_permissao   ).
          view_apontar_confirmacao->set_attribute( name = 'tipo_apto'     value = event         ).

          call_view( view_apontar_confirmacao ).

        WHEN ycl_apontamento_op=>c_salvar_apontamento.

          CLEAR: w_tela_apto, v_nome_tela, v_tipo_apto, w_msg_app, v_json.

          w_tela_apto-ordem_processo = request->get_form_field('nro_op'        ). " Ordem de processo
          w_tela_apto-centro         = request->get_form_field('centro'        ). " Centro
          w_tela_apto-nro_operacao   = request->get_form_field('operacao'      ). " N�mero da opera��o
          w_tela_apto-fase           = request->get_form_field('fase'          ). " Txt.breve opera��o
          w_tela_apto-recurso        = request->get_form_field('recurso'       ). " Recurso
          w_tela_apto-hr_apo_tp_prep = request->get_form_field('hr_apo_tp_prep'). " APO Tp. prepara��o
          w_tela_apto-hr_apo_tp_maq  = request->get_form_field('hr_apo_tp_maq' ). " APO Tp. maquina
          w_tela_apto-hr_hh_tp_prep  = request->get_form_field('hr_hh_tp_prep' ). " Custo HH Tp. prepara��o
          w_tela_apto-hr_hh_tp_maq   = request->get_form_field('hr_hh_tp_maq'  ). " Custo HH Tp. maquina
          w_tela_apto-qtd_boa        = request->get_form_field('qtd_boa'       ). " Quantidade boa
          w_tela_apto-refugo         = request->get_form_field('refugo'        ). " Refugo

          o_apto_op->set_w_apontamento( w_tela_apto ).

          v_tipo_apto = request->get_form_field( 'tipo_apto' ).

          v_json = o_apto_op->salvar_apontamento( v_tipo_apto ).

*         Exibe a mensagem de sucesso ap�s salvar o apontamento
          view_mensagem->set_attribute( name  = 'json' value = v_json ).

          call_view( view_mensagem ).

        WHEN 'confirmarEstorno'.
          CLEAR: w_tela_apto, w_msg_app, v_json.

*         Obt�m as vari�veis que foram enviadas na requisi��o Ajax:
*         function confirmarEstorno(linhaDataTable) {
*         url: "cor6n?onInputProcessing=confirmarEstorno",
*         data: { nro_op: $('#nro_op').val()
          w_tela_apto-ordem_processo = request->get_form_field('nro_op'     ). " Ordem de processo
          w_tela_apto-centro         = request->get_form_field('centro'     ). " Centro
          w_tela_apto-nro_operacao   = request->get_form_field('operacao'   ). " N�mero da opera��o
          w_tela_apto-fase           = request->get_form_field('fase'       ). " Txt.breve opera��o
          w_tela_apto-recurso        = request->get_form_field('recurso'    ). " Recurso
          w_tela_apto-confirmacao    = request->get_form_field('confirmacao'). " Confirma��o do apontamento
          w_tela_apto-hr_apo_tp_prep = space                                 . " APO Tp. prepara��o
          w_tela_apto-hr_apo_tp_maq  = space                                 . " APO Tp. maquina
          w_tela_apto-hr_hh_tp_prep  = space                                 . " Custo HH Tp. prepara��o
          w_tela_apto-hr_hh_tp_maq   = space                                 . " Custo HH Tp. maquina
          w_tela_apto-qtd_boa        = space                                 . " Quantidade boa
          w_tela_apto-refugo         = space                                 . " Refugo

*         Salva a work-area no atributo da classe YCL_APTO_OP ap�s fazer uma pr�-valida��o
*         dos campos que ser�o salvos
          o_apto_op->set_w_apontamento( w_tela_apto ).

          v_json = o_apto_op->estornar_apontamento( ).

          view_mensagem->set_attribute( name  = 'json' value = v_json ).

          call_view( view_mensagem ).

        WHEN ycl_apontamento_op=>c_logout.
          call_view( view_logout ).

      ENDCASE.

    CATCH ycx_apo INTO o_cx_apo    .
      w_msg_app-tipo = 'error'     .
      w_msg_app-msg = o_cx_apo->msg.

      v_json = ycl_apontamento_op=>converter_msg_json( w_msg_app ).

      view_mensagem->set_attribute( name = 'json' value = v_json ).

      call_view( view_mensagem ).

    CATCH cx_root INTO o_cx_root                 .       "#EC CATCH_ALL
      w_msg_app-tipo = 'error'                   .
      w_msg_app-msg  = o_cx_root->get_longtext( ).

      v_json = ycl_apontamento_op=>converter_msg_json( w_msg_app ).

      view_mensagem->set_attribute( name = 'json' value = v_json ).

      call_view( view_mensagem ).
  ENDTRY.

ENDMETHOD.                    "do_handle_event
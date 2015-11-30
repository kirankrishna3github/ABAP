*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : ESTORNAR_APONTAMENTO                                      *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Estornar apontamento da ordem de processo                 *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- RETURNING VALUE( EX_MSG_RETORNO ) TYPE STRING

METHOD estornar_apontamento.
  TRY.
      TYPES:
       BEGIN OF ty_afru       ,
         aufnr TYPE afru-aufnr, " N� ordem
         vornr TYPE afru-vornr, " N� opera��o
         rueck TYPE afru-rueck, " N� confirma��o da opera��o
         rmzhl TYPE afru-rmzhl, " Numerador da confirma��o
         stokz TYPE afru-stokz, " C�digo 'documento foi estornado'
         stzhl TYPE afru-stzhl, " Numerador de confirma��o da confirma��o estornada
       END OF ty_afru         .

      DATA:
        v_msg_erro     TYPE string                    ,
        o_cx_apo       TYPE REF TO ycx_apo            ,
        w_apontamento  TYPE ty_apontamento            ,
        w_permissao    TYPE ty_permissao              ,     "#EC NEEDED
        w_msg_app      TYPE ty_msg_app                ,
        w_afru         TYPE ty_afru                   ,
        v_confirmacao  TYPE bapi_pi_conf_key-conf_no  ,
        v_confirm_cont TYPE bapi_pi_conf_key-conf_cnt ,
        w_retorno      TYPE bapiret1                  ,
        w_retorno2     TYPE bapiret2                  .     "#EC NEEDED

      w_apontamento = get_w_apontamento( ).

*     Certifica-se que o usu�rio realmente tem permiss�o para alterar
      w_permissao = get_permissoes_usuario( im_usuario = sy-uname
                                            im_centro  = w_apontamento-centro
                                            im_recurso = w_apontamento-recurso
                                            im_estorno = abap_true ).

*     Confirma��es de ordens
      SELECT SINGLE aufnr vornr rueck rmzhl stokz stzhl     "#EC *
       FROM afru
       INTO w_afru
       WHERE aufnr = w_apontamento-ordem_processo
         AND vornr = w_apontamento-nro_operacao
         AND rmzhl = w_apontamento-confirmacao
         AND stzhl = '00000000'.                            "#EC NOTEXT

      IF w_afru IS INITIAL.
*       Confirma��o da ordem n�o encontrada
        MESSAGE e024(yapo) INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
      ENDIF.

      v_confirmacao  = w_afru-rueck. " N� confirma��o da opera��o
      v_confirm_cont = w_afru-rmzhl. " Numerador da confirma��o

*     Estorna o apontamento realizado na COR6N
      CALL FUNCTION 'BAPI_PROCORDCONF_CANCEL'
        EXPORTING
          confirmation        = v_confirmacao
          confirmationcounter = v_confirm_cont
        IMPORTING
          return              = w_retorno.

      IF w_retorno-type = 'E'.                              "#EC NOTEXT
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
          IMPORTING
            return = w_retorno2.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = abap_true
          IMPORTING
            return = w_retorno2.
      ENDIF.

      CLEAR w_msg_app.

      CASE w_retorno-type.
        WHEN 'E'.                                           "#EC NOTEXT
          w_msg_app-tipo = 'error'             .            "#EC NOTEXT
          CONCATENATE w_retorno-message
          w_retorno-message_v3
          INTO w_msg_app-msg SEPARATED BY ' - '.
        WHEN 'S' OR 'I' OR space.                           "#EC NOTEXT
          w_msg_app-tipo = 'success'        .               "#EC NOTEXT

          IF w_retorno-message IS INITIAL.
            w_msg_app-msg = 'Apontamento estornado com sucesso'. "#EC NOTEXT
          ELSE.
            w_msg_app-msg  = w_retorno-message.
          ENDIF.

        WHEN 'W'.                                           "#EC NOTEXT
          w_msg_app-tipo = 'warning'        .               "#EC NOTEXT
          w_msg_app-msg  = w_retorno-message.
      ENDCASE.                                              "#EC NOTEXT

      ex_msg_retorno = converter_msg_json( w_msg_app ).

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.
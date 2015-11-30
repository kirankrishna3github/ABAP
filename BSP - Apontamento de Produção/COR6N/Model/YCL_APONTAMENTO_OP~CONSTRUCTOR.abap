*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : CONSTRUCTOR                                               *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Faz as valida��es iniciais no momento de criar a classe   *
*            como verificar se o usu�rio tem permiss�o de acesso �     *
*            p�gina BSP e se ele est� conectado h� mais de 20 minutos  *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD constructor.

  TRY.
      DATA:
         v_msg_erro   TYPE string        ,
         w_permissoes TYPE ty_permissao  ,                  "#EC NEEDED
         o_cx_apo     TYPE REF TO ycx_apo.

*     Verifica se o usu�rio est� com acesso (tabela YAPT001)
      w_permissoes = get_permissoes_usuario( sy-uname ).

*     Verifica se o usu�rio est� conectado h� mais de 20 minutos
      get_tempo_conexao( sy-uname ).

    CATCH ycx_apo INTO o_cx_apo .
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.
*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : GET_HORA_LOGIN_USUARIO                                    *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obt�m a data/hora do login do usu�rio                     *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_USUARIO	       TYPE SY-UNAME
*<-- RETURNING VALUE( EX_LOGIN ) TYPE YAPT002

METHOD get_hora_login_usuario.

  DATA: v_msg_erro TYPE string.

  SELECT SINGLE * FROM yapt002
   INTO ex_login
   WHERE uname = im_usuario.

  IF ex_login IS INITIAL.
*   N�o h� registro de login para o usu�rio &
    MESSAGE e017(yapo) WITH im_usuario INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
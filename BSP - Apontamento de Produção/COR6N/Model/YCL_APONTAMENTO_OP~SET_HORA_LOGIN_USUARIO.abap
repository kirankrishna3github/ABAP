*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : SET_HORA_LOGIN_USUARIO                                    *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Preenche a data/hora de login do usu�rio                  *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_USUARIO	TYPE SY-UNAME

METHOD set_hora_login_usuario.
  DATA: w_login TYPE yapt002. "APO - Apto Horas OP - Data/hora de login do usu�rio.

  WRITE: sy-uzeit TO w_login-hora USING EDIT MASK '__:__:__',
         sy-datum TO w_login-data DD/MM/YYYY                .

  w_login-uname = im_usuario.

  IF w_login IS NOT INITIAL.
    MODIFY yapt002 FROM w_login.
  ENDIF.

ENDMETHOD.
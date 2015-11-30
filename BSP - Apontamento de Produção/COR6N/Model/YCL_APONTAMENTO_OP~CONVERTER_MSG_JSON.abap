*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : CONVERTER_MSG_JSON                                        *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Converte a mensagem de sucesso/erro para retornar � view  *
*            no formato Json                                           *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_W_MSG_APP	    TYPE YCL_APTO_OP=>TY_MSG_APP
*<-- RETURNING VALUE( EX_JSON )	TYPE STRING

METHOD converter_msg_json.
  DATA:
    o_json    TYPE REF TO ycl_json,
    w_msg_app LIKE im_w_msg_app.

  w_msg_app = im_w_msg_app.

* Remover aspas simples da mensagem sen�o ocorre erro quando for gerar o Json
  REPLACE ALL OCCURRENCES OF '''' IN w_msg_app-msg WITH space.

  CREATE OBJECT o_json
    EXPORTING
      DATA = w_msg_app.

  o_json->serialize( ).

  ex_json = o_json->get_data( ).

ENDMETHOD.
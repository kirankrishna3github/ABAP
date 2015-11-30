*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : GET_INSTANCE                                              *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Cria a classe YCL_APTO_OP utilizando design pattern       *
*            Singleton - ver: http://oprsteny.com/?p=1113              *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- RETURNING VALUE( EX_INSTANCIA )  TYPE REF TO YCL_APTO_OP

METHOD get_instance.

  TRY.
      DATA:
        v_msg_erro TYPE string        ,
        o_cx_apo   TYPE REF TO ycx_apo.

      IF apto_op IS NOT BOUND.
*       Cria a classe privada ap�s chamar o m�todo Constructor
*       que verifica se o usu�rio tem permiss�o e se ele est� inativo h� mais de 20 minutos
        CREATE OBJECT apto_op TYPE ycl_apontamento_op.
      ENDIF.

*     retorna a inst�ncia da classe
      ex_instancia = apto_op.

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.
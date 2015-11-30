*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* M�todo   : GET_INSTANCE                                              *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Cria a classe YCL_POLITICA_COMERCIAL utilizando design    *
*            pattern Singleton - ver: http://oprsteny.com/?p=1113      *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- RETURNING VALUE( EX_INSTANCIA )  TYPE REF TO YCL_POLITICA_COMERCIAL

METHOD get_instance.

  TRY.
      DATA:
        v_msg_erro TYPE string       ,
        o_cx_pc    TYPE REF TO ycx_pc.

      IF politica_comercial IS NOT BOUND.
        CREATE OBJECT politica_comercial TYPE ycl_politica_comercial.
      ENDIF.

*     retorna a inst�ncia da classe
      ex_instancia = politica_comercial.

    CATCH ycx_pc INTO o_cx_pc.
      v_msg_erro = o_cx_pc->msg.
      RAISE EXCEPTION TYPE ycx_pc EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.
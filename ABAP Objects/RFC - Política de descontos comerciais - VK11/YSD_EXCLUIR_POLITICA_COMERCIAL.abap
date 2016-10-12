FUNCTION ysd_excluir_politica_comercial.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(T_POLITICA) TYPE  YCT_POLITICA_COMERCIAL OPTIONAL
*"  EXPORTING
*"     VALUE(T_RETORNO) TYPE  YCT_MENSAGENS
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* M�dulo de Fun��o : YSD_EXCLUIR_POLITICA_COMERCIAL                    *
* Grupo de Fun��es : YSD_VK15                                          *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Exclui as pol�ticas de desconto comerciais (YDEC)         *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  07.05.2015  #100197 - Desenvolvimento inicial              *
* ACTHIAGO  24.06.2015  #100197 - Altera��o para physical_deletion     *
*----------------------------------------------------------------------*

  TRY.
      DATA:
        o_politica_comercial TYPE REF TO ycl_politica_comercial,
        o_cx_pc              TYPE REF TO ycx_pc                ,
        w_retorno            TYPE ymensagens                   ,
        v_msg_exception      TYPE string                       .

      o_politica_comercial = ycl_politica_comercial=>get_instance( ).

      o_politica_comercial->excluir_politica_comercial( t_politica ).

      t_retorno = o_politica_comercial->get_msg_retorno( ).

    CATCH ycx_pc INTO o_cx_pc.
      v_msg_exception = o_cx_pc->msg             .
      w_retorno-tipo  = 'E'                      .
      WRITE v_msg_exception TO w_retorno-mensagem.
      APPEND w_retorno TO t_retorno              .
  ENDTRY.

ENDFUNCTION.

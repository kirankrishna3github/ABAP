*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                 *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* M�todo   : ENVIAR_EMAIL_NFE_DANFE                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Enviar e-mail com XML e DANFE em anexo                    *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_alv_nfe.
  APPEND LINES OF me->t_alv TO ex_t_alv.
ENDMETHOD.
*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* M�todo   : CONVERTER_FLOAT_DECIMAL                                   *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Converter float para decimal                              *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  24.07.2015  #111437 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD converter_float_decimal.

  CALL FUNCTION 'C14W_NUMBER_CHAR_CONVERSION'
    EXPORTING
      i_float        = float
    IMPORTING
      e_dec          = decimal
    EXCEPTIONS
      number_too_big = 1
      OTHERS         = 2.

ENDMETHOD.

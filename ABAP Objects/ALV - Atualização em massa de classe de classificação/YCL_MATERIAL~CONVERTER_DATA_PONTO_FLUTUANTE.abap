*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* M�todo   : CONVERTER_DATA_PONTO_FLUTUANTE                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Converter data em ponto flutuante - ATFLV                 *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD converter_data_ponto_flutuante.
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_data_txt TYPE c LENGTH 10,
    v_intern   TYPE sy-datum   ,
    v_dia      TYPE cawn-atwrt .

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  v_data_txt = im_valor.

  CONDENSE v_data_txt NO-GAPS.

  IF v_data_txt IS INITIAL.
    EXIT.
  ENDIF.

  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = v_data_txt
    IMPORTING
      date_internal            = v_intern
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.

  IF sy-subrc = 0.
    v_dia = v_intern.

    CALL FUNCTION 'CTCV_CONVERT_DATE_TO_FLOAT'
      EXPORTING
        date  = v_dia
      IMPORTING
        float = ex_valor_convertido.
  ENDIF.

ENDMETHOD.
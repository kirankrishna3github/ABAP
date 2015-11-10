*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* M�todo   : CONVERTER_MATERIAL                                        *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Converter c�digo do material                              *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD converter_material.

  DATA v_erro_procto TYPE string.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = im_material
    IMPORTING
      output       = ex_material
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid
     TYPE sy-msgty
     NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
     INTO v_erro_procto.

    RAISE EXCEPTION TYPE ycx_pc EXPORTING msg = v_erro_procto.
  ENDIF.

ENDMETHOD.

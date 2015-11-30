*----------------------------------------------------------------------*
*                       ACH� LABORAT�RIOS                              *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Upload excel para tabela interna                          *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  08.10.2014  #78961 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_ARQUIVO  TYPE LOCALFILE
*<-- CHANGING  EX_T_TABELA TYPE STANDARD TABLE Tabela Interna

METHOD upload_excel_itab.

  TYPE-POOLS: truxs.

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_raw_data TYPE truxs_t_text_data.

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_extensao TYPE c LENGTH 04.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*
  CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
    EXPORTING
      filename  = im_arquivo
    IMPORTING
      extension = v_extensao.

  IF v_extensao <> 'XLS'                                    "#EC NOTEXT
    AND v_extensao <> 'XLSX'.                               "#EC NOTEXT
    EXIT.
  ENDIF.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_tab_raw_data       = t_raw_data
      i_filename           = im_arquivo
    TABLES
      i_tab_converted_data = ex_t_tabela[]
    EXCEPTIONS
      OTHERS               = 2.

ENDMETHOD.

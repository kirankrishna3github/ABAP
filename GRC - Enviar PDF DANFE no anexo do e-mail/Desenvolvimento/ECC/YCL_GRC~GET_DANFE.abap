*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_GRC                                                   *
* M�todo   : GET_DANFE                                                 *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obt�m o PDF da DANFE em bin�rio                           *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  08.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_danfe.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_pdf_binario TYPE STANDARD TABLE OF hrb2a_raw255.

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
     v_tamanho_arquivo TYPE i      ,
     v_pdf             TYPE xstring.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  CALL FUNCTION 'YGRC_ANEXA_DANFE_EMAIL'
    EXPORTING
      i_docnum   = im_nro_documento
    IMPORTING
      e_pdf_data = t_pdf_binario
      e_bin_size = v_tamanho_arquivo.

  IF t_pdf_binario IS NOT INITIAL.
    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = v_tamanho_arquivo
      IMPORTING
        buffer       = v_pdf
      TABLES
        binary_tab   = t_pdf_binario
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.

    IF sy-subrc = 0.
      cl_document_bcs=>xstring_to_solix( EXPORTING ip_xstring = v_pdf
                                         RECEIVING rt_solix   = rt_t_danfe ).
    ENDIF.
  ENDIF.

ENDMETHOD.
*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* M�todo   : VERIFICAR_EXTENSAO_ARQUIVO                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Verificar se a extens�o do arquivo importado � XLSX       *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD verificar_extensao_arquivo.
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
   v_extensao TYPE string,
   v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  FIND REGEX '[.](.*)$' IN im_nome_arquivo SUBMATCHES v_extensao.

  TRANSLATE v_extensao TO UPPER CASE.
  CONDENSE v_extensao NO-GAPS.

  IF v_extensao IS INITIAL.
*   Selecione a planilha do Excel para importar.
    MESSAGE e007(ymaterial) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ELSEIF v_extensao <> 'XLSX'.                              "#EC NOTEXT
*   Formato inv�lido. Somente XLSX � suportado.
    MESSAGE e001(ymaterial) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
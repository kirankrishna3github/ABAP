*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* M�todo   : VERIFICAR_EXTENSAO_ARQUIVO                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Verificar se a extens�o do arquivo importado � XLSX       *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.01.2016  #142490 - Desenvolvimento inicial              *
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
    MESSAGE e005(yplano_controle) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.

  ELSEIF v_extensao <> 'XLSX'.                              "#EC NOTEXT
*   Formato inv�lido. Somente XLSX � suportado.
    MESSAGE e006(yplano_controle) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.

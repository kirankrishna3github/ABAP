*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_INVENTARIO                                            *
* M�todo   : VALIDAR_EXCEL                                             *
*----------------------------------------------------------------------*
* Projeto  : Operador Log�stico                                        *
* M�dulo   : MM/WM                                                     *
* Funcional: Sergio Vieira de Alc�ntara / Danilo Morente Carrasco      *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Validar as entradas do excel para atualizar ou incluir    *
*            materiais no invent�rio (LI11N)                           *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  26.11.2014  #93085 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- EX_T_EXCEL	     TYPE TP_EXCEL
*<-- EX_T_INVENTARIO TYPE TP_INVENTARIO
*<-- EX_T_LOG	       TYPE TP_LOG

METHOD validar_excel.
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_qtd_registros TYPE i         ,
    v_deposito      TYPE lqua-lgort,
    v_msg_erro      TYPE t100-text .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_log        TYPE me->ty_log       ,
    w_excel      TYPE me->ty_excel     ,
    w_inventario TYPE me->ty_inventario,
    w_mch1       TYPE me->ty_mch1      ,
    w_ol_empresa TYPE me->ty_ol_empresa,
    w_linp       TYPE me->ty_linp      ,
    w_mara       TYPE me->ty_mara      ,
    w_lqua       TYPE me->ty_lqua      ,
    w_linv       TYPE me->ty_linv      ,
    w_linv_aux   TYPE linv             .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_material_promocional TYPE t134-mtart VALUE 'YPRO'.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*
  IF ex_t_excel IS INITIAL.
*   Planilha do excel n�o possui dados
    MESSAGE e011(yol) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ol EXPORTING mensagem = v_msg_erro.
  ENDIF.

* Dados de invent�rio por quanto
  SELECT SINGLE lgnum ivnum ivpos lgtyp
                lgpla plpos matnr werks charg
   FROM linv
   INTO w_linv
    WHERE lgnum = me->deposito
      AND ivnum = me->doc_inventario.

  LOOP AT ex_t_excel INTO w_excel.
    CLEAR:
       w_inventario, w_log, w_mch1, w_ol_empresa, w_mara,
       w_linv_aux, w_linp, w_lqua, v_deposito.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = w_excel-matnr
      IMPORTING
        output       = w_excel-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.

*   Dados de invent�rio por quanto
    SELECT SINGLE * FROM linv
     INTO w_linv_aux
     WHERE lgnum = me->deposito
       AND ivnum = me->doc_inventario
       AND matnr = w_excel-matnr
       AND charg = w_excel-charg.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING w_linv_aux TO w_inventario.
      w_inventario-uname = sy-uname         . " Usu�rio que alterou o material
      w_inventario-menga = w_excel-menge    . " Qtd. para entrada do resultado da contagem
      APPEND w_inventario TO ex_t_inventario.

*----------------------------------------------------------------------*
*   Material que n�o existia no invent�rio
*----------------------------------------------------------------------*
    ELSE.

*     Lotes (para administr.de lotes a n�vel de todos os centros)
      SELECT SINGLE matnr charg hsdat vfdat
       FROM mch1
       INTO w_mch1
       WHERE matnr = w_excel-matnr
         AND charg = w_excel-charg.

      IF sy-subrc <> 0.
        w_log-lgnum = me->deposito                     . " N�dep�sito/complexo de dep�sito
        w_log-ivnum = me->doc_inventario               . " N� documento de invent�rio
        w_log-matnr = w_excel-matnr                    . " Material
        w_log-charg = w_excel-charg                    . " Lote
        w_log-menge = w_excel-menge                    . " Quantidade
        w_log-stat  = me->c_erro                       . " Status
        w_log-text  = 'Material e lote n�o encontrados'.    "#EC NOTEXT
        APPEND w_log TO ex_t_log                       .
      ELSE.

*       Parametriza��o de empresas (Operador Log�stico)
        SELECT SINGLE werks lgort_da lgort_dp
         FROM ymm_ol_empresa
         INTO w_ol_empresa
         WHERE werks = w_linv-werks.

*       Dados gerais de material
        SELECT SINGLE matnr mtart
         FROM mara
         INTO w_mara
         WHERE matnr = w_excel-matnr.

        IF w_mara-mtart = c_material_promocional. " YPRO
          v_deposito = w_ol_empresa-lgort_dp. " Dep�sito Promocional
        ELSE.
          v_deposito = w_ol_empresa-lgort_da. " Dep�sito Acabado
        ENDIF.

*       Item de doc.invent�rio em WM
        SELECT SINGLE lgnum ivnum lgpla idatu
         FROM linp
         INTO w_linp
         WHERE lgnum = me->deposito
           AND ivnum = me->doc_inventario.

*       Quantos
        SELECT SINGLE lgnum lqnum matnr werks
                      charg lgtyp lgpla bestq
         FROM lqua
         INTO w_lqua
         WHERE lgnum = me->deposito
*           AND ivnum = me->doc_inventario
           AND matnr = w_mara-matnr
           AND werks = w_linv-werks
           AND charg = w_excel-charg
           AND lgort = v_deposito.

        IF sy-subrc EQ 0. "Se encontrar na LQUA, pegar o status que vem do campo BESTQ
          w_inventario-bestq = w_lqua-bestq     . " Tipo de estoque
        ELSE. "Sen�o colocar 'S' - Bloqueado
          w_inventario-bestq = 'S'     . " Lote
        ENDIF.

        w_inventario-lgnum = w_linv-lgnum     . " Dep�sito
        w_inventario-ivnum = w_linv-ivnum     . " Documento de invent�rio
        w_inventario-ivpos = w_linv-ivpos     . " N� item no documento de invent�rio
        w_inventario-lgtyp = w_linv-lgtyp     . " Tipo de dep�sito
        w_inventario-lgpla = w_linp-lgpla     . " Posi��o no dep�sito
        w_inventario-plpos = w_linv-plpos     . " Item na posi��o do dep�sito
        w_inventario-matnr = w_mch1-matnr     . " Material
        w_inventario-werks = w_linv-werks     . " Centro
        w_inventario-wdatu = w_mch1-hsdat     . " Data da entrada de mercadorias
        w_inventario-charg = w_mch1-charg     . " Lote
        w_inventario-menga = w_excel-menge    . " Qtd. para entrada do resultado da contagem
        w_inventario-idatu = w_linp-idatu     . " Data do invent�rio
        w_inventario-vfdat = w_mch1-vfdat     . " Data de vencimento (IDOC)
        w_inventario-lgort = v_deposito       . " Deposito
        w_inventario-uname = sy-uname         . " Usu�rio que incluiu o novo material
        APPEND w_inventario TO ex_t_inventario.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF ex_t_inventario IS INITIAL.
*   Dados n�o encontrados para incluir/alterar o invent�rio
    MESSAGE e012(yol) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ol EXPORTING mensagem = v_msg_erro.
  ENDIF.

ENDMETHOD.
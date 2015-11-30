*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : SET_TOTAL_OPERACAO                                        *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Preenche a soma das horas por opera��o                    *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_total_operacao.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_caufv         ,
      aufnr  TYPE caufv-aufnr ,  " N� ordem
      plnbez TYPE caufv-plnbez,  " N� material para ordem
      ktext  TYPE caufv-ktext ,  " N�mero do lote
      werks  TYPE caufv-werks ,  " Descri��o do material
      gamng  TYPE caufv-gamng ,  " Quantidade b�sica
    END OF ty_caufv           ,

    BEGIN OF ty_afru          ,
      aufnr TYPE afru-aufnr   ,
      vornr TYPE afru-vornr   ,
      smeng TYPE afru-smeng   ,
      meinh TYPE afru-meinh   ,
    END OF ty_afru            .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
     t_crca TYPE STANDARD TABLE OF rcrca,
     t_crco TYPE STANDARD TABLE OF rcrco,
     t_crtx TYPE STANDARD TABLE OF rcrtx.

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
     w_caufv          TYPE ty_caufv         ,
     w_total_operacao TYPE ty_total_operacao,
     w_crtx           LIKE LINE OF t_crtx   ,
     w_afru           TYPE ty_afru          .

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
     v_quantidade_refugo TYPE afru-xmnga,
     v_recurso           TYPE crhd-arbpl,
     v_centro            TYPE crhd-werks.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*
  READ TABLE im_t_total_operacao
  INTO w_total_operacao
  INDEX 1.

  IF sy-subrc = 0.
    SELECT SINGLE aufnr plnbez ktext werks gamng
     FROM caufv
     INTO w_caufv
     WHERE aufnr = w_total_operacao-ordem_processo.
  ENDIF.

  LOOP AT im_t_total_operacao INTO w_total_operacao.
    FREE: v_quantidade_refugo, w_afru,
          v_recurso, v_centro, t_crca, t_crco, t_crtx.

    SELECT SINGLE aufnr vornr smeng meinh
     FROM afru
     INTO w_afru
     WHERE aufnr = w_total_operacao-ordem_processo
       AND vornr = w_total_operacao-operacao.

    SELECT SUM( xmnga )
     FROM afru
     INTO v_quantidade_refugo
     WHERE aufnr = w_total_operacao-ordem_processo
       AND vornr = w_total_operacao-operacao.

    w_total_operacao-qtd_boa = w_afru-smeng        -
                               v_quantidade_refugo -
                               w_total_operacao-qtd_apontada.

    w_total_operacao-qtd_planejada  = w_afru-smeng.
    w_total_operacao-unidade_medida = w_afru-meinh.

    CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
      EXPORTING
        input_string  = w_caufv-ktext
      IMPORTING
        output_string = w_total_operacao-dsc_material.

    w_total_operacao-material = w_caufv-plnbez.
    w_total_operacao-centro   = w_caufv-werks .

    SHIFT:
      w_total_operacao-material LEFT DELETING LEADING '0'.

    v_recurso = w_total_operacao-recurso.
    v_centro  = w_total_operacao-centro.

    CALL FUNCTION 'CR_WORKCENTER_READ_DIALOG_NAME'
      EXPORTING
        arbpl     = v_recurso
        werks     = v_centro
      TABLES
        t_crca    = t_crca
        t_crco    = t_crco
        t_crtx    = t_crtx
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc = 0.
      READ TABLE t_crtx
      INTO w_crtx
      INDEX 1.

      CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
        EXPORTING
          input_string  = w_crtx-ktext_up
        IMPORTING
          output_string = w_total_operacao-dsc_recurso.
    ENDIF.

    APPEND w_total_operacao TO me->t_total_operacao.
  ENDLOOP.

ENDMETHOD.
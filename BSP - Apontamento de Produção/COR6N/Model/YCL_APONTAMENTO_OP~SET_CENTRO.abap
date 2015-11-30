*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* M�todo   : SET_CENTRO                                                *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Valida o centro                                           *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING ex_centro TYPE WERKS_D

METHOD set_centro.

  DATA: v_msg_erro TYPE string,
        v_qtd_reg  TYPE i     .

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ex_centro
    IMPORTING
      output = ex_centro.

* Remove textos e caracteres especiais para evitar SQL Injection
  REPLACE ALL OCCURRENCES OF REGEX '[^\d]' IN ex_centro WITH space.

  SELECT COUNT( DISTINCT werks )
    FROM t001w
    INTO v_qtd_reg
    WHERE werks = ex_centro.

  IF v_qtd_reg = 0.
*   Centro & n�o existe
    MESSAGE e021(yapo) WITH ex_centro INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.

  ELSE.
    DATA: v_ordem_processo TYPE afko-aufnr.

    v_ordem_processo = get_ordem_processo( ).

*   Vis�o dos cabe�alhos de ordens PCP/RK
    SELECT COUNT( DISTINCT aufnr )
     FROM caufv
     INTO v_qtd_reg
     WHERE aufnr = v_ordem_processo
       AND autyp = me->c_ordem_processo "40
       AND werks = ex_centro.

    IF v_qtd_reg = 0.
*     Ordem de processo n�o existe no centro &
      MESSAGE e022(yapo) WITH ex_centro INTO v_msg_erro.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
    ENDIF.
  ENDIF.

ENDMETHOD.
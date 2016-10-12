*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* M�todo   : GET_CARACTERISTICAS_INTERNAS                              *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obt�m as caracter�sticas internas de acordo com a classe  *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD caracteristicas_internas_f4.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_caracteristica      TYPE STANDARD TABLE OF ty_caracteristica,
    t_caracteristica_aux  TYPE STANDARD TABLE OF ty_caracteristica,
    t_campo_alv           TYPE STANDARD TABLE OF ty_campo_alv     ,
    t_linhas_selecionadas TYPE salv_t_row                         .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_caracteristica_aux  LIKE LINE OF t_caracteristica     ,
    w_linhas_selecionadas LIKE LINE OF t_linhas_selecionadas.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  t_caracteristica_aux = get_caracteristicas_internas( im_classe_material ).

* Campos que n�o ser�o exibidos no ALV no F4
  t_campo_alv = inibir_campos_alv_caract( ).

  exibir_tabela_como_search_help( EXPORTING im_t_campo_alv         = t_campo_alv
                                  IMPORTING ex_linhas_selecionadas = t_linhas_selecionadas
                                  CHANGING  im_tabela              = t_caracteristica_aux ).

  LOOP AT t_linhas_selecionadas INTO w_linhas_selecionadas.
    CLEAR w_caracteristica_aux.

    READ TABLE t_caracteristica_aux
    INTO w_caracteristica_aux
    INDEX w_linhas_selecionadas.

    IF sy-subrc = 0.
      APPEND w_caracteristica_aux TO t_caracteristica.
      ex_caracteristica = w_caracteristica_aux-imerk.
    ENDIF.
  ENDLOOP.

  FREE me->t_caracteristicas.

  APPEND LINES OF t_caracteristica TO me->t_caracteristicas.
ENDMETHOD.
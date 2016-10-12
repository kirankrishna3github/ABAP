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

METHOD get_caracteristicas_internas.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_ksml        ,
      clint TYPE ksml-clint , " N� classe interno
      imerk TYPE ksml-imerk , " Caracter�stica interna
      klart TYPE ksml-klart , " Tipo de classe
    END OF ty_ksml          ,

    BEGIN OF ty_cabn        ,
      atinn TYPE cabn-atinn , " Caracter�stica interna
      atnam TYPE cabn-atnam , " Nome da caracter�stica
      atfor TYPE cabn-atfor , " Categoria de dados da caracter�stica
      adzhl TYPE cabn-adzhl , " Contador interno p/arquivo objeto mediante controle modifs.
    END OF ty_cabn          ,

    BEGIN OF ty_cabnt       ,
      atinn TYPE cabnt-atinn, " Caracter�stica interna
      spras TYPE cabnt-spras, " C�digo de idioma
      atbez TYPE cabnt-atbez, " Denomina��o caract.
    END OF ty_cabnt         .

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_ksml           TYPE STANDARD TABLE OF ty_ksml          ,
    t_cabn           TYPE STANDARD TABLE OF ty_cabn          ,
    t_cabnt          TYPE STANDARD TABLE OF ty_cabnt         ,
    t_caracteristica TYPE STANDARD TABLE OF ty_caracteristica.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_ksml           LIKE LINE OF t_ksml          ,
    w_cabn           LIKE LINE OF t_cabn          ,
    w_cabnt          LIKE LINE OF t_cabnt         ,
    w_caracteristica LIKE LINE OF t_caracteristica.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  IF im_caracteristica IS NOT INITIAL.
*   Caracter�sticas para classes
    SELECT clint imerk klart
     FROM ksml
     INTO TABLE t_ksml
     WHERE klart = im_classe_material
       AND imerk = im_caracteristica.
  ELSE.
*   Caracter�sticas para classes
    SELECT clint imerk klart
     FROM ksml
     INTO TABLE t_ksml
     WHERE klart = im_classe_material.
  ENDIF.

  IF t_ksml IS NOT INITIAL.
*   Caracter�stica
    SELECT atinn atnam atfor adzhl
     FROM cabn
     INTO TABLE t_cabn
     FOR ALL ENTRIES IN t_ksml
     WHERE atinn = t_ksml-imerk.
  ENDIF.

  IF t_cabn IS NOT INITIAL.
    SELECT atinn spras atbez
      FROM cabnt
      INTO TABLE t_cabnt
      FOR ALL ENTRIES IN t_cabn
      WHERE atinn = t_cabn-atinn
        AND spras = c_pt_br.
  ENDIF.

  LOOP AT t_ksml INTO w_ksml.
    CLEAR: w_caracteristica, w_cabn.

    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        input  = w_ksml-imerk
      IMPORTING
        output = w_caracteristica-imerk.

    READ TABLE t_cabn
    INTO w_cabn
    WITH KEY atinn = w_ksml-imerk.

    IF sy-subrc = 0.
      w_caracteristica-atnam = w_cabn-atnam. " Nome da caracter�stica
      w_caracteristica-atfor = w_cabn-atfor. " Categoria de dados da caracter�stica
      w_caracteristica-adzhl = w_cabn-adzhl. " Contador interno p/arquivo objeto mediante controle modifs.
    ENDIF.

    READ TABLE t_cabnt
    INTO w_cabnt
    WITH KEY atinn = w_ksml-imerk.

    IF sy-subrc = 0.
      w_caracteristica-atbez = w_cabnt-atbez. " Denomina��o caract.
    ENDIF.

    w_caracteristica-klart = w_ksml-klart.  " Tipo de classe

    APPEND w_caracteristica TO t_caracteristica.
  ENDLOOP.

  SORT t_caracteristica BY imerk ASCENDING.

  APPEND LINES OF t_caracteristica TO ex_t_caracteristica.

ENDMETHOD.
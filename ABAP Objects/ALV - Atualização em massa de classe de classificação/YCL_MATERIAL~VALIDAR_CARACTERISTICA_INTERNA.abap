*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* M�todo   : VALIDAR_CARACTERISTICA_INTERNA                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Validar caracter�stica interna x Tipo de classe           *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD validar_caracteristica_interna.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_caracteristica TYPE STANDARD TABLE OF ty_caracteristica.

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
     v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  IF me->t_caracteristicas IS INITIAL
    AND im_caracteristica IS INITIAL.
*   Selecione a caracter�stica interna
    MESSAGE e005(ymaterial) WITH c_classe_material INTO v_msg_erro. "#EC *
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

  FREE me->t_caracteristicas.

  t_caracteristica = me->get_caracteristicas_internas( im_classe_material = im_classe_material
                                                       im_caracteristica  = im_caracteristica ).

  IF t_caracteristica IS NOT INITIAL.
    APPEND LINES OF t_caracteristica TO me->t_caracteristicas.
  ELSE.
*   A caracter�stica interna selecionada n�o pertence ao tipo de classe
    MESSAGE e006(ymaterial) WITH c_classe_material INTO v_msg_erro. "#EC *
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
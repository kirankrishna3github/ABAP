*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* M�todo   : XML_PARSER                                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Faz o parse do XML que � recebido em Xstring              *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  10.08.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD xml_parser.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_xml TYPE STANDARD TABLE OF ty_xml.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_xml LIKE LINE OF t_xml.

*----------------------------------------------------------------------*
* Vari�veis tipos refer�ncia (Objetos)
*----------------------------------------------------------------------*
  DATA:
    o_xml_document       TYPE REF TO cl_xml_document,
    o_xml_main_node      TYPE REF TO if_ixml_node   ,
    o_xml_child_node     TYPE REF TO if_ixml_node   ,
    o_xml_sub_child_node TYPE REF TO if_ixml_node   .

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*
  IF im_xml IS INITIAL.
    EXIT.
  ENDIF.

  CREATE OBJECT o_xml_document TYPE cl_xml_document.

  o_xml_document->parse_xstring( im_xml ).

* Busca a tag principal
  IF o_xml_document IS BOUND.
    o_xml_main_node = o_xml_document->find_node( name = im_raiz ).
  ENDIF.

* Busca a 1� tag filha
  IF o_xml_main_node IS BOUND.
    o_xml_child_node = o_xml_main_node->get_first_child( ).
  ENDIF.

  WHILE o_xml_child_node IS NOT INITIAL.

    CASE o_xml_child_node->get_type( ).
      WHEN if_ixml_node=>co_node_element.

        IF o_xml_child_node->get_name( ) = im_filho_raiz.
          o_xml_sub_child_node = o_xml_child_node->get_first_child( ).

          WHILE o_xml_sub_child_node IS NOT INITIAL.

            IF o_xml_sub_child_node->get_type( ) = if_ixml_node=>co_node_element.
              CLEAR w_xml                                     .
              w_xml-tag   = o_xml_sub_child_node->get_name( ) .
              w_xml-valor = o_xml_sub_child_node->get_value( ).

              IF im_sub_no IS NOT INITIAL AND im_sub_no = w_xml-tag.
                APPEND w_xml TO t_xml.

              ELSEIF im_sub_no IS INITIAL.
                CLEAR w_xml                                     .
                w_xml-tag   = o_xml_sub_child_node->get_name( ) .
                w_xml-valor = o_xml_sub_child_node->get_value( ).
                APPEND w_xml TO t_xml                           .
              ENDIF.
            ENDIF.

            o_xml_sub_child_node = o_xml_sub_child_node->get_next( ).
          ENDWHILE.
        ELSE.

*         Se n�o quer retornar nenhuma tag espec�fica, retorna o valor de todas as tags
          IF im_sub_no IS INITIAL.
            CLEAR w_xml                                 .
            w_xml-tag   = o_xml_child_node->get_name( ) .
            w_xml-valor = o_xml_child_node->get_value( ).
            APPEND w_xml TO t_xml                       .
          ENDIF.

        ENDIF.
    ENDCASE.

    o_xml_child_node = o_xml_child_node->get_next( ).
  ENDWHILE.

  IF t_xml IS NOT INITIAL.
    APPEND LINES OF t_xml TO ex_t_xml.
  ENDIF.

ENDMETHOD.
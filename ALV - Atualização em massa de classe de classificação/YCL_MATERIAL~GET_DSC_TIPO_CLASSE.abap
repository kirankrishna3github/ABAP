*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* M�todo   : GET_DSC_TIPO_CLASSE                                       *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obt�m a descri��o do tipo da classe                       *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_dsc_tipo_classe.

* Denomina��o do tipo de classe
  SELECT SINGLE artxt
   FROM tclat
   INTO ex_descricao
   WHERE klart = im_classe_material
     AND spras = c_pt_br.

ENDMETHOD.
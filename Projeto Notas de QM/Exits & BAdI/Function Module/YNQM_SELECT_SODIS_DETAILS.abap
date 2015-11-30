FUNCTION ynqm_select_sodis_details.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(USUARIO_COMP) TYPE  USR02-BNAME
*"     REFERENCE(USUARIO_LOG) TYPE  USR02-BNAME
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_usuario              ,
      bname      TYPE usr21-bname    , " Nome do usu�rio no mestre de usu�rios
      smtp_addr  TYPE adr6-smtp_addr , " Endere�o de e-mail
      addrnumber TYPE adr6-addrnumber, " N� endere�o
      persnumber TYPE adr6-persnumber, " N� pessoa
    END OF ty_usuario                .

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_usuario TYPE STANDARD TABLE OF ty_usuario, " Usuario/E-mail
    t_adr6    TYPE STANDARD TABLE OF adr6      , " Endere�os de e-mail
    t_addsmtp TYPE STANDARD TABLE OF bapiadsmtp, " Estrutura BAPI p/endere�os e-mail (admin.endere�os central)
    t_return  TYPE STANDARD TABLE OF bapiret2  . " Par�metro de retorno

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
  DATA:
    w_bcst    TYPE bcst_assignments ,
    w_usuario LIKE LINE OF t_usuario,
    w_adr6    LIKE LINE OF t_adr6   ,
    w_addsmtp LIKE LINE OF t_addsmtp.

*----------------------------------------------------------------------*
* Vari�veis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_objyr           TYPE sood-objyr ,
    v_objno           TYPE sood-objno ,
    v_usuario_compras TYPE usr02-bname,
    v_usuario_logado  TYPE usr02-bname,
    v_indice          TYPE i          .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS:
    c_docto_editor     TYPE tsotd-objtp VALUE 'RAW', "Documento editor SAP.
    c_atribuir_usuario TYPE c LENGTH 01 VALUE 'U'  ,
    c_visib_geral      TYPE c LENGTH 01 VALUE 'C'  .

*----------------------------------------------------------------------*
* Inicio                                                               *
*----------------------------------------------------------------------*
  SELECT SINGLE bname
    FROM usr02
    INTO (v_usuario_compras)
    WHERE bname = usuario_comp.

  SELECT SINGLE bname
    FROM usr02
    INTO (v_usuario_logado)
    WHERE bname = usuario_log.

  IF  v_usuario_compras IS INITIAL
   OR v_usuario_logado  IS INITIAL.
    EXIT.
  ENDIF.

* Procura os ano da ID e o n� do objeto 'Sem dados Obrigat�rios' da SODIS
  SELECT SINGLE objyr objno
   FROM sood
   INTO (v_objyr, v_objno)
    WHERE objnam = 'DISCLOSURE'
      AND objdes = 'NO_DISCLOSURE'.

  IF sy-subrc = 0.
    CLEAR: w_bcst.

    SELECT SINGLE * FROM bcst_assignments
     INTO w_bcst
     WHERE objtp           = c_docto_editor     " RAW
       AND objyr           = v_objyr
       AND objno           = v_objno
       AND assignment_type = c_atribuir_usuario " U
       AND assignment      = v_usuario_compras
       AND visibility      = c_visib_geral.     " C

    IF sy-subrc <> 0.
*     Adiciona o usu�rio no grupo 'Sem dados Obrigat�rios' da SODIS
*     Dessa forma n�o s�o inseridos dados obrigat�rios, como o texto standard
*     da op��o 'Dados obrigat�rios standard' configurado
      w_bcst-objtp           = c_docto_editor    . " RAW
      w_bcst-objyr           = v_objyr           .
      w_bcst-objno           = v_objno           .
      w_bcst-assignment_type = c_atribuir_usuario. " U
      w_bcst-assignment      = v_usuario_compras      .
      w_bcst-visibility      = c_visib_geral     . " C

      INSERT bcst_assignments FROM w_bcst.
    ENDIF.
  ENDIF.

* Obt�m o e-mail do usu�rio
  SELECT b~bname      " Nome do usu�rio
         a~smtp_addr  " Endere�o de e-mail
         b~addrnumber " N� endere�o
         a~persnumber " N� pessoa
   FROM adr6 AS a
   INNER JOIN usr21 AS b ON a~persnumber = b~persnumber
                        AND a~addrnumber = b~addrnumber
   INTO TABLE t_usuario
   WHERE b~bname = v_usuario_compras.

  CLEAR w_usuario.
  READ TABLE t_usuario
  INTO w_usuario
  INDEX 1.

  IF sy-subrc = 0.
    SELECT * FROM adr6
     INTO TABLE t_adr6
     WHERE addrnumber = w_usuario-addrnumber
      AND persnumber  = w_usuario-persnumber.

*   Obt�m o e-mail do usu�rio logado pois ser� ele quem enviar� o e-mail
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = v_usuario_logado
      TABLES
        return   = t_return
        addsmtp  = t_addsmtp.
  ENDIF.

  LOOP AT t_adr6 INTO w_adr6.
    v_indice = sy-tabix.

    CLEAR w_addsmtp.
    READ TABLE t_addsmtp
    INTO w_addsmtp
    INDEX 1.

    IF sy-subrc = 0.
      w_adr6-smtp_addr = w_addsmtp-e_mail.
      MODIFY t_adr6 FROM w_adr6 INDEX v_indice.
    ENDIF.
  ENDLOOP.

* Altera o e-mail
  IF t_adr6 IS NOT INITIAL.
    MODIFY adr6 FROM TABLE t_adr6.
  ENDIF.

ENDFUNCTION.

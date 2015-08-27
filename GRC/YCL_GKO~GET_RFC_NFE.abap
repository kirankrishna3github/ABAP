*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* M�todo   : GET_RFC_NFE                                               *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obt�m a RFC do ECC para salvar os dados da NF-e           *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  10.08.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_rfc_nfe.
*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_sistema_logico TYPE /xnfe/inctehd-logsys,
    v_msg_erro       TYPE string              .

*----------------------------------------------------------------------*
* Objetos
*----------------------------------------------------------------------*
  DATA:
    o_cx_gko TYPE REF TO ycx_gko.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_carga_nfe_grc TYPE rs38l-name VALUE 'YGKO_CARGA_NFE_GRC'.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  TRY.
*     Selecionar sistema l�gico da NF-e
      SELECT SINGLE logsys                                  "#EC WARNOK
       FROM /xnfe/innfehd
       INTO (v_sistema_logico)
       WHERE nfeid = im_id_nfe.

      IF v_sistema_logico IS INITIAL.
*       N�o foi encontrado o sistema l�gico
        MESSAGE e002(ygko) INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
      ENDIF.

      me->testar_rfc_destination( EXPORTING im_sistema_logico  = v_sistema_logico
                                            im_nome_rfc_ecc    = c_carga_nfe_grc
                                   CHANGING ex_nome_rfc_ecc    = ex_nome_rfc
                                            ex_rfc_destination = ex_rfc_destination ).
    CATCH ycx_gko INTO o_cx_gko.
      RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = o_cx_gko->msg.
  ENDTRY.

ENDMETHOD.
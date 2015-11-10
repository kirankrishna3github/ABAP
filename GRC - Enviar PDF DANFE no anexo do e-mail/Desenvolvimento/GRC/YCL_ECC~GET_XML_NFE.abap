*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* M�todo   : OBTER_XML_NFE                                             *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obter XML da NF-e                                         *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_xml_nfe.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_nfe TYPE STANDARD TABLE OF ty_nfe.

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_nfe_autorizada TYPE /xnfe/tstat-statcode VALUE '100'.

*----------------------------------------------------------------------*
* Ranges
*----------------------------------------------------------------------*
  TYPES:
    r_dhemi_range   TYPE RANGE OF /xnfe/dhemi_utc,
    r_dhemi_linha   TYPE LINE OF  r_dhemi_range  ,
    r_emissao_linha TYPE LINE OF  r_emissao      .

  DATA:
    r_dhemi   TYPE r_dhemi_range  ,
    w_dhemi   TYPE r_dhemi_linha  ,
    w_emissao TYPE r_emissao_linha.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  IF im_chave_acesso IS NOT INITIAL.
*   Obt�m o XML da NF-e
    SELECT nfe~id         " Chave de acesso de 44 caracteres
           nfe~docnum     " N� do documento NF-e
           nfe~logsys     " Sistema l�gico
           nfe~serie      " S�rie
           nfe~nnf        " N� de NF-e de 9 posi��es
           nfe~cnpj_dest  " CNPJ do destinat�rio
           nfe~cpf_dest   " CPF do destinat�rio
           nfe~xnome_emit " Nome da empresa - emissor
           nfe~dhemi      " Data/hora da emiss�o em UTC
           xml~xmlstring  " XML da nota
     FROM /xnfe/outnfehd AS nfe
     INNER JOIN /xnfe/outnfexml AS xml ON nfe~guid = xml~guid
     INTO TABLE t_nfe
      WHERE id      = im_chave_acesso
        AND statcod = c_nfe_autorizada.

  ELSE.

    LOOP AT im_emissao INTO w_emissao.
      CLEAR w_dhemi     .
      w_dhemi-sign = 'I'.

      IF w_emissao-high IS NOT INITIAL.
        CONCATENATE w_emissao-low  '000000' INTO w_dhemi-low.
        CONCATENATE w_emissao-high '235959' INTO w_dhemi-high.
        w_dhemi-option = 'BT'.
      ELSE.
        CONCATENATE w_emissao-low '235959' INTO w_dhemi-high.
        CONCATENATE w_emissao-low '000000' INTO w_dhemi-low.
        w_dhemi-option = 'BT'.
      ENDIF.

      APPEND w_dhemi TO r_dhemi.
    ENDLOOP.

*   Obt�m o XML da NF-e
    SELECT nfe~id         " Chave de acesso de 44 caracteres
           nfe~docnum     " N� do documento NF-e
           nfe~logsys     " Sistema l�gico
           nfe~serie      " S�rie
           nfe~nnf        " N� de NF-e de 9 posi��es
           nfe~cnpj_dest  " CNPJ do destinat�rio
           nfe~cpf_dest   " CPF do destinat�rio
           nfe~xnome_emit " Nome da empresa - emissor
           nfe~dhemi      " Data/hora da emiss�o em UTC
           xml~xmlstring  " XML da nota
     FROM /xnfe/outnfehd AS nfe
     INNER JOIN /xnfe/outnfexml AS xml ON nfe~guid = xml~guid
     INTO TABLE t_nfe
      WHERE id        IN im_id_nfe
        AND nnf       IN im_nro_nfe
        AND docnum    IN im_docnum
        AND dhemi     IN r_dhemi
        AND cnpj_dest IN im_cnpj_dest
        AND cpf_dest  IN im_cpf_dest
        AND statcod   EQ c_nfe_autorizada.
  ENDIF.

  APPEND LINES OF t_nfe TO me->t_nfe.

  IF me->t_nfe IS INITIAL.
*   Nenhuma NF-e encontrada
    MESSAGE e011(yecc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
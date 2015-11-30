*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Programa : YYPCL_PP017                                               *
* Transa��o: YPPLEADTIME                                               *
* Descri��o: Relat�rio de Lead Time para identificar gaps na produ��o  *
* Tipo     : Relat�rio ALV                                             *
* M�dulo   : PP                                                        *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descri��o das Modifica��es                           *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  28.08.2013  #59472 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

REPORT yypcl_pp017 NO STANDARD PAGE HEADING.

TABLES: afko, " Dados de cabe�alho da ordem de ordens PCP
        afru, " Confirma��es de ordens
        aufk. " Dados mestre da ordem

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_afko         , " Dados de cabe�alho da ordem de ordens PCP
    aufnr  TYPE afko-aufnr , " N� ordem
    ftrmi  TYPE afko-ftrmi , " Data de libera��o real
    plnbez TYPE afko-plnbez, " N� do material
    erdat  TYPE aufk-erdat , " Data de entrada
  END OF ty_afko           ,

  BEGIN OF ty_afpo         , " Item da ordem
    aufnr  TYPE afpo-aufnr , " N� ordem
    posnr  TYPE afpo-posnr , " N� item da ordem
    matnr  TYPE afpo-matnr , " N� material para ordem
    pwerk  TYPE afpo-pwerk , " Centro de planejamento para a ordem
    dwerk  TYPE afpo-dwerk , " Centro
    charg  TYPE afpo-charg , " N�mero do lote
  END OF ty_afpo           ,

  BEGIN OF ty_granel       ,
    op_pa  TYPE afko-aufnr , " N� ordem da OP de produto acabado
    op_gr  TYPE afko-aufnr , " N� ordem do granel
  END OF ty_granel         ,

  BEGIN OF ty_aufm         , " Movimentos de material para a ordem
    aufnr  TYPE aufm-aufnr , " N� ordem
    mblnr  TYPE aufm-mblnr , " N� documento de material
    mjahr  TYPE aufm-mjahr , " Ano do documento do material
    bwart  TYPE aufm-bwart , " Tipo de movimento (administra��o de estoques)
    budat  TYPE aufm-budat , " Data de lan�amento no documento
    matnr  TYPE aufm-matnr , " N� do material
    mtart  TYPE mara-mtart , " Tipo de material
    werks  TYPE aufm-werks , " Centro
    shkzg  TYPE aufm-shkzg , " C�digo d�bito/cr�dito
    menge  TYPE aufm-menge , " Quantidade
    meins  TYPE aufm-meins , " Unidade de medida b�sica
    lgort  TYPE aufm-lgort , " Dep�sito
    charg  TYPE aufm-charg , " N�mero do lote
    elikz  TYPE aufm-elikz , " C�digo de remessa final
  END OF ty_aufm           ,

  BEGIN OF ty_makt         , " Textos breves de material
    matnr  TYPE makt-matnr , " N� do material
    maktx  TYPE makt-maktx , " Texto breve de material
  END OF ty_makt           .

DATA: BEGIN OF it_qals OCCURS 0.
        INCLUDE STRUCTURE qals.
DATA : mark TYPE c.
DATA: END   OF it_qals.


DATA: BEGIN OF it_jest OCCURS 0.
        INCLUDE STRUCTURE jest.
DATA: END   OF it_jest.

DATA: BEGIN OF it_qave OCCURS 0.
        INCLUDE STRUCTURE qave.
DATA: END   OF it_qave.


*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  t_afko_prod_ac    TYPE STANDARD TABLE OF ty_afko      , " Produto Acabado - cabe�alho
  t_afpo_prod_itm   TYPE STANDARD TABLE OF ty_afpo      , " Produto Acabado - item
  t_dsc_prd_acb     TYPE STANDARD TABLE OF ty_makt      , " Produto Acabado - nome do material
  t_mvtos_prd_acb   TYPE STANDARD TABLE OF ty_aufm      , " Produto Acabado - movimentos do material
  t_afko_granel     TYPE STANDARD TABLE OF ty_afko      , " Granel - cabe�alho
  t_afpo_granel_itm TYPE STANDARD TABLE OF ty_afpo      , " Granel - item
  t_dsc_granel      TYPE STANDARD TABLE OF ty_makt      , " Granel - nome do material
  t_mvtos_granel    TYPE STANDARD TABLE OF ty_aufm      , " Granel - movimentos do material
  t_alv             TYPE STANDARD TABLE OF yalv_leadtime, " ALV de exibi��o
  t_fieldcat        TYPE lvc_t_fcat                     , " Fieldcatalog (campos ALV)
  v_prueflos        LIKE qals-prueflos,
  v_tabix TYPE sy-tabix.

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  w_afko_prod_ac    LIKE LINE OF t_afko_prod_ac   ,
  w_afpo_prod_itm   LIKE LINE OF t_afpo_prod_itm  ,
  w_dsc_prd_acb     LIKE LINE OF t_dsc_prd_acb    ,
  w_mvtos_prd_acb   LIKE LINE OF t_mvtos_prd_acb  ,
  w_afko_granel     LIKE LINE OF t_afko_granel    ,
  w_afpo_granel_itm LIKE LINE OF t_afpo_granel_itm,
  w_dsc_granel      LIKE LINE OF t_dsc_granel     ,
  w_mvtos_granel    LIKE LINE OF t_mvtos_granel   ,
  w_alv             LIKE LINE OF t_alv  ,
  w_fieldcat        TYPE lvc_s_fcat               .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_cont_alv_lead    TYPE scrfname        VALUE 'CONT_ALV_LEAD',
  c_alv_lead         TYPE ddobjname       VALUE 'YALV_LEADTIME',
  c_ordem_embalagem1 TYPE t003o-auart     VALUE 'ZE01'         , " Ordem de Embalagem - I
  c_ordem_embalagem2 TYPE t003o-auart     VALUE 'ZE02'         , " Ordem de Embalagem - I
  c_entrada_mercd    TYPE t156-bwart      VALUE '101'          ,
  c_sm_para_ordem    TYPE t156-bwart      VALUE '261'          ,
  c_qtd_livre        TYPE t156-bwart      VALUE '321'          ,
  c_semi_acabado     TYPE t134-mtart      VALUE 'HALB'         ,
  c_pt_br            TYPE t002-laiso      VALUE 'PT'           ,
  c_hostpot_op_acb   TYPE dd03p-fieldname VALUE 'OP_PRD_ACB'   ,
  c_hostpot_op_grn   TYPE dd03p-fieldname VALUE 'OP_GRANEL'    .

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_container TYPE REF TO cl_gui_custom_container,
  obj_alv_grid  TYPE REF TO cl_gui_alv_grid        .

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_evento_alv DEFINITION.
  PUBLIC SECTION.
    METHODS: hotspot_click
     FOR EVENT hotspot_click OF cl_gui_alv_grid
     IMPORTING e_row_id
               e_column_id
               es_row_no.
ENDCLASS.                    "lcl_evento_alv DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_evento_alv IMPLEMENTATION.
  METHOD hotspot_click.
    PERFORM event_hotspot_click
      USING e_row_id
            e_column_id.
  ENDMETHOD.                    "hotspot_click
ENDCLASS.                    "lcl_evento_alv IMPLEMENTATION

*----------------------------------------------------------------------*
* Tela de sele��o                                                      *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001. " Informe a ordem de produ��o
SELECT-OPTIONS:
  s_ftrmi  FOR afko-ftrmi OBLIGATORY, " Data de libera��o real
  s_werks  FOR afru-werks           , " Centro
  s_aufnr  FOR afko-aufnr           , " Ordem de Produ��o
  s_plnbez FOR afko-plnbez          . " N� do material
SELECTION-SCREEN END OF BLOCK b1    .

*----------------------------------------------------------------------*
* Inicio                                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM: f_selecionar_produto_acabado,
           f_selecionar_granel         ,
           f_montar_tabela_alv         .

  IF t_alv IS NOT INITIAL.
    PERFORM f_montar_fieldcatalog
     TABLES t_fieldcat
      USING w_fieldcat
            c_alv_lead " YALV_LEADTIME
            'X'.

    PERFORM f_montar_alv
      USING obj_container
            obj_alv_grid
            c_cont_alv_lead " CONT_ALV_LEAD
            t_fieldcat
            t_alv
            space
            space.

    CALL SCREEN 1001.
  ELSE.
    MESSAGE 'Dados n�o encontrados'
    TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

*----------------------------------------------------------------------*
* MODULE status_1001 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  SET PF-STATUS 'S1001'.

* Relat�rio de Lead Time para identificar gaps na produ��o
  SET TITLEBAR 'T1001'.
ENDMODULE.                                           "status_0001 OUTPUT

*----------------------------------------------------------------------*
* MODULE USER_COMMAND_0001 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE. "USER_COMMAND_0001 INPUT

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_produto_acabado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_produto_acabado.
  PERFORM: f_produto_acabado          ,
           f_itens_produto_acabado    ,
           f_descricao_produto_acabado,
           f_movimentos_prod_acabado  .
ENDFORM.                    "f_selecionar_produto_acabado

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_granel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_granel.
  PERFORM: f_movimentos_granel,
           f_itens_granel     ,
           f_descricao_granel ,
           f_granel           .
ENDFORM.                    "f_selecionar_granel

*&---------------------------------------------------------------------*
*&      Form  f_produto_acabado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_produto_acabado.
  SELECT afko~aufnr afko~ftrmi afko~plnbez aufk~erdat
   FROM afko
   INNER JOIN aufk ON aufk~aufnr = afko~aufnr
   INTO TABLE t_afko_prod_ac
   WHERE afko~aufnr  IN s_aufnr  " Ordem de Produ��o
     AND afko~ftrmi  IN s_ftrmi  " Data de libera��o real
     AND afko~plnbez IN s_plnbez " N� do material
     AND aufk~auart  IN (c_ordem_embalagem1,                " ZE01
                         c_ordem_embalagem2).               " ZE02
ENDFORM.                    "f_produto_acabado

*&---------------------------------------------------------------------*
*&      Form  f_itens_produto_acabado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_itens_produto_acabado.
  IF t_afko_prod_ac IS NOT INITIAL.
    SELECT aufnr posnr matnr pwerk dwerk charg
     FROM afpo
     INTO TABLE t_afpo_prod_itm
     FOR ALL ENTRIES IN t_afko_prod_ac
      WHERE aufnr EQ t_afko_prod_ac-aufnr " Ordem de Produ��o
        AND dwerk IN s_werks.             " Centro
  ENDIF.
ENDFORM.                    "f_itens_produto_acabado

*&---------------------------------------------------------------------*
*&      Form  f_descricao_produto_acabado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_descricao_produto_acabado.
  IF t_afpo_prod_itm IS NOT INITIAL.
    SELECT matnr maktx
     FROM makt
     INTO TABLE t_dsc_prd_acb
     FOR ALL ENTRIES IN t_afpo_prod_itm
      WHERE matnr = t_afpo_prod_itm-matnr
        AND spras = c_pt_br.

    DELETE ADJACENT DUPLICATES FROM t_dsc_prd_acb.
  ENDIF.
ENDFORM.                    "f_descricao_produto_acabado

*&---------------------------------------------------------------------*
*&      Form  f_movimentos_prod_acabado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_movimentos_prod_acabado.
  IF t_afko_prod_ac IS NOT INITIAL.
    SELECT aufm~aufnr aufm~mblnr aufm~mjahr aufm~bwart aufm~budat aufm~matnr
           mara~mtart aufm~werks aufm~shkzg aufm~menge aufm~meins
           aufm~lgort aufm~charg aufm~elikz
     FROM aufm
     INNER JOIN mara ON aufm~matnr = mara~matnr
     INTO TABLE t_mvtos_prd_acb
     FOR ALL ENTRIES IN t_afko_prod_ac
      WHERE aufnr EQ t_afko_prod_ac-aufnr  " Ordem de Produ��o
        AND bwart IN (c_entrada_mercd ,                     " 101
                      c_qtd_livre    ).                     " 321
  ENDIF.
ENDFORM.                    "f_movimentos_prod_acabado

*&---------------------------------------------------------------------*
*&      Form  f_movimentos_granel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_movimentos_granel.
  IF t_afko_prod_ac IS NOT INITIAL.
    SELECT aufm~aufnr aufm~mblnr aufm~mjahr aufm~bwart aufm~budat aufm~matnr
           mara~mtart aufm~werks aufm~shkzg aufm~menge aufm~meins
           aufm~lgort aufm~charg aufm~elikz
     FROM aufm
     INNER JOIN mara ON aufm~matnr = mara~matnr
     INTO TABLE t_mvtos_granel
     FOR ALL ENTRIES IN t_afko_prod_ac
      WHERE aufnr EQ t_afko_prod_ac-aufnr " Ordem de Produ��o
        AND mtart EQ c_semi_acabado       " HALB
        AND bwart IN (c_entrada_mercd ,                     " 101
                      c_sm_para_ordem ).                    " 261
  ENDIF.
ENDFORM.                    "f_movimentos_granel

*&---------------------------------------------------------------------*
*&      Form  f_itens_granel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_itens_granel.
  IF t_mvtos_granel IS NOT INITIAL.
    SELECT aufnr posnr matnr pwerk dwerk charg
     FROM afpo
     INTO TABLE t_afpo_granel_itm
     FOR ALL ENTRIES IN t_mvtos_granel
      WHERE matnr = t_mvtos_granel-matnr  " N� do material
        AND charg = t_mvtos_granel-charg  " N�mero do lote
        AND dwerk = t_mvtos_granel-werks. " Centro
  ENDIF.
ENDFORM.                    "f_itens_granel

*&---------------------------------------------------------------------*
*&      Form  f_granel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_granel.
  IF t_afpo_granel_itm IS NOT INITIAL.
    SELECT afko~aufnr
           afko~ftrmi
           afko~plnbez
           aufk~erdat
     FROM afko
     INNER JOIN aufk ON aufk~aufnr = afko~aufnr
     INTO TABLE t_afko_granel
     FOR ALL ENTRIES IN t_afpo_granel_itm
      WHERE afko~aufnr = t_afpo_granel_itm-aufnr. " Ordem de Produ��o
  ENDIF.
ENDFORM.                    "f_granel

*&---------------------------------------------------------------------*
*&      Form  f_descricao_granel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_descricao_granel.
  IF t_afpo_granel_itm IS NOT INITIAL.
    SELECT matnr maktx
     FROM makt
     APPENDING TABLE t_dsc_prd_acb
     FOR ALL ENTRIES IN t_afpo_granel_itm
      WHERE matnr = t_afpo_granel_itm-matnr
        AND spras = c_pt_br.

    DELETE ADJACENT DUPLICATES FROM t_dsc_prd_acb.
  ENDIF.
ENDFORM.                    "f_descricao_granel

*&---------------------------------------------------------------------*
*&      Form  f_montar_tabela_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_montar_tabela_alv.
  DATA: v_indice   TYPE sy-tabix,
        v_qtd_dias TYPE i       .

  SORT: t_afko_prod_ac  BY aufnr ASCENDING,
        t_afko_granel   BY aufnr ASCENDING,
        t_afpo_prod_itm BY aufnr ASCENDING.

  LOOP AT t_afko_prod_ac INTO w_afko_prod_ac.
    READ TABLE t_afpo_prod_itm
    TRANSPORTING NO FIELDS
    WITH KEY aufnr = w_afko_prod_ac-aufnr.

    v_indice = sy-tabix.

    LOOP AT t_afpo_prod_itm INTO w_afpo_prod_itm FROM v_indice.
      IF w_afko_prod_ac-aufnr NE w_afpo_prod_itm-aufnr.
        EXIT.
      ENDIF.

      READ TABLE t_dsc_prd_acb
      INTO w_dsc_prd_acb
      WITH KEY matnr = w_afpo_prod_itm-matnr.

      w_alv-cod_prd_acb   = w_afko_prod_ac-plnbez. " C�digo do produto acabado
      w_alv-dsc_prd_acb   = w_dsc_prd_acb-maktx  . " Descri��o
      w_alv-lote          = w_afpo_prod_itm-charg. " Lote
      w_alv-centro        = w_afpo_prod_itm-pwerk. " Centro
      w_alv-op_prd_acb    = w_afko_prod_ac-aufnr . " OP Embalagem
      w_alv-dt_abr_op_emb = w_afko_prod_ac-erdat . " Data Abert. OP. (PA)
      w_alv-dt_lib_op_prd = w_afko_prod_ac-ftrmi . " Data Liber. OP (PA)

*---------------------------------------------------------------------*
*     L�to. 1� Pallet (Produto Acabado)
*    (Data de lan�amento no documento)
*---------------------------------------------------------------------*
      SELECT SINGLE MIN( budat )
       FROM aufm
       INTO (w_alv-lcto_pr_pallet) " L�to. 1� Pallet (PA)
       WHERE aufnr = w_afpo_prod_itm-aufnr
         AND bwart = c_entrada_mercd.                       " 101

*---------------------------------------------------------------------*
*     Lan�amento �ltimo Pallet (Produto Acabado)
*    (Data de lan�amento no documento)
*---------------------------------------------------------------------*
      SELECT SINGLE MAX( budat )
       FROM aufm
       INTO (w_alv-lcto_ul_pallet) " L�to. �lt Pallet (PA)
       WHERE aufnr = w_afpo_prod_itm-aufnr
         AND bwart = c_entrada_mercd.                       " 101

*---------------------------------------------------------------------*
*     Data da DU
*---------------------------------------------------------------------*

* 26/09/13 - Begin of cvmeire

*      CLEAR : v_prueflos, w_alv-dt_du.
*
*      SELECT SINGLE prueflos
*        FROM qals
*        INTO (v_prueflos)
*        WHERE werk =  w_alv-centro
*        AND aufnr = w_afpo_prod_itm-aufnr.
*
*      SELECT SINGLE vaedatum
*       FROM qave
*       INTO (w_alv-dt_du) " Data da DU
*       WHERE prueflos = v_prueflos.

      CLEAR : it_qals, it_jest, it_qave, w_alv-dt_du.
      REFRESH: it_qals, it_jest, it_qave.


      SELECT *
        FROM qals
        INTO TABLE it_qals
        WHERE werk = w_alv-centro
        AND aufnr = w_afpo_prod_itm-aufnr.

*   Verifica se encontrou algum lote com status estornado
      SELECT *
       FROM jest
       INTO TABLE it_jest
       FOR ALL ENTRIES IN it_qals
       WHERE objnr  = it_qals-objnr
         AND stat   = 'I0224'
         AND inact  = space.

      CLEAR : v_tabix.

      LOOP AT it_qals.
        v_tabix = sy-tabix.
        READ TABLE it_jest WITH KEY objnr = it_qals-objnr.
        IF sy-subrc EQ 0.
          it_qals-mark = 'X'.
        ENDIF.
        MODIFY it_qals INDEX v_tabix.
      ENDLOOP.

      DELETE it_qals WHERE mark = 'X'.

*   Datas da DU
      SELECT *
       FROM qave
       INTO TABLE it_qave
       FOR ALL ENTRIES IN it_qals
       WHERE prueflos = it_qals-prueflos.

      SORT it_qave BY vaedatum DESCENDING.
      READ TABLE it_qave INDEX 1.
      w_alv-dt_du = it_qave-vaedatum.

* 26/09/13 - End of cvmeire

*---------------------------------------------------------------------*
*     Tempo ordem aberta (Produto Acabado)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-dt_abr_op_emb " Data Abert. OP. (PA)
              w_alv-dt_lib_op_prd " Data Liber. OP (PA)
     CHANGING v_qtd_dias.

      w_alv-tmp_ord_ab = v_qtd_dias. " Tmp OP Aberta (PA)

*---------------------------------------------------------------------*
*     Tempo de ordem liberada (Produto Acabado)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-dt_lib_op_prd   " Data Liber. OP (PA)
              w_alv-lcto_pr_pallet  " L�to. 1� Pallet (PA)
     CHANGING v_qtd_dias.

      w_alv-tmp_ord_lib = v_qtd_dias. " Tmp OP Liberada (PA)

*---------------------------------------------------------------------*
*     Tempo de embalagem (Produto Acabado)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-lcto_pr_pallet " L�to. 1� Pallet (PA)
              w_alv-lcto_ul_pallet " L�to. �lt Pallet (PA)
     CHANGING v_qtd_dias.

      w_alv-tmp_emb = v_qtd_dias. " Tmp Embalagem (PA)

*---------------------------------------------------------------------*
*     Tempo de aprova��o (Produto Acabado)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-lcto_ul_pallet " L�to. �lt Pallet (PA)
              w_alv-dt_du          " Data da DU
     CHANGING v_qtd_dias.

      w_alv-tmp_aprv = v_qtd_dias. " Tmp. Aprova��o

*---------------------------------------------------------------------*
*     Lead Time (Produto Acabado)
*---------------------------------------------------------------------*
      w_alv-lt_emb = w_alv-tmp_ord_lib + " Tmp OP Liberada (PA)
                     w_alv-tmp_emb     + " Tmp Embalagem (PA)
                     w_alv-tmp_aprv    . " Tmp. Aprova��o

*---------------------------------------------------------------------*
*     Granel
*---------------------------------------------------------------------*
      CLEAR: w_mvtos_granel, w_afpo_granel_itm, w_afko_granel, w_dsc_prd_acb.

      READ TABLE t_mvtos_granel
      INTO w_mvtos_granel
      WITH KEY aufnr = w_afpo_prod_itm-aufnr.

      IF sy-subrc = 0.
        READ TABLE t_afpo_granel_itm
        INTO w_afpo_granel_itm
        WITH KEY charg = w_mvtos_granel-charg.

        IF sy-subrc = 0.
*         Seleciona o n�mero da OP do granel
          READ TABLE t_afko_granel
          INTO w_afko_granel
          WITH KEY aufnr = w_afpo_granel_itm-aufnr.

          IF sy-subrc = 0.
*           Nome do material do granel
            READ TABLE t_dsc_prd_acb
            INTO w_dsc_prd_acb
            WITH KEY matnr = w_afko_granel-plnbez.
          ENDIF.
        ENDIF.
      ENDIF.

      w_alv-op_granel  = w_afko_granel-aufnr . " OP. Granel
      w_alv-cod_granel = w_afko_granel-plnbez. " N� do material
      w_alv-dsc_granel = w_dsc_prd_acb-maktx . " Descri��o
      w_alv-abr_op_grn = w_afko_granel-erdat . " Data Abert. OP. (SA)
      w_alv-lib_op_grn = w_afko_granel-ftrmi . " Data Liber. OP (SA)

*---------------------------------------------------------------------*
*     Data Entrada (SA)
*---------------------------------------------------------------------*
      SELECT SINGLE MAX( budat ) " Data de lan�amento no documento
       FROM aufm
       INTO (w_alv-dt_ent_qtd_prod) " Data Entrada (SA)
       WHERE aufnr = w_afko_granel-aufnr
         AND bwart = c_entrada_mercd.                       " 101

*---------------------------------------------------------------------*
*     L�to. 1� MP (SA) (granel)
*---------------------------------------------------------------------*
      SELECT SINGLE MIN( budat ) " Data de lan�amento no documento
       FROM aufm
       INTO (w_alv-lcto_pr_mp_pes) " L�to. 1� MP (SA)
       WHERE aufnr = w_afko_granel-aufnr
         AND bwart = c_sm_para_ordem.                       " 261

*---------------------------------------------------------------------*
*     L�to. Ult. MP (SA) (Granel)
*---------------------------------------------------------------------*
      SELECT SINGLE MAX( budat ) " Data de lan�amento no documento
       FROM aufm
       INTO (w_alv-lcto_ul_mp_pes) " L�to. Ult. MP (SA)
       WHERE aufnr = w_afko_granel-aufnr
         AND bwart = c_sm_para_ordem.                       " 261

*---------------------------------------------------------------------*
*     Tempo ordem aberta (Granel)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-abr_op_grn " Data libera��o OP (PA)
              w_alv-lib_op_grn " Data abertura OP (PA)
     CHANGING v_qtd_dias.

      w_alv-tmp_ord_abe_fab = v_qtd_dias.

*---------------------------------------------------------------------*
*     Tempo de ordem liberada (Granel)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-lib_op_grn     " Data Liber. OP (SA)
              w_alv-lcto_pr_mp_pes " L�to. 1� MP (SA)
     CHANGING v_qtd_dias.

      w_alv-tmp_ord_lib_fab = v_qtd_dias. " Tmp OP Liberada (SA)

*---------------------------------------------------------------------*
*     Tempo de pesagem (Granel)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-lcto_pr_mp_pes " L�to. 1� MP (SA)
              w_alv-lcto_ul_mp_pes " L�to. Ult. MP (SA)
     CHANGING v_qtd_dias.

      w_alv-tmp_pesagem = v_qtd_dias. " Tmp Pesagem

*---------------------------------------------------------------------*
*     Tempo de fabrica��o (Granel)
*---------------------------------------------------------------------*
      PERFORM f_intervalo_entre_datas
        USING w_alv-lcto_ul_mp_pes  " L�to. Ult. MP (SA)
              w_alv-dt_ent_qtd_prod " Data Entrada (SA)
     CHANGING v_qtd_dias.

      w_alv-tmp_fabric = v_qtd_dias. " Tmp Fabrica��o

*---------------------------------------------------------------------*
*     Lead Time Granel
*---------------------------------------------------------------------*
      w_alv-lt_grn = w_alv-tmp_ord_lib_fab + " Tmp OP Liberada (SA)
                     w_alv-tmp_pesagem     + " Tempo de pesagem
                     w_alv-tmp_fabric      . " Tempo de fabrica��o
*---------------------------------------------------------------------*
*     Lead Time geral
*---------------------------------------------------------------------*
      w_alv-lt_geral = w_alv-lt_emb + " Lead time (PA)
                       w_alv-lt_grn . " Lead Time Granel

      APPEND w_alv TO t_alv.
    ENDLOOP. " LOOP AT t_afpo_prod_itm INTO w_afpo_prod_itm FROM v_indice.
  ENDLOOP. " LOOP AT t_afko_prod_ac INTO w_afko_prod_ac.

  SORT t_alv BY cod_prd_acb op_prd_acb ASCENDING.
ENDFORM.                    "f_montar_tabela_alv

*&---------------------------------------------------------------------*
*&      Form  f_intervalo_entre_datas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->BEGDA      text
*      -->ENDDA      text
*      -->P_DIAS     text
*----------------------------------------------------------------------*
FORM f_intervalo_entre_datas
     USING begda  TYPE d
           endda  TYPE d
  CHANGING p_dias TYPE i.

  CLEAR p_dias.

  CHECK begda IS NOT INITIAL
    AND endda IS NOT INITIAL.

  CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
    EXPORTING
      begda = begda
      endda = endda
    IMPORTING
      days  = p_dias.

* A fun��o retorna 1 dia a mais, por isso � necess�rio subtrair 1
  IF p_dias > 0.
    p_dias = p_dias - 1.
  ELSE.
    p_dias = p_dias + 1.
  ENDIF.

ENDFORM.                    "f_intervalo_entre_datas

*&---------------------------------------------------------------------*
*&      Form  f_montar_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_t_fcat   text
*      -->p_w_fcat   text
*      -->P_STRUCTURE text
*      -->P_HOSTPOT   text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_t_fcat    TYPE lvc_t_fcat
   USING p_w_fcat    TYPE lvc_s_fcat
         p_structure TYPE ddobjname
         p_hostpot   TYPE c        .

  DATA: t_campos TYPE STANDARD TABLE OF dd03p,
        w_campos LIKE LINE OF t_campos      .

  DATA: v_campo       TYPE rollname       ,
        v_nome_coluna TYPE dd04t-scrtext_m.

  CONSTANTS:
    c_versao_ativa  TYPE ddobjstate VALUE 'A'.

  FREE: p_t_fcat, p_w_fcat.

* Obt�m o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_structure
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = t_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT t_campos INTO w_campos.
    v_campo = w_campos-rollname.

*   Seleciona a descri��o m�dia do elemento de dados
    SELECT SINGLE scrtext_m
    FROM  dd04t
    INTO (v_nome_coluna)
     WHERE rollname  = v_campo
      AND ddlanguage = c_pt_br
      AND as4local   = c_versao_ativa.

    MOVE-CORRESPONDING w_campos TO p_w_fcat.
    p_w_fcat-coltext = v_nome_coluna.
    p_w_fcat-col_pos = sy-tabix     .

    IF p_hostpot IS NOT INITIAL
      AND w_campos-fieldname = c_hostpot_op_acb
       OR w_campos-fieldname = c_hostpot_op_grn.
      p_w_fcat-hotspot = 'X'.
    ENDIF.

    APPEND p_w_fcat TO p_t_fcat.
    CLEAR p_w_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTAINER text
*      -->P_ALV_GRID  text
*      -->P_NOME_CONT text
*      -->P_FIELDCAT  text
*      -->P_T_ALV     text
*      -->P_TITULO    text
*      -->P_TOOLBAR   text
*----------------------------------------------------------------------*
FORM f_montar_alv
 USING p_container  TYPE REF TO cl_gui_custom_container
       p_alv_grid   TYPE REF TO cl_gui_alv_grid
       p_nome_cont  TYPE scrfname
       p_fieldcat   TYPE lvc_t_fcat
       p_t_alv      TYPE STANDARD TABLE
       p_titulo     TYPE lvc_s_layo-grid_title
       p_no_toolbar TYPE c.

  IF p_container IS NOT INITIAL.
    p_container->free( ).
  ENDIF.

  CREATE OBJECT p_container
    EXPORTING
      container_name = p_nome_cont
    EXCEPTIONS
      OTHERS         = 6.

* Cria uma inst�ncia da classe cl_gui_alv_grid no custom container
* inserido no layout da tela
  CREATE OBJECT p_alv_grid
    EXPORTING
      i_parent = p_container
    EXCEPTIONS
      OTHERS   = 5.

  DATA: o_evt_alv TYPE REF TO lcl_evento_alv.
  CREATE OBJECT o_evt_alv.
  SET HANDLER o_evt_alv->hotspot_click FOR p_alv_grid.

  DATA: w_alv_layout TYPE lvc_s_layo.
  w_alv_layout-zebra      = 'X'     . " Zebrado
  w_alv_layout-cwidth_opt = 'X'     . " Otimiza��o da coluna
  w_alv_layout-grid_title = p_titulo. " Titulo do ALV
  w_alv_layout-info_fname = 'ROWCOLOR'."For row coloring

  DATA: t_sort TYPE STANDARD TABLE OF lvc_s_sort INITIAL SIZE 0.
  DATA: w_sort TYPE  lvc_s_sort.

  w_sort-spos      = 2            .
  w_sort-fieldname = 'COD_PRD_ACB'.
  w_sort-group     = 'X'          .
  APPEND w_sort TO t_sort         .

  w_sort-spos      = 3            .
  w_sort-fieldname = 'DSC_PRD_ACB'.
  w_sort-group     = 'X'          .
  APPEND w_sort TO t_sort         .

  w_sort-spos      = 17           .
  w_sort-fieldname = 'COD_GRANEL'.
  w_sort-group     = 'X'          .
  APPEND w_sort TO t_sort         .

  w_sort-spos      = 18           .
  w_sort-fieldname = 'DSC_GRANEL'.
  w_sort-group     = 'X'          .
  APPEND w_sort TO t_sort         .

* Exclui os bot�es da barra de tarefas do ALV (Exportar p/ Excel)
  IF p_no_toolbar IS NOT INITIAL.
    w_alv_layout-no_toolbar = p_no_toolbar.
  ENDIF.

  p_alv_grid->set_table_for_first_display(
     EXPORTING
       is_layout       = w_alv_layout
     CHANGING
       it_outtab       = p_t_alv
       it_fieldcatalog = p_fieldcat
       it_sort         = t_sort
     EXCEPTIONS
       OTHERS          = 4 ).

  p_alv_grid->refresh_table_display( ).

ENDFORM.                    "f_montar_alv

*&---------------------------------------------------------------------*
*&      Form  event_hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_COLUMN   text
*----------------------------------------------------------------------*
FORM event_hotspot_click
 USING p_row    TYPE lvc_s_row
       p_column TYPE lvc_s_col.

  READ TABLE t_alv
  INTO w_alv
  INDEX p_row-index.

  IF p_column = c_hostpot_op_acb.
    PERFORM f_carregar_cor3
     USING w_alv-op_prd_acb.
  ELSEIF p_column = c_hostpot_op_grn.
    PERFORM f_carregar_cor3
     USING w_alv-op_granel.
  ENDIF.
ENDFORM.                    "event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  f_carregar_cor3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_num_op  text
*----------------------------------------------------------------------*
FORM f_carregar_cor3
 USING p_num_op TYPE yalv_leadtime-op_prd_acb.

  IF p_num_op IS NOT INITIAL.
    SET PARAMETER ID 'BR1' FIELD p_num_op.
    CALL TRANSACTION 'COR3' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    "f_carregar_cor3
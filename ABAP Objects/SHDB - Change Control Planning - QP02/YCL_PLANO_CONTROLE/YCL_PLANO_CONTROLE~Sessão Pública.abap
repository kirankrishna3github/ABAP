*----------------------------------------------------------------------*
*       CLASS YCL_PLANO_CONTROLE  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_plano_controle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

*"* public components of class YCL_PLANO_CONTROLE
*"* do not include other source files here!!!
  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_mapl                 ,
                                    plnty TYPE mapl-plnty          , " Tipo de roteiro
                                    plnnr TYPE mapl-plnnr          , " Chave do grupo de listas de tarefas
                                    plnal TYPE mapl-plnal          , " Numerador de grupos
                                    datuv TYPE mapl-datuv          , " Data in�cio validade
                                    loekz TYPE mapl-loekz          , " C�digo de elimina��o
                                    matnr TYPE mapl-matnr          , " N� do material
                                    werks TYPE mapl-werks          , " Centro
                                  END OF ty_mapl .
    TYPES:
      BEGIN OF ty_alv                  ,
                                    matnr      TYPE mapl-matnr     , " N� do material
                                    plnnr      TYPE mapl-plnnr     , " Chave do grupo de listas de tarefas
                                    plnal      TYPE mapl-plnal     , " Numerador de grupos
                                    werks      TYPE mapl-werks     , " Centro
                                    ktext      TYPE plko-ktext     , " TxtBrv.LstTaref.
                                    verwe      TYPE plko-verwe     , " Utiliza��o do plano
                                    statu      TYPE plko-statu     , " Status do plano
                                    losvn      TYPE plko-losvn     , " Tamanho de lote desde
                                    losbs      TYPE plko-losbs     , " Grupo de planejamento/departamento respons�vel
                                    plnme      TYPE plko-plnme     , " Unidade de medida da lista de tarefas
                                    vornr      TYPE plpo-vornr     , " N� opera��o
                                    steus      TYPE plpo-steus     , " Chave de controle
                                    ltxa1      TYPE plpo-ltxa1     , " Txt.breve opera��o
                                    merknr     TYPE plmk-merknr    , " N� caracter�stica de controle
                                    verwmerkm  TYPE plmk-verwmerkm , " Carac.mestre contr.
                                    kurztext   TYPE plmkb-kurztext , " Texto breve para caracter�stica de controle
                                    pmethode   TYPE plmk-pmethode  , " M�todo de controle
                                    sollwert   TYPE ysollwert      , " Valor te�rico para uma caracter�stica quantitativa
                                    toleranzun TYPE ytoleranzun    , " Limite inferior de toler�ncia
                                    toleranzob TYPE ytoleranzob    , " Valor limite superior
                                    stichprver TYPE plmk-stichprver, " Processo de amostra na caracter�stica de controle
                                    probemgeh  TYPE plmk-probemgeh , " Unidade de medida da amostra
                                    fakprobme  TYPE yfakprobme     , " Fator para convers�o UM amostra em UM material
                                    vsteuerkz  TYPE plmkb-vsteuerkz, " Proposta para c�digos de controle da caracter�stica
                                    stellen    TYPE plmk-stellen   , " N�mero de casas decimais (precis�o)
                                    masseinhsw TYPE plmk-masseinhsw, " Unidade de medida, na qual os dds.quantit.s�o gravados
                                    auswmenge1 TYPE plmk-auswmenge1, " Grupo de codes / conjunto de sele��o atribu�do
                                    auswmgwrk1 TYPE plmk-auswmgwrk1, " Centro do conjunto selecionado atribuido
                                  END OF ty_alv .

    TYPES:
  BEGIN OF ty_material_qp02        ,
                                matnr TYPE mara-matnr          , " Material
                                werks TYPE rc27m-werks         , " Centro
                              END OF ty_material_qp02 .

    TYPES:
      BEGIN OF ty_excel_qp02           ,
                                    matnr TYPE mara-matnr          , " Material
                                    werks TYPE rc27m-werks         , " Centro
                                    plnal TYPE plkod-plnal         , " Numerador de grupos
                                    qdynregel TYPE qdynregel       , " Regra de controle din�mico
                                    statu TYPE plkod-statu         , " Status do plano
                                    vornr TYPE plpod-vornr         , " N� opera��o
                                    merknr TYPE plmkb-merknr       , " N� caracter�stica de controle
                                    toleranzun TYPE yavrg_dec_11_2 , " Limite inferior
                                    toleranzob TYPE yavrg_dec_11_2 , " Limite superior
                                    ctrdin TYPE plmkb-qdynregel    , " Controle din�mico - Amostra <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    masseinhsw TYPE qmgeh6         , " Unidade
                        END OF ty_excel_qp02 .

    TYPES:
      BEGIN OF ty_lista_tarefas_qp02        ,
                                  matnr TYPE mara-matnr          , " Material
                                  werks TYPE rc27m-werks         , " Centro
                                  plnal TYPE plkod-plnal         , " Numerador de grupos
                                  qdynregel TYPE qdynregel       , " Regra de controle din�mico
                                  qdynhead TYPE plkod-qdynhead   , " N�vel no qual devem ser definidos par�ms.controle din�mico
                                  statu    TYPE plkod-statu      , " Status do plano
                                END OF ty_lista_tarefas_qp02 .
    TYPES:
      BEGIN OF ty_operacoes_qp02        ,
                                  matnr TYPE mara-matnr          , " Material
                                  werks TYPE rc27m-werks         , " Centro
                                  plnal TYPE plkod-plnal         , " Numerador de grupos
                                  vornr TYPE plpod-vornr         , " N� opera��o
                                END OF ty_operacoes_qp02 .
    TYPES:
      BEGIN OF ty_caracteristicas_ctrl_qp02        ,
                                  matnr TYPE mara-matnr          , " Material
                                  werks TYPE rc27m-werks         , " Centro
                                  plnal TYPE plkod-plnal         , " Numerador de grupos
                                  vornr TYPE plpod-vornr         , " N� opera��o
                                  merknr TYPE plmkb-merknr       , " N� caracter�stica de controle
                                  qdynregel TYPE qdynregel       , " Regra de controle din�mico
                                  toleranzun TYPE char12         , "yavrg_dec_11_2 , " Limite inferior
                                  toleranzob TYPE char12         , "yavrg_dec_11_2 , " Limite superior
                                  masseinhsw TYPE qmgeh6         , " Unidade
                                END OF ty_caracteristicas_ctrl_qp02 .
    TYPES:
      BEGIN OF ty_alv_log_qp02         ,
                                    matnr       TYPE mara-matnr    ,
                                    msg_erro    TYPE c LENGTH 99   ,
                                  END OF ty_alv_log_qp02 .
    TYPES:
      tp_mapl          TYPE STANDARD TABLE OF ty_mapl          WITH DEFAULT KEY .
    TYPES:
      tp_alv           TYPE STANDARD TABLE OF ty_alv           WITH DEFAULT KEY .
    TYPES:
      tp_excel_qp02    TYPE STANDARD TABLE OF ty_excel_qp02    WITH DEFAULT KEY .
    TYPES:
      tp_material_qp02 TYPE STANDARD TABLE OF ty_material_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_lista_tarefas_qp02 TYPE STANDARD TABLE OF ty_lista_tarefas_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_operacoes_qp02 TYPE STANDARD TABLE OF ty_operacoes_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_caracteristicas_ctrl_qp02 TYPE STANDARD TABLE OF ty_caracteristicas_ctrl_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_alv_log_qp02  TYPE STANDARD TABLE OF ty_alv_log_qp02  WITH DEFAULT KEY .
    TYPES:
      r_plnnr TYPE RANGE OF char10 .
    TYPES:
      r_datuv TYPE RANGE OF mapl-datuv .
    TYPES:
      r_matnr TYPE RANGE OF mapl-matnr .
    TYPES:
      r_werks TYPE RANGE OF mapl-werks .
    TYPES:
      r_plnal TYPE RANGE OF mapl-plnal .

    METHODS exibir_alv
      CHANGING
        !t_alv TYPE tp_alv .
    METHODS exibir_alv_log_qp02 .
    METHODS get_planos_materiais
      IMPORTING
        !plnnr TYPE r_plnnr
        !datuv TYPE r_datuv OPTIONAL
        !matnr TYPE r_matnr OPTIONAL
        !werks TYPE r_werks OPTIONAL
      RETURNING
        value(t_mapl) TYPE tp_mapl
      RAISING
        ycx_plano_controle .
    METHODS get_plano_controle
      IMPORTING
        !t_mapl TYPE tp_mapl
      RETURNING
        value(t_alv) TYPE tp_alv
      RAISING
        ycx_plano_controle .
    METHODS modificar_plano_controle
      IMPORTING
        !im_nome_arquivo TYPE localfile
        !im_opcao_batch TYPE ctu_mode
      RAISING
        ycx_plano_controle .
    CLASS-METHODS selecionar_planilha
      RETURNING
        value(ex_nome_arquivo) TYPE localfile .
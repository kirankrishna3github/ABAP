PROTECTED SECTION.

  TYPES:
*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
    BEGIN OF ty_vbak           ,
     vbeln TYPE vbak-vbeln    , " Documento de vendas
     erdat TYPE vbak-erdat    , " Data de cria��o do registro
     vkorg TYPE vbak-vkorg    , " Organiza��o de vendas
     vtweg TYPE vbak-vtweg    , " Canal de distribui��o
     spart TYPE vbak-spart    , " Setor de atividade
     vkbur TYPE vbak-vkbur    , " Escrit�rio de vendas
     knumv TYPE vbak-knumv    , " N� condi��o do documento
     netwr TYPE vbak-netwr    , " Valor l�quido da ordem
     bstnk TYPE vbak-bstnk    , " N� pedido do cliente
   END OF ty_vbak .
  TYPES:
    BEGIN OF ty_vbpa           ,
     vbeln TYPE vbpa-vbeln    , " N� documento de vendas e distribui��o
     lifnr TYPE vbpa-lifnr    , " N� conta do fornecedor
     pernr TYPE vbpa-pernr    , " N� pessoal
     parvw TYPE vbpa-parvw    , " Fun��o do parceiro
   END OF ty_vbpa .
  TYPES:
    BEGIN OF ty_vbkd           ,
     vbeln TYPE vbkd-vbeln    , " N� documento de vendas e distribui��o
     zterm TYPE vbkd-zterm    , " Chave de condi��es de pagamento
   END OF ty_vbkd .
  TYPES:
    BEGIN OF ty_vbfa           ,
     vbelv   TYPE vbfa-vbelv  , " Documento de vendas e distribui��o precedente
     vbeln   TYPE vbfa-vbeln  , " N� documento de vendas e distribui��o
     vbtyp_n TYPE vbfa-vbtyp_n, " Categoria de documento SD subseq�ente
     vbtyp_v TYPE vbfa-vbtyp_v, " Ctg.documento de venda e distribui��o (SD) precedente
   END OF ty_vbfa .
  TYPES:
    BEGIN OF ty_bseg           ,
     vbeln TYPE bseg-vbeln    , " N� documento de vendas e distribui��o
     buzei TYPE bseg-buzei    , " N� linha de lan�amento no documento cont�bil
     augbl TYPE bseg-augbl    , " N� documento de compensa��o
     koart TYPE bseg-koart    , " Tipo de conta
     parc  TYPE sy-tabix      , " Quantidade de parcelas
   END OF ty_bseg .
  TYPES:
    BEGIN OF ty_konv           ,
     knumv TYPE konv-knumv    , " N� condi��o do documento
     kposn TYPE konv-kposn    , " N� item ao qual se aplicam as condi��es
     kschl TYPE konv-kschl    , " Tipo de condi��o
     kbetr TYPE konv-kbetr    , " Montante ou porcentagem da condi��o
     kwert TYPE konv-kwert    , " Valor condi��o
   END OF ty_konv .
  TYPES:
    BEGIN OF ty_konv_total     ,
     knumv TYPE konv-knumv    , " N� condi��o do documento
     kschl TYPE konv-kschl    , " Tipo de condi��o
     kwert TYPE konv-kwert    , " Valor condi��o
   END OF ty_konv_total .
  TYPES:
    BEGIN OF ty_lfa1           ,
     lifnr TYPE lfa1-lifnr    , " N� conta do fornecedor
     name1 TYPE lfa1-name1    , " Descri��o
   END OF ty_lfa1 .
  TYPES:
    BEGIN OF ty_pa0001        ,
     pernr TYPE pa0001-pernr  , " N� pessoal
     sname TYPE pa0001-sname  , " Nome do empregado (orden�vel, SOBRENOME NOME)
   END OF ty_pa0001 .
  TYPES:
    BEGIN OF ty_cond_parc    ,
        kschl TYPE kschl      , " Tipo de condi��o
        parvw TYPE parvw      , " Parceiro
        fehgr TYPE fehgr      , " Esquema de dados
      END OF ty_cond_parc .
  TYPES:
    r_parvw TYPE RANGE OF parvw .
  TYPES:
    r_kschl TYPE RANGE OF kschl .
  TYPES:
    tp_vbak       TYPE STANDARD TABLE OF ty_vbak       WITH DEFAULT KEY .
  TYPES:
    tp_konv_total TYPE STANDARD TABLE OF ty_konv_total WITH DEFAULT KEY .
  TYPES:
    tp_cond_parc TYPE STANDARD TABLE OF ty_cond_parc WITH DEFAULT KEY .

  CONSTANTS c_rep_externo TYPE tvuv-fehgr VALUE '08'.       "#EC NOTEXT
  CONSTANTS c_rep_interno TYPE tvuv-fehgr VALUE '09'.       "#EC NOTEXT
  CONSTANTS c_fatura TYPE vbtyp VALUE 'M'.                  "#EC NOTEXT
  CONSTANTS c_ordem TYPE vbtyp VALUE 'C'.                   "#EC NOTEXT
  CONSTANTS c_conta_cliente TYPE vbtyp VALUE 'D'.           "#EC NOTEXT
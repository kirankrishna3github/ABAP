*"* protected components of class YCL_INVENTARIO
*"* do not include other source files here!!!
protected section.

  types:
    BEGIN OF ty_linv                      ,
     lgnum TYPE linv-lgnum                , " N�dep�sito/complexo de dep�sito
     ivnum TYPE linv-ivnum                , " N� documento de invent�rio
     ivpos TYPE linv-ivpos                , " N� item no documento de invent�rio
     lgtyp TYPE linv-lgtyp                , " Tipo de dep�sito
     lgpla TYPE linv-lgpla                , " Posi��o no dep�sito
     plpos TYPE linv-plpos                , " Item na posi��o do dep�sito
     matnr TYPE linv-matnr                , " N� do material
     werks TYPE linv-werks                , " Centro
     charg TYPE linv-charg                , " N�mero do lote
    END OF ty_linv .
  types:
    BEGIN OF ty_ol_empresa                ,
     werks    TYPE ymm_ol_empresa-werks   , " Centro
     lgort_da TYPE ymm_ol_empresa-lgort_da, " Dep�sito Acabado
     lgort_dp TYPE ymm_ol_empresa-lgort_dp, " Dep�sito Promocional
    END OF ty_ol_empresa .
  types:
    BEGIN OF ty_linp                      ,
     lgnum TYPE linp-lgnum                , " N�dep�sito/complexo de dep�sito
     ivnum TYPE linp-ivnum                , " N� documento de invent�rio
     lgpla TYPE linp-lgpla                , " Posi��o no dep�sito
     idatu TYPE linp-idatu                , " Data do invent�rio
    END OF ty_linp .
  types:
    BEGIN OF ty_mch1                      ,
     matnr TYPE mch1-matnr                , " N� do material
     charg TYPE mch1-charg                , " Lote
     hsdat TYPE mch1-hsdat                , " Data de produ��o
     vfdat TYPE mch1-vfdat                , " Data do vencimento
    END OF ty_mch1 .
  types:
    BEGIN OF ty_mara                      ,
     matnr TYPE mara-matnr                , " N� do material
     mtart TYPE mara-mtart                , " Tipo de material
    END OF ty_mara .
  types:
    BEGIN OF ty_lqua                      ,
     lgnum TYPE lqua-lgnum                , " N�dep�sito/complexo de dep�sito
     lqnum TYPE lqua-lqnum                , " Quanto
     matnr TYPE lqua-matnr                , " N� do material
     werks TYPE lqua-werks                , " Centro
     charg TYPE lqua-charg                , " N�mero do lote
     lgtyp TYPE lqua-lgtyp                , " Tipo de dep�sito
     lgpla TYPE lqua-lgpla                , " Posi��o no dep�sito
     bestq TYPE lqua-bestq                , " Tipo de estoque no sistema de administra��o de dep�sito
   END OF ty_lqua .
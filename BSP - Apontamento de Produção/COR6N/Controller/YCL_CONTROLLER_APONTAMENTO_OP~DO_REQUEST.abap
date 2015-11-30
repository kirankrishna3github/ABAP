*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Super-classe: CL_BSP_CONTROLLER2                                     *
* Sub-classe  : YCL_CONTROLLER_APONTAMENTO_OP                          *
* M�todo      : DO_REQUEST                                             *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimiza��o Avan�ada do Planejamento de Produ��o)         *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descri��o: M�todo redefinido para associar o evento solicitado ao    *
*            controller                                                *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD do_request.
  me->dispatch_input( ).
ENDMETHOD.
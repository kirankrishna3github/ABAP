*----------------------------------------------------------------------*
*               Ach� Laborat�rios Farmac�uticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* M�todo   : GET_CORPO_EMAIL_NFE                                       *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descri��o: Obter corpo do e-mail da NF-e                             *
*----------------------------------------------------------------------*
*                   Descri��o das Modifica��es                         *
*----------------------------------------------------------------------*
* Nome      Data        Descri��o                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_corpo_email_nfe.
*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_corpo_email LIKE LINE OF t_corpo_email.

*----------------------------------------------------------------------*
* Vari�veis
*----------------------------------------------------------------------*
  DATA:
    v_nr_nfe TYPE c LENGTH 9.

*----------------------------------------------------------------------*
* In�cio
*----------------------------------------------------------------------*

  APPEND 'Segue anexo o arquivo XML da Nota Fiscal eletr�nica.' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  CLEAR v_nr_nfe.
  v_nr_nfe = w_nfe-nnf.
  SHIFT v_nr_nfe LEFT DELETING LEADING '0'.

  CONCATENATE 'NF-e: ' v_nr_nfe 'S�rie: ' w_nfe-serie INTO w_corpo_email RESPECTING BLANKS. "#EC NOTEXT
  APPEND w_corpo_email TO t_corpo_email     .

  CONCATENATE 'Data de emiss�o: ' w_nfe-dhemi+4(2) '/' w_nfe-dhemi(4) INTO w_corpo_email RESPECTING BLANKS. "#EC NOTEXT
  APPEND w_corpo_email TO t_corpo_email     .

  CONCATENATE 'Chave de acesso: ' w_nfe-id INTO w_corpo_email RESPECTING BLANKS. "#EC NOTEXT
  APPEND w_corpo_email TO t_corpo_email     .

  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Para efetuar a consulta da sua NF-e acesse o link abaixo:' TO t_corpo_email. "#EC NOTEXT
  APPEND 'http://www.nfe.fazenda.gov.br/PORTAL/Default.aspx ' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Se voc� utiliza um filtro de e-mail ou um bloqueador de SPAM, o Ach� recomenda que voc� adicione o dom�nio "ache.com.br" � sua lista de remetentes seguros.' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Envio de e-mail autom�tico, favor n�o responder.' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Atenciosamente, ' TO t_corpo_email.               "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .
  APPEND w_nfe-emit TO t_corpo_email        .

ENDMETHOD.
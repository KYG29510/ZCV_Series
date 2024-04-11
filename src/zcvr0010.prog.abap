*&---------------------------------------------------------------------*
*& Report ZCVR0010
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Program Description: BP Master Upload
* Developer : LJ
* Date : 20 NOV 2021
* Detail : BP Master Upload form frontend
*&----------------------------------------------------------------------*

*&---------------------------------------------------------------------**
REPORT zcvr0010.


*----------------------------------------------------------------------*
*       Tables
*----------------------------------------------------------------------*
DATA :
  gt_return LIKE STANDARD TABLE OF cvis_bp_return,
  g_error           TYPE flag.

DATA:
  gr_table     TYPE REF TO cl_salv_table.

*&---------------------------------------------------------------------*
*&   Selection screen
*&---------------------------------------------------------------------*

*SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.
*
*
*  SELECTION-SCREEN SKIP .
*
*  PARAMETERS:
*    p_file  TYPE string OBLIGATORY DEFAULT 'C:\',
*    p_batch type int4 DEFAULT '999' .
*
*  SELECTION-SCREEN SKIP .
*
*  PARAMETERS:
*    p_test   LIKE mdat1-kz_test DEFAULT 'X',
*    p_taxjur LIKE mdat1-kz_test DEFAULT 'X' NO-DISPLAY.
*SELECTION-SCREEN END OF BLOCK blk1.
*

INCLUDE zcvi0000 .

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.


  IF prd_fg IS NOT INITIAL .

*---read excel file
  PERFORM frm_upload_excle_file
                         USING p_file
                               p_batch
                      CHANGING gt_excel.

  ELSE .

*---read excel file
    PERFORM frm_read_flat_file
                           USING p_sfile
                        CHANGING gt_excel.


  ENDIF .



*---mapping to CVI Maintain
  PERFORM frm_BUSINESS_PARTNER_MAINTAIN
                      USING gt_excel .



*---show the result
  PERFORM frm_SHOW_ALV_RESULT .

*----------------------------------------------------------------------*
*      Form  BUSINESS_PARTNER_MAINTAIN                                      *
*----------------------------------------------------------------------*
FORM frm_business_partner_maintain
         USING i_t_raw_excel TYPE typ_t_excel  .


  DATA:
    lt_cvis_bp_general             LIKE STANDARD TABLE OF cvis_bp_general,
    lt_cvis_bp_role                LIKE STANDARD TABLE OF cvis_bp_role,
    lt_cvis_bp_industry            LIKE STANDARD TABLE OF cvis_bp_industry,
    lt_cvis_bp_ident_numbers       LIKE STANDARD TABLE OF cvis_bp_ident_numbers,
    lt_cvis_bp_bank_details        LIKE STANDARD TABLE OF cvis_bp_bank_details,
    lt_cvis_bp_tax_number          LIKE STANDARD TABLE OF cvis_bp_tax_number,
    lt_cvis_bp_tax_number_common   LIKE STANDARD TABLE OF cvis_bp_tax_number_common,
    lt_cvis_bp_address             LIKE STANDARD TABLE OF cvis_bp_address,
    lt_cvis_bp_address_usage       LIKE STANDARD TABLE OF cvis_bp_address_usage,
    lt_cvis_bp_address_teleno      LIKE STANDARD TABLE OF cvis_bp_address_teleno,
    lt_cvis_bp_address_faxno       LIKE STANDARD TABLE OF cvis_bp_address_faxno,
    lt_cvis_bp_address_email       LIKE STANDARD TABLE OF cvis_bp_address_email,
    lt_cvis_bp_address_url         LIKE STANDARD TABLE OF cvis_bp_address_url,
    lt_cvis_bp_relation            LIKE STANDARD TABLE OF cvis_bp_relation,
    lt_cvis_customer_general       LIKE STANDARD TABLE OF cvis_customer_general,
    lt_cvis_customer_company       LIKE STANDARD TABLE OF cvis_customer_company,
    lt_cvis_customer_sales         LIKE STANDARD TABLE OF cvis_customer_sales,
    lt_cvis_customer_comp_dunning  LIKE STANDARD TABLE OF cvis_customer_comp_dunning,
    lt_cvis_customer_sales_func    LIKE STANDARD TABLE OF cvis_customer_sales_func,
    lt_cvis_customer_tax_indicator LIKE STANDARD TABLE OF cvis_customer_tax_indicator,
    lt_cvis_customer_general_vat   LIKE STANDARD TABLE OF cvis_customer_general_vat,
    lt_cvis_supplier_general       LIKE STANDARD TABLE OF cvis_supplier_general,
    lt_cvis_supplier_company       LIKE STANDARD TABLE OF cvis_supplier_company,
    lt_cvis_supplier_company_wtax  LIKE STANDARD TABLE OF cvis_supplier_company_wtax,
    lt_cvis_supplier_purchasing    LIKE STANDARD TABLE OF cvis_supplier_purchasing,
    lt_cvis_supplier_general_vat   LIKE STANDARD TABLE OF cvis_supplier_general_vat.



  DATA :
    lt_cvis_bp_address_teleno_re  LIKE STANDARD TABLE OF cvis_address_telno_remarks,
    lt_cvis_bp_address_email_re   LIKE STANDARD TABLE OF cvis_address_email_remarks,
    lt_cvis_bp_finserv               LIKE STANDARD TABLE OF cvis_bp_finserv,
    lt_CVIS_BP_PAYMENT_CARD       LIKE STANDARD TABLE OF cvis_bp_payment_card,
    lt_CVIS_CUSTOMER_CREDITCARD   LIKE STANDARD TABLE OF cvis_customer_creditcard,
    lt_CVIS_CUSTOMER_GEN_TEXTS    LIKE STANDARD TABLE OF cvis_customer_gen_texts,
    lt_cvis_customer_loading      LIKE STANDARD TABLE OF cvis_customer_loading,
    lt_CVIS_CUSTOMER_EXPORT       LIKE STANDARD TABLE OF cvis_customer_export,
    lt_CVIS_CUSTOMER_ALT_PAYEE    LIKE STANDARD TABLE OF cvis_customer_alt_payee,
    lt_CVIS_CUSTOMER_WTAX         LIKE STANDARD TABLE OF cvis_customer_wtax,
    lt_CVIS_CUSTOMER_CC_TEXTS     LIKE STANDARD TABLE OF cvis_customer_cc_texts,
    lt_cvis_customer_company_apay LIKE STANDARD TABLE OF cvis_customer_alt_payee,
    lt_cvis_customer_sales_texts  LIKE STANDARD TABLE OF cvis_customer_sales_texts,
    lt_CUST_GENERAL_LOADING       LIKE STANDARD TABLE OF cvis_customer_loading,
    lt_CVIS_SUPPLIER_ALT_PAYEE    LIKE STANDARD TABLE OF cvis_supplier_alt_payee,
    lt_CVIS_SUPPLIER_GEN_TEXTS    LIKE STANDARD TABLE OF cvis_supplier_gen_texts,
    lt_CVIS_SUPPLIER_CC_TEXTS     LIKE STANDARD TABLE OF cvis_supplier_cc_texts,
    lt_cvis_supplier_prog_texts   LIKE STANDARD TABLE OF cvis_supplier_porg_texts,
    lt_cvis_supplier_purchasing2  LIKE STANDARD TABLE OF cvis_supplier_purchasing2,
    lt_CVIS_SUPPLIER_PURCH_FUNC   LIKE STANDARD TABLE OF cvis_supplier_purch_func.


  DATA :
    lt_CVIS_SUPPLIER_CONTACTS      LIKE STANDARD TABLE OF cvis_supplier_contacts,
    lt_CVIS_SUPP_CONT_ADDRESS1     LIKE STANDARD TABLE OF cvis_SUPP_cont_address1,
    lt_CVIS_SUPP_CONT_ADDRESS2     LIKE STANDARD TABLE OF cvis_SUPP_cont_address2,
    lt_CVIS_SUPP_CONT_ADDRESS3     LIKE STANDARD TABLE OF cvis_SUPP_cont_address3,
    lt_CVIS_SUPP_CONT_TELENO1      LIKE STANDARD TABLE OF cvis_SUPP_cont_teleno1,
    lt_CVIS_SUPP_CONT_TELENO2      LIKE STANDARD TABLE OF cvis_SUPP_cont_teleno2,
    lt_CVIS_SUPP_CONT_TELENO3      LIKE STANDARD TABLE OF cvis_SUPP_cont_teleno3,
    lt_CVIS_SUPP_CONT_FAX1         LIKE STANDARD TABLE OF cvis_SUPP_cont_fax1,
    lt_CVIS_SUPP_CONT_FAX2         LIKE STANDARD TABLE OF cvis_SUPP_cont_fax2,
    lt_CVIS_SUPP_CONT_FAX3         LIKE STANDARD TABLE OF cvis_SUPP_cont_fax3,
    lt_CVIS_SUPP_CONT_EMAIL1       LIKE STANDARD TABLE OF cvis_SUPP_cont_EMAIL1,
    lt_CVIS_SUPP_CONT_EMAIL2       LIKE STANDARD TABLE OF cvis_SUPP_cont_EMAIL2,
    lt_CVIS_SUPP_CONT_EMAIL3       LIKE STANDARD TABLE OF cvis_SUPP_cont_EMAIL3,


    lt_CVIS_CUST_CONT_ADDRESS1     LIKE STANDARD TABLE OF cvis_cust_cont_address1,
    lt_CVIS_CUST_CONT_ADDRESS2     LIKE STANDARD TABLE OF cvis_cust_cont_address2,
    lt_CVIS_CUST_CONT_ADDRESS3     LIKE STANDARD TABLE OF cvis_cust_cont_address3,
    lt_CVIS_CUST_CONT_TELENO1      LIKE STANDARD TABLE OF cvis_cust_cont_teleno1,
    lt_CVIS_CUST_CONT_TELENO2      LIKE STANDARD TABLE OF cvis_cust_cont_teleno2,
    lt_CVIS_CUST_CONT_TELENO3      LIKE STANDARD TABLE OF cvis_cust_cont_teleno3,
    lt_CVIS_CUST_CONT_FAX1         LIKE STANDARD TABLE OF cvis_cust_cont_fax1,
    lt_CVIS_CUST_CONT_FAX2         LIKE STANDARD TABLE OF cvis_cust_cont_fax2,
    lt_CVIS_CUST_CONT_FAX3         LIKE STANDARD TABLE OF cvis_cust_cont_fax3,
    lt_CVIS_CUST_CONT_EMAIL1       LIKE STANDARD TABLE OF cvis_cust_cont_EMAIL1,
    lt_CVIS_CUST_CONT_EMAIL2       LIKE STANDARD TABLE OF cvis_cust_cont_EMAIL2,
    lt_CVIS_CUST_CONT_EMAIL3       LIKE STANDARD TABLE OF cvis_cust_cont_EMAIL3,
    lt_CVIS_CUSTOMER_CONTACT_TEXTS LIKE STANDARD TABLE OF cvis_customer_contact_texts.




  DATA l_partner_guid TYPE bu_partner_guid  .

  DATA l_commit TYPE swo_commit .



  DATA:
    BEGIN OF ls_sp_fields,
      runid TYPE string VALUE 'RUN_ID',
      bp    TYPE string VALUE 'BPARTNER',
    END OF ls_sp_fields.

  DATA :
    l_structure     TYPE char50,
    lw_dynamic_itab TYPE string,
    lref            TYPE REF TO data.

  DATA :
    l_runid TYPE  cvi_run_id,
    l_bp    TYPE  bu_partner.

  DATA :
    lt_structure TYPE STANDARD TABLE OF typ_excel,
    lt_fields    TYPE STANDARD TABLE OF typ_excel,
    lt_data      TYPE STANDARD TABLE OF typ_excel.


  FIELD-SYMBOLS :
    <lfs_t_itab> TYPE STANDARD TABLE,
    <lfs_s_itab> TYPE any,
    <lfs_comp>   TYPE any.


  CHECK g_error IS INITIAL .


*---
  LOOP AT i_t_raw_excel ASSIGNING FIELD-SYMBOL(<lfs_raw_excel>).

    CASE <lfs_raw_excel>-row .
*--structure
      WHEN 1 .

        APPEND <lfs_raw_excel> TO lt_structure .

*--fields
      WHEN 2 .


        APPEND <lfs_raw_excel> TO lt_fields  .

      WHEN 3 OR 4 OR 5 .

*--Just sikp
      WHEN OTHERS .

        APPEND <lfs_raw_excel> TO lt_data .

    ENDCASE .

  ENDLOOP.

*--
  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) .


*--processing line by line .
    AT NEW row .

      CLEAR: l_runid, l_bp ,l_partner_guid .

      IF <lfs_t_itab> IS ASSIGNED .

        UNASSIGN : <lfs_t_itab>, <lfs_s_itab> .

      ENDIF .

    ENDAT .


*--get structure
    READ TABLE lt_structure ASSIGNING FIELD-SYMBOL(<lfs_structure>)
                                WITH KEY col = <lfs_data>-col .


*-
    IF <lfs_structure>-value <> '<EOL>' .

      IF l_structure <> <lfs_structure>-value .


        IF <lfs_t_itab> IS ASSIGNED
         AND <lfs_s_itab> IS NOT INITIAL .


          ASSIGN COMPONENT ls_sp_fields-runid OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

          IF sy-subrc = 0 .

            <LFs_comp> = l_runid .

          ENDIF .


          ASSIGN COMPONENT ls_sp_fields-bp OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

          IF sy-subrc = 0 .

            <lfs_comp> = l_bp .

          ENDIF .


*---if structure change then append to table .

          APPEND <lfs_s_itab> TO <lfs_t_itab> .

          SORT <lfs_t_itab> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

*---if line break then append to table and contitune new data .

          if <lfs_structure>-value  = '<LB>' .

           CONTINUE .
         endif .

          UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.
          CLEAR l_structure .


        ENDIF .



        l_structure = <lfs_structure>-value .

*--generate bapi table as {LT_} + {Structure name }

        CONCATENATE 'LT_' <lfs_structure>-value INTO lw_dynamic_itab .

        ASSIGN (lw_dynamic_itab) TO <lfs_t_itab> .

        CREATE DATA lref LIKE LINE OF <lfs_t_itab> .

        ASSIGN lref->* TO <lfs_s_itab> .


      ENDIF .


*---get fields to fillout structure fields .



      READ TABLE lt_fields ASSIGNING FIELD-SYMBOL(<lfs_fields>)
                                  WITH KEY col = <lfs_data>-col .


      IF <lfs_fields>-value = ls_sp_fields-bp .

        l_runid = <lfs_data>-value  .
        l_bp = <lfs_data>-value  .

      ENDIF .


      ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_itab>  TO <lfs_comp> .

      IF sy-subrc = 0 .

        <lfs_comp> = <lfs_data>-value .

      ENDIF .



*---add guid for Modification case .

*      IF <lfs_fields>-value = 'OBJECT_TASK'
*       AND <lfs_data>-value = 'M' .
*
*        SELECT SINGLE partner_guid
*          FROM but000
*          INTO l_partner_guid
*          WHERE partner = l_bp .
*
*
*        IF sy-subrc = 0 .
*
*          ASSIGN COMPONENT 'BPARTNERGUID' OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .
*
*          IF sy-subrc = 0 .
*
*            <lfs_comp> = l_partner_guid.
*
*          ENDIF .
*
*        ENDIF .
*
*      ENDIF .


    ENDIF .



*--last structure.
    IF <lfs_data>-value = '<EOL>' .

      IF <lfs_t_itab> IS ASSIGNED
       AND <lfs_s_itab> IS NOT INITIAL .

        ASSIGN COMPONENT ls_sp_fields-runid OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

        IF sy-subrc = 0 .

          <LFs_comp> = l_runid .

        ENDIF .

        ASSIGN COMPONENT ls_sp_fields-bp OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

        IF sy-subrc = 0 .

          <lfs_comp> = l_bp .

        ENDIF .

*---if structure change then append to table .
        APPEND <lfs_s_itab> TO <lfs_t_itab> .

        SORT <lfs_t_itab> .

        DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

        UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

        CLEAR l_structure .

      ENDIF .

    ENDIF .

  ENDLOOP .




  IF p_test IS NOT INITIAL .
    l_commit = abap_false .
  ELSE .
    l_commit = abap_true .
  ENDIF .



*--call function .
  CALL FUNCTION 'RFC_CVI_EI_INBOUND_MAIN'
    EXPORTING
      iv_docommit                  = l_commit
      iv_create_applog             = 'X'
      iv_suppress_taxjur_check     = 'X'
    TABLES
      it_bp_general                = lt_cvis_bp_general
      it_bp_role                   = lt_cvis_bp_role
      it_bp_industry               = lt_cvis_bp_industry
      it_bp_ident_numbers          = lt_cvis_bp_ident_numbers
      it_bp_bank_details           = lt_cvis_bp_bank_details
      it_bp_tax_number             = lt_cvis_bp_tax_number
      it_bp_tax_number_common      = lt_cvis_bp_tax_number_common
      it_bp_address                = lt_cvis_bp_address
      it_bp_address_usage          = lt_cvis_bp_address_usage
      it_bp_address_teleno         = lt_cvis_bp_address_teleno
      it_bp_address_teleno_remarks = lt_cvis_bp_address_teleno_re
      it_bp_address_faxno          = lt_cvis_bp_address_faxno
      it_bp_address_email          = lt_cvis_bp_address_email
      it_bp_address_email_remarks  = lt_cvis_bp_address_email_re
      it_bp_address_uri            = lt_cvis_bp_address_url
      it_bp_relations              = lt_cvis_bp_relation
      it_bp_finserv                = lt_cvis_bp_finserv
      it_bp_payment_card           = lt_CVIS_BP_PAYMENT_CARD
      it_cust_general              = lt_cvis_customer_general
      it_cust_general_creditcard   = lt_CVIS_CUSTOMER_CREDITCARD
      it_cust_general_texts        = lt_CVIS_CUSTOMER_GEN_TEXTS
      it_cust_general_loading      = lt_CVIS_CUSTOMER_LOADING
      it_cust_general_export       = lt_CVIS_CUSTOMER_EXPORT
      it_cust_general_alt_payee    = lt_CVIS_CUSTOMER_ALT_PAYEE
      it_cust_company              = lt_cvis_customer_company
      it_cust_company_wtax         = lt_CVIS_CUSTOMER_WTAX
      it_cust_company_texts        = lt_CVIS_CUSTOMER_CC_TEXTS
      it_cust_company_alt_payee    = lt_CVIS_CUSTOMER_ALT_PAYEE
      it_cust_sales                = lt_cvis_customer_sales
      it_cust_sales_texts          = lt_cvis_customer_sales_texts
      it_cust_comp_dunning         = lt_cvis_customer_comp_dunning
      it_cust_sales_functions      = lt_cvis_customer_sales_func
      it_cust_tax_indicator        = lt_cvis_customer_tax_indicator
      it_cust_cont_address1        = lt_CVIS_CUST_CONT_ADDRESS1
      it_cust_cont_address2        = lt_CVIS_CUST_CONT_ADDRESS2
      it_cust_cont_address3        = lt_CVIS_CUST_CONT_ADDRESS3
      it_cust_cont_teleno1         = lt_CVIS_CUST_CONT_TELENO1
      it_cust_cont_teleno2         = lt_CVIS_CUST_CONT_TELENO2
      it_cust_cont_teleno3         = lt_CVIS_CUST_CONT_TELENO3
      it_cust_cont_fax1            = lt_CVIS_CUST_CONT_FAX1
      it_cust_cont_fax2            = lt_CVIS_CUST_CONT_FAX2
      it_cust_cont_fax3            = lt_CVIS_CUST_CONT_FAX3
      it_cust_cont_email1          = lt_CVIS_CUST_CONT_EMAIL1
      it_cust_cont_email2          = lt_CVIS_CUST_CONT_EMAIL2
      it_cust_cont_email3          = lt_CVIS_CUST_CONT_EMAIL3
      it_cust_cont_texts           = lt_CVIS_CUSTOMER_CONTACT_TEXTS
      it_cust_general_vat          = lt_cvis_customer_general_vat
      it_sup_general_alt_payee     = lt_CVIS_SUPPLIER_ALT_PAYEE
      it_sup_general               = lt_cvis_supplier_general
      it_sup_general_texts         = lt_CVIS_SUPPLIER_GEN_TEXTS
      it_sup_company               = lt_cvis_supplier_company
      it_sup_company_texts         = lt_CVIS_SUPPLIER_CC_TEXTS
      it_sup_company_wtax          = lt_cvis_supplier_company_wtax
      it_sup_company_alt_payee     = lt_CVIS_SUPPLIER_ALT_PAYEE
      it_sup_purchasing_texts      = lt_cvis_supplier_prog_texts
      it_sup_purchasing            = lt_cvis_supplier_purchasing
      it_sup_purchasing2           = lt_cvis_supplier_purchasing2
      it_sup_purch_functions       = lt_CVIS_SUPPLIER_PURCH_FUNC
      it_supplier_contacts         = lt_CVIS_SUPPLIER_CONTACTS
      it_sup_cont_address1         = lt_CVIS_SUPP_CONT_ADDRESS1
      it_sup_cont_address2         = lt_CVIS_SUPP_CONT_ADDRESS2
      it_sup_cont_address3         = lt_CVIS_SUPP_CONT_ADDRESS3
      it_sup_cont_teleno1          = lt_CVIS_SUPP_CONT_teleno1
      it_sup_cont_teleno2          = lt_CVIS_SUPP_CONT_teleno2
      it_sup_cont_teleno3          = lt_CVIS_SUPP_CONT_teleno3
      it_sup_cont_fax1             = lt_CVIS_SUPP_CONT_fax1
      it_sup_cont_fax2             = lt_CVIS_SUPP_CONT_fax2
      it_sup_cont_fax3             = lt_CVIS_SUPP_CONT_fax3
      it_sup_cont_email1           = lt_CVIS_SUPP_CONT_email1
      it_sup_cont_email2           = lt_CVIS_SUPP_CONT_email2
      it_sup_cont_email3           = lt_CVIS_SUPP_CONT_email3
      it_sup_general_vat           = lt_cvis_supplier_general_vat
      ct_return                    = gt_return.


*---
  CALL FUNCTION 'DEQUEUE_ALL'.

ENDFORM.

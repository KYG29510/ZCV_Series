*&---------------------------------------------------------------------*
*& Report ZCVR0030
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Program Description: sales Quatation creation
* Developer : LJ
* Date : 20 OCT 2022
* Detail : Sales Quatation creation
*&----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT zcvr0030.

*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CONSTANTS :


*---header w/o update flag
  BEGIN OF cns_grouph1 ,
    str1 TYPE char50 VALUE 'BAPIVBELN',
  END OF cns_grouph1,


*---header with update flag
  BEGIN OF cns_grouph2 ,
    str1 TYPE char50 VALUE 'BAPISDHD1',
    str2 TYPE char50 VALUE 'BAPISDH1',

  END OF cns_grouph2,


*---item w/o update flag
  BEGIN OF cns_groupi1 ,
    str1 TYPE char50 VALUE 'BAPIPARNR',
  END OF cns_groupi1 ,

*---item with update flag
  BEGIN OF cns_groupi2 ,
    str1 TYPE char50 VALUE 'BAPISDITM',
    str2 TYPE char50 VALUE 'BAPISCHDL',
    str3 TYPE char50 VALUE 'BAPICOND',
  END OF cns_groupi2 ,


*---extension
  BEGIN OF cns_groupex ,
    str2 TYPE char50 VALUE 'BAPIPAREX',
  END OF cns_groupex .



*----------------------------------------------------------------------*
*       Tables
*----------------------------------------------------------------------*
DATA :
  gt_return LIKE STANDARD TABLE OF bapie1ret2,
  g_error   TYPE flag.

DATA:
  grt_grouph1 TYPE RANGE OF char50,
  grt_grouph2 TYPE RANGE OF char50,
  grt_groupi1 TYPE RANGE OF char50,
  grt_groupi2 TYPE RANGE OF char50,
  grt_groupex TYPE RANGE OF char50.




DATA:
  gr_table     TYPE REF TO cl_salv_table.
*&---------------------------------------------------------------------*
*& INCLUDE
*&---------------------------------------------------------------------*

INCLUDE zcvi0000 .

*---update mode
PARAMETERS p_updkz TYPE updkz_d .

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*

START-OF-SELECTION.

*---init condition
  PERFORM frm_init_processing_condtion .



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

*---sales quotation create
  PERFORM frm_sales_quotation_create
                  USING gt_excel .


*---show the result
  PERFORM frm_show_alv_result .

*&---------------------------------------------------------------------*
*&      Form  frm_f4help_p_infile
*&---------------------------------------------------------------------*
FORM frm_init_processing_condtion .


*-items
  DATA : lrs_grouph1 LIKE LINE OF grt_grouph1 .
  DATA : lrs_grouph2 LIKE LINE OF grt_grouph2 .



*-header
  DATA : lrs_groupi1 LIKE LINE OF grt_groupi1.
  DATA : lrs_groupi2 LIKE LINE OF grt_groupi2.


*-header
  DATA : lrs_groupex LIKE LINE OF grt_groupex.




  FIELD-SYMBOLS <lfs_comp> TYPE char50 .


*--groupH1
  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_grouph1 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_grouph1-sign = 'I' .
      lrs_grouph1-option = 'EQ' .
      lrs_grouph1-low  = <lfs_comp>  .

      TRANSLATE  lrs_grouph1-low TO UPPER CASE .

      APPEND lrs_grouph1 TO grt_grouph1 .

    ENDIF .

  ENDDO .


*--groupH2
  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_grouph2 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_grouph2-sign = 'I' .
      lrs_grouph2-option = 'EQ' .
      lrs_grouph2-low  = <lfs_comp>  .

      TRANSLATE  lrs_grouph2-low TO UPPER CASE .

      APPEND lrs_grouph2 TO grt_grouph2 .

    ENDIF .

  ENDDO .


*--groupI1

  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_groupi1 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_groupi1-sign = 'I' .
      lrs_groupi1-option = 'EQ' .
      lrs_groupi1-low  = <lfs_comp>  .

      TRANSLATE  lrs_groupi1-low TO UPPER CASE .

      APPEND lrs_groupi1 TO grt_groupi1 .

    ENDIF .

  ENDDO .


*--groupI2

  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_groupi2 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_groupi2-sign = 'I' .
      lrs_groupi2-option = 'EQ' .
      lrs_groupi2-low  = <lfs_comp>  .

      TRANSLATE  lrs_groupi2-low TO UPPER CASE .

      APPEND lrs_groupi2 TO grt_groupi2 .

    ENDIF .

  ENDDO .

*--groupI2

  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_groupex TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_groupex-sign = 'I' .
      lrs_groupex-option = 'EQ' .
      lrs_groupex-low  = <lfs_comp>  .

      TRANSLATE  lrs_groupex-low TO UPPER CASE .

      APPEND lrs_groupex TO grt_groupex .

    ENDIF .

  ENDDO .




ENDFORM.

*----------------------------------------------------------------------*
*      Form  BUSINESS_PARTNER_MAINTAIN                                      *
*----------------------------------------------------------------------*
FORM frm_sales_quotation_create
         USING i_t_raw_excel TYPE typ_t_excel  .


data
  l_bapivbeln  type bapivbeln-vbeln .


  DATA :
    ls_bapivbeln  TYPE bapivbeln,
    lt_bapisdhd1  TYPE STANDARD TABLE OF bapisdhd1,
    ls_bapisdhd1  TYPE bapisdhd1,
    ls_bapisdhd1x TYPE bapisdhd1x.

*--for change
 data :
    ls_BAPISDH1  TYPE BAPISDH1,
    ls_BAPISDH1x TYPE BAPISDH1x.


*---enhancemnet

  DATA :
    ls_bape_vbak  TYPE bape_vbak,
    ls_bape_vbakx TYPE bape_vbakx,
    ls_bape_vbap  TYPE bape_vbap,
    ls_bape_vbapx TYPE bape_vbapx,
    ls_bape_vbep  TYPE bape_vbepx,
    ls_bape_vbepx TYPE bape_vbepx.

*---enhancemnet

  DATA :
    lt_bapisditm  TYPE STANDARD TABLE OF bapisditm,
    lt_bapisditmx TYPE STANDARD TABLE OF bapisditmx.


  DATA :
    lt_bapischdl  TYPE STANDARD TABLE OF bapischdl,
    lt_bapischdlx TYPE STANDARD TABLE OF bapischdlx.


  DATA :
    lt_bapicond  TYPE STANDARD TABLE OF bapicond,
    lt_bapicondx TYPE STANDARD TABLE OF bapicondx.



  DATA :
     lt_bapiparnr TYPE STANDARD TABLE OF bapiparnr .


  DATA lt_bapiparex TYPE STANDARD TABLE OF bapiparex .



  DATA:
    BEGIN OF ls_sp_fields,
      str TYPE string VALUE 'STR',
      tab TYPE string VALUE 'TAB',
    END OF ls_sp_fields.


  DATA :
    l_header_breakers TYPE bapimeoutheader .

  DATA :
    lw_dynamic_str  TYPE string,
    lw_dynamic_strx TYPE string.


  DATA :
    lt_return TYPE STANDARD TABLE OF bapiret2 .



  DATA :
    l_structure      TYPE char50,
    lw_dynamic_itab  TYPE string,
    lref             TYPE REF TO data,

    l_structurex     TYPE char50,
    lw_dynamic_itabx TYPE string,
    lref_x           TYPE REF TO data.

  DATA :

    lw_ex_str  TYPE char50,
    lw_ex_strx TYPE char50.

  DATA lw_te_struc TYPE te_struc .


  DATA :
    l_str TYPE  string,
    l_tab TYPE  string.


  DATA :
    lt_structure TYPE STANDARD TABLE OF typ_excel,
    lt_fields    TYPE STANDARD TABLE OF typ_excel,
    lt_data      TYPE STANDARD TABLE OF typ_excel,
    lt_data2     TYPE STANDARD TABLE OF typ_excel.

*--header
  FIELD-SYMBOLS :
    <lfs_s_str>  TYPE any,
    <lfs_s_strx> TYPE any.


*--items
  FIELD-SYMBOLS :
    <lfs_t_itab>  TYPE STANDARD TABLE,
    <lfs_s_itab>  TYPE any,
    <lfs_comp>    TYPE any,

    <lfs_t_itabx> TYPE STANDARD TABLE,
    <lfs_s_itabx> TYPE any,
    <lfs_compx>   TYPE any.

  FIELD-SYMBOLS :
    <lfs_s_ext>  TYPE any,
    <lfs_s_extx> TYPE any.



  DATA :
    l_key_structure TYPE string,
    l_key_fields    TYPE string,
    l_key_val       TYPE string,
    l_key_col       TYPE num6,
    l_key_breaker   TYPE string.


*---
  l_key_structure = 'BAPIVBELN' .
  l_key_fields = 'VBELN' .
*  l_key_col = '000001'.



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
        APPEND <lfs_raw_excel> TO lt_data2 .


    ENDCASE .
  ENDLOOP.


*--get key structure
  LOOP AT  lt_structure ASSIGNING FIELD-SYMBOL(<lfs_key_structure>)
                             WHERE value = l_key_structure .

*--get key fields
    LOOP AT  lt_fields ASSIGNING FIELD-SYMBOL(<lfs_key_fields>)
         WHERE value = l_key_fields
         AND col = <lfs_key_structure>-col .
      EXIT .
    ENDLOOP .

    IF sy-subrc = 0 .
      EXIT .
    ENDIF .

  ENDLOOP .


  IF sy-subrc = 0 .
    l_key_col = <lfs_key_structure>-col .
  ELSE .
    g_error = abap_true .
    MESSAGE s006(zcv001) DISPLAY LIKE 'E' .
    RETURN .
  ENDIF .

  CHECK sy-subrc = 0 .


*--
  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) .

*---
    AT NEW row .

      READ TABLE lt_data2 ASSIGNING FIELD-SYMBOL(<lfs_data2>)
                             WITH KEY row = <lfs_data>-row
                                      col = l_key_col .

      IF l_key_breaker IS INITIAL .

        l_key_breaker = <lfs_data2>-value  .

      ELSE .
*-----
        IF l_key_breaker <> <lfs_data2>-value  .
*---
          CLEAR lt_return .

*
*---if insert then clear .
          IF p_updkz = 'I' .
*            CLEAR ls_bapivbeln .

             clear l_bapivbeln  .

*
            CALL FUNCTION 'BAPI_QUOTATION_CREATEFROMDATA2'
              EXPORTING
                salesdocumentin          = l_bapivbeln
                quotation_header_in      = ls_bapisdhd1
                quotation_header_inx     = ls_bapisdhd1x
*               SENDER                   =
*               BINARY_RELATIONSHIPTYPE  = ' '
*               INT_NUMBER_ASSIGNMENT    = ' '
*               BEHAVE_WHEN_ERROR        = ' '
*               LOGIC_SWITCH             =
                testrun                  = p_test
*               CONVERT                  = ' '
* IMPORTING
*               SALESDOCUMENT            =
              TABLES
                return                   = lt_return
                quotation_items_in       = lt_bapisditm
                quotation_items_inx      = lt_bapisditmx
                quotation_partners       = lt_bapiparnr
                quotation_schedules_in   = lt_bapischdl
                quotation_schedules_inx  = lt_bapischdlx
                quotation_conditions_in  = lt_bapicond
                quotation_conditions_inx = lt_bapicondx
*               QUOTATION_CFGS_REF       =
*               QUOTATION_CFGS_INST      =
*               QUOTATION_CFGS_PART_OF   =
*               QUOTATION_CFGS_VALUE     =
*               QUOTATION_CFGS_BLOB      =
*               QUOTATION_CFGS_VK        =
*               QUOTATION_CFGS_REFINST   =
*               QUOTATION_KEYS           =
*               QUOTATION_TEXT           =
                extensionin              = lt_bapiparex
*               PARTNERADDRESSES         =
*               EXTENSIONEX              =
*               NFMETALLITMS             =
              .

          ELSE .


              l_bapivbeln  = ls_bapivbeln .


            CALL FUNCTION 'BAPI_CUSTOMERQUOTATION_CHANGE'
              EXPORTING
                salesdocument        = l_bapivbeln
                quotation_header_in  = ls_BAPISDH1
                quotation_header_inx = ls_BAPISDH1x
                simulation           = p_test
*               BEHAVE_WHEN_ERROR    =
*               INT_NUMBER_ASSIGNMENT        =
*               LOGIC_SWITCH         =
*               NO_STATUS_BUF_INIT   = ' '
              TABLES
                return               = lt_return
                quotation_item_in    = lt_bapisditm
                quotation_item_inx   = lt_bapisditmx
*               PARTNERS             = lt_bapiparnr
*               PARTNERCHANGES       =
*               PARTNERADDRESSES     =
                conditions_in        = lt_bapicond
                conditions_inx       = lt_bapicondx
*               QUOTATION_CFGS_REF   =
*               QUOTATION_CFGS_INST  =
*               QUOTATION_CFGS_PART_OF       =
*               QUOTATION_CFGS_VALUE =
*               QUOTATION_CFGS_BLOB  =
*               QUOTATION_CFGS_VK    =
*               QUOTATION_CFGS_REFINST       =
                schedule_lines       = lt_bapischdl
                schedule_linesx      = lt_bapischdlx
*               QUOTATION_TEXT       =
*               QUOTATION_KEYS       =
                extensionin          = lt_bapiparex
*               EXTENSIONEX          =
*               NFMETALLITMS         =
              .


          ENDIF .


*--
          LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<lfs_return>)
                                   WHERE type = 'E' OR  type = 'A'.
            EXIT .
          ENDLOOP .

          IF sy-subrc <> 0 .

            COMMIT WORK AND WAIT .

          ELSE .

            ROLLBACK WORK .

          ENDIF .


          APPEND LINES OF lt_return TO gt_return .

          l_key_breaker = <lfs_data2>-value  .

          UNASSIGN : <lfs_s_str> , <lfs_s_strx> .

          CLEAR : lt_bapisditm, lt_bapisditmx,
                  lt_bapicondx, lt_bapicond,
                  lt_bapiparnr, lt_bapischdl,
                  lt_bapischdlx .


        ENDIF .
      ENDIF .

    ENDAT .


*--get structure
    READ TABLE lt_structure ASSIGNING FIELD-SYMBOL(<lfs_structure>)
                                WITH KEY col = <lfs_data>-col .


    IF <lfs_structure>-value <> '<EOL>' .

      IF l_structure IS NOT INITIAL
      AND  l_structure <> <lfs_structure>-value .

*--header
        IF l_structure IN grt_grouph1
        OR  l_structure IN grt_grouph2 .

          IF l_structure IN grt_grouph2 .

            PERFORM frm_mark_update_flag  USING    <lfs_s_str>
                                         CHANGING  <lfs_s_strx> .

            UNASSIGN : <lfs_s_strx>.

          ENDIF .

          UNASSIGN :   <lfs_s_str>.
          CLEAR l_structure .

*item .
        ELSEIF l_structure IN grt_groupi1
         OR l_structure IN grt_groupi2
         OR l_structure IN grt_groupex .

*---extenstion table
          IF l_structure IN grt_groupex.

*--
            <lfs_s_itab>+30(960) = <lfs_s_ext> .

            APPEND <lfs_s_itab> TO <lfs_t_itab> .


            PERFORM frm_mark_update_flag  USING    <lfs_s_ext>
                                         CHANGING  <lfs_s_extx> .

*---
            CONCATENATE <lfs_s_itab>+0(30)
                        'X'
                   INTO lw_te_struc .

            CONDENSE lw_te_struc .

            <lfs_s_itab>+0(30) = lw_te_struc .
*--
            <lfs_s_itab>+30(960) = <lfs_s_extx> .

            UNASSIGN : <lfs_s_ext> ,<lfs_s_extx> .
            CLEAR lw_te_struc .


          ENDIF .


          APPEND <lfs_s_itab> TO <lfs_t_itab> .

          SORT <lfs_t_itab> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

*---line break for partner funciton .

          IF l_structure IN grt_groupi1
          AND <lfs_structure>-value  = '<LB>' .
            CONTINUE .
          ENDIF .


*-- item add condition break for groupi2
          IF l_structure IN grt_groupi2 .

            PERFORM frm_mark_update_flag  USING    <lfs_s_itab>
                                        CHANGING  <lfs_s_itabx> .


            APPEND <lfs_s_itabx> TO <lfs_t_itabx> .

            SORT <lfs_t_itabx> .

            DELETE ADJACENT DUPLICATES FROM <lfs_t_itabx> COMPARING ALL FIELDS .

            UNASSIGN :  <lfs_s_itabx> , <lfs_t_itabx>.

          ENDIF .



          UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

        ENDIF .

      ENDIF .


      l_structure = <lfs_structure>-value .

*---generate bapi table as {LS_} + {Structure name }
      IF l_structure IN grt_grouph1
       OR l_structure IN grt_grouph2 .

        IF <lfs_s_str> IS NOT ASSIGNED .

          CONCATENATE 'LS_' <lfs_structure>-value INTO lw_dynamic_str .
          ASSIGN (lw_dynamic_str) TO <lfs_s_str> .

*--key structure not have update flag

          IF l_structure IN grt_grouph2 .
            CONCATENATE 'LS_' <lfs_structure>-value 'X' INTO lw_dynamic_strx .
            ASSIGN (lw_dynamic_strx) TO <lfs_s_strx> .

          ENDIF .


        ENDIF .

      ELSE .

        IF <lfs_s_itab> IS NOT ASSIGNED .

          CONCATENATE 'LT_' <lfs_structure>-value INTO lw_dynamic_itab .

          ASSIGN (lw_dynamic_itab) TO <lfs_t_itab> .

          CREATE DATA lref LIKE LINE OF <lfs_t_itab> .

          ASSIGN lref->* TO <lfs_s_itab> .
        ENDIF .
      ENDIF .

*---generate bapi table as {LT_} + {Structure name } + {X}
      IF l_structure IN grt_groupi2 .
        IF  <lfs_s_itabx> IS NOT ASSIGNED .

          CONCATENATE 'LT_' <lfs_structure>-value  'X' INTO  lw_dynamic_itabx .

          ASSIGN (lw_dynamic_itabx) TO <lfs_t_itabx> .

          CREATE DATA lref_x LIKE LINE OF <lfs_t_itabx> .

          ASSIGN lref_x->* TO <lfs_s_itabx> .

        ENDIF .

      ENDIF .


*---get fields to fillout structure fields .
      READ TABLE lt_fields ASSIGNING FIELD-SYMBOL(<lfs_fields>)
                                  WITH KEY col = <lfs_data>-col .

      IF l_structure IN grt_grouph1
      OR l_structure IN grt_grouph2 .

*---header strucrute
        ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_str>  TO <lfs_comp> .

        IF sy-subrc = 0 .

          <lfs_comp> = <lfs_data>-value .

        ENDIF .


      ELSE .


*---extenstion structrue start
        IF l_structure IN grt_groupex .

          ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_itab>  TO <lfs_comp> .

          IF sy-subrc = 0 .

            IF <lfs_fields>-value = 'STRUCTURE'.

              <lfs_comp> = <lfs_data>-value .

              CONCATENATE 'LS_'
                          <lfs_data>-value
                       INTO lw_ex_str .

              CONCATENATE lw_ex_str
                          'X'
                      INTO lw_ex_strx .

              ASSIGN (lw_ex_str) TO <lfs_s_ext> .
              ASSIGN (lw_ex_strx) TO <lfs_s_extx> .


            ENDIF .

          ELSE .

*-------check extenstion structure
            ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_ext>  TO <lfs_comp> .

            IF sy-subrc = 0 .

              <lfs_comp> = <lfs_data>-value .

            ENDIF .

          ENDIF .

*---extenstion structrue end
        ELSE  .

*---item structure
          ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_itab>  TO <lfs_comp> .

          IF sy-subrc = 0 .

            <lfs_comp> = <lfs_data>-value .

          ENDIF .

        ENDIF .
      ENDIF .

    ENDIF .



*--last structure.
    IF <lfs_data>-value = '<EOL>' .

*---if structure change then append to table .
      IF <lfs_s_itab> IS NOT INITIAL .


*---
        IF l_structure IN grt_groupex.

*--
          <lfs_s_itab>+30(960) = <lfs_s_ext> .

          APPEND <lfs_s_itab> TO <lfs_t_itab> .


          PERFORM frm_mark_update_flag  USING    <lfs_s_ext>
                                       CHANGING  <lfs_s_extx> .


*---
          CONCATENATE <lfs_s_itab>+0(30)
                      'X'
                 INTO lw_te_struc .


          CONDENSE lw_te_struc .

          <lfs_s_itab>+0(30) = lw_te_struc .

*--
          <lfs_s_itab>+30(960) = <lfs_s_extx> .


          UNASSIGN : <lfs_s_ext> ,<lfs_s_extx> .
          CLEAR lw_te_struc .

        ENDIF .




        APPEND <lfs_s_itab> TO <lfs_t_itab> .

        SORT <lfs_t_itab> .

        DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

*-- item add condition break for group item 2
        IF l_structure IN grt_groupi2 .

          PERFORM frm_mark_update_flag  USING    <lfs_s_itab>
                                      CHANGING  <lfs_s_itabx> .

          APPEND <lfs_s_itabx> TO <lfs_t_itabx> .

          SORT <lfs_t_itabx> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itabx> COMPARING ALL FIELDS .

          UNASSIGN :  <lfs_s_itabx> , <lfs_t_itabx>.

        ENDIF .

        UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

      ENDIF.

      CLEAR l_structure .

    ENDIF .


    AT LAST .

      CLEAR lt_return .
*
*---if insert then clear .
      IF p_updkz = 'I' .
        CLEAR l_bapivbeln .

        CALL FUNCTION 'BAPI_QUOTATION_CREATEFROMDATA2'
          EXPORTING
            salesdocumentin          = l_bapivbeln
            quotation_header_in      = ls_bapisdhd1
            quotation_header_inx     = ls_bapisdhd1x
*           SENDER                   =
*           BINARY_RELATIONSHIPTYPE  = ' '
*           INT_NUMBER_ASSIGNMENT    = ' '
*           BEHAVE_WHEN_ERROR        = ' '
*           LOGIC_SWITCH             =
            testrun                  = p_test
*           CONVERT                  = ' '
* IMPORTING
*           SALESDOCUMENT            =
          TABLES
            return                   = lt_return
            quotation_items_in       = lt_bapisditm
            quotation_items_inx      = lt_bapisditmx
            quotation_partners       = lt_bapiparnr
            quotation_schedules_in   = lt_bapischdl
            quotation_schedules_inx  = lt_bapischdlx
            quotation_conditions_in  = lt_bapicond
            quotation_conditions_inx = lt_bapicondx
*           QUOTATION_CFGS_REF       =
*           QUOTATION_CFGS_INST      =
*           QUOTATION_CFGS_PART_OF   =
*           QUOTATION_CFGS_VALUE     =
*           QUOTATION_CFGS_BLOB      =
*           QUOTATION_CFGS_VK        =
*           QUOTATION_CFGS_REFINST   =
*           QUOTATION_KEYS           =
*           QUOTATION_TEXT           =
            extensionin              = lt_bapiparex
*           PARTNERADDRESSES         =
*           EXTENSIONEX              =
*           NFMETALLITMS             =
          .

      ELSE .


              l_bapivbeln  = ls_bapivbeln .


        CALL FUNCTION 'BAPI_CUSTOMERQUOTATION_CHANGE'
          EXPORTING
            salesdocument        = l_bapivbeln
            quotation_header_in  = ls_BAPISDH1
            quotation_header_inx = ls_BAPISDH1x
            simulation           = p_test
*           BEHAVE_WHEN_ERROR    =
*           INT_NUMBER_ASSIGNMENT        =
*           LOGIC_SWITCH         =
*           NO_STATUS_BUF_INIT   = ' '
          TABLES
            return               = lt_return
            quotation_item_in    = lt_bapisditm
            quotation_item_inx   = lt_bapisditmx
*           PARTNERS             = lt_bapiparnr
*           PARTNERCHANGES       =
*           PARTNERADDRESSES     =
            conditions_in        = lt_bapicond
            conditions_inx       = lt_bapicondx
*           QUOTATION_CFGS_REF   =
*           QUOTATION_CFGS_INST  =
*           QUOTATION_CFGS_PART_OF       =
*           QUOTATION_CFGS_VALUE =
*           QUOTATION_CFGS_BLOB  =
*           QUOTATION_CFGS_VK    =
*           QUOTATION_CFGS_REFINST       =
            schedule_lines       = lt_bapischdl
            schedule_linesx      = lt_bapischdlx
*           QUOTATION_TEXT       =
*           QUOTATION_KEYS       =
            extensionin          = lt_bapiparex
*           EXTENSIONEX          =
*           NFMETALLITMS         =
          .
      ENDIF .




      LOOP AT lt_return ASSIGNING <lfs_return>
                               WHERE type = 'E'
                                 OR  type = 'A'.
        EXIT .
      ENDLOOP .

      IF sy-subrc <> 0 .

        COMMIT WORK AND WAIT .

      ELSE .

        ROLLBACK WORK .

      ENDIF .



      APPEND LINES OF lt_return TO gt_return .



    ENDAT .
  ENDLOOP .


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FRM_MARK_UPDATE_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_mark_update_flag  USING    i_s_in TYPE any
                           CHANGING o_s_inx TYPE any .


  DATA :
    lref  TYPE REF TO data,
    lrefx TYPE REF TO data.

  DATA :
    l_comp_name  TYPE string,
    l_help_name1 TYPE string,
    l_help_name2 TYPE string,
    l_comp_type  TYPE string.

  DATA :
    l_tabname TYPE ddobjname,
    lt_dfies  TYPE STANDARD TABLE OF dfies.


  FIELD-SYMBOLS :
    <lfs_in>  TYPE any,
    <lfs_inx> TYPE any.

  FIELD-SYMBOLS :
    <lfs_comp>  TYPE any,
    <lfs_compx> TYPE any.



*--
  CREATE DATA lref LIKE i_s_in .

  ASSIGN lref->* TO <lfs_in> .

  <lfs_in> = i_s_in .

  CREATE DATA lrefx LIKE o_s_inx .
  ASSIGN lrefx->* TO <lfs_inx> .

*---
  MOVE-CORRESPONDING <lfs_in> TO <lfs_inx> .

*--clear component type as 'BAPIUPDATE' fields .

  DESCRIBE FIELD <lfs_inx> HELP-ID l_tabname .


  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = l_tabname
*     FIELDNAME      = ' '
*     LANGU          = SY-LANGU
*     LFIELDNAME     = ' '
*     ALL_TYPES      = ' '
*     GROUP_NAMES    = ' '
*     UCLEN          =
*     DO_NOT_WRITE   = ' '
*   IMPORTING
*     X030L_WA       =
*     DDOBJTYPE      =
*     DFIES_WA       =
*     LINES_DESCR    =
    TABLES
      dfies_tab      = lt_dfies
*     FIXED_VALUES   =
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*--
  LOOP AT lt_dfies ASSIGNING FIELD-SYMBOL(<lfs_dfies>) .

    ASSIGN COMPONENT sy-tabix OF STRUCTURE <lfs_inx> TO <lfs_comp> .

    IF <lfs_dfies>-rollname = 'BAPIUPDATE'.

      CLEAR <lfs_comp> .

    ENDIF .

*---
  ENDLOOP .



  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE <lfs_in> TO <lfs_comp> .

    IF sy-subrc = 0 .

      IF <lfs_comp> IS NOT INITIAL .

        DESCRIBE FIELD <lfs_comp> HELP-ID l_comp_name .

        SPLIT l_comp_name AT '-' INTO : l_help_name1
                                        l_help_name2 .


        READ TABLE lt_dfies ASSIGNING <lfs_dfies> WITH KEY fieldname = l_help_name2 .

        IF sy-subrc = 0 .


          ASSIGN COMPONENT l_help_name2 OF STRUCTURE <lfs_inx> TO <lfs_compx> .

*--flag update
          IF <lfs_dfies>-rollname = 'BAPIUPDATE'.

            <lfs_compx> = abap_true .
*--other value
          ELSE .

            <lfs_compx> = <lfs_comp> .

          ENDIF .


        ENDIF .

      ENDIF .
    ELSE .
      EXIT .
    ENDIF .

  ENDDO .



*--flag updatemode
  IF <lfs_inx>  IS NOT INITIAL .

    ASSIGN COMPONENT 'UPDATEFLAG' OF STRUCTURE <lfs_inx> TO <lfs_compx> .

    IF sy-subrc = 0 .
      <lfs_compx>  = p_updkz.
    ENDIF .

  ENDIF .


*--
  o_s_inx  = <lfs_inx> .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_line_break_keyvalue
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM read_line_break_keyvalue  USING   i_key_col TYPE num6
                                       i_s_data TYPE typ_excel
                             CHANGING o_key_breaker TYPE string .


  FIELD-SYMBOLS <lfs_comp> TYPE any.


  ASSIGN COMPONENT i_key_col OF STRUCTURE i_s_data TO <lfs_comp> .

  IF sy-subrc = 0 .

    o_key_breaker = i_s_data-value .

  ENDIF .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_in_extension
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_BAPIPAREX
*&---------------------------------------------------------------------*
FORM fill_in_extension  CHANGING lt_bapiparex TYPE bapiparextab .


  CLEAR lt_bapiparex .

  DATA: wa_bapiparex  TYPE bapiparex,
        wa_bape_vbak  TYPE bape_vbak,
        wa_bape_vbakx TYPE bape_vbakx.



  CLEAR wa_bape_vbak.
  wa_bape_vbak-zz1_test_headtxt_sdh     = 'kygxxxxxkyg'.
  wa_bapiparex-structure = 'BAPE_VBAK'.
  wa_bapiparex+30(960)   = wa_bape_vbak.

  APPEND wa_bapiparex TO lt_bapiparex.

*--
  wa_bape_vbakx-zz1_test_headtxt_sdh     = 'X'.
  wa_bapiparex-structure = 'BAPE_VBAKX'.
  wa_bapiparex+30(960)   = wa_bape_vbakx.


  APPEND wa_bapiparex TO lt_bapiparex.




ENDFORM.

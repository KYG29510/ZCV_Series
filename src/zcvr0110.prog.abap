*&---------------------------------------------------------------------*
*& Report ZCVR0020
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Program Description: Kanban Control Cycle
* Developer : LJ
* Date : 20 NOV 2021
* Detail : kanban control Cycle upload
*&----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT zcvr0110.


*----------------------------------------------------------------------*
*       Tables
*----------------------------------------------------------------------*
DATA :
  gt_return LIKE STANDARD TABLE OF bapie1ret2,
  g_error   TYPE flag.

*DATA:
*  grt_group2 TYPE RANGE OF char50 .


DATA:
  gr_table     TYPE REF TO cl_salv_table.
*&---------------------------------------------------------------------*
*& INCLUDE
*&---------------------------------------------------------------------*

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

*---mapping to material bap
  PERFORM frm_kanban_cc_creation
                  USING gt_excel .


**---show the result
  PERFORM frm_show_alv_result .

*----------------------------------------------------------------------*
*      Form  BUSINESS_PARTNER_MAINTAIN                                      *
*----------------------------------------------------------------------*
FORM frm_kanban_cc_creation
         USING i_t_raw_excel TYPE typ_t_excel  .



  DATA :
    lt_structure TYPE STANDARD TABLE OF typ_excel,
    lt_fields    TYPE STANDARD TABLE OF typ_excel,
    lt_data      TYPE STANDARD TABLE OF typ_excel.


  FIELD-SYMBOLS :
    <lfs_t_itab>  TYPE STANDARD TABLE,
    <lfs_s_itab>  TYPE any,
    <lfs_comp>    TYPE any,

    <lfs_t_itabx> TYPE STANDARD TABLE,
    <lfs_s_itabx> TYPE any,
    <lfs_compx>   TYPE any.

  DATA :
    l_structure     TYPE char50,
    lw_dynamic_itab TYPE string,
    lref            TYPE REF TO data.



  DATA :
    ls_return TYPE  bapiret2,
    lt_return TYPE  STANDARD TABLE OF bapiret2.

  DATA : l_error TYPE pp_kab_technical_call_error .


  DATA : lt_pkhd TYPE pkhdx,
         ls_pkhd TYPE pkhd,
         es_pkhd TYPE pkhd.




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


*---


*--
  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) .

*--processing line by line .
    AT NEW row .

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


*---if structure change then append to table .
          APPEND <lfs_s_itab> TO <lfs_t_itab> .

          SORT <lfs_t_itab> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .


          UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

          CLEAR l_structure .

        ENDIF .


        l_structure = <lfs_structure>-value .

*---generate bapi table as {LT_} + {Structure name }

        CONCATENATE 'LT_' <lfs_structure>-value INTO lw_dynamic_itab .

        ASSIGN (lw_dynamic_itab) TO <lfs_t_itab> .

        CREATE DATA lref LIKE LINE OF <lfs_t_itab> .

        ASSIGN lref->* TO <lfs_s_itab> .


      ENDIF .


*---get fields to fillout structure fields .
      READ TABLE lt_fields ASSIGNING FIELD-SYMBOL(<lfs_fields>)
                                  WITH KEY col = <lfs_data>-col .


      ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_itab>  TO <lfs_comp> .

      IF sy-subrc = 0 .

        <lfs_comp> = <lfs_data>-value .

      ENDIF .

    ENDIF .


*--last structure.
    IF <lfs_data>-value = '<EOL>' .

      IF <lfs_t_itab> IS ASSIGNED
       AND <lfs_s_itab> IS NOT INITIAL .

*---if structure change then append to table .

        APPEND <lfs_s_itab> TO <lfs_t_itab> .

        SORT <lfs_t_itab> .

        DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

        UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

        CLEAR l_structure .

      ENDIF .

    ENDIF .

  ENDLOOP .



*--
  LOOP AT lt_pkhd INTO ls_pkhd .

  cl_pk_luw=>start_luw_with_buffer_init( iv_is_multipe_call_allowed = abap_true ).


    CLEAR lt_return .

    CALL FUNCTION 'PK_CREATE_KANBAN_CONTROL_CYCLE'
      EXPORTING
        iv_testrun          = p_test
        is_pkhd             = ls_pkhd
      IMPORTING
        es_pkhd             = es_pkhd
        et_return           = lt_return
        ev_odata_call_error = l_error.

*---
    IF p_test IS INITIAL .

      READ TABLE lt_return TRANSPORTING NO FIELDS
                          WITH KEY type = 'E' .
      IF sy-subrc = 0 .

       ROLLBACK WORK .


      ELSE .

       COMMIT WORK AND WAIT .


      ENDIF .

    ENDIF .


    APPEND LINES OF lt_return TO gt_return .
  ENDLOOP.


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

  ENDLOOP .




  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE <lfs_in> TO <lfs_comp> .

    IF sy-subrc = 0 .

      IF <lfs_comp> IS NOT INITIAL .

        DESCRIBE FIELD <lfs_comp> HELP-ID l_comp_name .

        SPLIT l_comp_name AT '-' INTO : l_help_name1
                                        l_help_name2 .


        READ TABLE lt_dfies ASSIGNING <lfs_dfies> WITH KEY fieldname = l_help_name2 .

        IF sy-subrc = 0  AND
          <lfs_dfies>-rollname = 'BAPIUPDATE'.


          ASSIGN COMPONENT l_help_name2 OF STRUCTURE <lfs_inx> TO <lfs_compx> .


          <lfs_compx> = abap_true .

        ENDIF .

      ENDIF .
    ELSE .
      EXIT .
    ENDIF .

  ENDDO .

*--
  o_s_inx  = <lfs_inx> .

ENDFORM.

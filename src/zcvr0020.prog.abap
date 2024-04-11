*&---------------------------------------------------------------------*
*& Report ZCVR0020
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Program Description: Material  Master Upload
* Developer : LJ
* Date : 20 NOV 2021
* Detail : Material Master Upload form frontend
*&----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT ZCVR0020.


*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CONSTANTS :

*---w/o update flag
  BEGIN OF cns_group1 ,
    str1 TYPE char50 VALUE 'bapie1makt',
    str2 TYPE char50 VALUE 'bapie1mean',
    str3 TYPE char50 VALUE 'bapie1mltx',
    str4 TYPE char50 VALUE 'bapie1mlan',
    str5 TYPE char50 VALUE 'bapie1mprw',
    str6 TYPE char50 VALUE 'bapie1mveu',
    str7 TYPE char50 VALUE 'bapie1mveg',
  END OF cns_group1 ,

*---with update flag
  BEGIN OF cns_group2 ,

    str1 TYPE char50 VALUE 'bapie1mara',
    str2 TYPE char50 VALUE 'bapie1marc',
    str3 TYPE char50 VALUE 'bapie1mpop',
    str4 TYPE char50 VALUE 'bapie1mpgd',
    str5 TYPE char50 VALUE 'bapie1mard',
    str6 TYPE char50 VALUE 'bapie1mbew',
    str7 TYPE char50 VALUE 'bapie1mlgn',
    str8 TYPE char50 VALUE 'bapie1marm',
    str9 TYPE char50 VALUE 'bapie1mfhm',
    stra TYPE char50 VALUE 'bapie1parex',

  END OF cns_group2 .

*----------------------------------------------------------------------*
*       Tables
*----------------------------------------------------------------------*
DATA :
  gt_return LIKE STANDARD TABLE OF bapie1ret2,
  g_error   TYPE flag.

DATA:
  grt_group2 TYPE RANGE OF char50 .


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

*---mapping to material bap
  PERFORM frm_material_savereplica
                  USING gt_excel .


*---show the result
  PERFORM frm_SHOW_ALV_RESULT .

*&---------------------------------------------------------------------*
*&      Form  frm_f4help_p_infile
*&---------------------------------------------------------------------*
FORM frm_init_processing_condtion .


  DATA : lrs_group2 LIKE LINE OF grt_group2 . .

  FIELD-SYMBOLS <lfs_comp> TYPE char50 .


  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_group2 TO <lfs_comp> .


    IF sy-subrc <> 0 .
      EXIT .

    ELSE .

      lrs_group2-sign = 'I' .
      lrs_group2-option = 'EQ' .
      lrs_group2-low  = <lfs_comp>  .

      TRANSLATE  lrs_group2-low TO UPPER CASE .

      APPEND lrs_group2 TO grt_group2 .
      .

    ENDIF .



  ENDDO .


ENDFORM.

*----------------------------------------------------------------------*
*      Form  BUSINESS_PARTNER_MAINTAIN                                      *
*----------------------------------------------------------------------*
FORM frm_material_savereplica
         USING i_t_raw_excel TYPE typ_t_excel  .


  DATA :
    lt_BAPIE1MATHEADER TYPE STANDARD TABLE OF bapie1matheader,

    lt_BAPIE1MAKT      TYPE STANDARD TABLE OF bapie1makt,
    lt_BAPIE1MEAN      TYPE STANDARD TABLE OF bapie1mean,
    lt_BAPIE1MLTX      TYPE STANDARD TABLE OF bapie1mltx,
    lt_BAPIE1MLAN      TYPE STANDARD TABLE OF bapie1mlan,
    lt_BAPIE1MPRW      TYPE STANDARD TABLE OF bapie1mprw,
    lt_BAPIE1MVEU      TYPE STANDARD TABLE OF bapie1mveu,
    lt_BAPIE1MVEG      TYPE STANDARD TABLE OF bapie1mveg,

    lt_BAPIE1MARA      TYPE STANDARD TABLE OF bapie1mara,
    lt_BAPIE1MARAx     TYPE STANDARD TABLE OF BAPIE1MARAx,
    lt_BAPIE1MARC      TYPE STANDARD TABLE OF bapie1marc,
    lt_BAPIE1MARCx     TYPE STANDARD TABLE OF BAPIE1MARCx,
    lt_BAPIE1MPOP      TYPE STANDARD TABLE OF bapie1mpop,
    lt_BAPIE1MPOPx     TYPE STANDARD TABLE OF BAPIE1MPOPx,
    lt_BAPIE1MPGD      TYPE STANDARD TABLE OF bapie1mpgd,
    lt_BAPIE1MPGDX     TYPE STANDARD TABLE OF BAPIE1MPGDx,
    lt_BAPIE1MARD      TYPE STANDARD TABLE OF bapie1mard,
    lt_BAPIE1MARDx     TYPE STANDARD TABLE OF BAPIE1MARDx,

    lt_BAPIE1MBEW      TYPE STANDARD TABLE OF bapie1mbew,
    lt_BAPIE1MBEWx     TYPE STANDARD TABLE OF BAPIE1MBEWx,

    lt_BAPIE1MLGN      TYPE STANDARD TABLE OF bapie1mlgn,
    lt_BAPIE1MLGNx     TYPE STANDARD TABLE OF BAPIE1MLGNx,

    lt_BAPIE1MVKE      TYPE STANDARD TABLE OF bapie1mvke,
    lt_BAPIE1MVKEx     TYPE STANDARD TABLE OF bapie1mvkex,

    lt_BAPIE1MLGT      TYPE STANDARD TABLE OF bapie1mlgt,
    lt_BAPIE1MLGTx     TYPE STANDARD TABLE OF BAPIE1MLGTx,

    lt_BAPIE1MARM      TYPE STANDARD TABLE OF bapie1marm,
    lt_BAPIE1MARMx     TYPE STANDARD TABLE OF BAPIE1MARMx,

    lt_BAPIE1MFHM      TYPE STANDARD TABLE OF bapie1mfhm,
    lt_BAPIE1MFHMx     TYPE STANDARD TABLE OF BAPIE1MFHMx,

    lt_BAPIE1PAREX     TYPE STANDARD TABLE OF bapie1parex,
    lt_BAPIE1PAREXx    TYPE STANDARD TABLE OF BAPIE1PAREXx.




  DATA:
    BEGIN OF ls_sp_fields,
      function TYPE string VALUE 'FUNCTION',
      material TYPE string VALUE 'MATERIAL',
    END OF ls_sp_fields.


  DATA :
    l_structure      TYPE char50,
    lw_dynamic_itab  TYPE string,
    lref             TYPE REF TO data,

    l_structurex     TYPE char50,
    lw_dynamic_itabx TYPE string,
    lref_x           TYPE REF TO data.



  DATA :
    l_FUNCTION TYPE  bapifn,
    l_material TYPE  matnr18.


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

      CLEAR: l_FUNCTION, l_MATERIAL .


      IF <lfs_t_itab> IS ASSIGNED .

        UNASSIGN : <lfs_t_itab>, <lfs_s_itab> .

      ENDIF .

      IF <lfs_t_itabx> IS ASSIGNED .

        UNASSIGN : <lfs_t_itabx>, <lfs_s_itabx> .

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


          ASSIGN COMPONENT ls_sp_fields-function OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

          IF sy-subrc = 0 .

            <LFs_comp> = l_FUNCTION .

          ENDIF .


          ASSIGN COMPONENT ls_sp_fields-material OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

          IF sy-subrc = 0 .

            <lfs_comp> = l_MATERIAL .

          ENDIF .


*---if structure change then append to table .
          APPEND <lfs_s_itab> TO <lfs_t_itab> .

          SORT <lfs_t_itab> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

*--add condition break for group2

          IF l_structure IN grt_group2 .

            PERFORM frm_mark_update_flag  USING    <lfs_s_itab>
                                       CHANGING  <lfs_s_itabx> .



            APPEND <lfs_s_itabx> TO <lfs_t_itabx> .

            SORT <lfs_t_itabx> .

            DELETE ADJACENT DUPLICATES FROM <lfs_t_itabx> COMPARING ALL FIELDS .

            UNASSIGN :  <lfs_s_itabx> , <lfs_t_itabx>.


          ENDIF .



          UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.


          CLEAR l_structure .

        ENDIF .


        l_structure = <lfs_structure>-value .

*---generate bapi table as {LT_} + {Structure name }

        CONCATENATE 'LT_' <lfs_structure>-value INTO lw_dynamic_itab .

        ASSIGN (lw_dynamic_itab) TO <lfs_t_itab> .

        CREATE DATA lref LIKE LINE OF <lfs_t_itab> .

        ASSIGN lref->* TO <lfs_s_itab> .

*---generate bapi table as {LT_} + {Structure name } + {X}
        IF l_structure IN grt_group2 .


          CONCATENATE 'LT_' <lfs_structure>-value  'X' INTO  lw_dynamic_itabx .

          ASSIGN (lw_dynamic_itabx) TO <lfs_t_itabx> .

          CREATE DATA lref_x LIKE LINE OF <lfs_t_itabx> .

          ASSIGN lref_x->* TO <lfs_s_itabx> .

        ENDIF .

      ENDIF .


*---get fields to fillout structure fields .
      READ TABLE lt_fields ASSIGNING FIELD-SYMBOL(<lfs_fields>)
                                  WITH KEY col = <lfs_data>-col .


      IF <lfs_fields>-value = ls_sp_fields-material .

        l_MATERIAL = <lfs_data>-value  .

      ENDIF .


      IF <lfs_fields>-value = ls_sp_fields-function  .

        l_FUNCTION = <lfs_data>-value  .

      ENDIF .


      ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_itab>  TO <lfs_comp> .

      IF sy-subrc = 0 .

        <lfs_comp> = <lfs_data>-value .

      ENDIF .

    ENDIF .



*--last structure.
    IF <lfs_data>-value = '<EOL>' .

      IF <lfs_t_itab> IS ASSIGNED
       AND <lfs_s_itab> IS NOT INITIAL .

        ASSIGN COMPONENT ls_sp_fields-function OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

        IF sy-subrc = 0 .

          <LFs_comp> = l_function.

        ENDIF .

        ASSIGN COMPONENT ls_sp_fields-material OF STRUCTURE <lfs_s_itab> TO <lfs_comp> .

        IF sy-subrc = 0 .

          <lfs_comp> = l_material .

        ENDIF .

*---if structure change then append to table .

        APPEND <lfs_s_itab> TO <lfs_t_itab> .

        SORT <lfs_t_itab> .

        DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .


        IF l_structure IN grt_group2 .

          PERFORM frm_mark_update_flag  USING    <lfs_s_itab>
                                     CHANGING  <lfs_s_itabx> .



          APPEND <lfs_s_itabx> TO <lfs_t_itabx> .

          SORT <lfs_t_itabx> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itabx> COMPARING ALL FIELDS .

          UNASSIGN :  <lfs_s_itabx> , <lfs_t_itabx>.


        ENDIF .

        UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

        CLEAR l_structure .

      ENDIF .

    ENDIF .

  ENDLOOP .


  DATA ls_return  TYPE  bapiret2 .


  CALL FUNCTION 'BAPI_MATERIAL_SAVEREPLICA'
    EXPORTING
      noappllog            = 'X'
      nochangedoc          = 'X'
      testrun              = P_test
      inpfldcheck          = ' '
*     FLAG_CAD_CALL        = ' '
*     NO_ROLLBACK_WORK     = ' '
*     FLAG_ONLINE          = ' '
    IMPORTING
      return               = ls_return
    TABLES
      headdata             = lt_BAPIE1MATHEADER
      clientdata           = lt_BAPIE1MARA
      clientdatax          = lt_BAPIE1MARAX
      plantdata            = lt_BAPIE1MARC
      plantdatax           = lt_BAPIE1MARCX
      forecastparameters   = lt_BAPIE1MPOP
      forecastparametersx  = lt_BAPIE1MPOPX
      planningdata         = lt_BAPIE1MPGD
      planningdatax        = lt_BAPIE1MPGDX
      storagelocationdata  = lt_BAPIE1MARD
      storagelocationdatax = lt_BAPIE1MARDX
      valuationdata        = lt_BAPIE1MBEW
      valuationdatax       = lt_BAPIE1MBEWX
      warehousenumberdata  = lt_BAPIE1MLGN
      warehousenumberdatax = lt_BAPIE1MLGNX
      salesdata            = lt_BAPIE1MVKE
      salesdatax           = lt_BAPIE1MVKEX
      storagetypedata      = lt_BAPIE1MLGT
      storagetypedatax     = lt_BAPIE1MLGTX
      materialdescription  = lt_BAPIE1MAKT
      unitsofmeasure       = lt_BAPIE1MARM
      unitsofmeasurex      = lt_BAPIE1MARMx
      internationalartnos  = lt_BAPIE1MEAN
      materiallongtext     = lt_BAPIE1MLTX
      taxclassifications   = lt_BAPIE1MLAN
      prtdata              = lt_BAPIE1MFHM
      prtdatax             = lt_BAPIE1MFHMX
      extensionin          = lt_BAPIE1PAREX
      extensioninx         = lt_BAPIE1PAREXX
      forecastvalues       = lt_BAPIE1MPRW
      unplndconsumption    = lt_BAPIE1MVEU
      totalconsumption     = lt_BAPIE1MVEG
      returnmessages       = gt_return.


  APPEND ls_return TO gt_return .




*---
  CALL FUNCTION 'DEQUEUE_ALL'.



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
    l_TABNAME TYPE ddobjname,
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

  DESCRIBE FIELD <lfs_inx> HELP-ID l_TABNAME .


  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = l_TABNAME
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

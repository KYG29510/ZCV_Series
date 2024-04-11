*&---------------------------------------------------------------------*
*& Report ZCVI0010
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Program Description: Conversion object common include
* Developer : LJ
* Date : 20 NOV 2021
*&----------------------------------------------------------------------*

 TYPES :
   BEGIN OF typ_excel ,
     row   TYPE  num9,
     col   TYPE  num9,
     value TYPE  char50,
   END OF typ_excel ,
   typ_t_excel TYPE STANDARD TABLE OF typ_excel.

 DATA  gt_excel     TYPE typ_t_excel .

*&---------------------------------------------------------------------*
*&   Selection screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.

  PARAMETERS prd_bg RADIOBUTTON GROUP g01 .
  PARAMETERS:
    p_sfile TYPE string LOWER CASE .


  SELECTION-SCREEN COMMENT /2(50) text-s01 .

  SELECTION-SCREEN skip.


  PARAMETERS prd_fg RADIOBUTTON GROUP g01 DEFAULT 'X' .

  PARAMETERS:
    p_file  TYPE string,
    p_batch TYPE int4 DEFAULT '999'.


  SELECTION-SCREEN COMMENT /2(50) text-s02 .


  SELECTION-SCREEN skip.


  PARAMETERS:
    p_test type testrun DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK blk1.


*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON VALUE-REQUEST FOR DATASET
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_file.

   PERFORM frm_F4HELP_P_INFILE USING P_file.

**&---------------------------------------------------------------------*
**&   Event AT SELECTION-SCREEN ON VALUE-REQUEST FOR DATASET
**&---------------------------------------------------------------------*
AT SELECTION-SCREEN .

  IF prd_bg IS NOT INITIAL
  AND p_sfile IS INITIAL .

    MESSAGE e003(zcv001).
* バックグランド実行ファイルを指定してください。
  ENDIF .


  IF prd_fg IS NOT INITIAL
  AND p_file IS INITIAL .

    MESSAGE e004(zcv001).
* アップロードファイル名を指定してください。
  ENDIF .


*&---------------------------------------------------------------------*
*&      Form  frm_f4help_p_infile
*&---------------------------------------------------------------------*
 FORM frm_f4help_p_infile  USING  i_file TYPE string .


   DATA:
     ltd_fname     TYPE filetable,
     l_subrc       TYPE i,
     l_directory   TYPE string VALUE 'C:\',
     l_file_filter TYPE string.

   l_file_filter = TEXT-002.  " 'Microsoft Excel Files (*.XLS;*.XLSX;*.XLSM)|*.XLS;*.XLSX;*.XLSM|'(001).

   REFRESH : ltd_fname.

   CALL METHOD cl_gui_frontend_services=>file_open_dialog
     EXPORTING
*      window_title            = window_title
*      default_filename        = l_path
       file_filter             = l_file_filter
       with_encoding           = abap_true
       initial_directory       = l_directory
       multiselection          = abap_false
     CHANGING
       file_table              = ltd_fname
       rc                      = l_subrc
*      file_encoding           = g_encod
     EXCEPTIONS
       file_open_dialog_failed = 1
       cntl_error              = 2
       error_no_gui            = 3
       OTHERS                  = 4.

   IF sy-subrc <> 0.

   ELSE.
     IF l_subrc = 1.
       READ TABLE ltd_fname INTO i_file INDEX 1.
     ENDIF.
   ENDIF.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_UPLOAD_FILE_VIA_EXCLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM frm_upload_excle_file  USING i_file TYPE string
                                   i_batch TYPE int4
                             CHANGING ct_excel TYPE typ_t_excel .

   DATA l_paket TYPE i .
   DATA l_lines TYPE i .

   DATA :
     l_begin_row TYPE i,
     l_end_row   TYPE i.

   DATA ls_excel TYPE typ_excel .

   DATA :
     l_excel_fname TYPE rlgrap-filename,
     lt_raw_excel  TYPE issr_alsmex_tabline.

   l_excel_fname = i_file .


   l_begin_row = 1 .
   l_end_row = l_begin_row + i_batch .

   DO .

     CLEAR lt_raw_excel .

     CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
       EXPORTING
         filename                = l_excel_fname
         i_begin_col             = '1'
         i_begin_row             = l_begin_row
         i_end_col               = '256'
         i_end_row               = l_end_row
       TABLES
         intern                  = lt_raw_excel
       EXCEPTIONS
         inconsistent_parameters = 1
         upload_ole              = 2
         OTHERS                  = 3.

     IF sy-subrc <> 0 .
       g_error = abap_true .
       MESSAGE s001(zcv001) DISPLAY LIKE 'E'.
* EXCELファイルをSAPにアップロードできませんでした。
       EXIT.
     ENDIF .


     IF lt_raw_excel IS INITIAL .
       EXIT .
     ENDIF .


     CLEAR l_lines .
     LOOP AT lt_raw_excel ASSIGNING FIELD-SYMBOL(<lfs_raw_excel>) .
       CLEAR ls_excel .

       ls_excel-row = <lfs_raw_excel>-row + l_begin_row - 1 .
       ls_excel-col = <lfs_raw_excel>-col.
       ls_excel-value = <lfs_raw_excel>-value .

       APPEND ls_excel TO ct_excel .

       AT END OF row.
         l_lines = l_lines + 1 .
       ENDAT .

     ENDLOOP .


     l_paket =  l_end_row - l_begin_row .

     IF l_lines < l_paket  .
       EXIT .
     ELSE .

       l_begin_row = l_end_row + 1 .
       l_end_row = l_begin_row + i_batch .

     ENDIF .

   ENDDO.



   IF  ct_excel IS INITIAL  .
     g_error = abap_true .

     MESSAGE s002(zcv001) DISPLAY LIKE 'E' .
* アップロードしたEXCELファイルはブランクファイルです。
     RETURN .

   ENDIF .

 ENDFORM .
*&---------------------------------------------------------------------*
*&      Form  FRM_UPLOAD_FILE_VIA_EXCLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* FORM frm_upload_file_via_excle  USING i_file TYPE string
*                               CHANGING o_t_raw_excel TYPE issr_alsmex_tabline .
*
*
*   DATA : l_excel_fname TYPE rlgrap-filename .
*
*   DATA : l_col TYPE char04 .
*
*   FIELD-SYMBOLS
*      <lfs_raw_excel> LIKE LINE OF o_t_raw_excel .
*
*   l_excel_fname = i_file .
*
**
*   CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
*     EXPORTING
*       filename                = l_excel_fname
*       i_begin_col             = '1'
*       i_begin_row             = '1'
*       i_end_col               = '256'
*       i_end_row               = '65536'
*     TABLES
*       intern                  = o_t_raw_excel
*     EXCEPTIONS
*       inconsistent_parameters = 1
*       upload_ole              = 2
*       OTHERS                  = 3.
*
*
*
*   IF sy-subrc <> 0 .
*
*     g_error = abap_true .
*
*     MESSAGE s001(zcv001) DISPLAY LIKE 'E'.
** EXCELファイルをSAPにアップロードできませんでした。
*
*     RETURN .
*
*   ENDIF .
*
*
*   IF  o_t_raw_excel IS INITIAL  .
*     g_error = abap_true .
*
*     MESSAGE s002(zcv001) DISPLAY LIKE 'E' .
** アップロードしたEXCELファイルはブランクファイルです。
*     RETURN .
*
*   ENDIF .
*
* ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV_RESULT
*&---------------------------------------------------------------------*
 FORM frm_show_alv_result .


   DATA:
     lr_columns    TYPE REF TO cl_salv_columns_table,
     lr_selections TYPE REF TO cl_salv_selections,
     lr_layout_top TYPE REF TO cl_salv_form_layout_grid,
     lr_events     TYPE REF TO cl_salv_events_table.


   CHECK g_error IS INITIAL .


*----Create ALV table
   TRY.
       cl_salv_table=>factory(
         IMPORTING
           r_salv_table = gr_table
         CHANGING
           t_table      = gt_return ).
     CATCH cx_salv_msg.                                 "#EC NO_HANDLER
   ENDTRY.


*----set the columns technical
   lr_columns = gr_table->get_columns( ).
   lr_columns->set_optimize( abap_true ).


*----set up function button
   gr_table->set_screen_status(
    pfstatus      =  'SALV_STANDARD'
    report        =  'SALV_DEMO_METADATA'
    set_functions =  gr_table->c_functions_all ).


*----set up selections
   lr_selections = gr_table->get_selections( ).
   lr_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).



*----show ALV
   gr_table->display( ).


 ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_read_flat_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_SFILE
*&      <-- GT_EXCEL
*&---------------------------------------------------------------------*
FORM frm_read_flat_file  USING   i_sfile TYPE string
                         CHANGING ct_excel TYPE typ_t_excel .


  DATA l_rc TYPE c.

  DATA l_message TYPE string .

  DATA : ls_file_line TYPE string,
         lt_file      TYPE string_table,
         lt_line_val  TYPE string_table.


  FIELD-SYMBOLS <lfs_comp> TYPE any .

  TRY.

      l_rc = '*' .

      OPEN DATASET i_sfile  FOR INPUT IN TEXT MODE
      ENCODING DEFAULT  IGNORING CONVERSION ERRORS REPLACEMENT CHARACTER l_rc MESSAGE l_message .


      DO .

        READ DATASET i_sfile INTO ls_file_line .

        IF sy-subrc <> 0 .
          EXIT .
        ELSE .
          APPEND ls_file_line TO lt_file .
        ENDIF .
      ENDDO .


    CATCH cx_root .


      g_error = abap_true .

      MESSAGE s005(zcv001) WITH  i_sfile   DISPLAY LIKE 'E' .
* ファイルオープンエラー &1
      RETURN .
  ENDTRY.


  CLOSE DATASET i_sfile .


  DATA ls_excel TYPE typ_excel .

*--move to excel file stracture .
  LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<lfs_file>) .

    CLEAR : ls_excel ,
            lt_line_val.

    ls_excel-row = sy-tabix .


    SPLIT <lfs_file> AT cl_abap_char_utilities=>horizontal_tab
                    INTO TABLE lt_line_val .


    LOOP AT lt_line_val ASSIGNING <lfs_comp>.

      IF   <lfs_comp> IS NOT INITIAL .

        ls_excel-col = sy-tabix .


        ls_excel-value = <lfs_comp> .

*-----add end of line mark
        AT LAST .

          ls_excel-value = '<EOL>' .

        ENDAT .

        APPEND ls_excel TO ct_excel .

      ENDIF .

    ENDLOOP.

  ENDLOOP.


ENDFORM.

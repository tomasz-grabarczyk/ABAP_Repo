*&---------------------------------------------------------------------*
*&  Report  ZTG_FI_SALV_REPORT
*&---------------------------------------------------------------------*
*&  Author: Tomasz Grabarczyk
*&  Date: 31.07.2019
*&---------------------------------------------------------------------*
*&
*&  BKPF - FI document header
*&  BSEG - FI document positions (cluster table)
*&
*&  selection screen
*&  bukrs
*&  gjahr
*&  belnr
*&
*&  alv
*&  selection screen,  4 pola losowe - data księgowania (budat), usnam itd
*&  hotspot na belnr call transaction FB03 skip first screen
*&  action doubleclick show popup with alv with amounts and costs
*&  popup call screen start at ending at
*&  FM popup
*&
*&---------------------------------------------------------------------*

REPORT ztg_fi_salv_report.

TABLES bkpf.

SELECT-OPTIONS: so_bukrs FOR bkpf-bukrs,
                so_belnr FOR bkpf-belnr,
                so_gjahr FOR bkpf-gjahr.

DATA: it_bdcdata TYPE TABLE OF bdcdata,
      wa_bdcdata LIKE LINE OF it_bdcdata.

*----------------------------------------------------------------------*
*       CLASS lcl_report DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_bkpf,
         bukrs TYPE bkpf-bukrs, "Company Code
         belnr TYPE bkpf-belnr, "Accounting Document Number
         gjahr TYPE bkpf-gjahr, "Fiscal Year
         bldat TYPE bkpf-bldat, "Document Date in Document
         cputm TYPE bkpf-cputm, "Time of Entry
         usnam TYPE bkpf-usnam, "User name
         waers TYPE bkpf-waers, "Currency Key
       END OF ty_bkpf.

    TYPES: BEGIN OF ty_bseg,
             bukrs TYPE bseg-bukrs, "Company Code
             belnr TYPE bseg-belnr, "Accounting Document Number
             gjahr TYPE bseg-gjahr, "Fiscal Year
             shkzg TYPE bseg-shkzg, "Debit/Credit Indicator
             wrbtr TYPE bseg-wrbtr, "Amount in document currency
           END OF ty_bseg.

    DATA: it_bkpf TYPE TABLE OF ty_bkpf,
          it_bseg TYPE TABLE OF ty_bseg.

    DATA: o_alv TYPE REF TO cl_salv_table.

    METHODS:
      get_data,
      generate_output.

  PRIVATE SECTION.

    METHODS:
      set_hotspot
        IMPORTING
          co_alv TYPE REF TO cl_salv_table
          co_report TYPE REF TO lcl_report
          column_name TYPE c.

    METHODS:
      hotspot_handler
        FOR EVENT link_click OF cl_salv_events_table
          IMPORTING
            row
            column.

    METHODS:
      bdcdata_dynpro
        IMPORTING
          program TYPE string
          dynpro  TYPE string.

    METHODS:
      bdcdata_field_char
        IMPORTING
          fnam TYPE string
          fval TYPE c.

    METHODS:
      bdcdata_field_num
        IMPORTING
          fnam TYPE string
          fval TYPE n.

ENDCLASS.                    "LCL_REPORT DEFINITION

*--------------------------------------------------------------------*
*   START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: lo_report TYPE REF TO lcl_report.

  CREATE OBJECT lo_report.
  lo_report->get_data( ).
  lo_report->generate_output( ).

*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.

  METHOD get_data.

    SELECT bukrs belnr gjahr bldat cputm usnam waers
    FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE it_bkpf
    WHERE bukrs IN so_bukrs AND
          belnr IN so_belnr AND
          gjahr IN so_gjahr.

  ENDMETHOD.                    "GET_DATA

  METHOD generate_output.

    DATA: lx_msg TYPE REF TO cx_salv_msg.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = it_bkpf ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.

    CALL METHOD set_hotspot
      EXPORTING
        co_alv      = o_alv
        co_report   = lo_report
        column_name = 'BELNR'.

    CALL METHOD set_hotspot
      EXPORTING
        co_alv      = o_alv
        co_report   = lo_report
        column_name = 'WAERS'.

    o_alv->display( ).

  ENDMETHOD.                    "GENERATE_OUTPUT

  METHOD set_hotspot.

    DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table,
          lo_col_tab  TYPE REF TO cl_salv_column_table.

    lo_cols_tab = co_alv->get_columns( ).

    TRY.
        lo_col_tab ?= lo_cols_tab->get_column( column_name ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        CALL METHOD lo_col_tab->set_cell_type
          EXPORTING
            value = if_salv_c_cell_type=>hotspot.
        .
      CATCH cx_salv_data_error .
    ENDTRY.

    DATA: lo_events TYPE REF TO cl_salv_events_table.
    lo_events = o_alv->get_event( ).

    SET HANDLER co_report->hotspot_handler FOR lo_events.

  ENDMETHOD.                    "set_hotspot_vbeln

  METHOD hotspot_handler.
    DATA: lv_bkpf  TYPE ty_bkpf,
          lv_belnr TYPE ty_bkpf,
          lv_gjahr TYPE ty_bkpf.

    READ TABLE: lo_report->it_bkpf INTO lv_bkpf  INDEX row,
                lo_report->it_bkpf INTO lv_belnr INDEX row - 1,
                lo_report->it_bkpf INTO lv_gjahr INDEX row + 1.

    TRY.
        CASE column.
          WHEN 'BELNR'.
            IF lv_bkpf-belnr IS NOT INITIAL.

              DATA opt TYPE ctu_params.

              CALL METHOD bdcdata_dynpro EXPORTING program = 'SAPMF05L' dynpro = '0100'.

              CALL METHOD bdcdata_field_char EXPORTING fnam = 'RF05L-BUKRS' fval = lv_bkpf-bukrs.
              CALL METHOD bdcdata_field_char EXPORTING fnam = 'RF05L-BELNR' fval = lv_bkpf-belnr.
              CALL METHOD bdcdata_field_num EXPORTING fnam = 'RF05L-GJAHR' fval = lv_bkpf-gjahr.

              CALL METHOD bdcdata_dynpro EXPORTING program = 'RFBUEB00' dynpro = '1000'.

              CALL METHOD bdcdata_field_char EXPORTING fnam = 'BR_BUKRS-LOW' fval = lv_bkpf-bukrs.
              CALL METHOD bdcdata_field_char EXPORTING fnam = 'BR_BUKRS-HIGH' fval = lv_bkpf-bukrs.
              CALL METHOD bdcdata_field_char EXPORTING fnam = 'BR_BELNR-LOW' fval = lv_bkpf-belnr.
              CALL METHOD bdcdata_field_char EXPORTING fnam = 'BR_BELNR-HIGH' fval = lv_bkpf-belnr.
              CALL METHOD bdcdata_field_num EXPORTING fnam = 'BR_GJAHR-LOW' fval = lv_bkpf-gjahr.
              CALL METHOD bdcdata_field_num EXPORTING fnam = 'BR_GJAHR-HIGH' fval = lv_bkpf-gjahr.

              opt-dismode = 'A'.

              CALL TRANSACTION 'FB03' USING it_bdcdata OPTIONS FROM opt.

            ENDIF.
          WHEN 'WAERS'.
            DATA: o_popup_alv TYPE REF TO cl_salv_table.
            DATA: lo_functions TYPE REF TO cl_salv_functions_list.
            DATA: it_bkpf TYPE STANDARD TABLE OF ty_bkpf.

            SELECT bukrs gjahr belnr shkzg wrbtr
              FROM bseg
              INTO CORRESPONDING FIELDS OF TABLE it_bseg
              WHERE
                    bukrs = lv_bkpf-bukrs AND
                    belnr = lv_bkpf-belnr AND
                    gjahr = lv_bkpf-gjahr AND
                    shkzg = 'S'.

*          SELECT bukrs belnr gjahr bldat cputm usnam waers
*            FROM bkpf
*            INTO CORRESPONDING FIELDS OF TABLE it_bkpf
*            WHERE bukrs IN so_bukrs AND
*                  gjahr IN so_gjahr AND
*                  belnr IN so_belnr.
*
*          SELECT bukrs gjahr belnr shkzg wrbtr
*            FROM bseg
*            INTO CORRESPONDING FIELDS OF TABLE it_bseg
*            FOR ALL ENTRIES IN it_bkpf
*            WHERE belnr = it_bkpf-belnr
*              AND shkzg = 'S'.

            cl_salv_table=>factory(
               IMPORTING
                 r_salv_table   = o_popup_alv
              CHANGING
                t_table        = it_bseg ).

            lo_functions = o_popup_alv->get_functions( ).
            lo_functions->set_default( 'X' ).

            o_popup_alv->set_screen_popup(
              start_column = 80
              end_column   = 200
              start_line   = 3
              end_line     = 20 ).

            o_popup_alv->display( ).

        ENDCASE.
      CATCH cx_salv_msg.
    ENDTRY.

  ENDMETHOD.                    "belnr_hotspot_handler

  METHOD bdcdata_dynpro.
    CLEAR wa_bdcdata.
    wa_bdcdata-program  = program.
    wa_bdcdata-dynpro   = dynpro.
    wa_bdcdata-dynbegin = 'X'.
    APPEND wa_bdcdata TO it_bdcdata.
  ENDMETHOD.                    "bdcdata_dynpro

  METHOD bdcdata_field_char.
    CLEAR wa_bdcdata.
    wa_bdcdata-fnam = fnam.
    wa_bdcdata-fval = fval.
    APPEND wa_bdcdata TO it_bdcdata.
  ENDMETHOD.                    "bdcdata_field_char

  METHOD bdcdata_field_num.
    CLEAR wa_bdcdata.
    wa_bdcdata-fnam = fnam.
    wa_bdcdata-fval = fval.
    APPEND wa_bdcdata TO it_bdcdata.
  ENDMETHOD.                    "bdcdata_field_num

ENDCLASS.                   "LCL_REPORT IMPLEMENTATION

*--------------------------------------------------------------------*
*   INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.

  APPEND VALUE #( low = '0001' high = '1000' )            TO so_bukrs.
  APPEND VALUE #( low = '100001001' high = '100001010' )  TO so_belnr.
  APPEND VALUE #( low = '2018' high = '2019' )            TO so_gjahr.

*--------------------------------------------------------------------*
*   AT-LINE SELECTION
*--------------------------------------------------------------------*

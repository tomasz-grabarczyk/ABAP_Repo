*&---------------------------------------------------------------------*
*& Report: ZTG_FOR_ALL_ENTRIES
*&---------------------------------------------------------------------*
*& Author: Tomasz Grabarczyk
*& Last modified: 12.08.2019
*&---------------------------------------------------------------------*

REPORT ztg_for_all_entries.

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
             gjahr TYPE bseg-gjahr, "Fiscal Year
             belnr TYPE bseg-belnr, "Accounting Document Number
             shkzg TYPE bseg-shkzg, "Debit/Credit Indicator
             wrbtr TYPE bseg-wrbtr, "Amount in document currency
           END OF ty_bseg.

    DATA: it_bkpf TYPE TABLE OF bkpf,
          wa_bkpf LIKE LINE OF it_bkpf,
          it_bseg TYPE TABLE OF bseg,
          wa_bseg LIKE LINE OF it_bseg.

    TABLES bkpf.

    SELECT-OPTIONS: lv_bukrs FOR bkpf-bukrs,
                    lv_gjahr FOR bkpf-gjahr,
                    lv_belnr FOR bkpf-belnr.

    DATA: shkgz_rb TYPE c.

    PARAMETERS: shkgz_s RADIOBUTTON GROUP rbg,
                shkgz_h RADIOBUTTON GROUP rbg.

    IF shkgz_s = 'X'.
      shkgz_rb = 'S'.
    ELSEIF shkgz_h = 'X'.
      shkgz_rb = 'H'.
    ENDIF.

*--------------------------------------------------------------------*
*   INITIALIZATION
*--------------------------------------------------------------------*
    INITIALIZATION.

      lv_bukrs-low = '0001'.
      lv_bukrs-high = '1000'.
      APPEND lv_bukrs.

      lv_belnr-low = '100001008'.
      lv_belnr-high = '100001010'.
      APPEND lv_belnr.

      lv_gjahr-low = '2018'.
      lv_gjahr-high = '2019'.
      APPEND lv_gjahr.

*--------------------------------------------------------------------*
*   START-OF-SELECTION
*--------------------------------------------------------------------*
    START-OF-SELECTION.

      SELECT bukrs belnr gjahr bldat cputm usnam waers
        FROM bkpf
        INTO CORRESPONDING FIELDS OF TABLE it_bkpf
        WHERE bukrs IN lv_bukrs AND
              gjahr IN lv_gjahr AND
              belnr IN lv_belnr.

      SELECT bukrs gjahr belnr shkzg wrbtr
        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE it_bseg
        FOR ALL ENTRIES IN it_bkpf
        WHERE belnr = it_bkpf-belnr
          AND shkzg = shkgz_rb.

      WRITE: '(BUKRS)        '  COLOR COL_HEADING,
             '(BELNR)        '  COLOR COL_HEADING,
             '(GJAHR)        '  COLOR COL_HEADING,
             '(BLDAT)        '  COLOR COL_HEADING,
             '(CPUTM)        '  COLOR COL_HEADING,
             '(USNAM)        '  COLOR COL_HEADING,
             '(WAERS)        '  COLOR COL_HEADING,
             '(SHKZG)        '  COLOR COL_HEADING,
             '(WRBTR)        '  COLOR COL_HEADING.

      LOOP AT it_bkpf INTO wa_bkpf.
        LOOP AT it_bseg INTO wa_bseg
          WHERE bukrs = wa_bkpf-bukrs.
          WRITE: / wa_bkpf-bukrs UNDER '(BUKRS)        '  LEFT-JUSTIFIED,
                   wa_bkpf-belnr UNDER '(BELNR)        '  LEFT-JUSTIFIED,
                   wa_bkpf-gjahr UNDER '(GJAHR)        '  LEFT-JUSTIFIED,
                   wa_bkpf-bldat UNDER '(BLDAT)        '  LEFT-JUSTIFIED,
                   wa_bkpf-cputm UNDER '(CPUTM)        '  LEFT-JUSTIFIED,
                   wa_bkpf-usnam UNDER '(USNAM)        '  LEFT-JUSTIFIED,
                   wa_bkpf-waers UNDER '(WAERS)        '  LEFT-JUSTIFIED,
                   wa_bseg-shkzg UNDER '(SHKZG)        '  LEFT-JUSTIFIED,
                   wa_bseg-wrbtr UNDER '(WRBTR)        '  LEFT-JUSTIFIED.
        ENDLOOP.
      ENDLOOP.

*--------------------------------------------------------------------*
*   AT LINE-SELECTION
*--------------------------------------------------------------------*
    AT LINE-SELECTION.

*&---------------------------------------------------------------------*
*& Report  ZARCIE_W_MAKU
*&
*& Author: Tomasz Grabarczyk
*& Last modified: 02.09.2019
*&
*&---------------------------------------------------------------------*

REPORT zarcie_w_maku.

TYPES: BEGIN OF ty_mak_cust,
          name TYPE ztg_mak_cust-name,
          surname TYPE ztg_mak_cust-surname,
          mail TYPE ztg_mak_cust-email_address,
       END OF ty_mak_cust.

TYPES: BEGIN OF ty_mak_menu,
          name TYPE ztg_mak_menu-name,
       END OF ty_mak_menu.

DATA: it_mak_cstmr TYPE TABLE OF ty_mak_cust,
      it_mak_order TYPE TABLE OF ty_mak_menu,
      it_mak_tempt TYPE TABLE OF ty_mak_menu.

DATA: msg(100) TYPE c.

SELECTION-SCREEN BEGIN OF SCREEN 100.
  SELECTION-SCREEN BEGIN OF BLOCK menu WITH FRAME TITLE gv_title.
    PARAMETERS: burgr AS CHECKBOX,
                wraps AS CHECKBOX,
                brkft AS CHECKBOX,
                chick AS CHECKBOX,
                fries AS CHECKBOX,
                salad AS CHECKBOX,
                hotbv AS CHECKBOX,
                cldbv AS CHECKBOX,
                desrt AS CHECKBOX,
                sauce AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK menu.
SELECTION-SCREEN END OF SCREEN 100.

SELECT id
  FROM ztg_mak_cust
  INTO CORRESPONDING FIELDS OF TABLE it_mak_cstmr.

*--------------------------------------------------------------------*
* CLASS DEFINITION
*--------------------------------------------------------------------*
CLASS rand_num DEFINITION.

  PUBLIC SECTION.

    METHODS:
      print_to_screen.

  PRIVATE SECTION.

    METHODS:
      generate_order.

    METHODS:
      append_order
        IMPORTING
          prod_order TYPE c
          min_num TYPE i
          max_num TYPE i.

ENDCLASS.

CLASS rand_num IMPLEMENTATION.

  METHOD append_order.

    DATA:
      lo_ran TYPE REF TO cl_abap_random_int,
      lv_seed TYPE i,
      lv_random_number TYPE i.

    DATA: lv_stop TYPE i.

    CLEAR it_mak_tempt.
    CLEAR lv_seed.
    CLEAR lv_random_number.

    SELECT product name
      FROM ztg_mak_menu
      INTO CORRESPONDING FIELDS OF TABLE it_mak_tempt
      WHERE product EQ prod_order.

    lv_stop = lines( it_mak_tempt ).

    lv_seed = sy-timlo.
    lo_ran = cl_abap_random_int=>create( min = min_num max = max_num seed = lv_seed ).
    lv_random_number = lo_ran->get_next( ).

    SELECT product name id
      FROM ztg_mak_menu
      APPENDING CORRESPONDING FIELDS OF TABLE it_mak_order
      WHERE product EQ prod_order AND id = lv_random_number.

  ENDMETHOD.

  METHOD generate_order.

    IF burgr = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'BURGR'
          min_num    = 1
          max_num    = 14.
    ENDIF.

    IF wraps = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'WRAPS'
          min_num    = 15
          max_num    = 16.
    ENDIF.

    IF brkft = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'BRKFT'
          min_num    = 17
          max_num    = 30.
    ENDIF.

    IF chick = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'CHICK'
          min_num    = 31
          max_num    = 32.
    ENDIF.

    IF fries = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'FRIES'
          min_num    = 33
          max_num    = 33.
    ENDIF.

    IF salad = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'SALAD'
          min_num    = 34
          max_num    = 35.
    ENDIF.

    IF hotbv = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'HOTBV'
          min_num    = 36
          max_num    = 42.
    ENDIF.

    IF cldbv = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'CLDBV'
          min_num    = 43
          max_num    = 51.
    ENDIF.

    IF desrt = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'DESRT'
          min_num    = 52
          max_num    = 60.
    ENDIF.

    IF sauce = 'X'.
      CALL METHOD append_order
        EXPORTING
          prod_order = 'SAUCE'
          min_num    = 61
          max_num    = 70.
    ENDIF.

  ENDMETHOD.

  METHOD print_to_screen.

    LOOP AT it_mak_cstmr ASSIGNING FIELD-SYMBOL(<fs_cstmr>).
      CONCATENATE 'ORDER FOR:' <fs_cstmr>-name <fs_cstmr>-surname INTO msg SEPARATED BY space.
      WRITE: / msg.
    ENDLOOP.

    CALL METHOD generate_order.

    LOOP AT it_mak_order ASSIGNING FIELD-SYMBOL(<fs_order>).
      WRITE: / <fs_order>.
    ENDLOOP.

    WRITE: /.

    MESSAGE 'ORDER CREATED SUCCESSFULLY!' TYPE 'S'.

  ENDMETHOD.

ENDCLASS.

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  DATA: lo_rand_num TYPE REF TO rand_num.

  CREATE OBJECT lo_rand_num.

  DO lines( it_mak_cstmr ) TIMES.
    burgr = ''. wraps = ''. brkft = ''. chick = ''. fries = ''.
    salad = ''. hotbv = ''. cldbv = ''. desrt = ''. sauce = ''.

    SELECT name surname
      FROM ztg_mak_cust
      INTO CORRESPONDING FIELDS OF TABLE it_mak_cstmr
      WHERE id = sy-index.

    LOOP AT it_mak_cstmr ASSIGNING FIELD-SYMBOL(<fs_cst>).
      CONCATENATE 'ORDER FOR:' <fs_cst>-name <fs_cst>-surname INTO msg SEPARATED BY space.
      gv_title = msg.
    ENDLOOP.

    CALL SELECTION-SCREEN 100.

    CLEAR it_mak_order.

    lo_rand_num->print_to_screen( ).
  ENDDO.

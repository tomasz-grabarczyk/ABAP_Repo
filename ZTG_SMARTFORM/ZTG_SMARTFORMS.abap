*&---------------------------------------------------------------------*
*& 
*& Report  ZTG_SMARTFORMS
*&
*& Author: Tomasz Grabarczyk
*& Last modified: 26.08.2019
*&
*&---------------------------------------------------------------------*

REPORT ztg_smartforms.

PARAMETERS: p_vbeln       TYPE vbap-vbeln,
            p_kunnr       TYPE kna1-kunnr,
            p_nrlow       TYPE vbap-posnr,
            p_nrhigh      TYPE vbap-posnr.

TYPES: BEGIN OF ty_recipient,
         kunnr TYPE kna1-kunnr, "Customer Number
         name1 TYPE kna1-name1, "Name 1
         stras TYPE kna1-stras, "House number and street
         pstlz TYPE kna1-pstlz, "Postal Code
         ort01 TYPE kna1-ort01, "City
       END OF ty_recipient.

DATA: it_recipient TYPE TABLE OF ty_recipient,
      lv_recipient LIKE LINE OF it_recipient.

DATA: lv_barcode(50).
DATA: lv_footer(100) VALUE 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'.

SELECT kunnr name1 stras pstlz ort01
FROM kna1
INTO CORRESPONDING FIELDS OF TABLE it_recipient
WHERE kunnr = p_kunnr.

*SELECT k~vbeln, k~netwr, p~posnr, p~matnr, p~arktx
*  FROM vbak AS k
*  INNER JOIN vbap AS p
*  ON k~vbeln = p~vbeln
*  INTO TABLE @data(it_material)
*  WHERE k~vbeln = @p_vbeln AND
*        p~posnr IN @so_posnr.
*
*SELECT kunnr name1 stras pstlz ort01
*  FROM kna1
*  INTO TABLE @data(it_recipient)
*  WHERE kunnr = @p_kunnr.

TRY.
    lv_recipient = it_recipient[ 1 ].
  CATCH  cx_sy_itab_line_not_found.
* handle error
ENDTRY.

CONCATENATE p_vbeln p_nrhigh INTO lv_barcode.
CALL FUNCTION '/1BCDWB/SF00000613'
  EXPORTING
    barcode_number       = lv_barcode
    address_to_name      = lv_recipient-name1
    address_to_street    = lv_recipient-stras
    address_to_post_code = lv_recipient-pstlz
    address_to_country   = lv_recipient-ort01
    footer               = lv_footer
    vbeln                = p_vbeln
    posnr_low            = p_nrlow
    posnr_high           = p_nrhigh.

*--------------------------------------------------------------------*
* INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.

  p_vbeln = '0000004995'.
  p_kunnr = '0000001455'.
  p_nrlow = '10'.
  p_nrhigh = '40'.

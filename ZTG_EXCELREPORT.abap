*&---------------------------------------------------------------------*
*& Report:  ZTG_EXCELREPORT
*& Author:  Tomasz Grabarczyk
*& Date:    16.07.2019
*&---------------------------------------------------------------------*

REPORT ztg_excelreport.

WRITE: / text-002 COLOR COL_HEADING,
         text-004 COLOR COL_HEADING,
         text-005 COLOR COL_HEADING,
         text-009 COLOR COL_HEADING,
         text-013 COLOR COL_HEADING,
         text-014 COLOR COL_HEADING.

TYPES: BEGIN OF ty_excel_report,
          assigned_group    TYPE ztg_excelreport-assigned_group,
          incident_number   TYPE ztg_excelreport-incident_number,
          sap_area          TYPE ztg_excelreport-sap_area,
          reported_date     TYPE ztg_exrep_dates-reported_date,
          priority          TYPE ztg_exrep_pc-priority,
          country           TYPE ztg_exrep_pc-country,
        END OF ty_excel_report.

DATA: it_excel_report_join   TYPE TABLE OF ty_excel_report,
      wa_excel_report_join   LIKE LINE OF  it_excel_report_join.

SELECT rep~assigned_group rep~incident_number rep~sap_area dat~reported_date pc~priority pc~country
    FROM ztg_excelreport    AS rep
    JOIN ztg_exrep_dates    AS dat
    ON rep~incident_number  = dat~incident_number
    JOIN ztg_exrep_pc       AS pc
    ON rep~incident_number  = pc~incident_number
    INTO CORRESPONDING FIELDS OF TABLE it_excel_report_join
    UP TO 100 ROWS
    WHERE ( rep~sap_area    EQ 'LOGISTICS'  OR
            rep~sap_area    EQ 'SALES'      OR
            rep~sap_area    EQ 'FICO' )     AND
            pc~country      EQ 'GUITHIO MOAFA'
    ORDER BY dat~reported_date.

LOOP AT it_excel_report_join INTO wa_excel_report_join.
  WRITE: / wa_excel_report_join-assigned_group   UNDER text-002 LEFT-JUSTIFIED,
           wa_excel_report_join-incident_number  UNDER text-004 LEFT-JUSTIFIED,
           wa_excel_report_join-sap_area         UNDER text-005 LEFT-JUSTIFIED,
           wa_excel_report_join-reported_date    UNDER text-009 LEFT-JUSTIFIED,
           wa_excel_report_join-priority         UNDER text-013 LEFT-JUSTIFIED,
           wa_excel_report_join-country          UNDER text-014 LEFT-JUSTIFIED.
ENDLOOP.

"Display data without having to use working area
"cl_demo_output=>display( it_excel_report_join ).

*&---------------------------------------------------------------------*
*& Report ZTEST_SP_ALV_FRM_CDS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcn_customer_cds_alv.

**&---------------------------------------------------------------------*
**& OPEN SQL STATEMENT TO ACCESS THE CDS VIEW
**&---------------------------------------------------------------------*
**Select * from I_SalesDocument
**  into table @data(it_slsdata).
**&---------------------------------------------------------------------*
**& CDS VIEW IN ALV REPORT
**&---------------------------------------------------------------------*
*DATA: lo_alv TYPE REF TO if_salv_gui_table_ida.
*  TRY.
****  cl_salv_gui_table_ida=>create(
****  EXPORTING
****    iv_table_name = 'ZSQL_MARAMAKT'"'ZCDS_MAra_makt' ""name of the CDS VIEW
****  RECEIVING
****    ro_alv_gui_table_ida = lo_alv ).
*
**    TRY.
*  break-point.
*    CALL METHOD cl_salv_gui_table_ida=>create_for_cds_view
*      EXPORTING
*        iv_cds_view_name      = 'ZCNCCUSCONT'
**        io_gui_container      =
**        io_calc_field_handler =
*      RECEIVING
*        ro_alv_gui_table_ida  = lo_alv
*        .
*      CATCH cx_salv_db_connection.
*      CATCH cx_salv_db_table_not_supported.
*      CATCH cx_salv_ida_contract_violation.
*      CATCH cx_salv_function_not_supported.
*        MESSAGE 'Error' TYPE 'E'.
*    ENDTRY.
*
*
**  Display ALV.
*  lo_alv->fullscreen( )->display( ).
*
*
***  lo_alv->
cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = 'ZCUSTOMER_CONTACT' )->fullscreen( )->display( ).
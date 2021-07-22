************************************************************
* This method is not used as part of notification creation *
* Attachment cannot be sent as part of Deep Entity         *
************************************************************

  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
*    IO_EXPAND               =
**    io_tech_request_context =
**  IMPORTING
**    er_deep_entity          =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

DATA: BEGIN OF ls_deep_entity.
        INCLUDE TYPE zcl_zcloudnative_notif_mpc=>TS_PMNOTIF.
    DATA: NotiftoPhoto TYPE TABLE OF zcl_zcloudnative_notif_mpc=>TS_PMNOTIFPHOTO,
          END OF ls_deep_entity.

DATA: ls_request_input_data TYPE ZCL_ZCLOUDNATIVE_NOTIF_MPC=>TS_PMNOTIF,
        ls_header             TYPE BAPI2080_NOTHDRI,
        ls_notif_export       TYPE BAPI2080_NOTHDRE,
        ls_return             TYPE BAPIRET2.



  io_data_provider->read_entry_data(
      IMPORTING
        es_data = ls_deep_entity ).

    if iv_entity_name = 'PMNOTIF'.



     CALL METHOD me->CUSTOM_CREATE_DEEP_ENTITY
       EXPORTING
*         IV_ENTITY_NAME          =
*         IV_ENTITY_SET_NAME      =
*         IV_SOURCE_NAME          =
         IO_DATA_PROVIDER        = io_data_provider
         IT_KEY_TAB              = it_key_tab
         IT_NAVIGATION_PATH      = it_navigation_path
         IO_EXPAND               = io_expand
         IO_TECH_REQUEST_CONTEXT = io_tech_request_context
       IMPORTING
         ER_DEEP_ENTITY          = er_deep_entity.
         .


    else.
      "zcl_pm_inspection_app_bus=>raise_error( iv_msgno = '033' iv_attr1 = conv #( iv_entity_set_name ) ).
    endif.

  endmethod.
  METHOD pmnotifphotoset_get_entity.
**TRY.
*CALL METHOD SUPER->PMNOTIFPHOTOSET_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
DATA: lv_notif TYPE qmnum.
     TRY.
    DATA(ls_tab) = it_key_tab[ name =  'ZcnNotifnum' ].

lv_notif = |{ ls_tab-value ALPHA = IN }|.
 DATA: ls_key    TYPE /iwbep/s_mgw_name_value_pair,
          lv_noti   TYPE qmnum,
          ls_attach TYPE zcn_notifphoto.

    DATA: lt_attachment TYPE swuoconttab,
          ls_attachment TYPE solisti1,
          ls_att_val    TYPE string.
    DATA: ls_error            TYPE zeamst_error.
    DATA: lv_objkey           TYPE swotobjid-objkey.

    DATA: lt_data TYPE STANDARD TABLE OF bdn_con,
          ls_data TYPE bdn_con.
    CONSTANTS:
      lc_classname            TYPE bapibds01-classname VALUE  'BUS2038'.    " Business Document Service: Class name
***************** data declaration****************************************
*    READ TABLE it_key_tab WITH KEY name = 'Noti_no' INTO ls_key.
*    lv_noti = ls_key-value.
    IF lv_notif IS NOT INITIAL.
*   Get the document id of the attachment
      lv_objkey = lv_notif.
      CALL FUNCTION 'BDS_GOS_CONNECTIONS_GET'
        EXPORTING
          classname          = lc_classname                              " Business Document Service: Class Name
          objkey             = lv_objkey                                 " Object Key
        TABLES
          gos_connections    = lt_data                                   " Business Document Navigator: Internal Connection Table
        EXCEPTIONS
          no_objects_found   = 1
          internal_error     = 2
          internal_gos_error = 3
          OTHERS             = 4.
    ENDIF.
    LOOP AT lt_data INTO ls_data.
      ls_attach-zcn_notifnum        = lv_notif.
      "ls_attach-doc_id          = ls_data-loio_id.
      ls_attach-content    = ls_data-descript.
      ls_attach-filename       = ls_data-descript.
      ls_attach-mimetype       = ls_data-docuclass.
      ls_attach-folder_id  = ls_data-loio_id.
      "APPEND ls_attach TO et_entityset.
      MOVE-CORRESPONDING ls_attach TO er_entity.
      EXIT.
    ENDLOOP.

CATCH cx_sy_itab_line_not_found.
  ENDTRY.
  ENDMETHOD.
  METHOD pmnotifset_get_entity.
**TRY.
*CALL METHOD SUPER->PMNOTIFSET_GET_ENTITY
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

    SELECT SINGLE * FROM qmel INTO @DATA(ls_qmel) WHERE qmnum = @lv_notif.

  IF sy-subrc = 0.

    er_entity-zcn_notifnum    = ls_qmel-qmnum.

    er_entity-equipment = ls_qmel-shn_equipment.

    er_entity-functional_location  = ls_qmel-shn_funct_loc.

    er_entity-reference_notif     = ls_qmel-qwrnum.

    er_entity-short_text    = ls_qmel-qmtxt.

    er_entity-matnr = ls_qmel-matnr.

    er_entity-priority = '2-High'.

    er_entity-status = 'Received'.

    er_entity-qmdat = ls_qmel-qmdat. "|{ <fs_qmel>-QMDAT DATE = USER }|.

  ENDIF.

CATCH cx_sy_itab_line_not_found.
  ENDTRY.


  ENDMETHOD.
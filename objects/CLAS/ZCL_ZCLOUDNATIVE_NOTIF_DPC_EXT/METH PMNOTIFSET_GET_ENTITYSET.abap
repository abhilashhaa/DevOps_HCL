  METHOD pmnotifset_get_entityset.
**TRY.
*CALL METHOD SUPER->PMNOTIFSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

DATA: ls_qmel TYPE zcl_zcloudnative_notif_mpc=>ts_pmnotif.

 SELECT * FROM qmel INTO TABLE @DATA(lt_qmel) WHERE qmart = 'M1' AND
                                                    ernam = '90001092'." AND
                                                 "   erdat = @sy-datum.

  IF sy-subrc = 0.

  SORT lt_qmel BY qmnum DESCENDING.

  LOOP AT lt_qmel ASSIGNING FIELD-SYMBOL(<fs_qmel>).

   IF sy-tabix > 20.
      EXIT.
   ENDIF.

   ls_qmel-zcn_notifnum    = <fs_qmel>-qmnum.

   ls_qmel-equipment       = <fs_qmel>-shn_equipment.

    ls_qmel-functional_location  = <fs_qmel>-shn_funct_loc.

    ls_qmel-reference_notif = <fs_qmel>-qwrnum.

    ls_qmel-short_text    = <fs_qmel>-qmtxt.

    ls_qmel-matnr         = <fs_qmel>-matnr.

    ls_qmel-priority      = '2-High'.

    ls_qmel-status        = 'Received'.

    ls_qmel-qmdat         = <fs_qmel>-qmdat. "|{ <fs_qmel>-QMDAT DATE = USER }|.

    APPEND ls_qmel TO et_entityset.

ENDLOOP.

UNASSIGN <fs_qmel>.

  ENDIF.

  ENDMETHOD.
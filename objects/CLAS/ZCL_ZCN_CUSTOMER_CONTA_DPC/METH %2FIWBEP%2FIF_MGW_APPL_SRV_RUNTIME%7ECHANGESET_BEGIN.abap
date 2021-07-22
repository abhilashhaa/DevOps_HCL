  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN.
    if_sadl_gw_dpc_util~get_dpc( )->begin_changeset( EXPORTING it_operation_info = it_operation_info
                                                     CHANGING cv_defer_mode      = cv_defer_mode ).
  endmethod.
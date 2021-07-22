  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS.
    if_sadl_gw_dpc_util~get_dpc( )->process_changeset( EXPORTING it_changeset_request  = it_changeset_request
                                                       CHANGING  ct_changeset_response = ct_changeset_response ).
  endmethod.
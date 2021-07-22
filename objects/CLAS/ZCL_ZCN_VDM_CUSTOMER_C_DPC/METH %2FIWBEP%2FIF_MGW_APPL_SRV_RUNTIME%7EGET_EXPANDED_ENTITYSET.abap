  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET.
   if_sadl_gw_dpc_util~get_dpc( )->get_expanded_entityset( EXPORTING io_expand_node               = io_expand
                                                                     io_tech_request_context      = io_tech_request_context
                                                           IMPORTING er_entityset                 = er_entityset
                                                                     et_expanded_tech_clauses     = et_expanded_tech_clauses
                                                                     es_response_context          = es_response_context ).
  endmethod.
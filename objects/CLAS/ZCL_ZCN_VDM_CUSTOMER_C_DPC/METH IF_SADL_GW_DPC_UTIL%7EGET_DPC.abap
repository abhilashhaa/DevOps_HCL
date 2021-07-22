  method IF_SADL_GW_DPC_UTIL~GET_DPC.
    TYPES ty_i_draftadministrativeda_1 TYPE i_draftadministrativedata ##NEEDED. " reference for where-used list
    TYPES ty_zcn_c_customercontact_2 TYPE zcn_c_customercontact ##NEEDED. " reference for where-used list
    TYPES ty_zcn_cuscon_3 TYPE zcn_cuscon ##NEEDED. " reference for where-used list

    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>| &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="" >| &
               | <sadl:dataSource type="CDS" name="ZCN_C_CUSTOMERCONTACT" binding="ZCN_C_CUSTOMERCONTACT" />| &
               |<sadl:resultSet>| &
               |<sadl:structure name="ZCN_C_CUSTOMERCONTACT" dataSource="ZCN_C_CUSTOMERCONTACT" maxEditMode="RO" exposure="TRUE" >| &
               | <sadl:query name="SADL_QUERY">| &
               | </sadl:query>| &
               |</sadl:structure>| &
               |</sadl:resultSet>| &
               |</sadl:definition>| .
    ro_dpc = cl_sadl_gw_dpc_factory=>create_for_sadl( iv_sadl_xml   = lv_sadl_xml
               iv_timestamp         = 20200218144030
               iv_uuid              = 'ZCN_VDM_CUSTOMER_CONTACT'
               io_context           = me->mo_context ).
  endmethod.
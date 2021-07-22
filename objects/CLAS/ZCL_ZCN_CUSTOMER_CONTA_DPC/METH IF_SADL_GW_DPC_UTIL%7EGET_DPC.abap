  method IF_SADL_GW_DPC_UTIL~GET_DPC.
    TYPES ty_ZCUSTOMER_CONTACT_1 TYPE zcustomer_contact ##NEEDED. " reference for where-used list

    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>| &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="" >| &
               | <sadl:dataSource type="CDS" name="ZCUSTOMER_CONTACT" binding="ZCUSTOMER_CONTACT" />| &
               |<sadl:resultSet>| &
               |<sadl:structure name="ZCUSTOMER_CONTACT" dataSource="ZCUSTOMER_CONTACT" maxEditMode="RO" exposure="TRUE" >| &
               | <sadl:query name="SADL_QUERY">| &
               | </sadl:query>| &
               |</sadl:structure>| &
               |</sadl:resultSet>| &
               |</sadl:definition>| .
    ro_dpc = cl_sadl_gw_dpc_factory=>create_for_sadl( iv_sadl_xml   = lv_sadl_xml
               iv_timestamp         = 20200716163520
               iv_uuid              = 'ZCN_CUSTOMER_CONTACT'
               io_context           = me->mo_context ).
  endmethod.
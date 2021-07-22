class ZCL_ZCN_CUSTOMER_CONTA_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  interfaces IF_SADL_GW_MODEL_EXPOSURE_DATA .

  types:
   TS_ZCUSTOMER_CONTACTTYPE type ZCUSTOMER_CONTACT .
  types:
   TT_ZCUSTOMER_CONTACTTYPE type standard table of TS_ZCUSTOMER_CONTACTTYPE .

  constants GC_ZCUSTOMER_CONTACTTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCUSTOMER_CONTACTType' ##NO_TEXT.

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .
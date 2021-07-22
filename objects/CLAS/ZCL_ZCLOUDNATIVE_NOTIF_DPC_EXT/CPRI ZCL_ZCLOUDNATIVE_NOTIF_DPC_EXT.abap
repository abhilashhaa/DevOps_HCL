private section.

  methods ADD_NOTIF_PHOTO
    importing
      !IT_NOTIF2PHOTO type ZCN_INSNOTIFPHOTO_TT
      !IV_QMNUM type QMNUM
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION .
  methods CONVERT_ATTACHMENT_XSTRING
    importing
      !IV_QMNUM type QMNUM
      !IV_DOC_ID type BDS_DOCID
    exporting
      !EV_XSTR_VAL type XSTRING
      !ET_ATTACH_BIN type SOLIX_TAB .
  methods METH_DISPLAY_NOTIF_ATTACHMENT
    importing
      !IM_QMNUM type QMNUM optional
      !XDOC_ID type BDS_DOCID optional
    exporting
      !EX_ERROR type ZEAMST_ERROR
      !CONTENTS_HEX type SOLIX_TAB
      !DOC_DATA type SOFOLENTI1
      !EX_ATTACHMENT_LIST type ZEAMT_ATTACHMENT_LIST .
  methods METH_FILL_ERROR_MESSAGE
    importing
      !IM_BAPIRET_ST type BAPIRET2 optional
      !IM_MESSAGE type ITEX132 optional
    exporting
      !EX_ERROR type ZEAMST_ERROR
    changing
      !CH_BAPIRET type BAPIRET2_TAB optional .
  methods CUSTOM_CREATE_DEEP_ENTITY
    importing
      !IV_ENTITY_NAME type STRING optional
      !IV_ENTITY_SET_NAME type STRING optional
      !IV_SOURCE_NAME type STRING optional
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH optional
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
    exporting
      !ER_DEEP_ENTITY type DATA .
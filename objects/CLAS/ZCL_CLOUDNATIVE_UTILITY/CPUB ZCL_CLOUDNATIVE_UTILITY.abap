class ZCL_CLOUDNATIVE_UTILITY definition
  public
  final
  create public .

public section.

  types:
    GTT_INGRP TYPE STANDARD TABLE OF ingrp INITIAL SIZE 0 .

  class-data XC_NOTIF_CR type CHAR20 .
  class-data XC_TIME_CR type CHAR20 .
  class-data XC_MEASURE_CR type CHAR20 .
  class-data XC_WORKORDER_UPD type CHAR20 .

  class-methods METH_CREA_ATTAC_NOTIF
    importing
      !IM_NOTIF_NO type QMNUM optional
      !IM_FILE_EXT type SO_FILEEXT optional
      !IM_FILE_NAME type STRING optional
      !IM_I_CONTENT type SOLI_TAB optional
    exporting
      !EX_SUCCESS_MSG type BAPI_MSG
      !EX_ERROR type ZEAMST_ERROR
      !EX_FOLDERID type SOODK .
  class-methods METH_FILL_ERROR_MESSAGE
    importing
      !IM_BAPIRET_ST type BAPIRET2 optional
      !IM_MESSAGE type ITEX132 optional
    exporting
      !EX_ERROR type ZCN_ERROR
    changing
      !CH_BAPIRET type BAPIRET2_TAB optional .
  class-methods METH_ERROR_HANDLING
    importing
      !IM_NOTIFICATION type QMNUM optional
      !IM_WORKORDER type AUFNR optional
      !IM_MEASURING_DOC type IMRC_POINT optional
      !IM_TIME_CONF type POINT optional
      !IM_INSPEC_LOT type QPLOS optional
      !IM_SHORT_TEXT type LONGTEXT optional
      !IM_LONG_TEXT type BAPIRET2_T optional
      !IM_TRAN_TYPE type CHAR01 optional
      !IM_EQUIPMENT type EQUNR optional .
  class-methods METH_GET_USER_DETAIL
    importing
      !IM_USERID type SYUNAME
    exporting
      !EX_NOTIFTYP type ZCN_NOTIFTYP
      !EX_WOTYP type ZCN_WOTYP
      !EX_WRK type WERKS_D
      !EX_IFL type ZCN_FLOC
      !EX_LAG type ZCN_RIGID
      !EX_ZHIST type INT1
      !EX_ZUOM type CHAR1
      !EX_INGRP type GTT_INGRP
      !EX_IWERK type IWERK
      !EX_ERROR type ZCN_ERROR .
CLASS zcl_zcloudnative_notif_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zcloudnative_notif_mpc
  CREATE PUBLIC .

PUBLIC SECTION.

 TYPES : BEGIN OF ts_deep_entity,
    zcn_notifnum        TYPE  qmnum,
    short_text          TYPE  qmtxt,
    functional_location TYPE  tplnr,
    reference_notif     TYPE  qwrnum,
    equipment           TYPE  equnr,
    qmdat               TYPE  qmdat,
    matnr               TYPE  matnr,
    priority            TYPE  char10,
    status              TYPE  char20,
    NotiftoPhoto        TYPE STANDARD TABLE OF ts_pmnotifphoto
                     WITH DEFAULT KEY,
  END OF ts_deep_entity.

  METHODS define
    REDEFINITION .
  METHOD custom_create_deep_entity.

DATA:
   lr_deep_entity   TYPE zcl_zcloudnative_notif_mpc_ext=>ts_deep_entity,
   lt_pmnotif       TYPE zcl_zcloudnative_notif_mpc_ext=>tt_pmnotif,
   ls_pmnotif       TYPE zcl_zcloudnative_notif_mpc_ext=>ts_pmnotif,
   lt_pmnotifphoto  TYPE zcl_zcloudnative_notif_mpc_ext=>tt_pmnotifphoto,
   ls_pmnotifphoto  TYPE zcl_zcloudnative_notif_mpc_ext=>ts_pmnotifphoto.

  DATA :
  ls_general_data   TYPE zcn_notif,
  lt_ord_comp_data  TYPE STANDARD TABLE OF zcn_notifphoto,
  ls_ord_comp_data  TYPE zcn_notifphoto.

  FIELD-SYMBOLS:
  <ls_notif_photo> TYPE   zcl_zcloudnative_notif_mpc_ext=>ts_pmnotifphoto.

******message******
  DATA:
        lr_message_container  TYPE REF TO /iwbep/if_message_container,
        lv_message                 TYPE bapi_msg     ,
        lv_msgid                     TYPE symsgid      ,
        lv_msgno                    TYPE symsgno      .

  DATA: ls_request_input_data TYPE zcl_zcloudnative_notif_mpc=>ts_pmnotif,
        ls_header             TYPE bapi2080_nothdri,
        ls_notif_export       TYPE bapi2080_nothdre,
        ls_return             TYPE bapiret2,
        ls_notif_photo        TYPE zcn_insnotifphoto,
        lt_notif_photo        TYPE table of zcn_insnotifphoto.


*lr_message_container = me->mo_context

*  Transform data into the internal structure

  BREAK-POINT.
  TRY.
  io_data_provider->read_entry_data(
                     IMPORTING
                         es_data = lr_deep_entity ).
  CATCH /iwbep/cx_mgw_tech_exception ##CATCH_ALL ##NO_HANDLER.
    ENDTRY.

***********Collect the header fields here
*      ls_header-EQUIPMENT = ls_deep_entity-EQUIPMENT.
*      ls_header-FUNCT_LOC = ls_deep_entity-FUNCTIONAL_LOCATION.
*      ls_header-SHORT_TEXT = ls_deep_entity-SHORT_TEXT.
  ls_header-equipment = lr_deep_entity-equipment.
      ls_header-funct_loc = lr_deep_entity-functional_location.
      ls_header-short_text = lr_deep_entity-short_text.
CALL FUNCTION 'BAPI_ALM_NOTIF_CREATE'
  EXPORTING
*   EXTERNAL_NUMBER                     =
    notif_type                          = 'M1'
    notifheader                         = ls_header
*   TASK_DETERMINATION                  = ' '
*   SENDER                              =
*   ORDERID                             =
*   IV_DONT_CHK_MANDATORY_PARTNER       =
*   NOTIFCATION_COPY                    =
*   DOCUMENT_ASSIGN_COPY                = ' '
 IMPORTING
   notifheader_export                  = ls_notif_export
* TABLES
*   NOTITEM                             =
*   NOTIFCAUS                           =
*   NOTIFACTV                           =
*   NOTIFTASK                           =
*   NOTIFPARTNR                         =
*   LONGTEXTS                           =
*   KEY_RELATIONSHIPS                   =
*   RETURN                              =
*   EXTENSIONIN                         =
*   EXTENSIONOUT                        =
          .

CALL FUNCTION 'BAPI_ALM_NOTIF_SAVE'
  EXPORTING
    number                    = ls_notif_export-notif_no
*   TOGETHER_WITH_ORDER       = ' '
* IMPORTING
*   NOTIFHEADER               =
* TABLES
*   RETURN                    =
          .
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
* EXPORTING
*   WAIT          =
 IMPORTING
   return        = ls_return
          .

********Collect  photo fields

  LOOP AT lr_deep_entity-NotiftoPhoto ASSIGNING <ls_notif_photo>.

    CLEAR  ls_notif_photo.

   ls_notif_photo-qmnum    = ls_notif_export-notif_no.
   ls_notif_photo-mimetype = <ls_notif_photo>-mimetype.
   ls_notif_photo-filename = <ls_notif_photo>-filename.
   ls_notif_photo-content  = <ls_notif_photo>-content.

    APPEND ls_notif_photo TO lt_notif_photo.

*  io_data_provider->read_entry_data( IMPORTING es_data = ls_request_input_data ).
*
*   ls_notif_photo-qmnum = ls_request_input_data-zcn_notifnum.
*   ls_notif_photo-mimetype = ls_request_input_data-mimetype.
*   ls_notif_photo-filename = ls_request_input_data-filename.
*   ls_notif_photo-content  = ls_request_input_data-content.
*   APPEND ls_notif_photo TO lt_notif_photo.

 me->add_notif_photo( EXPORTING it_notif2photo = lt_notif_photo iv_qmnum = ls_notif_export-notif_no ).

  ENDLOOP.

  ENDMETHOD.
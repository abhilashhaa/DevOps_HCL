  METHOD pmnotifphotoset_update_entity.

DATA:   ls_request_input_data TYPE zcl_zcloudnative_notif_mpc=>ts_pmnotifphoto,
        ls_header             TYPE bapi2080_nothdri,
        ls_notif_export       TYPE bapi2080_nothdre,
        ls_return             TYPE bapiret2,
        ls_notif_photo        TYPE zcn_insnotifphoto,
        lt_notif_photo        TYPE table of zcn_insnotifphoto.


 io_data_provider->read_entry_data( IMPORTING es_data = ls_request_input_data ).

   ls_notif_photo-qmnum = ls_request_input_data-zcn_notifnum.
   ls_notif_photo-mimetype = ls_request_input_data-mimetype.
   ls_notif_photo-filename = ls_request_input_data-filename.
   ls_notif_photo-content  = ls_request_input_data-content.
   APPEND ls_notif_photo TO lt_notif_photo.

   .
 me->add_notif_photo( EXPORTING it_notif2photo = lt_notif_photo iv_qmnum = ls_request_input_data-zcn_notifnum ).

  ENDMETHOD.
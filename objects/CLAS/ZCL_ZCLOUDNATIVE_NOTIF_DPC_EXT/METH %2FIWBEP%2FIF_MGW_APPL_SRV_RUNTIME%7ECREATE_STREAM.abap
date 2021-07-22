************************************************************
* This method is used as part of notification creation     *
* It recieves image from MDK and create the attachment for *
* a specified notification number                          *
************************************************************
  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IS_MEDIA_RESOURCE       =
**    it_key_tab              =
**    it_navigation_path      =
*    IV_SLUG                 =
**    io_tech_request_context =
**  IMPORTING
**    er_entity               =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
    DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
          lt_key_tab TYPE /iwbep/t_mgw_name_value_pair.
    DATA: ls_navigation_path TYPE /iwbep/s_mgw_navigation_path,
          ls_key             TYPE /iwbep/s_mgw_name_value_pair.
    DATA: lv_ord_no    TYPE aufnr,
          lv_mime_type TYPE so_fileext.
    DATA: ls_s_msg TYPE bapi_msg,
          ls_e_msg TYPE zeamst_error.
    DATA: lt_content          TYPE STANDARD TABLE OF soli.
    DATA: lv_string_con       TYPE string.
    DATA: lv_noti_no   TYPE qmnum,
          im_file_name TYPE string,
          ls_notif_no  TYPE qmnum.
    DATA: lv_length TYPE i,
          l_string  TYPE string.
    DATA: lv_oper_no   TYPE char4,
          ls_ord_no    TYPE aufnr,
          lo_container TYPE REF TO /iwbep/if_message_container,
          lv_error     TYPE bapi_msg.
    DATA: ls_attach   TYPE zcn_notifphoto,
          ls_folderid TYPE soodk,
          lv_filename TYPE filep.
    DATA: lx_cv_attach              TYPE REF TO cx_odata_cv_base_exception.

    DATA: lv_string_base64    TYPE string.

    TYPES:
      BEGIN OF tech_expection,
        msgid TYPE symsgid,
        msgno TYPE symsgno,
        attr1 TYPE scx_attrname,
        attr2 TYPE scx_attrname,
        attr3 TYPE scx_attrname,
        attr4 TYPE scx_attrname,
      END OF tech_expection .
    DATA: wa_auth TYPE  tech_expection.
*********************data declaration*************************

    CLEAR : ls_attach, ls_Folderid, lv_filename.

    TRY.
        IF iv_slug IS INITIAL.
          RAISE EXCEPTION TYPE cx_odata_cv_attach_exception
            EXPORTING
              textid = cx_odata_cv_attach_exception=>attachment_name_empty.
        ENDIF.

        IF is_media_resource IS INITIAL.
          lv_filename = iv_slug.
          RAISE EXCEPTION TYPE cx_odata_cv_attach_exception
            EXPORTING
              textid   = cx_odata_cv_attach_exception=>attachment_content_empty
              filename = lv_filename.
        ENDIF.

        lv_noti_no = |{ iv_slug ALPHA = IN }|.
        IF im_file_name IS INITIAL.
          im_file_name = 'attach'.
        ENDIF.

        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer          = is_media_resource-value
            append_to_table = 'X'
          IMPORTING
            output_length   = lv_length
          TABLES
            binary_tab      = lt_content.


        CALL FUNCTION 'SCMS_BINARY_TO_STRING'
          EXPORTING
            input_length = lv_length
          TABLES
            binary_tab   = lt_content
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.

        CALL METHOD cl_http_utility=>if_http_utility~encode_x_base64
          EXPORTING
            unencoded = is_media_resource-value
          RECEIVING
            encoded   = lv_string_base64.

        ls_attach-zcn_notifnum  = lv_noti_no.
        ls_attach-content  = lv_string_base64. "is_media_resource-value.
        ls_attach-filename = im_file_name.
        ls_attach-mimetype = 'JPG'.

        CALL METHOD zcl_cloudnative_utility=>meth_crea_attac_notif
          EXPORTING
            im_notif_no    = lv_noti_no
            im_file_ext    = 'JPG'
            im_i_content   = lt_content
            im_file_name   = im_file_name
          IMPORTING
            ex_success_msg = ls_s_msg
            ex_error       = ls_e_msg
            ex_folderid    = ls_folderid.

* Move folder id to entity value
        ls_attach-folder_id  = ls_folderid.

*  "Fill the export parameter er_entity accordingly
        copy_data_to_ref( EXPORTING is_data = ls_attach
                              CHANGING  cr_data = er_entity ).

      CATCH: cx_odata_cv_attach_exception cx_odata_cv_db_exception cx_odata_cv_base_exception INTO lx_cv_attach.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            previous = lx_cv_attach.
    ENDTRY.

  ENDMETHOD.
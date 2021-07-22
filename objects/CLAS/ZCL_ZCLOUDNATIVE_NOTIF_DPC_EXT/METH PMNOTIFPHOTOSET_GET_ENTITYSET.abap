  METHOD pmnotifphotoset_get_entityset.
**TRY.
*CALL METHOD SUPER->PMNOTIFPHOTOSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
    DATA: lv_notif TYPE qmnum.

* IF sy-uname = '90001092'.

*    lv_notif = '000010000410'.

* ELSE.

    TRY.
        DATA(ls_tab) = it_key_tab[ name =  'ZcnNotifnum' ].

        lv_notif = |{ ls_tab-value ALPHA = IN }|.

      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

*ENDIF.

    DATA: ls_key    TYPE /iwbep/s_mgw_name_value_pair,
          lv_noti   TYPE qmnum,
          ls_attach TYPE zcn_notifphoto.

    DATA: lt_attachment TYPE swuoconttab,
          ls_attachment TYPE solisti1,
          ls_att_val    TYPE string.
    DATA: ls_error            TYPE zeamst_error.
    DATA: lv_objkey           TYPE swotobjid-objkey.

    DATA: lt_data TYPE STANDARD TABLE OF bdn_con,
          ls_data TYPE bdn_con.
    CONSTANTS:
      lc_classname            TYPE bapibds01-classname VALUE  'BUS2038'.    " Business Document Service: Class name
***************Old Code **********
****************** data declaration****************************************
**    READ TABLE it_key_tab WITH KEY name = 'Noti_no' INTO ls_key.
**    lv_noti = ls_key-value.
*    IF lv_notif IS NOT INITIAL.
**   Get the document id of the attachment
*      lv_objkey = lv_notif.
*      CALL FUNCTION 'BDS_GOS_CONNECTIONS_GET'
*        EXPORTING
*          classname          = lc_classname                              " Business Document Service: Class Name
*          objkey             = lv_objkey                                 " Object Key
*        TABLES
*          gos_connections    = lt_data                                   " Business Document Navigator: Internal Connection Table
*        EXCEPTIONS
*          no_objects_found   = 1
*          internal_error     = 2
*          internal_gos_error = 3
*          OTHERS             = 4.
*    ENDIF.
*    LOOP AT lt_data INTO ls_data.
*      ls_attach-zcn_notifnum        = lv_notif.
*      "ls_attach-doc_id          = ls_data-loio_id.
*      ls_attach-content    = ls_data-descript.
*      ls_attach-filename       = ls_data-descript.
*      ls_attach-mimetype       = ls_data-docuclass.
*      ls_attach-folder_id  = ls_data-loio_id.
*      APPEND ls_attach TO et_entityset.
*    ENDLOOP.
***** End Old Code *************

*---------
* Get all the NOTE attached to Business object
*---------
*
* buseinss object key
    DATA: gs_lpor TYPE sibflporb.

    TYPES:
      BEGIN OF ts_pmnotifphoto,
        aufnr    TYPE c LENGTH 12,
        qmnum    TYPE qmnum,
        mimetype TYPE c LENGTH 3,
        filename TYPE c LENGTH 50,
        content  TYPE string,
      END OF ts_pmnotifphoto .
    TYPES:
      tt_pmnotifphoto TYPE STANDARD TABLE OF ts_pmnotifphoto .

    DATA: ls_entity           TYPE ts_pmnotifphoto,
          lt_obj_content      TYPE STANDARD TABLE OF solisti1,
          lt_obj_header       TYPE STANDARD TABLE OF solisti1,
          lt_contents_hex     TYPE STANDARD TABLE OF solix,
          ls_document_data    TYPE sofolenti1,
          ls_lpor             TYPE sibflporb,
          lt_relat            TYPE obl_t_relt,
          ls_relat            TYPE obl_s_relt,
          lt_links            TYPE obl_t_link,
          lo_root             TYPE REF TO cx_root   ##NEEDED,
          lv_document_id      TYPE sofolenti1-doc_id,
          lv_xstring_contents TYPE xstring,
          lv_string_base64    TYPE string,
          lv_length           TYPE i,
          lv_len_b            TYPE i.


*
    gs_lpor-instid = lv_notif.
    gs_lpor-typeid = 'BUS2038'.
    gs_lpor-catid  = 'BO'.
*
* attachment type selection
    DATA: "lt_relat TYPE obl_t_relt,
          la_relat LIKE LINE OF lt_relat.
*
    la_relat-sign = 'I'.
    la_relat-option = 'EQ'.
    la_relat-low = 'ATTA'.
    APPEND la_relat TO lt_relat.
*
* Read the links
    DATA: t_links  TYPE obl_t_link,
          la_links LIKE LINE OF t_links.
*
    "DATA: lo_root TYPE REF TO cx_root.
*
    TRY.
        CALL METHOD cl_binary_relation=>read_links
          EXPORTING
            is_object           = gs_lpor
            it_relation_options = lt_relat
          IMPORTING
            et_links            = t_links.
      CATCH cx_root INTO lo_root.
    ENDTRY.
*
    LOOP AT t_links ASSIGNING FIELD-SYMBOL(<ls_link>).
      lv_document_id = <ls_link>-instid_b.

      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id                = lv_document_id          "<= pass  ls_links-instid_b here
        IMPORTING
          document_data              = ls_document_data
        TABLES
          object_header              = lt_obj_header
          object_content             = lt_obj_content
          contents_hex               = lt_contents_hex
        EXCEPTIONS
          document_id_not_exist      = 1
          operation_no_authorization = 2
          x_error                    = 3
          OTHERS                     = 4.
      IF sy-subrc IS INITIAL.

        CLEAR: lv_length.
        LOOP AT lt_contents_hex ASSIGNING FIELD-SYMBOL(<ls_hex>).
          DESCRIBE FIELD <ls_hex> LENGTH lv_len_b IN BYTE MODE.
          lv_length = lv_length + lv_len_b.
        ENDLOOP.

        CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
          EXPORTING
            input_length = lv_length
          IMPORTING
            buffer       = lv_xstring_contents
          TABLES
            binary_tab   = lt_contents_hex
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.
        IF sy-subrc = 0.

          CALL METHOD cl_http_utility=>if_http_utility~encode_x_base64
            EXPORTING
              unencoded = lv_xstring_contents
            RECEIVING
              encoded   = lv_string_base64.

          IF lv_string_base64 IS NOT INITIAL.
            CLEAR: ls_entity.
            ls_attach-zcn_notifnum        = lv_notif.
            "          ls_entity-qmnum    = iv_qmnum.
            ls_attach-content  = lv_string_base64. "lv_xstring_contents
            ls_attach-filename = ls_document_data-obj_descr.
            ls_attach-mimetype = ls_document_data-obj_type.
            ls_attach-folder_id  = ls_document_data-doc_id. "ls_data-loio_id.
            APPEND ls_attach TO et_entityset.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
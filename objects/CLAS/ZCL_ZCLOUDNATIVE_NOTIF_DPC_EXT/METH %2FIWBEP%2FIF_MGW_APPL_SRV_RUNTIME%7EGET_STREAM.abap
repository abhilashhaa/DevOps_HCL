************************************************************
* This method is used to fetch image from notification     *
* and pass the object back to MDK for display purpose      *
************************************************************
  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
**  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
**    it_key_tab              =
**    it_navigation_path      =
**    io_tech_request_context =
**  IMPORTING
**    er_stream               =
**    es_response_context     =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
DATA: ls_key                    TYPE /iwbep/s_mgw_name_value_pair.
    DATA: lv_ord_no                 TYPE aufnr.
    DATA: lv_noti_no                TYPE qmnum.
    DATA: lv_doc_id                 TYPE bds_docid.
    DATA: lt_attachment      TYPE swuoconttab,
          lt_attachment_bin  TYPE solix_tab,
          lt_attachment_list TYPE zeamt_attachment_list,
          ls_attachment_list TYPE zeams_attachment_list,
          ls_attachment      TYPE solisti1,
          ls_attachment_bin  TYPE solix,
          ls_att_val         TYPE xstring.
    DATA: ls_error       TYPE zeamst_error,
          ls_lheader     TYPE ihttpnvp,
          ls_doc_data    TYPE sofolenti1,
          ls_stream      TYPE ty_s_media_resource,
          lv_filename    TYPE string,
          lv_tab_size    TYPE i,
          lv_xstring_val TYPE xstring.
    DATA: lv_entity_type_name       TYPE string.
    DATA: lt_key_val TYPE /iwbep/t_mgw_name_value_pair,
          ls_key_val TYPE /iwbep/s_mgw_name_value_pair.
    DATA: ls_navigation_path        TYPE /iwbep/s_mgw_navigation_path.

    TRY.

        DATA(ls_tab) = it_key_tab[ name = 'ZcnNotifnum' ].

        lv_noti_no = |{ ls_tab-value ALPHA = IN }|.

        lv_doc_id = it_key_tab[ name = 'FolderId' ]-value.

        IF lv_noti_no IS NOT INITIAL
            AND lv_doc_id IS NOT INITIAL.
          CALL METHOD me->convert_attachment_xstring
            EXPORTING
              iv_qmnum      = lv_noti_no
              iv_doc_id     = lv_doc_id
            IMPORTING
              ev_xstr_val   = lv_xstring_val
              et_attach_bin = lt_attachment_bin.
          ls_stream-mime_type = 'IMAGE/JPEG'.
          ls_stream-value = lv_xstring_val. "ls_att_val.
          copy_data_to_ref( EXPORTING is_data = ls_stream
                            CHANGING  cr_data = er_stream ).
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  endmethod.
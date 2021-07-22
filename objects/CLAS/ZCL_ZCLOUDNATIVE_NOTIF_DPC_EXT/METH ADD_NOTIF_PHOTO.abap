  method ADD_NOTIF_PHOTO.
   DATA: lt_contents_hex     TYPE STANDARD TABLE OF solix,
          lt_return           TYPE STANDARD TABLE OF bapiret2,
          ls_fol_id           TYPE soodk,
          ls_obj_data         TYPE sood1,
          ls_document_id      TYPE soodk,
          ls_obj_display      TYPE sood2      ##NEEDED,
          ls_folmem_k         TYPE sofmk,
          ls_object           TYPE borident,
          ls_note             TYPE borident,
          ls_return           TYPE bapiret2,
          lv_xstring_contents TYPE xstring,
          lv_length           TYPE i.


**Check if Photo Attached for upload
    IF it_notif2photo IS INITIAL.
      RETURN.
    ENDIF.

**Get GOS Folder Details
    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
      EXPORTING
        region                = 'B'
      IMPORTING
        folder_id             = ls_fol_id
      EXCEPTIONS
        communication_failure = 1
        owner_not_exist       = 2
        system_failure        = 3
        x_error               = 4
        OTHERS                = 5.
    IF sy-subrc IS NOT INITIAL.
      CLEAR: ls_return.
      ls_return-id         = sy-msgid.
      ls_return-number     = sy-msgno.
      ls_return-type       = sy-msgty.
      ls_return-message_v1 = sy-msgv1.
      ls_return-message_v2 = sy-msgv2.
      ls_return-message_v3 = sy-msgv3.
      ls_return-message_v4 = sy-msgv4.
      APPEND ls_return TO lt_return.

**Raise error
      "me->raise_error_from_bapi( it_return = lt_return ).
    ENDIF.


    LOOP AT it_notif2photo ASSIGNING FIELD-SYMBOL(<ls_photo>).

**Convert Base64 to XString Format
      CALL METHOD cl_http_utility=>if_http_utility~decode_x_base64
        EXPORTING
          encoded = <ls_photo>-content
        RECEIVING
          decoded = lv_xstring_contents.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer        = lv_xstring_contents
        IMPORTING
          output_length = lv_length
        TABLES
          binary_tab    = lt_contents_hex.

**Object Key
      ls_object-objtype = 'BUS2038'."gc_bo_typeid.
      ls_object-objkey  = iv_qmnum.

**Object Data
      ls_obj_data-objsns   = 'O'.
      ls_obj_data-objla    = sy-langu.
      ls_obj_data-objdes   = <ls_photo>-filename.
      ls_obj_data-file_ext = <ls_photo>-mimetype.
      ls_obj_data-objlen   = lv_length.

**Upload Object
      CALL FUNCTION 'SO_DOCUMENT_INSERT'
        EXPORTING
          parent_id                  = ls_fol_id
          object_hd_change           = ls_obj_data
          document_type              = 'EXT'
        IMPORTING
          document_id                = ls_document_id
          object_hd_display          = ls_obj_display
        TABLES
          objcont_bin                = lt_contents_hex
        EXCEPTIONS
          active_user_not_exist      = 1
          dl_name_exist              = 2
          folder_not_exist           = 3
          folder_no_authorization    = 4
          object_type_not_exist      = 5
          operation_no_authorization = 6
          owner_not_exist            = 7
          parameter_error            = 8
          substitute_not_active      = 9
          substitute_not_defined     = 10
          x_error                    = 11
          OTHERS                     = 12.
      IF sy-subrc IS NOT INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

**Raise error
        CLEAR: ls_return.
        ls_return-id         = sy-msgid.
        ls_return-number     = sy-msgno.
        ls_return-type       = sy-msgty.
        ls_return-message_v1 = sy-msgv1.
        ls_return-message_v2 = sy-msgv2.
        ls_return-message_v3 = sy-msgv3.
        ls_return-message_v4 = sy-msgv4.
        APPEND ls_return TO lt_return.

        "me->raise_error_from_bapi( it_return = lt_return ).
      ENDIF.

      IF ls_object-objkey IS NOT INITIAL.

        ls_folmem_k-foltp = ls_fol_id-objtp.
        ls_folmem_k-folyr = ls_fol_id-objyr.
        ls_folmem_k-folno = ls_fol_id-objno.
        ls_folmem_k-doctp = ls_document_id-objtp.
        ls_folmem_k-docyr = ls_document_id-objyr.
        ls_folmem_k-docno = ls_document_id-objno.

        ls_note-objtype = 'MESSAGE'.
        ls_note-objkey = ls_folmem_k.

        CALL FUNCTION 'BINARY_RELATION_CREATE'
          EXPORTING
            obj_rolea      = ls_object
            obj_roleb      = ls_note
            relationtype   = 'ATTA'
          EXCEPTIONS
            no_model       = 1
            internal_error = 2
            unknown        = 3
            OTHERS         = 4.
        IF sy-subrc IS NOT INITIAL.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

**Raise error
          CLEAR: ls_return.
          ls_return-id         = sy-msgid.
          ls_return-number     = sy-msgno.
          ls_return-type       = sy-msgty.
          ls_return-message_v1 = sy-msgv1.
          ls_return-message_v2 = sy-msgv2.
          ls_return-message_v3 = sy-msgv3.
          ls_return-message_v4 = sy-msgv4.
          APPEND ls_return TO lt_return.

          "me->raise_error_from_bapi( it_return = lt_return ).

        ENDIF.
      ENDIF.

    ENDLOOP.

  endmethod.
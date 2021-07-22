  method METH_DISPLAY_NOTIF_ATTACHMENT.



*&------------------Constant variables---------------------------------*
    CONSTANTS:
      lc_classname       TYPE bapibds01-classname VALUE  'BUS2038'.    " Business Document Service: Class name
*&---------------------------------------------------------------------*

*&------------------Local variable declarations------------------------*
    DATA:
      lv_document_id TYPE sofolenti1-doc_id,                       " Folder Entry ID (Obj+Fol+Forwarder Name)
      lv_objkey      TYPE swotobjid-objkey.                        " Object key
*&---------------------------------------------------------------------*

*&------------------Local work area declarations-----------------------*
    DATA:
      lst_data     TYPE bdn_con,                                 " Numeric field length 8
      lst_doc_data TYPE sofolenti1.                              " Document attributes
*&---------------------------------------------------------------------*

*&------------------Local Internal table declarations------------------*
    DATA:
      li_data            TYPE STANDARD TABLE OF bdn_con,               " Numeric field length 8
      li_header          TYPE STANDARD TABLE OF solisti1,              " Text field length 255: texts
      li_content         TYPE STANDARD TABLE OF solisti1,              " Text field length 255: texts
      li_attachment_list TYPE STANDARD TABLE OF soattlsti1,            " SAPoffice: Structure of Attachments List
      li_contents_hex    TYPE STANDARD TABLE OF solix.                 " Binary data
*&---------------------------------------------------------------------*
    CLEAR: lst_doc_data,
           ex_error,
           contents_hex,
           doc_data,
           ex_attachment_list.

*   Copy the WO number in the local variable due to type casting
    lv_objkey = im_qmnum.

*   Get the document id of the attachment
    CALL FUNCTION 'BDS_GOS_CONNECTIONS_GET'
      EXPORTING
        classname          = lc_classname                              " Business Document Service: Class Name
        objkey             = lv_objkey                                 " Object Key
      TABLES
        gos_connections    = li_data                                   " Business Document Navigator: Internal Connection Table
      EXCEPTIONS
        no_objects_found   = 1
        internal_error     = 2
        internal_gos_error = 3
        OTHERS             = 4.

    IF sy-subrc EQ 0.
      LOOP AT li_data INTO lst_data.
        IF xdoc_id IS NOT INITIAL.
          MOVE xdoc_id TO lv_document_id.
        ELSE.
          MOVE lst_data-loio_id TO lv_document_id.
        ENDIF.

*       Get the attachment data in binary format
        CALL FUNCTION 'SO_DOCUMENT_READ_API1'
          EXPORTING
            document_id                = lv_document_id                " ID of folder entry to be viewed
          IMPORTING
            document_data              = lst_doc_data
          TABLES
            object_header              = li_header                     " Header data for document (spec.header)
            object_content             = li_content                    " Document Content
            attachment_list            = li_attachment_list            " Table with attachments for document
            contents_hex               = li_contents_hex
          EXCEPTIONS
            document_id_not_exist      = 1
            operation_no_authorization = 2
            x_error                    = 3
            OTHERS                     = 4.

        IF sy-subrc <> 0.
          CALL METHOD me->meth_fill_error_message
            EXPORTING
              im_message =
                           'No Document id exist'(030)
            IMPORTING
              ex_error   = ex_error.                                   " Error return table
        ELSE.
          contents_hex = li_contents_hex. "single record
          doc_data     = lst_doc_data.    "single record
*Move the result to attachment list - will be used for mobilie offline
*          lst_att_list-doc_data = lst_doc_data.
*          lst_att_list-con_hex  = li_contents_hex.
*          lst_att_list-obj_con  = li_content.
*          APPEND lst_att_list TO ex_attachment_list.

*          LOOP AT li_content INTO lst_content.                        " No need to convert char
*            APPEND lst_content TO ex_attachment.
*          ENDLOOP.                                                     " Create the exporting table in binary data
        ENDIF.                                                         " Check if the document id exist or not
        IF xdoc_id IS NOT INITIAL.                                     " exit loop if document id passed
          EXIT.
        ENDIF.
      ENDLOOP.                                                         " Loop on the document id's
    ELSE.
      CALL METHOD me->meth_fill_error_message
        EXPORTING
          im_message =
                       'No Attachment found for the Work order'(031)
        IMPORTING
          ex_error   = ex_error.                                       " Error return table
    ENDIF.

  endmethod.
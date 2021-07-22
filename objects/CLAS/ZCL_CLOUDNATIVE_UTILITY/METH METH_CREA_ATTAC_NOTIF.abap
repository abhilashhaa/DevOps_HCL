  METHOD meth_crea_attac_notif.
************************************************************************
*                        ALL RIGHTS RESERVED                           *
************************************************************************
*----------------------------------------------------------------------*
* PROGRAM NAME       : Class ZEAMCL_CRT_UPD_MOBILITY and method        *
*                      METH_CREA_ATTAC_NOTIF                           *
* PROGRAM DESCRIPTION: This method is called to create attachment for  *
*                      notification created from mobile                *
* DEVELOPER          : Ajay Mukkasa/Luciano Lopez                      *
* CREATION DATE      : 03-15-2016                                      *
* OBJECT ID          : N/A                                             *
* TRANSPORT NUMBER(S): N/A                                             *
*----------------------------------------------------------------------*

* REVISION HISTORY-----------------------------------------------------*
* REVISION NO  : REV. NO. / <TRANSPORT NO>                             *
* REFERENCE NO : <DER OR TPR OR SCR>                                   *
* DEVELOPER    :                                                       *
* DATE         : YYYY-MM-DD                                            *
* DESCRIPTION  :                                                       *
*----------------------------------------------------------------------*
*-------------------------------CONSTANTS------------------------------*
    CONSTANTS :
      lc_objtyp_notif TYPE swo_objtyp VALUE 'BUS2038',                 " Object type Service notification Orig BUS2080
      lc_objtp        TYPE so_obj_tp  VALUE 'EXT',                     " Object type External
      lc_length       TYPE int3       VALUE '255',                     " Total length
      lc_objtyp_att   TYPE swo_objtyp VALUE 'MESSAGE',                 " Object type Message
      lc_error        TYPE bapi_mtype VALUE 'E'.                       " Message type: E Error
*      lc_one          TYPE char1      VALUE '1'.                       " Counter addition

*----------------------------------------------------------------------*

*--------------------------------VARIABLES-----------------------------*
    DATA: lv_ep_note    TYPE swo_typeid,                               " Object key
          lv_message    TYPE bapi_msg,                                 " Error message
          lv_number     TYPE char1,                                    " Counter for attachments
          lv_short_text TYPE longtext,                                 " Description
          lv_tran_type  TYPE char01.                                   " Transaction Type
*----------------------------------------------------------------------*

*-------------------------------STRUCTURES-----------------------------*
    DATA:
*      lst_content     TYPE soli,                                       " Structure of length 255
*      lst_content_tmp TYPE soli,                                       " Structure of length 255
      lst_fol_id      TYPE soodk,                                      " Structure Definition of an Object
      lst_obj_data    TYPE sood1,                                      " Structure object definition, change attributes
      lst_obj_id      TYPE soodk,                                      " Structure definition of an Object (Key Part)
      lst_folmem_k    TYPE sofmk,                                      " Structure folder contents (key part)
      lst_object      TYPE borident,                                   " Structure Object Relationship Service: BOR object identifier
      lst_note        TYPE borident,                                   " Structure Object Relationship Service: BOR object identifier
      lst_return      TYPE bapiret2,                                   " Structure Return message

*----------------------------------------------------------------------*

*-----------------------------INTERNAL TABLES--------------------------*
      li_objhead      TYPE STANDARD TABLE OF soli     INITIAL SIZE 0,  " Internal Table for object header
      li_content      TYPE STANDARD TABLE OF soli     INITIAL SIZE 0,  " Internal Table for attachment content
*      li_content_tmp  TYPE STANDARD TABLE OF soli     INITIAL SIZE 0,  " Internal Table for attachment content
      li_final_ret    TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.  " Internal Table for final error return
*----------------------------------------------------------------------*
    CLEAR : ex_success_msg,
            ex_error.


*   Check if the input parameters are not passed
    IF im_i_content IS NOT INITIAL
   AND im_notif_no  IS NOT INITIAL
   AND im_file_ext  IS NOT INITIAL.

      li_content[] = im_i_content[].                                   " Internal table with multiple attachment files

*     Convert into binary data
      CALL FUNCTION 'SO_CONVERT_CONTENTS_BIN'
        EXPORTING
          it_contents_bin = li_content                                 " Data file to be uploaded
        IMPORTING
          et_contents_bin = li_content.                                " Binary file to be uploaded

*     Create root folder id for attachment
      CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
        EXPORTING
          region                = 'B' " zcrscl_ccd_fetch=>gc_fol             " Reg shared folder "B"
        IMPORTING
          folder_id             = lst_fol_id                           " Folder id
        EXCEPTIONS
          communication_failure = 1
          owner_not_exist       = 2
          system_failure        = 3
          x_error               = 4
          OTHERS                = 5.
      IF sy-subrc = 0.
*       Create attachment in root folder
        lst_obj_data-objsns = 'O'.  "zcrscl_ccd_fetch=>gc_objsns.             " O - Standard Attachment
        lst_obj_data-objla = sy-langu.                                 " Language key

        lst_obj_data-objdes = im_file_name.                            " Attachment name for Notification
*        CONCATENATE im_file_name                                       " Attachment name for Notification
*               INTO lst_obj_data-objdes                                " im_notif_no
*       SEPARATED BY space.                                             " Description

        lst_obj_data-file_ext = im_file_ext.                           " JPG
        lst_obj_data-objlen   = lines( li_content ) * lc_length.       " Total length of the content

        CALL FUNCTION 'SO_OBJECT_INSERT'
          EXPORTING
            folder_id                  = lst_fol_id                    " Folder id
            object_hd_change           = lst_obj_data                  " Structure for obj data
            object_type                = lc_objtp                      " Object type EXT
          IMPORTING
            object_id                  = lst_obj_id                    " Object ID
          TABLES
            objcont                    = li_content                    " Object contents
            objhead                    = li_objhead                    " Specific header of object
          EXCEPTIONS
            active_user_not_exist      = 1
            communication_failure      = 2
            component_not_available    = 3
            dl_name_exist              = 4
            folder_not_exist           = 5
            folder_no_authorization    = 6
            object_type_not_exist      = 7
            operation_no_authorization = 8
            owner_not_exist            = 9
            parameter_error            = 10
            substitute_not_active      = 11
            substitute_not_defined     = 12
            system_failure             = 13
            x_error                    = 14
            OTHERS                     = 15.
        IF sy-subrc = 0.
*         Get object details for folder id
          lst_folmem_k-foltp = lst_fol_id-objtp.                       " Code for document class
          lst_folmem_k-folyr = lst_fol_id-objyr.                       " Object: Year from ID
          lst_folmem_k-folno = lst_fol_id-objno.                       " Object: Number from ID

*         Get object details for object id
          lst_folmem_k-doctp = lst_obj_id-objtp.                       " Code for document class
          lst_folmem_k-docyr = lst_obj_id-objyr.                       " Object: Year from ID
          lst_folmem_k-docno = lst_obj_id-objno.                       " Object: Number from ID

*         SAP office: folder contents (key part)
          lv_ep_note         = lst_folmem_k.                           " SAP office: folder contents (key part)
          lst_note-objtype   = lc_objtyp_att.                          " Message
          lst_note-objkey    = lv_ep_note.                             " Object key

*         Pass folder ID to main create stream
          ex_folderid        = lst_fol_id.

*         Create link between attachment and the notification
*         documents

          CLEAR lst_object.
          lst_object-objtype      = lc_objtyp_notif.                   " Service Notification BO BUS2080
          lst_object-objkey       = im_notif_no.                       " Service Notification number

          CALL FUNCTION 'BINARY_RELATION_CREATE_COMMIT'
            EXPORTING
              obj_rolea      = lst_object                              " Role Object A
              obj_roleb      = lst_note                                " Role Object B
              relationtype   = 'ATTA'  "zcrscl_ccd_fetch=>gc_reltype   " ATTA
            EXCEPTIONS
              no_model       = 1
              internal_error = 2
              unknown        = 3
              OTHERS         = 4.
          IF sy-subrc = 0.
            ex_success_msg = 'Attachment created successfully.'(003).
          ELSE.                                                        " If binary relation creation fails
*           Clear the success message if error occurs
            CLEAR ex_success_msg.

*           Prepare Error return table
            CONCATENATE 'Attachment creation failed for #'(004)
                        im_notif_no                                    " Notification number
                   INTO lv_message                                     " Error message
           SEPARATED BY space.

            lst_return-type    = lc_error.                             " Message type
            lst_return-message = lv_message.                           " Error Message
            APPEND lst_return TO li_final_ret.

*           Clear the temporary message
            CLEAR: lv_message,
                   lst_return.
          ENDIF.                                                       " IF sy-subrc = 0, Binary relation creation
        ELSE.                                                          " IF Object creation fails
*         Clear the success message if error occurs
          CLEAR ex_success_msg.

*         Prepare Error return table
          CONCATENATE 'Attachment creation failed for #'(004)
                      im_notif_no                                      " Notification number
                 INTO lv_message                                       " Error message
         SEPARATED BY space.

          lst_return-type    = lc_error.                               " Message type
          lst_return-message = lv_message.                             " Error Message
          APPEND lst_return TO li_final_ret.

*         Clear the temporary message
          CLEAR: lv_message,
                 lst_return.
        ENDIF.                                                         " IF sy-subrc = 0, Object insertion
      ELSE.                                                            " Folder creation fails
*       Clear the success message if error occurs
        CLEAR ex_success_msg.

*       Prepare Error return table
        CONCATENATE 'Attachment creation failed for #'(004)
                    lv_number                                          " Number of attacment
               INTO lv_message                                         " Error message
       SEPARATED BY space.

        lst_return-type    = lc_error.                                 " Message type
        lst_return-message = lv_message.                               " Error Message
        APPEND lst_return TO li_final_ret.

*       Clear the temporary message
        CLEAR: lv_message,
               lst_return.
      ENDIF.                                                           " if sy-subrc = 0, Folder creation .

*     Clear contents of the file after file is attached
      CLEAR : li_content[].

*     Clear all the structures for further attachment process
      CLEAR : lst_fol_id,
              lst_obj_data,
              lst_obj_id,
              lst_folmem_k,
              lst_object,
              lst_note,
              lst_return.
    ELSE.                                                              " If Input parameters are initial
*     CALL METHOD to fill the error messages
      zcl_cloudnative_utility=>meth_fill_error_message(
      EXPORTING
        im_message = 'Input Parameters are blank.'(005)
      IMPORTING
        ex_error   = ex_error ).                                       " Error return table
    ENDIF.                                                             " IF im_i_content AND im_notif_no IS NOT INITIAL.

    IF li_final_ret IS NOT INITIAL.
      lv_short_text  = 'Notification Attachment creation failed'(040).
      lv_tran_type   = '6'.                                             " Transaction type 6
*     Update error message in custome table
      CALL METHOD ZCL_CLOUDNATIVE_UTILITY=>meth_error_handling
        EXPORTING
          im_notification  = im_notif_no
          im_short_text    = lv_short_text
          im_long_text     = li_final_ret
          im_tran_type     = lv_tran_type.
*     Populate exporting parameter with messages collected
*     but continue further processing
      ZCL_CLOUDNATIVE_UTILITY=>meth_fill_error_message(
        IMPORTING
          ex_error   = ex_error
        CHANGING
          ch_bapiret = li_final_ret ).

      CLEAR li_final_ret[].
    ENDIF.
  ENDMETHOD.
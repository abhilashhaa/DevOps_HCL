  method CONVERT_ATTACHMENT_XSTRING.

  DATA: lt_attachment_bin  TYPE solix_tab,
          lt_attachment_list TYPE zeamt_attachment_list.
    DATA: ls_error    TYPE zeamst_error,
          ls_doc_data TYPE sofolenti1.
    DATA:  lv_tab_size TYPE i.

    IF iv_qmnum IS NOT INITIAL
       AND iv_doc_id IS NOT INITIAL.
      CLEAR: ls_error, lt_attachment_bin, lt_attachment_list.

      CALL METHOD me->METH_DISPLAY_NOTIF_ATTACHMENT
        EXPORTING
          im_qmnum     = iv_qmnum
          xdoc_id      = iv_doc_id
        IMPORTING
          ex_error     = ls_error
          contents_hex = et_attach_bin
          doc_data     = ls_doc_data.

      CLEAR: lv_tab_size.
      lv_tab_size = ls_doc_data-doc_size.
*convert binary to xstring
      CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = lv_tab_size
        IMPORTING
          buffer       = ev_xstr_val
        TABLES
          binary_tab   = et_attach_bin
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.
    ENDIF.

  endmethod.
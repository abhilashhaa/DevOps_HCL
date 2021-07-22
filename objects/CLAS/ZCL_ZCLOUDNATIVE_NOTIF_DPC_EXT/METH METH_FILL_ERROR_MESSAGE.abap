  method METH_FILL_ERROR_MESSAGE.


*&--------------------------WORK AREA----------------------------------*
    DATA : lst_errormsg TYPE bapi_msg,                                 " Error Message Work Area
           lst_bapiret  TYPE bapiret2,                                 " BAPI Return Work Area
*----------------------------------------------------------------------*

*&-----------------------INTERNAL TABLES-------------------------------*
           li_errormsg  TYPE STANDARD TABLE OF bapi_msg
                        INITIAL SIZE 0.                                " Error Message Table
*&---------------------------------------------------------------------*

*     Initialize Exporting parameter
      CLEAR ex_error.

*   Fill suitable Error Message from structure, table or Message Text
*   Message Text
    IF im_message IS NOT INITIAL.
      lst_errormsg = im_message.                                       " Error Message
      APPEND lst_errormsg TO li_errormsg.
      CLEAR lst_errormsg.

*   Message Structure
    ELSEIF im_bapiret_st IS NOT INITIAL.
      lst_errormsg = im_bapiret_st-message.                            " Error Message
      APPEND lst_errormsg TO li_errormsg.
      CLEAR lst_errormsg.

*   Message Table
    ELSEIF ch_bapiret IS NOT INITIAL.
      SORT ch_bapiret BY type.
*     Keep messages of type Error only
      DELETE ch_bapiret WHERE type <> 'E'.

*     Populate the Error Table
      LOOP AT ch_bapiret INTO lst_bapiret.
        lst_errormsg = lst_bapiret-message.                            " Error Message
        APPEND lst_errormsg TO li_errormsg.
        CLEAR : lst_errormsg,
                lst_bapiret.
      ENDLOOP.
    ENDIF.                                                             " Check Importing parameters

*   Fill exporting parameter
*   Default the error code to 'Error'
    ex_error-err_code = 'E'.                                           " Error Code - 'E'
    ex_error-err_msgtab = li_errormsg.                                 " Error Message Table

  endmethod.
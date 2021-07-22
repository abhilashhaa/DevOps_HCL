  method METH_ERROR_HANDLING.
*-----------------------TYPES DECLARATION------------------------------*
    TYPES :  BEGIN OF ty_afru,
               rueck TYPE co_rueck,                                    " Completion confirmation number for the operation
               rmzhl TYPE co_rmzhl,                                    " Confirmation counter
               arbid TYPE objektid,                                    " Object ID
               pernr TYPE co_pernr,                                    " Personnel number
               objty TYPE cr_objty,                                    " Object types of the CIM resource
               objid TYPE cr_objid,                                    " Object ID of the resource
               arbpl TYPE arbpl,                                       " Work center
               werks TYPE werks_d,                                     " Plant
             END OF ty_afru.
*----------------------------------------------------------------------*

*----------------------CONSTANTS---------------------------------------*
    CONSTANTS : lc_objty TYPE cr_objty VALUE 'P'.                      " Object Type for Personnel Number
*----------------------------------------------------------------------*

*----------------------VARIABLES---------------------------------------*
    DATA: lv_begda     TYPE p0105-begda,                               " Start Date
          lv_endda     TYPE p0105-endda,                               " End Date
          lv_usrid     TYPE p0105-usrid,                               " Communication Identification/Number
          lv_usrty     TYPE p0105-usrty,                               " Communication Type
          lv_usr_pernr TYPE p0105-pernr,                               " Personnel Number
          lv_werks     TYPE werks_d,                                   " Plant
          lv_long_text TYPE ztext.                                     " Long text
*----------------------------------------------------------------------*

*-------------------------------WORK AREA------------------------------*
    DATA: lst_afru           TYPE ty_afru,
          lst_zcn_zerrorlog  TYPE zcn_zerrorlog,                      " Table to capture all the error logs for update
          lst_return         TYPE bapiret2,                            " zeamt_bapiret2.
          lst_input          TYPE rcrid,
          lst_arbpl          TYPE object_person_assignment.
*----------------------------------------------------------------------*

*-----------------------------INTERNAL TABLES--------------------------*
    DATA : li_afru   TYPE STANDARD TABLE OF ty_afru  INITIAL SIZE 0,
           li_return TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0,
           li_input  TYPE STANDARD TABLE OF rcrid    INITIAL SIZE 0,
           li_arbpl  TYPE STANDARD TABLE OF object_person_assignment
                                                     INITIAL SIZE 0.
*----------------------------------------------------------------------*


    lv_begda = sy-datum.                                               " Start Date
    lv_endda = sy-datum.                                               " End Date
    lv_usrid = sy-uname.                                               " User name
    lv_usrty = '0001'.                                                 " Communication Type
    SHIFT lv_usrid LEFT DELETING LEADING '0'.

    CALL FUNCTION 'RP_GET_PERNR_FROM_USERID'
      EXPORTING
        begda     = lv_begda                                           " Start Date
        endda     = lv_endda                                           " End Date
        usrid     = lv_usrid                                           " User name
        usrty     = lv_usrty                                           " Communication Type
      IMPORTING
        usr_pernr = lv_usr_pernr
      EXCEPTIONS
        retcd     = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
*      SELECT a~rueck,                                                    " Completion confirmation number for the operation
*             a~rmzhl,                                                    " Confirmation counter
*             a~arbid,                                                    " Object ID
*             a~pernr,                                                    " Personnel number
*             b~objty,                                                    " Object types of the CIM resource
*             b~objid,                                                    " Object ID of the resource
*             b~arbpl,                                                    " Work center
*             b~werks                                                     " Plant
*       FROM afru AS a
*        INNER JOIN crhd AS b
*        ON b~objid = a~arbid
*        INTO TABLE @li_afru
*        WHERE pernr EQ @lv_usr_pernr.
*
*      IF li_afru IS NOT INITIAL.
*        READ TABLE li_afru INTO lst_afru INDEX 1.
*      ENDIF.                                                             " IF li_afru IS NOT INITIAL

*     Get the plant maintained in the User Parameters of the User
      CALL METHOD zcl_cloudnative_utility=>meth_get_user_detail
        EXPORTING
          im_userid   = sy-uname                                       " User Name
        IMPORTING
          ex_wrk      = lv_werks.                                      " Maintenance Planning Plant

      lst_input-objty = lc_objty.
      lst_input-objid = lv_usr_pernr.
      APPEND lst_input TO li_input.
*     Call FM 'COI2_WORKCENTER_OF_PERSON' to fetch the assigned to the
*     user
      CALL FUNCTION 'COI2_WORKCENTER_OF_PERSON'
        EXPORTING
          begda                       = sy-datlo                       " Local Date of User
          endda                       = sy-datlo                       " Local Date of User
        TABLES
          in_object                   = li_input                       " Personnel Number data
          out_object                  = li_arbpl                       " Work Center data
        EXCEPTIONS
          no_in_objects               = 1
          invalid_object              = 2
          invalid_hr_planning_variant = 3
          other_error                 = 4
          evaluation_path_not_found   = 5
          OTHERS                      = 6 .

      IF sy-subrc = 0.
        DELETE li_arbpl WHERE werks <> lv_werks.
        SORT li_arbpl DESCENDING BY begda endda.
        READ TABLE li_arbpl INTO lst_arbpl INDEX 1.
      ENDIF.

      li_return = im_long_text.
      LOOP AT li_return INTO lst_return.
        CONCATENATE lv_long_text lst_return-message
        INTO lv_long_text
        SEPARATED BY space.
        CLEAR: lst_return-message.
      ENDLOOP.                                                         " LOOP AT li_return INTO lst_return

      CASE im_tran_type.
        WHEN '1'.
          lst_zcn_zerrorlog-transaction_type
          = 'Create Notification'(028).                                " Transaction type 1
        WHEN '2'.
          lst_ZCn_zerrorlog-transaction_type
          = 'Shell Work Order Update'(029).                            " Transaction type 2
        WHEN '3'.
          lst_zcn_zerrorlog-transaction_type
          = 'Work Order Update'(030).                                  " Transaction type 3
        WHEN '4'.
          lst_zcn_zerrorlog-transaction_type
          = 'Time Confirmation'(031).                                  " Transaction type 4
        WHEN '5'.
          lst_zcn_zerrorlog-transaction_type
          = 'Measurement Document Creation'(032).                      " Transaction type 5
        WHEN '6'.
          lst_zcn_zerrorlog-transaction_type
          = 'Update Notification'(037).                                " Transaction type 6
        WHEN '7'.
          lst_zcn_zerrorlog-transaction_type
          = 'Inspection Results Update'(042).                          " Transaction type 7
        WHEN OTHERS.
      ENDCASE.

      lst_zcn_zerrorlog-requestor            = lv_usrid.              " User Name
      lst_zcn_zerrorlog-log_date             = sy-datum.              " System Date
      lst_zcn_zerrorlog-time                 = sy-uzeit.              " System time
      lst_zcn_zerrorlog-notification         = im_notification.       " Notification Number
      lst_zcn_zerrorlog-work_order           = im_workorder.          " Order Number
      lst_zcn_zerrorlog-plant                = lst_arbpl-werks.       " Plant
      lst_zcn_zerrorlog-work_center          = lst_arbpl-arbpl.       " Work center
      lst_zcn_zerrorlog-inspection_lot       = im_inspec_lot.         " Inspection Lot Number
      lst_zcn_zerrorlog-equipment            = im_equipment.          " Inspection Lot Number
      lst_zcn_zerrorlog-error_log_short_text = im_short_text.         " Short text
      lst_zcn_zerrorlog-error_log_long_text  = lv_long_text.          " Long text

      INSERT ZCN_ZERRORLOG FROM lst_zcn_zerrorlog.
      COMMIT WORK.
      CLEAR: lv_long_text,
             lst_zcn_zerrorlog.
    ENDIF.
  endmethod.
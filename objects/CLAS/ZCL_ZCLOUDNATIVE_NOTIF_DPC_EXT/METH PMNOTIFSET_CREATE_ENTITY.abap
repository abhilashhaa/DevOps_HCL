  method PMNOTIFSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->PMNOTIFSET_CREATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
DATA: ls_request_input_data TYPE ZCL_ZCLOUDNATIVE_NOTIF_MPC=>TS_PMNOTIF,
        ls_header             TYPE BAPI2080_NOTHDRI,
        ls_notif_export       TYPE BAPI2080_NOTHDRE,
        ls_return             TYPE BAPIRET2.

io_data_provider->read_entry_data( IMPORTING es_data = ls_request_input_data ).

ls_header-EQUIPMENT = ls_request_input_data-EQUIPMENT.
ls_header-FUNCT_LOC = ls_request_input_data-FUNCTIONAL_LOCATION.
ls_header-SHORT_TEXT = ls_request_input_data-SHORT_TEXT.
ls_header-NOTIF_DATE = sy-datum.
CALL FUNCTION 'BAPI_ALM_NOTIF_CREATE'
  EXPORTING
*   EXTERNAL_NUMBER                     =
    NOTIF_TYPE                          = 'M1'
    NOTIFHEADER                         = ls_header
*   TASK_DETERMINATION                  = ' '
*   SENDER                              =
*   ORDERID                             =
*   IV_DONT_CHK_MANDATORY_PARTNER       =
*   NOTIFCATION_COPY                    =
*   DOCUMENT_ASSIGN_COPY                = ' '
 IMPORTING
   NOTIFHEADER_EXPORT                  = ls_notif_export
* TABLES
*   NOTITEM                             =
*   NOTIFCAUS                           =
*   NOTIFACTV                           =
*   NOTIFTASK                           =
*   NOTIFPARTNR                         =
*   LONGTEXTS                           =
*   KEY_RELATIONSHIPS                   =
*   RETURN                              =
*   EXTENSIONIN                         =
*   EXTENSIONOUT                        =
          .

CALL FUNCTION 'BAPI_ALM_NOTIF_SAVE'
  EXPORTING
    NUMBER                    = ls_notif_export-NOTIF_NO
*   TOGETHER_WITH_ORDER       = ' '
* IMPORTING
*   NOTIFHEADER               =
* TABLES
*   RETURN                    =
          .
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
* EXPORTING
*   WAIT          =
 IMPORTING
   RETURN        = ls_return
          .

if ls_return is INITIAL.
"++ Code added to populate the Notification number in the response
  ls_request_input_data-ZCN_NOTIFNUM = ls_notif_export-NOTIF_NO.
  er_entity = LS_REQUEST_INPUT_DATA.
  ENDIF.

  endmethod.
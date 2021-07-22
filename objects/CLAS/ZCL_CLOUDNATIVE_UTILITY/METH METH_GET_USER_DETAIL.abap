  method METH_GET_USER_DETAIL.
*&--------------------------TYPES--------------------------------------*
    TYPES:
      BEGIN OF lty_parameter,
        parid TYPE memoryid,                                           " Parameter ID
        parva TYPE xuvalue,                                            " Parameter value
      END OF lty_parameter,

      BEGIN OF lty_parva,
        parva TYPE xuvalue,                                            " Parameter value
      END OF lty_parva,

      BEGIN OF lty_plan,
        iwerk TYPE werks_d,                                            " Plant
        ingrp TYPE ingrp,                                              " Planner Group
      END OF lty_plan.
*&---------------------------------------------------------------------*

*&--------------------------CONSTANTS----------------------------------*
    CONSTANTS:
      lc_dummy         TYPE char5 VALUE 'IW32',                        " Dummy Value
      lc_paridqmr      TYPE char3 VALUE 'QMR',                         " Parameter id - QMR
      lc_paridaai      TYPE char3 VALUE 'AAI',                         " Parameter id - AAI
      lc_paridwrk      TYPE char3 VALUE 'WRK',                         " Parameter id - WRK
      lc_paridifl      TYPE char3 VALUE 'IFL',                         " Parameter id - IFL
      lc_paridpar      TYPE char3 VALUE 'PAR',                         " Parameter id - LAG
      lc_paridzhist    TYPE char8 VALUE 'ZHISTORY',                    " Parameter id - ZHISTORY
      lc_paridzuom     TYPE char4 VALUE 'ZUOM',                        " Parameter id - ZUOM
      lc_delimitcomma  TYPE char1 VALUE ','.                           " Delimiter    - Comma
*&---------------------------------------------------------------------*

*&--------------------------WORK AREA----------------------------------*
    DATA:
      lst_parameter TYPE lty_parameter,                                " User parameter
      lst_parva     TYPE lty_parva,                                    " Parameter value
      lst_rigid     TYPE ZCN_ST_RIGID,                                 " RID id detail
      lst_ingrp     TYPE ingrp,                                        " Planner Group
      lst_plan      TYPE lty_plan,                                     " Planning Data
*&---------------------------------------------------------------------*

*&--------------------------INTERNAL TABLES----------------------------*
      li_parameter  TYPE STANDARD TABLE OF lty_parameter
                    INITIAL SIZE 0,                                    " User Parameters table
      li_parva      TYPE STANDARD TABLE OF lty_parva
                    INITIAL SIZE 0,                                    " Parameter value table
      li_plan       TYPE STANDARD TABLE OF lty_plan
                    INITIAL SIZE 0.                                    " Planning Data
*&---------------------------------------------------------------------*

*   Initialize exporting parameters
    CLEAR:
      ex_notiftyp,
      ex_wotyp,
      ex_wrk,
      ex_ifl,
      ex_lag,
      ex_zhist,
      ex_zuom,
      ex_error,
      ex_ingrp.

*   Get user parameters from USRO5 table
    SELECT parid,                                                      " Parameter id
           parva                                                       " Parameter value
           FROM usr05
           INTO TABLE @li_parameter
           WHERE bname = @im_userid.                                   " SAP User id
    IF sy-subrc NE 0.
*     If no user parameters found, append suitable error message
      CALL METHOD ZCL_CLOUDNATIVE_UTILITY=>meth_fill_error_message
        EXPORTING
          im_message =
                       'No default parameters maintained for the current user'(010)
        IMPORTING
          ex_error   = ex_error.                                       " Error return table
    ENDIF.

*   Loop thru parameter values selected to fill respective exporting
*   parameters
    LOOP AT li_parameter INTO lst_parameter.

      CASE lst_parameter-parid.
        WHEN lc_paridqmr.                                              " Parameter ID - QMR
*         Fill Notification types
          SPLIT lst_parameter-parva AT lc_delimitcomma                 " Demiliter - Comma
                                    INTO TABLE ex_notiftyp.

        WHEN lc_paridaai.                                              " Parameter ID - AAI
*         Fill work order types
          SPLIT lst_parameter-parva AT lc_delimitcomma                 " Delimiter - Comma
                                    INTO TABLE ex_wotyp.

        WHEN lc_paridifl.                                              " Parameter ID - IFL
*         Fill functional location
          SPLIT lst_parameter-parva AT lc_delimitcomma                 " Delimiter - Comma
                                    INTO TABLE ex_ifl.

        WHEN lc_paridwrk.                                              " Parameter ID - WRK
*         Fill Plant
          ex_wrk =  lst_parameter-parva.

        WHEN lc_paridpar.                                              " Parameter ID - PAR
*         Fill Partner details
*         Mulitple sets are separated by comma
          SPLIT lst_parameter-parva AT lc_delimitcomma                 " Delimiter - Comma
                                    INTO TABLE li_parva.

*         Individual partner details are separated by Hyphen
          LOOP AT li_parva INTO lst_parva.
*            SPLIT lst_parva AT lc_delimithyphen                        " Delimiter - Hyphen '-'
*                           INTO: lst_rigid-parvw                       " Partner Function
*                                 lst_rigid-parnr                       " Partner Number
*                                 lst_rigid-pardesc.                    " Partner description
            lst_rigid-parvw   =  lst_parva+0(2).  " Partner Function
*getting conversion short dump due to special character '-' adding below logic to remove it
            REPLACE ALL OCCURRENCES OF '-' IN lst_parva WITH space.
            CONDENSE lst_parva+2(38).

            lst_rigid-parnr   =   lst_parva+2(38). " Partner Number
            APPEND lst_rigid TO ex_lag.
            CLEAR: lst_parva,
                   lst_rigid.
          ENDLOOP.                                                     " Loop at LI_PARVA
          CLEAR li_parva.

        WHEN lc_paridzhist.                                            " Parameter ID - ZHIST
*         Fill number of history records to be returned for the user
          ex_zhist = lst_parameter-parva.

        WHEN lc_paridzuom.                                             " Parameter ID - ZUOM
*         Fill Unit of measure
          ex_zuom = lst_parameter-parva.

        WHEN OTHERS.
      ENDCASE.                                                         " CASE lst_parametr-parid
*     Clearing local entities
      CLEAR lst_parameter.
    ENDLOOP.

*   Fetch all the Planner Group based on the Maintenance Planning Plant
*   assigned to the user
    SELECT a~iwerk,                                                    " Maintenance Planning Plant
           i~ingrp                                                     " Planner Group
      FROM t001w AS a
      INNER JOIN t024i AS i
      ON i~iwerk = a~iwerk
      INTO TABLE @li_plan
      WHERE a~werks = @ex_wrk.                                          " Maintenance Planning Plant
      IF sy-subrc = 0.
        LOOP AT li_plan INTO lst_plan.
          ex_iwerk = lst_plan-iwerk.
*          AUTHORITY-CHECK OBJECT 'I_INGRP'
*                              ID 'TCD'    FIELD lc_dummy
*                              ID 'IWERK'  FIELD lst_plan-iwerk
*                              ID 'INGRP'  FIELD lst_plan-ingrp.
          IF sy-subrc = 0.
            lst_ingrp = lst_plan-ingrp.
            APPEND lst_ingrp TO ex_ingrp.
          ENDIF.
        ENDLOOP.
      ENDIF.

  endmethod.
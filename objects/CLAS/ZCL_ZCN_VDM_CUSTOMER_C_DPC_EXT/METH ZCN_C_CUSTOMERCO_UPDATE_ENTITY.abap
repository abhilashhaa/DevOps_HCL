  method ZCN_C_CUSTOMERCO_UPDATE_ENTITY.
    DO.
      ENDDO.
**TRY.
*CALL METHOD SUPER->ZCN_C_CUSTOMERCO_UPDATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    IO_TECH_REQUEST_CONTEXT =
*    IT_NAVIGATION_PATH      =
**    IO_DATA_PROVIDER        =
**  IMPORTING
**    ER_ENTITY               =
*    .
** CATCH /IWBEP/CX_MGW_BUSI_EXCEPTION .
** CATCH /IWBEP/CX_MGW_TECH_EXCEPTION .
**ENDTRY.
  endmethod.
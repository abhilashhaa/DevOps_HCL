*******************************************************************
*   THIS FILE IS GENERATED BY THE FUNCTION LIBRARY.               *
*   NEVER CHANGE IT MANUALLY, PLEASE!                             *
*******************************************************************
FUNCTION $$UNIT$$ CONVERT_SELECT_INTO_WHERE

    IMPORTING
       VALUE(SELECT_TABLENAME) LIKE !DFIES-TABNAME
    TABLES
       !IN_SELECT_FIELDS STRUCTURE !SEL_TABLE
       !OUT_WHERE_COND STRUCTURE !WHERE_TAB
    EXCEPTIONS
       !WRONG_INPUT_DATA .
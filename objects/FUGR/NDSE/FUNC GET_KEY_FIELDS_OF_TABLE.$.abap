*******************************************************************
*   THIS FILE IS GENERATED BY THE FUNCTION LIBRARY.               *
*   NEVER CHANGE IT MANUALLY, PLEASE!                             *
*******************************************************************
FUNCTION $$UNIT$$ GET_KEY_FIELDS_OF_TABLE

         IMPORTING
               VALUE(TABNAME) LIKE !DFIES-TABNAME
               VALUE(MANDT_NEEDED) DEFAULT SPACE
         TABLES
               !KEY_FIELDTAB STRUCTURE !DFIES
         EXCEPTIONS
!NOT_SUPPORTED .
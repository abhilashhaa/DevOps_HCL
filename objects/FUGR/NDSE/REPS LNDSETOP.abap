FUNCTION-POOL NDSE.                         "MESSAGE-ID ..
*-------------Transparente Tabellen------------------------------------*

*-------------Strukturen-----------------------------------------------*

*-------------Interne Tabellen-----------------------------------------*
* DDIC-Informationen zur Struktur von DB-Tabellen
DATA: T_DFIES LIKE DFIES OCCURS 0 WITH HEADER LINE.

*-------------Einzelfelder---------------------------------------------*
DATA: PREFIX(12).      "\BE Note 400837 (auf 12 Byte verlängert)
DATA: OPTION(10).

*-------------Konstanten-----------------------------------------------*
CONSTANTS: MAX_DFIES      LIKE SY-TABIX            VALUE 1000.
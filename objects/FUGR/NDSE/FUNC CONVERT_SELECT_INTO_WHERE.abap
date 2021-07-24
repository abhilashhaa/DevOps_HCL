FUNCTION CONVERT_SELECT_INTO_WHERE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(SELECT_TABLENAME) LIKE  DFIES-TABNAME
*"  TABLES
*"      IN_SELECT_FIELDS STRUCTURE  SEL_TABLE
*"      OUT_WHERE_COND STRUCTURE  WHERE_TAB
*"  EXCEPTIONS
*"      WRONG_INPUT_DATA
*"----------------------------------------------------------------------
*
* Anmerkungen/Informationen:
* - Bei dynam. WHERE-Klausel dürfen keine Ausdrücke wie
*   KUNNR IN KUNNR_RANGE enthalten sein, d.h. ein Auflösen von RANGES
*   durch die Datenbank-Schnittstelle ist nicht möglich.
* - Bei RANGES mit EQ, BT, ... wird '*' bzw. '+' nicht als generisches
*   Suchzeichen interpretiert (nur bei CP).

* nimmt Selektionskriterien zur gewünschten Tabelle auf.
DATA: LT_SELECT_FIELDS LIKE SEL_TABLE OCCURS 0 WITH HEADER LINE.
* nimmt eine Zeile einer Where-Bedingung auf
DATA: L_WHERE_COND LIKE WHERE_TAB.
DATA: L_WHERE_COND_LONG LIKE WHERE_TAB. "note 430415
* Hilfsfeld, nimmt Namen eines Tabellenfeldes auf.
DATA: L_HFIELD LIKE DNTAB-FIELDNAME.

* Rückgabetabelle löschen
 REFRESH OUT_WHERE_COND.

* Einschränken auf relevante Tabelle
 LOOP AT IN_SELECT_FIELDS WHERE TABLE = SELECT_TABLENAME.
   IF IN_SELECT_FIELDS-SIGN = 'E'.
     IN_SELECT_FIELDS-SIGN = 'I'.
     CASE IN_SELECT_FIELDS-OPTION.
       WHEN 'EQ'.
         IN_SELECT_FIELDS-OPTION = 'NE'.
       WHEN 'NE'.
         IN_SELECT_FIELDS-OPTION = 'EQ'.
       WHEN 'BT'.
         IN_SELECT_FIELDS-OPTION = 'NB'.
       WHEN 'NB'.
         IN_SELECT_FIELDS-OPTION = 'BT'.
       WHEN 'CP'.
         IN_SELECT_FIELDS-OPTION = 'NP'.
       WHEN 'NP'.
         IN_SELECT_FIELDS-OPTION = 'CP'.
       WHEN 'LT'.
         IN_SELECT_FIELDS-OPTION = 'GE'.
       WHEN 'GE'.
         IN_SELECT_FIELDS-OPTION = 'LT'.
       WHEN 'GT'.
         IN_SELECT_FIELDS-OPTION = 'LE'.
       WHEN 'LE'.
         IN_SELECT_FIELDS-OPTION = 'GT'.
     ENDCASE.
   ENDIF.
   APPEND IN_SELECT_FIELDS TO LT_SELECT_FIELDS.
 ENDLOOP.

* Sicherstellen, daß die negierenden (ausschließenden) Optionen am
* Ende kommen (-> beginnen alle mit 'N').
 SORT LT_SELECT_FIELDS BY FIELD OPTION.    "Note 403033

 LOOP AT LT_SELECT_FIELDS.
*   Prüfen, ob die übergebenen Daten sinnvoll sind
    PERFORM CHECK_EINGABEN USING LT_SELECT_FIELDS.
* Aufbau der Where-Bedingung (pro Zeile)
    PERFORM WHERE_COND_AUFBAUEN USING    LT_SELECT_FIELDS
                                CHANGING L_WHERE_COND
                                         L_WHERE_COND_LONG
                                         L_HFIELD.

    APPEND L_WHERE_COND TO OUT_WHERE_COND.
    IF not L_WHERE_COND_LONG is initial.
      APPEND L_WHERE_COND_LONG TO OUT_WHERE_COND.
    ENDIF.

 ENDLOOP.

* Die WHERE-Bedingung zur letzten Tabelle abschließen
  IF SY-SUBRC = 0.
     L_WHERE_COND-ZEILE = ')' .
     APPEND L_WHERE_COND TO OUT_WHERE_COND.
  ENDIF.

ENDFUNCTION.
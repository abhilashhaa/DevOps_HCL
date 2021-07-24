FUNCTION CHECK_SUPPORTED_FIELD.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(TABNAME) LIKE  DFIES-TABNAME
*"             VALUE(FIELDNAME) LIKE  DFIES-FIELDNAME
*"       EXCEPTIONS
*"              NOT_SUPPORTED
*"----------------------------------------------------------------------

* Felder der Tabellen prüfen
* Prüfen, ob DDIC-Infos zur Tabellenstruktur schon gelesen wurden
  READ TABLE T_DFIES WITH KEY TABNAME = TABNAME
                              FIELDNAME = FIELDNAME
                     BINARY SEARCH.
  CHECK SY-SUBRC NE 0.

* Noch nicht gefunden ==> Nachlesen und in T_DFIES aufnehmen
  PERFORM NACHLESEN_TAB_FELDER_DFIES  USING TABNAME.

  READ TABLE T_DFIES WITH KEY TABNAME   = TABNAME
                              FIELDNAME = FIELDNAME
                     BINARY SEARCH.
  IF SY-SUBRC NE 0.
     MESSAGE E005(AZ) WITH FIELDNAME TABNAME
                      RAISING NOT_SUPPORTED.
*   Das Feld &1 ist in Tabelle &2 nicht vorhanden.
  ENDIF.


ENDFUNCTION.
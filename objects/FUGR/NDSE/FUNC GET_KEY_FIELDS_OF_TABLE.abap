FUNCTION GET_KEY_FIELDS_OF_TABLE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(TABNAME) LIKE  DFIES-TABNAME
*"             VALUE(MANDT_NEEDED) DEFAULT SPACE
*"       TABLES
*"              KEY_FIELDTAB STRUCTURE  DFIES
*"       EXCEPTIONS
*"              NOT_SUPPORTED
*"----------------------------------------------------------------------
* Key-Felder der Tabelle zurückliefern (es wird davon ausgegangen,
* daß zu jeder Tabelle mindestens ein Key-Feld existiert)

DATA: LOK_TABIX LIKE SY-TABIX.

* Eingabetabelle löschen
  REFRESH KEY_FIELDTAB.

* Prüfen, ob DDIC-Infos zur Tabellenstruktur schon gelesen wurden
  READ TABLE T_DFIES WITH KEY TABNAME = TABNAME
                     BINARY SEARCH.
  IF SY-SUBRC = 0.
     LOK_TABIX = SY-TABIX.
  ELSE.
* Noch nicht gefunden ==> Nachlesen und in T_DFIES aufnehmen
     PERFORM NACHLESEN_TAB_FELDER_DFIES  USING TABNAME.
     READ TABLE T_DFIES WITH KEY TABNAME   = TABNAME
                       BINARY SEARCH.
     IF SY-SUBRC = 0.
        LOK_TABIX = SY-TABIX.
     ELSE.
        MESSAGE E006(AZ) WITH TABNAME RAISING NOT_SUPPORTED.
*   Die Tabelle &1 ist im System nicht bekannt.
     ENDIF.
  ENDIF.

  DO.
    READ TABLE T_DFIES INDEX LOK_TABIX.
    IF SY-SUBRC = 0.
       IF T_DFIES-TABNAME <> TABNAME.
          EXIT.             "alle Felder zur Tabelle durch => raus
       ELSE.
          IF NOT T_DFIES-KEYFLAG IS INITIAL.
*                Key-Feld
             IF T_DFIES-FIELDNAME = 'MANDT'.
                IF NOT MANDT_NEEDED IS INITIAL.
*                Mandant auch gewünscht => aufnehmen
                   APPEND T_DFIES TO KEY_FIELDTAB.
                ENDIF.
             ELSE.
*                Key-Feld ungleich Mandant => aufnehmen
                APPEND T_DFIES TO KEY_FIELDTAB.
             ENDIF.
          ENDIF.
*                Index erhöhen, solange Felder zur Tabelle gefunden
          LOK_TABIX = LOK_TABIX + 1.
       ENDIF.
    ELSE.
*                alles gelesen => raus
       EXIT.
    ENDIF.
  ENDDO.

* Key-Felder nach Position sortiert ausgeben
  SORT KEY_FIELDTAB BY POSITION.

ENDFUNCTION.
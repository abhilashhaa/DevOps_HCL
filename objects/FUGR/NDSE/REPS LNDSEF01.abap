*----------------------------------------------------------------------*
***INCLUDE LNDSEF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_EINGABEN
*&---------------------------------------------------------------------*
*       Prüfen, ob die eingegebene Selektionsbedingung korrekt
*       aufgebaut ist.
*----------------------------------------------------------------------*
*      -->P_SELECT_FIELDS  Zu prüfende Selektionsbedingung
*----------------------------------------------------------------------*
FORM CHECK_EINGABEN USING    P_SELECT_FIELDS LIKE SEL_TABLE.

* SIGN checken (erst mal nur INCL unterstützen (kein EXCL))
  IF P_SELECT_FIELDS-SIGN CN 'I'.    "CN 'IE' später mal
     MESSAGE E002(AZ) WITH TEXT-003 RAISING WRONG_INPUT_DATA.
*   Fehlerhafte Eingabedaten: &
  ENDIF.

* OPTION checken
  IF P_SELECT_FIELDS-OPTION NE 'EQ'    AND
     P_SELECT_FIELDS-OPTION NE 'NE'    AND
     P_SELECT_FIELDS-OPTION NE 'GT'    AND
     P_SELECT_FIELDS-OPTION NE 'GE'    AND
     P_SELECT_FIELDS-OPTION NE 'LT'    AND
     P_SELECT_FIELDS-OPTION NE 'LE'    AND
     P_SELECT_FIELDS-OPTION NE 'CP'    AND
     P_SELECT_FIELDS-OPTION NE 'NP'    AND
     P_SELECT_FIELDS-OPTION NE 'BT'    AND
     P_SELECT_FIELDS-OPTION NE 'NB'.
     MESSAGE E002(AZ) WITH TEXT-003 RAISING WRONG_INPUT_DATA.
*   Fehlerhafte Eingabedaten: &
  ENDIF.

* Felder der Tabellen prüfen
 CALL FUNCTION 'CHECK_SUPPORTED_FIELD'
      EXPORTING
           TABNAME       = P_SELECT_FIELDS-TABLE
           FIELDNAME     = P_SELECT_FIELDS-FIELD
      EXCEPTIONS
           NOT_SUPPORTED = 1
           OTHERS        = 2
           .
 IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            RAISING WRONG_INPUT_DATA.
 ENDIF.

ENDFORM.                    " CHECK_EINGABEN

*&---------------------------------------------------------------------*
*&      Form  NACHLESEN_TAB_FELDER_DFIES
*&---------------------------------------------------------------------*
*       Felder einer Tabelle aus dem DDIC lesen.
*       Puffertabelle T_DFIES wird gelöscht und neu aufgebaut, wenn die
*       Anzahl der Einträge eine gewisse Grenze übersteigt.
*----------------------------------------------------------------------*
*      -->P_TABNAME   Name der Tabelle
*----------------------------------------------------------------------*
FORM NACHLESEN_TAB_FELDER_DFIES  USING  P_TABNAME LIKE DFIES-TABNAME.

DATA: X030L LIKE X030L,
      RET LIKE SY-SUBRC,
      NAMETAB LIKE DFIES OCCURS 1,
      TAB_ANZ TYPE I.

* Tabelle T_DFIES löschen, wenn bereits viele Einträge vorhanden
 DESCRIBE TABLE T_DFIES LINES TAB_ANZ.
 IF TAB_ANZ > MAX_DFIES.
    REFRESH T_DFIES.
 ENDIF.

 CALL FUNCTION 'GET_FIELDTAB'
      EXPORTING
           TABNAME             = P_TABNAME
           WITHTEXT            = ' '
      IMPORTING
           HEADER              = X030L
           RC                  = RET
      TABLES
           FIELDTAB            = NAMETAB
      EXCEPTIONS
           INTERNAL_ERROR      = 01
           NO_TEXTS_FOUND      = 02
           TABLE_HAS_NO_FIELDS = 03
           TABLE_NOT_ACTIV     = 04.

 IF SY-SUBRC = 0.
    APPEND LINES OF NAMETAB TO T_DFIES.
    SORT T_DFIES BY TABNAME FIELDNAME.
 ENDIF.

ENDFORM.                    " NACHLESEN_TAB_FELDER_DFIES
*&---------------------------------------------------------------------*
*&      Form  WHERE_COND_AUFBAUEN
*&---------------------------------------------------------------------*
*       Zeilenweise die where-Bedingung aufbauen
*----------------------------------------------------------------------*
*      -->P_SELECT_FIELDS  Zu prüfende Selektionsbedingung
*      <--P_WHERE_COND     Daraus aufgebaute Where-Bedingung
*      <--P_FIELD          Feld, für das Selektionsbedingung gilt
*----------------------------------------------------------------------*
FORM WHERE_COND_AUFBAUEN  USING    P_SELECT_FIELDS LIKE SEL_TABLE
                          CHANGING P_WHERE_COND    LIKE WHERE_TAB
                                   P_WHERE_COND_LONG LIKE WHERE_TAB
                                   P_FIELD         LIKE DFIES-FIELDNAME.

  CLEAR P_WHERE_COND.
  CLEAR P_WHERE_COND_LONG.
  IF P_FIELD <> P_SELECT_FIELDS-FIELD
* Note 403033
  OR (     P_SELECT_FIELDS-SIGN      = 'I'     "= Include
       AND P_SELECT_FIELDS-OPTION(1) = 'N' ).  "= NE, NB, NP
    IF P_FIELD IS INITIAL.
      PREFIX = '('.
    ELSE.
      PREFIX = ' ) AND ('.
    ENDIF.
  ELSE.
    PREFIX = 'OR'.
  ENDIF.
  P_FIELD = P_SELECT_FIELDS-FIELD.

  CONSTANTS LC_QUOTE TYPE STRING VALUE ''''.
  DATA: LR_FIELD_LOW TYPE REF TO DATA,
        LR_FIELD_HIGH TYPE REF TO DATA.
  FIELD-SYMBOLS: <LF_FIELD_LOW> TYPE ANY,
                 <LF_FIELD_HIGH> TYPE ANY.

  CREATE DATA LR_FIELD_LOW TYPE C LENGTH 82. "LIKE P_SELECT_FIELDS-LOW.
  ASSIGN LR_FIELD_lOW->* TO <LF_FIELD_LOW>.
  <LF_FIELD_LOW> = P_SELECT_FIELDS-LOW.
  REPLACE ALL OCCURRENCES OF LC_QUOTE IN <LF_FIELD_LOW> WITH ''''''.

  CREATE DATA LR_FIELD_HIGH TYPE C LENGTH 82. "LIKE P_SELECT_FIELDS-HIGH.
  ASSIGN LR_FIELD_HIGH->* TO <LF_FIELD_HIGH>.
  <LF_FIELD_HIGH> = P_SELECT_FIELDS-HIGH.
  REPLACE ALL OCCURRENCES OF LC_QUOTE IN <LF_FIELD_HIGH> WITH ''''''.

* Range-OPTION auswerten und als WHERE-Bedingung formulieren
  CASE P_SELECT_FIELDS-OPTION.
    WHEN 'EQ' OR 'NE' OR 'LT' OR 'LE' OR 'GT' OR 'GE'.
      CASE P_SELECT_FIELDS-OPTION.
        WHEN 'EQ'.
          OPTION = ' = '''.
        WHEN 'NE'.
          OPTION = ' <> '''.
        WHEN 'LT'.
          OPTION = ' < '''.
        WHEN 'LE'.
          OPTION = ' <= '''.
        WHEN 'GT'.
          OPTION = ' > '''.
        WHEN 'GE'.
          OPTION = ' >= '''.
        WHEN OTHERS.
          CLEAR OPTION.
      ENDCASE.
      CONCATENATE PREFIX
                  P_SELECT_FIELDS-FIELD
                  INTO P_WHERE_COND-ZEILE SEPARATED BY SPACE.
      CONCATENATE P_WHERE_COND-ZEILE
                  OPTION
                  <LF_FIELD_LOW> ''''
                  INTO P_WHERE_COND-ZEILE.
    WHEN 'BT' OR 'NB'.
      IF P_SELECT_FIELDS-OPTION = 'NB'.
        CONCATENATE PREFIX
                    ' NOT'
                    INTO PREFIX.
      ENDIF.
      CONCATENATE PREFIX
                  P_SELECT_FIELDS-FIELD
                  INTO P_WHERE_COND-ZEILE SEPARATED BY SPACE.
      CONCATENATE P_WHERE_COND-ZEILE
                  ' BETWEEN '''
                  <LF_FIELD_LOW> '''' INTO P_WHERE_COND-ZEILE.
      CONCATENATE ' AND '''
                  <LF_FIELD_HIGH> ''''
                  INTO P_WHERE_COND_LONG-ZEILE.
    WHEN 'CP' OR 'NP'.
      IF P_SELECT_FIELDS-OPTION = 'NP'.
        CONCATENATE PREFIX
                    ' NOT'
                    INTO PREFIX.
      ENDIF.
      CONCATENATE PREFIX
                  P_SELECT_FIELDS-FIELD
                  INTO P_WHERE_COND-ZEILE SEPARATED BY SPACE.
*   replace seach signs from ABAP with corresponding signs of DB
*   note 537230
      IF <LF_FIELD_LOW> CA '#'.
        translate <LF_FIELD_LOW> using '#&'.
        do.
          replace '&' with '##' into <LF_FIELD_LOW>.
          IF NOT SY-SUBRC IS INITIAL.
            EXIT.
          ENDIF.
        ENDDO.
      ENDIF.
      IF <LF_FIELD_LOW> CA '_'.
          translate <LF_FIELD_LOW> using '_&'.
          do.
            replace '&' with '#_' into <LF_FIELD_LOW>.
          IF NOT SY-SUBRC IS INITIAL.
            EXIT.
          ENDIF.
        ENDDO.
      ENDIF.
      IF <LF_FIELD_LOW> CA '%'.
        translate <LF_FIELD_LOW> using '%&'.
        do.
          replace '&' with '#%' into <LF_FIELD_LOW>.
          IF NOT SY-SUBRC IS INITIAL.
            EXIT.
          ENDIF.
        ENDDO.
      ENDIF.
*note 539899
      CONCATENATE P_WHERE_COND-ZEILE
                  ' LIKE '''
                  <LF_FIELD_LOW> ''''
                  INTO P_WHERE_COND-ZEILE.

*   Generische Suchzeichen im ABAP durch DB-Suchzeichen ersetzen.
*   Falls DB-Suchzeichen im String enthalten sind müssen diese vorher
*   maskiert werden.
*    IF P_WHERE_COND-ZEILE CA '%_#'.
*      REPLACE '#' WITH '##' INTO P_WHERE_COND-ZEILE.
*      REPLACE '%' WITH '#%' INTO P_WHERE_COND-ZEILE.
*      REPLACE '_' WITH '#_' INTO P_WHERE_COND-ZEILE.
*      CONCATENATE P_WHERE_COND-ZEILE
*                  ' ESCAPE ''' '#' ''''
*                  INTO P_WHERE_COND-ZEILE.
*    ENDIF.
*   replace seach signs from ABAP with corresponding signs of DB
      IF <LF_FIELD_LOW> CA '%_#'.
        CONCATENATE P_WHERE_COND-ZEILE
                    ' ESCAPE ''' '#' ''''
                    INTO P_WHERE_COND-ZEILE.
      ENDIF.

*   '*' durch '%' und '+' durch '_' ersetzen bei generischer Suche
    TRANSLATE P_WHERE_COND-ZEILE USING '*%+_'.
  ENDCASE.

ENDFORM.                    " WHERE_COND_AUFBAUEN
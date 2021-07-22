class ZCL_ZCLOUDNATIVE_NOTIF_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  types:
      FOLDERID type SOODK .
  types:
   begin of ts_text_element,
      artifact_name  type c length 40,       " technical name
      artifact_type  type c length 4,
      parent_artifact_name type c length 40, " technical name
      parent_artifact_type type c length 4,
      text_symbol    type textpoolky,
   end of ts_text_element .
  types:
         tt_text_elements type standard table of ts_text_element with key text_symbol .
  types:
     TS_PMNOTIF type ZCN_NOTIF .
  types:
TT_PMNOTIF type standard table of TS_PMNOTIF .
  types:
     TS_PMNOTIFPHOTO type ZCN_NOTIFPHOTO .
  types:
TT_PMNOTIFPHOTO type standard table of TS_PMNOTIFPHOTO .

  constants GC_FOLDERID type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FolderId' ##NO_TEXT.
  constants GC_PMNOTIF type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PMNOTIF' ##NO_TEXT.
  constants GC_PMNOTIFPHOTO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PMNOTIFPHOTO' ##NO_TEXT.

  methods LOAD_TEXT_ELEMENTS
  final
    returning
      value(RT_TEXT_ELEMENTS) type TT_TEXT_ELEMENTS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .
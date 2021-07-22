  METHOD define.

    super->define( ).
    DATA: lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
          lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

    DATA:
     lo_annotation     TYPE REF TO /iwbep/if_mgw_odata_annotation,
     lo_entity_type    TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
     lo_complex_type   TYPE REF TO /iwbep/if_mgw_odata_cmplx_type.

    lo_entity = model->get_entity_type( iv_entity_name = 'PMNOTIF' ).
     IF lo_entity_type IS BOUND.
      lo_entity_type->bind_structure( iv_structure_name = 'ZCL_ZCLOUDNATIVE_NOTIF_MPC_EXT=>TS_DEEP_ENTITY' ).
    ENDIF.

    lo_entity = model->get_entity_type( iv_entity_name = 'PMNOTIFPHOTO' ).
    lo_entity->set_is_media( ).
    IF lo_entity IS BOUND.
      lo_property = lo_entity->get_property( 'Mimetype' ).
      lo_property->set_as_content_type( ).
    ENDIF.

  ENDMETHOD.
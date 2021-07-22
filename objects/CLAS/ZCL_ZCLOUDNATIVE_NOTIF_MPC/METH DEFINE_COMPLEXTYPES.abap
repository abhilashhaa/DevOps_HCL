  method DEFINE_COMPLEXTYPES.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


 data:
       lo_annotation     type ref to /iwbep/if_mgw_odata_annotation,             "#EC NEEDED
       lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,             "#EC NEEDED
       lo_property       type ref to /iwbep/if_mgw_odata_property.                "#EC NEEDED

***********************************************************************************************************************************
*   COMPLEX TYPE - FolderId
***********************************************************************************************************************************
lo_complex_type = model->create_complex_type( 'FolderId' ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************
lo_property = lo_complex_type->create_property( iv_property_name  = 'Objtp' iv_abap_fieldname = 'OBJTP' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ).
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property = lo_complex_type->create_property( iv_property_name  = 'Objyr' iv_abap_fieldname = 'OBJYR' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 2 ).
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property = lo_complex_type->create_property( iv_property_name  = 'Objno' iv_abap_fieldname = 'OBJNO' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 12 ).
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_complex_type->bind_structure( iv_structure_name   = 'SOODK'
                                 iv_bind_conversions = 'X' ). "#EC NOTEXT
  endmethod.
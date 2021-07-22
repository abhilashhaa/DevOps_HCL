class ZCL_A_DELETE_CN_I_CUSTOMERCONT definition
  public
  inheriting from /BOBF/CL_LIB_A_DELETE_ACTIVE
  final
  create public .

public section.

  methods /BOBF/IF_LIB_DELETE_ACTIVE~DELETE_ACTIVE_ENTITY
    redefinition .
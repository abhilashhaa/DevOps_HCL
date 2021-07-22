class-pool .
*"* class pool for class ZCL_D_CN_I_CUSTOMERCONTACT_ACT

*"* local type definitions
include ZCL_D_CN_I_CUSTOMERCONTACT_ACTccdef.

*"* class ZCL_D_CN_I_CUSTOMERCONTACT_ACT definition
*"* public declarations
  include ZCL_D_CN_I_CUSTOMERCONTACT_ACTcu.
*"* protected declarations
  include ZCL_D_CN_I_CUSTOMERCONTACT_ACTco.
*"* private declarations
  include ZCL_D_CN_I_CUSTOMERCONTACT_ACTci.
endclass. "ZCL_D_CN_I_CUSTOMERCONTACT_ACT definition

*"* macro definitions
include ZCL_D_CN_I_CUSTOMERCONTACT_ACTccmac.
*"* local class implementation
include ZCL_D_CN_I_CUSTOMERCONTACT_ACTccimp.

class ZCL_D_CN_I_CUSTOMERCONTACT_ACT implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_D_CN_I_CUSTOMERCONTACT_ACT implementation

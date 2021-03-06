!-------------------------------------------------------------------------------
! Name: attribute_structures.F90
!
! Purpose:
! Define variables types which hold the global attribute data.
!
! Description and Algorithm details:
! None
!
! Arguments:
! None
!
! History:
! 2012/02/13, MJ: creates initial structure.
! 2014/08/31, GM: Moved to the orac common tree.
! 2014/08/31, GM: Make global attribute list CF-1.4 compliant.
! 2014/08/31, GM: Modify global_attributes_s field names to relate to their
!    global attribute field.
! 2014/12/01, CP: Added new global attributes
!
! $Id$
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------

module global_attributes_m

   use common_constants_m

   implicit none

   type global_attributes_t
      ! Global attribute 'Conventions' as defined by CF-1.4, section 2.6.1.
      character(len=attribute_length)      :: Conventions

      ! Global attributes for the 'Description of file contents' as defined by
      ! CF-1.4, section 2.6.2.
      character(len=attribute_length)      :: title
      character(len=attribute_length)      :: institution
      character(len=attribute_length)      :: source
      character(len=attribute_length)      :: history
      character(len=attribute_length_long) :: references
      character(len=attribute_length)      :: comment

      ! Extra global attributes defined by ORAC
      character(len=attribute_length)      :: Project
      character(len=attribute_length)      :: File_Name
      character(len=attribute_length)      :: UUID
      character(len=attribute_length)      :: NetCDF_Version
      character(len=attribute_length)      :: Product_Name
      character(len=attribute_length)      :: Date_Created
      character(len=attribute_length)      :: Production_Time
      character(len=attribute_length)      :: L2_Processor
      character(len=attribute_length)      :: L2_Processor_Version
      character(len=attribute_length)      :: Platform
      character(len=attribute_length)      :: Sensor
      character(len=attribute_length)      :: AATSR_Processing_Version
      character(len=attribute_length)      :: Creator_Email
      character(len=attribute_length)      :: Creator_url
      character(len=attribute_length)      :: Keywords
      character(len=attribute_length)      :: Summary
      character(len=attribute_length)      :: License
      character(len=attribute_length)      :: SVN_Version
      character(len=attribute_length_long) :: ECMWF_Version
      character(len=attribute_length)      :: RTTOV_Version

      character(len=attribute_length)      :: file_version
   end type global_attributes_t

end module global_attributes_m

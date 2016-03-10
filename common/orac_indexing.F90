!-------------------------------------------------------------------------------
! Name: orac_common.F90
!
! Purpose:
! Module defining structures common to ORAC executables
!
! History:
! 2016/03/02, AP: Initial version, forked from orac_input and _output.
!
! $Id$
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------

module orac_indexing

   use common_constants

   implicit none

   type common_file_flags
      ! Flags relevant to both files
      logical :: do_cloud               ! Output cloud retrieval terms
      logical :: do_aerosol             ! Output aerosol retrieval terms
      logical :: do_rho                 ! Output retrieved surface reflectances
      logical :: do_swansea             ! Output retrieved Swansea parameters
      logical :: do_indexing            ! Output channel indexing data

      ! Primary file flags
      logical :: do_phase_pavolonis     ! Output the Pavolonis cloud phase
      logical :: do_cldmask             ! Output neural net cloud mask
      logical :: cloudmask_pre
      logical :: do_cldmask_uncertainty ! Output the uncertainty on that
      logical :: do_phase               ! Output particle type

      ! Secondary file flags
      logical :: do_covariance          ! Output the final covariance matrix
   end type common_file_flags


   type common_indices
      ! Channel indexing
      integer          :: Ny             ! No. of instrument channels used
      integer, pointer :: Y_Id(:)        ! Instrument IDs for used chs
      integer          :: NSolar         ! No. of chs with solar source
      integer, pointer :: YSolar(:)      ! Array indices for solar chs
                                         ! out of those used (Y)
      integer          :: NThermal       ! No. of chs w/ thermal source
      integer, pointer :: YThermal(:)    ! Array indices for thermal ch
      integer          :: NViews         ! No. of instrument views available
      integer, pointer :: View_Id(:)     ! IDs of instrument views
      integer, pointer :: Ch_Is(:)       ! A bit flag of ch properties

      ! State vector
      integer          :: Nx             ! Dimension of covariance matrix
      logical, pointer :: rho_terms(:,:) ! Flags use of surface property

      ! Instrument swath
      integer          :: Xdim           ! Across track dimension
      integer          :: X0             ! First pixel across track
      integer          :: X1             ! Last pixel across track
      integer          :: Ydim           ! Along track dimension
      integer          :: Y0             ! First pixel along track
      integer          :: Y1             ! Last pixel along track

      type(common_file_flags) :: flags      ! Fields to in/output
   end type common_indices


   ! common_file_flags bitmask locations
   integer, parameter :: cloud_bit      = 0
   integer, parameter :: aerosol_bit    = 1
   integer, parameter :: rho_bit        = 2
   integer, parameter :: swansea_bit    = 3
   integer, parameter :: indexing_bit   = 4
   integer, parameter :: pavolonis_bit  = 5
   integer, parameter :: cldmask_bit    = 6
   integer, parameter :: cldmask_u_bit  = 7
   integer, parameter :: phase_bit      = 8
   integer, parameter :: covariance_bit = 9


contains

subroutine dealloc_common_indices(ind)

   implicit none

   type(common_indices), intent(inout) :: ind

   deallocate(ind%Y_Id)
   deallocate(ind%YSolar)
   deallocate(ind%YThermal)
   deallocate(ind%View_Id)
   deallocate(ind%Ch_Is)
   if (associated(ind%rho_terms)) deallocate(ind%rho_terms)

end subroutine dealloc_common_indices


end module orac_indexing
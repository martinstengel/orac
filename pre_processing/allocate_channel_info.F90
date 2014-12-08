!-------------------------------------------------------------------------------
! Name: allocate_channel_info.F90
!
! Purpose:
! Allocate the arrays within the type defined in channel_info.F90
!
! Description and Algorithm details:
! 1) Allocate arrays to have length channel_info%nchannels_total
! 2) Initialise to the appropriate fill value
!
! Arguments:
! Name         Type   In/Out/Both Description
! ------------------------------------------------------------------------------
! channel_info struct both Structure to allocate arrays
!
! History:
! 2012/06/04, MJ: produces draft code
! 2013/09/06, AP: removed redundant arguments
! 2014/10/15, GM: Added allocation of map_ids_abs_to_ref_band_land and
!    map_ids_abs_to_ref_band_sea and removed allocation of channel_proc_flag.
!
! $Id$
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------

subroutine allocate_channel_info(channel_info)

   use preproc_constants

   implicit none

   type(channel_info_s), intent(out) :: channel_info

   allocate(channel_info%channel_ids_instr(channel_info%nchannels_total))
   channel_info%channel_ids_instr=lint_fill_value
   allocate(channel_info%channel_ids_abs(channel_info%nchannels_total))
   channel_info%channel_ids_abs=lint_fill_value

   allocate(channel_info%channel_wl_abs(channel_info%nchannels_total))
   channel_info%channel_wl_abs=sreal_fill_value

   allocate(channel_info%channel_sw_flag(channel_info%nchannels_total))
   channel_info%channel_sw_flag=lint_fill_value
   allocate(channel_info%channel_lw_flag(channel_info%nchannels_total))
   channel_info%channel_lw_flag=lint_fill_value

   allocate(channel_info%map_ids_abs_to_ref_band_land(channel_info%nchannels_total))
   channel_info%map_ids_abs_to_ref_band_land=lint_fill_value
   allocate(channel_info%map_ids_abs_to_ref_band_sea(channel_info%nchannels_total))
   channel_info%map_ids_abs_to_ref_band_sea=lint_fill_value

   allocate(channel_info%channel_view_ids(channel_info%nchannels_total))
   channel_info%channel_view_ids=lint_fill_value

end subroutine allocate_channel_info
!-------------------------------------------------------------------------------
! Name: define_preprop_grid.F90
!
! Purpose:
! Define the preprocessing grid in terms of known dimensions.
!
! Description and Algorithm details:
! 1) If option 1, determine dellat/lon from the ECMWF lat/lon grid.
! 2) If option 2, do nothing.
! 3) If option 3, determine horizontal grid size from dellat/lon.
!
! Arguments:
! Name         Type   In/Out/Both Description
! ------------------------------------------------------------------------------
! imager_geolocation  both Summary of pixel positions
!              struct
! preproc_dims struct Out  Structure summarising dimensions of preprocessing.
! verbose      logic  In   F: minimise information printed to screen; T: don't
!
! History:
! 2012/01/19, MJ: produces initial code version.
! 2012/05/02, GT: implicit none statement moved to correct location
! 2012/05/02, GT: implicit none statement moved to correct location
! 2012/10/25, CP: added extra level so surface information can b stored in the
!   same profile
! 2013/10/23, AP: Tidying. Removed ecmwf_prtm argument.
!
! $Id$
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------

subroutine define_preprop_grid(imager_geolocation,preproc_dims,verbose)

   use imager_structures
   use preproc_constants
   use preproc_structures

   implicit none

   type(imager_geolocation_s), intent(in)    :: imager_geolocation
   type(preproc_dims_s),       intent(inout) :: preproc_dims
   logical,                    intent(in)    :: verbose

   real(sreal), dimension(imager_geolocation%startx:imager_geolocation%endx, &
        1:imager_geolocation%ny)             :: lat, lon
   logical, dimension(imager_geolocation%startx:imager_geolocation%endx, &
        1:imager_geolocation%ny)             :: mask
   integer                                   :: xmax, ymax

   ! determine which preproc grid points each pixels falls in (start at 1)
   lat = (imager_geolocation%latitude + preproc_dims%lat_offset)* &
        preproc_dims%dellat + 1.
   lon = (imager_geolocation%longitude + preproc_dims%lon_offset)* &
        preproc_dims%dellon + 1.

   ! only consider valid lat/lon values
   mask =  imager_geolocation%latitude.gt.sreal_fill_value .and. &
        imager_geolocation%longitude.gt.sreal_fill_value

   ! take one more pixel than is required for interpolation
   ymax = nint(2.*preproc_dims%lat_offset*preproc_dims%dellat,kind=lint)
   preproc_dims%max_lat = maxval(ceiling(lat), mask) + 1
   if (preproc_dims%max_lat .gt. ymax) preproc_dims%max_lat = ymax
   preproc_dims%min_lat = minval(floor(lat), mask) - 1
   if (preproc_dims%min_lat .lt. 1) preproc_dims%min_lat = 1

   ! if longitude touches the grid edges, wrap around and use the whole grid
   xmax = nint(2.*preproc_dims%lon_offset*preproc_dims%dellon,kind=lint)
   preproc_dims%max_lon = maxval(ceiling(lon), mask) + 1
   preproc_dims%min_lon = minval(floor(lon), mask) - 1
   if (preproc_dims%max_lon.ge.xmax .or. preproc_dims%min_lon.le.1) then
      preproc_dims%max_lon = xmax
      preproc_dims%min_lon = 1
   end if

   preproc_dims%xdim = preproc_dims%max_lon - preproc_dims%min_lon + 1
   preproc_dims%ydim = preproc_dims%max_lat - preproc_dims%min_lat + 1

   if (verbose) then
      write(*,*) 'preproc_dims: ',preproc_dims%xdim, &
           preproc_dims%ydim,preproc_dims%kdim
      write(*,*) 'dellon, dellat: ',preproc_dims%dellon,preproc_dims%dellat
      print*, 'preproc_dims%min_lat: ', preproc_dims%min_lat
      print*, 'preproc_dims%max_lat: ', preproc_dims%max_lat
      print*, 'preproc_dims%min_lon: ', preproc_dims%min_lon
      print*, 'preproc_dims%max_lon: ', preproc_dims%max_lon
   end if

end subroutine define_preprop_grid
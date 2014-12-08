!-------------------------------------------------------------------------------
! Name: get_USGS_data.F90
!
! Purpose:
! Open and read USGS global land use and DEM data. Collocate with preproc orbit.
!
! Description and Algorithm details:
! 1)
! Arguments:
! Name                Type   In/Out/Both Description
!
!------------------------------------------------------------------------------
! path_to_USGS_file   string in   Full path to USGS file
!
! History:
! 2014/09/23, OS: writes code to read data from USGS file.
!
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------

subroutine get_USGS_data(path_to_USGS_file, imager_flags, imager_geolocation, usgs, &
     assume_full_paths, verbose)

  use imager_structures
  use orac_ncdf
  use USGS_physiography

  implicit none

  character(len=path_length),  intent(in)    :: path_to_USGS_file
  type(imager_flags_s),        intent(inout) :: imager_flags
  type(imager_geolocation_s),  intent(inout) :: imager_geolocation
  logical,                     intent(in)    :: assume_full_paths
  logical,                     intent(in)    :: verbose
  type(usgs_s),                intent(out)   :: usgs
  logical                          :: USGS_file_exist
  character(len=7)                 :: USGS_file_read
  integer(kind=4)                  :: i,j
  integer(kind=sint)               :: stat
  integer(kind=sint), dimension(2) :: nearest_xy

  if (verbose) write(*,*) '<<<<<<<<<<<<<<< Entering get_USGS_data()'

  ! Check that the defined file exists and is readable
  inquire(file=trim(path_to_USGS_file), exist=USGS_file_exist, &
       read=USGS_file_read)
  if (.not.USGS_file_exist) then
     write(*,*) 'ERROR: read_USGS_file(): USGS file does ' // &
          & 'not exist: ', trim(path_to_USGS_file)
     stop error_stop_code
  else if (trim(USGS_file_read).eq.'NO') then
     write(*,*) 'ERROR: read_USGS_file(): USGS file exists ' // &
          & 'but is not readable: ', trim(path_to_USGS_file)
     stop error_stop_code
  end if

  ! Read the data themselves
  if (read_USGS_file(path_to_USGS_file, usgs, verbose) .ne. 0) then
     write(*,*) 'ERROR: read_USGS_file(), problem reading USGS file: ', &
          trim(path_to_USGS_file)
     stop error_stop_code
  end if

  ! Do collocation of imager pixels with USGS data
  do i=imager_geolocation%startx,imager_geolocation%endx
     do j=1,imager_geolocation%ny

        if (imager_geolocation%latitude (i,j) .eq. sreal_fill_value .or. &
             imager_geolocation%longitude(i,j) .eq. sreal_fill_value) &
             cycle

        ! Do nearest neighbour collocation for each imager pixel with USGS
        ! data, applying a search window radius of +-0.25 degree lat/lon
        nearest_xy = nearest_USGS(imager_geolocation%latitude(i,j), &
             imager_geolocation%longitude(i,j), usgs)

        ! Assign nearest usgs pixel data to imager pixel
        imager_geolocation%dem(i,j) = usgs%dem(nearest_xy(2), nearest_xy(1))
        imager_flags%lusflag(i,j) = usgs%lus(nearest_xy(2), nearest_xy(1))

     enddo
  enddo

  ! Reset land surface flag to 1, i.e. all land
  imager_flags%lsflag = 1
  ! Set pixels to 0 where land use flags equals water flag value (=16)
  where(imager_flags%lusflag .eq. 16) imager_flags%lsflag = 0 ! Change hard-coded
  ! value to sym%water_flag from pavolonis_constants

  call deallocate_usgs(usgs)

  if (verbose) write(*,*) '>>>>>>>>>>>>>>> Leaving get_USGS_data()'

end subroutine get_USGS_data
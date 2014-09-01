!-------------------------------------------------------------------------------
! Name: ncdf_read_field.inc
!
! Purpose:
! Code shared by all version of nc_read_array function. See orac_ncdf.F90 for
! detailed header information.
!
! Description and Algorithm details:
! 1) Locate variable in file
! 2) Read fill values, apply scale factor, add offset
!
! History:
! 2014/02/10, AP: Original version.
! 2014/08/15, AP: Fixed bug in management of scale factor/offset. Homogenizing
!   verbose and error printing formats. Split into open field/read field.
!
! $Id$
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------
   
  ! read data
   ierr = nf90_get_var(ncid, vid, arr, start, counter, stride)
   if (ierr.ne.NF90_NOERR) then
      print*,'ERROR: nc_read_file(): Could not read variable ',trim(name)
      print*,nc_error(ierr)
      stop error_stop_code
   endif
   if (verbose) print*,'Reading variable: ',trim(name)
   
   ! replace file's fill value with our own and apply scale factor/offset
   where (arr.eq.fv) arr = fill
   if (sf .ne. 1.0 .or. of .ne. 0.0) then
      where (arr.ne.fv) arr = sf*arr + of
   end if

   ! additional information for print out
   if (verbose) then
      if (nf90_get_att(ncid,vid,'units',unit).eq.NF90_NOERR) &
           print*,'Field units: ',trim(unit)

      if (nf90_get_att(ncid,vid,'valid_min',fv).eq.NF90_NOERR) &
           print*,'Field valid min: ',fv

      if (nf90_get_att(ncid,vid,'valid_max',fv).eq.NF90_NOERR) &
           print*,'Field valid max: ',fv
   end if
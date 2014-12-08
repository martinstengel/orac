!-------------------------------------------------------------------------------
! Name: set_ecmwf.F90
!
! Purpose:
! Determines necessary ECMWF files for preprocessing.
!
! Description and Algorithm details:
! 1) Set root folder dependent on badc argument.
! 2) Round hour to nearest multiple of six on the same day to select file.
! 3) Generate ECMWF filename.
!
! Arguments:
! Name           Type   In/Out/Both Description
! ------------------------------------------------------------------------------
! hour           stint  in  Hour of day (0-59)
! cyear          string in  Year, as a 4 character string
! cmonth         string in  Month of year, as a 2 character string
! cday           string in  Day of month, as a 2 character string
! chour          string in  Hour of day, as a 2 character string
! ecmwf_path     string in  If badc, folder in which to find GGAM files.
!                           Otherwise, folder in which to find GRB files.
! ecmwf_path2    string in  If badc, folder in which to find GGAS files.
! ecmwf_path3    string in  If badc, folder in which to find GPAM files.
! ecmwf_pathout  string out If badc, full path to appropriate GGAM file.
!                           Otherwise, full path to appropriate GRB file.
! ecmwf_path2out string out If badc, full path to appropriate GGAS file.
! ecmwf_path3out string out If badc, full path to appropriate GPAM file.
! ecmwf_flag     int    in  0: A single GRB file; 1: 3 NCDF files; 2: BADC files
! assume_full_path
!                logic  in  T: inputs are filenames; F: folder names
!
! History:
! 2012/01/16, MJ; writes initial code version.
! 2012/01/19, MJ: fixed a potential bug in the file determination.
! 2012/08/06, CP: modified to include 3 new ecmwf pths to read data from the
!   BADC added in badc flag
! 2012/08/13, CP: modified badc paths
! 2012/11/14, CP: modified badc paths to include year/month/day changed gpam ggap
! 2012/12/06, CP: changed how ecmwf paths are defined because of looping chunks
!   and tidied up file
! 2013/03/06, CP: changed ggam from grb to netcdf file
! 2013/06/11, CP: set default ecmwf paths
! 2013/10/21, AP: removed redundant arguments. Tidying.
! 2014/02/03, AP: made badc a logical variable
! 2014/04/21, GM: Added logical option assume_full_path.
! 2014/05/02, AP: Replaced code with CASE statements. Added third option.
!
! $Id$
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------

subroutine set_ecmwf(cyear,cmonth,cday,chour,ecmwf_path,ecmwf_path2,ecmwf_path3, &
   ecmwf_path_file,ecmwf_path_file2,ecmwf_path_file3,ecmwf_flag,assume_full_path)

   use preproc_constants

   implicit none

   character(len=date_length), intent(in)  :: cyear,cmonth,cday,chour
   character(len=path_length), intent(in)  :: ecmwf_path
   character(len=path_length), intent(in)  :: ecmwf_path2
   character(len=path_length), intent(in)  :: ecmwf_path3
   character(len=path_length), intent(out) :: ecmwf_path_file
   character(len=path_length), intent(out) :: ecmwf_path_file2
   character(len=path_length), intent(out) :: ecmwf_path_file3
   integer,                    intent(in)  :: ecmwf_flag
   logical,                    intent(in)  :: assume_full_path

   integer   :: hour
   character :: cera_hour*2

   if (assume_full_path) then
      ! for ecmwf_flag=2, ensure NCDF file is listed in ecmwf_pathout
      if (index(ecmwf_path,'.nc') .gt. 0) then
         ecmwf_path_file  = ecmwf_path
         ecmwf_path_file2 = ecmwf_path2
         ecmwf_path_file3 = ecmwf_path3
      else if (index(ecmwf_path2,'.nc') .gt. 0) then
         ecmwf_path_file  = ecmwf_path2
         ecmwf_path_file2 = ecmwf_path
         ecmwf_path_file3 = ecmwf_path3
      else if (index(ecmwf_path3,'.nc') .gt. 0) then
         ecmwf_path_file  = ecmwf_path3
         ecmwf_path_file2 = ecmwf_path
         ecmwf_path_file3 = ecmwf_path2
      else
         ecmwf_path_file  = ecmwf_path
         ecmwf_path_file2 = ecmwf_path2
         ecmwf_path_file3 = ecmwf_path3
      end if
   else
      ! pick last ERA interim time wrt sensor time (as on the same day)
      read(chour, *) hour
      select case (hour)
      case(0:5)
         cera_hour='00'
      case(6:11)
         cera_hour='06'
      case(12:17)
         cera_hour='12'
      case(18:23)
         cera_hour='18'
      case default
         cera_hour='00'
      end select

      select case (ecmwf_flag)
      case(0)
         ecmwf_path_file=trim(adjustl(ecmwf_path))//'/ERA_Interim_an_'// &
              trim(adjustl(cyear))//trim(adjustl(cmonth))// &
              trim(adjustl(cday))//'_'//trim(adjustl(cera_hour))//'+00.grb'
      case(1)
         ecmwf_path_file=trim(adjustl(ecmwf_path))//'/ggas'// &
              trim(adjustl(cyear))//trim(adjustl(cmonth))// &
              trim(adjustl(cday))//trim(adjustl(cera_hour))//'00.nc'
         ecmwf_path_file2=trim(adjustl(ecmwf_path2))//'/ggam'// &
              trim(adjustl(cyear))//trim(adjustl(cmonth))// &
              trim(adjustl(cday))//trim(adjustl(cera_hour))//'00.nc'
         ecmwf_path_file3=trim(adjustl(ecmwf_path3))//'/gpam'// &
              trim(adjustl(cyear))//trim(adjustl(cmonth))// &
              trim(adjustl(cday))//trim(adjustl(cera_hour))//'00.nc'
      case(2)
         ecmwf_path_file=trim(adjustl(ecmwf_path2))//'/ggas'// &
              trim(adjustl(cyear))//trim(adjustl(cmonth))// &
              trim(adjustl(cday))//trim(adjustl(cera_hour))//'00.nc'
         ecmwf_path_file2=trim(adjustl(ecmwf_path))//'/ggam'// &
              trim(adjustl(cyear))//trim(adjustl(cmonth))// &
              trim(adjustl(cday))//trim(adjustl(cera_hour))//'00.grb'
         ecmwf_path_file3=trim(adjustl(ecmwf_path3))//'/spam'// &
              trim(adjustl(cyear))//trim(adjustl(cmonth))// &
              trim(adjustl(cday))//trim(adjustl(cera_hour))//'00.grb'
      case default
         write(*,*) 'ERROR: set_ecmwf(): Unknown ECMWF file format flag. ' // &
                  & 'Please select 0, 1, or 2.'
         stop error_stop_code
      end select
    end if

end subroutine set_ecmwf
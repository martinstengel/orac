subroutine read_hdf_sd_dims(filename,SDS_name,nX,nY)
  use common_constants_m

   implicit none

   include "hdf.f90"
   include "dffunc.f90"
 
   ! Input
   character(len=*)  , intent(in) :: filename
   character(len=*),   intent(in)  :: SDS_name

   ! Output
   integer(kind=lint), intent(out)  :: nX,nY
   
   ! Local
   integer :: fid
   integer            :: err_code
   integer            :: var_id
   integer(kind=lint)         :: dummy_type,dummy_numattrs,dummy_rank
   integer, dimension(2) :: dimsizes
   character(len=MAX_NC_NAME) :: dummy_name

   !get file id
   fid=sfstart(filename,DFACC_READ)

   var_id = sfselect(fid, sfn2index(fid, SDS_name))

   err_code=sfginfo(var_id,dummy_name,dummy_rank,dimsizes,dummy_type, &
        dummy_numattrs)
   
   !read from netCDF file
   nX=int(dimsizes(1))
   nY=int(dimsizes(2))


   err_code=sfendacc(var_id)

   !end access to hdfile
   err_code=sfend(fid)

!print*,'var_id: ',var_id
!print*,'name: ',trim(dummy_name)
!print*,'rank: ',dummy_rank
!print*,'dimensions: ',dimsizes
!print*,'type: ',dummy_type
!print*,'numattrs: ',dummy_numattrs

end subroutine read_hdf_sd_dims
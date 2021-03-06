!-------------------------------------------------------------------------------
! Name: read_avhrr_angles.F90
!
! Purpose:
! Read solar and viewing geometry from HDF5 file.
!
! Description and Algorithm details:
! 1) Open the data group, data set, and fetch a data space.
! 2) Read the data. Read the attributes.
! 3) Apply the scale factor and offset, setting missing or invalid values to
!    sreal_fill_value.
! 4) Close the file.
!
! Arguments:
! Name      Type   In/Out/Both Description
! ------------------------------------------------------------------------------
! fid       HID_T  in   HDF file ID from H5Fopen_f
! group     string in   Name of the group to open
! dataset   string in   Name of the dataset within that group to open
! attrgroup string in   Name of the group where the attributes are stored
! startx    lint   in   First pixel to read across track
! stopx     lint   in   Last pixel to read across track
! starty    lint   in   First pixel to read along track
! stopy     lint   in   Last pixel to read along track
! rtemp     sreal  both Array into which data will be stored
!
! History:
! 2012/01/27, MJ: adds code to read AVHRR HDF5 file.
! 2013/09/06, AP: tidying
!
! $Id$
!
! Bugs:
! None known.
!-------------------------------------------------------------------------------

subroutine read_avhrr_angles(fid,group,dataset,attrgroup,startx,stopx,starty, &
     stopy,rtemp)

   use hdf5
   use preproc_constants_m

   implicit none

   integer(kind=HID_T), intent(in)  :: fid
   character(len=*),    intent(in)  :: dataset, group, attrgroup
   integer(kind=lint),  intent(in)  :: startx,stopx,starty,stopy
   real(kind=sreal),    intent(out) :: rtemp(startx:stopx,starty:stopy)

   integer               :: err_code

   integer(kind=HID_T)   :: gr_id,dset_id,dset_id2,dspace_id,mem_id,attr_id

   integer(kind=HSIZE_T) :: start(2), stride(2), edge(2), adims(1)

   integer(kind=lint)    :: ix,jy

   integer(kind=lint)    :: temp(startx:stopx,starty:stopy)

   real(kind=sreal)      :: nodata,missingdata,scale,offset

   !open the data group
   call h5gopen_f(fid,group,gr_id,err_code)
   !open the dataset
   call h5dopen_f(gr_id,dataset,dset_id,err_code)
   !get dataspace id
   call h5dget_space_f(dset_id,dspace_id,err_code)
   !define parameters for size of subset and convert input to 8byte integer
   start(1) = int(startx-1,kind=HSIZE_T)
   start(2) = int(starty-1,kind=HSIZE_T)
   stride = int(1,kind=HSIZE_T)
   edge(1) = int(stopx-startx+1,kind=HSIZE_T)
   edge(2) = int(stopy-starty+1,kind=HSIZE_T)

   !select subset of data
   call h5sselect_hyperslab_f(dspace_id,H5S_SELECT_SET_F,start,edge,err_code, &
        stride)

   !create memory dataspace
   call h5screate_simple_f(2,edge,mem_id,err_code)
   !now finally read the  data
   temp=lint_fill_value
   call h5dread_f(dset_id,H5T_NATIVE_INTEGER,temp,edge,err_code,mem_id, &
        dspace_id)

   !open data group where attributes are stored
   call h5gopen_f(fid,attrgroup,dset_id2,err_code)
   !because those are all scalar atributes
   adims(1)=1

   !scale factor
   !get attribute id
   call h5aopen_name_f(dset_id2,'gain',attr_id,err_code)
   !read now the attribute
   call h5aread_f(attr_id,H5T_NATIVE_REAL,scale,adims,err_code)
   !close attribute
   call h5aclose_f(attr_id,err_code)

   !offset
   !get attribute id
   call h5aopen_name_f(dset_id2,'offset',attr_id,err_code)
   !read now the attribute
   call h5aread_f(attr_id,H5T_NATIVE_REAL,offset,adims,err_code)
   !close attribute
   call h5aclose_f(attr_id,err_code)

   !nodata
   !get attribute id
   call h5aopen_name_f(dset_id2,'nodata',attr_id,err_code)
   !read now the attribute
   call h5aread_f(attr_id,H5T_NATIVE_REAL,nodata,adims,err_code)
   !close attribute
   call h5aclose_f(attr_id,err_code)

   !missing data
   !get attribute id
   call h5aopen_name_f(dset_id2,'missingdata',attr_id,err_code)
   !read now the attribute
   call h5aread_f(attr_id,H5T_NATIVE_REAL,missingdata,adims,err_code)
   !close attribute
   call h5aclose_f(attr_id,err_code)

   !close attribute group
   call h5gclose_f(dset_id2, err_code)

   !make real numbers now
!   where(temp.eq.missingdata .or. float(temp).eq.nodata)
!      rtemp=sreal_fill_value
!   else where
!      rtemp=temp*scale+offset
!   end where
   do ix=startx,stopx
      do jy=starty,stopy
         if (float(temp(ix,jy)) .eq. missingdata .or. &
              float(temp(ix,jy)) .eq. nodata) then
            rtemp(ix,jy)=sreal_fill_value
         else
            rtemp(ix,jy)=temp(ix,jy)*scale+offset
         end if
      end do
   end do

   !close dataspace
   call h5sclose_f(mem_id,err_code)

   !close memspace
   call h5sclose_f(dspace_id,err_code)

   !close dataset
   call h5dclose_f(dset_id, err_code)

   !close data group
   call h5gclose_f( gr_id, err_code)

end subroutine read_avhrr_angles

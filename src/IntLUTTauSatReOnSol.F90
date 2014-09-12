!-------------------------------------------------------------------------------
! Name:
!    Int_LUT_TauSatReOnSol
!
! Purpose:
!    Interpolates values from a LUT array with dimensions (channel, Tau, SolZen,
!    Re) to give the value of the LUT array at a single value of Tau, SatZen, Re
!    across all channels.
!
! Description:
!    The subroutine is passed an array of data in 4 dimensions, plus info
!    relating to the Tau, Re and SolZen grids corresponding to the LUT array
!    points (the third dimension in the LUT array is the channel number, which
!    is not interpolated).
!
!    The subroutine calculates the value of the LUT at the current (Tau, SatZen,
!    Re) plus the gradients in Tau and Re.
!
! Arguments:
!    Name   Type       In/Out/Both Description
!    F      real array In          Function to be interpolated, i.e. array of
!                                  LUT values with dimensions (channels, Tau,
!                                  SolZen, Re).
!    Grid   struct     In          LUT Grid data: see SADLUT.F90
!                                  Includes the grid values in Tau, Re, SolZen,
!                                  no. of values and step size
!    Gzero  struct     In          Structure containing "zero'th" point indices,
!                                  i.e. LUT grid array indices for the nearest
!                                  neighbour point, plus dT, dR, dS values:
!                                  fraction of grid step from zero'th point to
!                                  the Tau, SolZen, Re value we want.
!    Ctrl   struct     In          Control structure: Needed for numbers of
!                                  channels and their indices
!    Ind    struct     In          The index structure from the SPixel array
!    FInt   real array Both        The interpolated values of F for all required
!                                  channels.
!    FGrads real array Both        Interpolated gradient values in Tau and Re
!                                  for all channels.
!    status int        Out         Standard status code set by ECP routines
!
! Algorithm:
!    See IntLUTTauSatRe. This routine is an exact copy with all values relating
!    to SolZen replaced by the equivalents for SatZenSolZen (e.g. GZero%Sa1). A
!    single, more general routine could have been used but this may have been
!    less easy to follow.
!
! Local variables:
!    Name Type Description
!
! History:
!    22nd May 2014, Greg McGarragh: Adapted from IntLUTTauSatRe.F90.
!
! Bugs:
!    None known.
!
! $Id: IntLUTTauSatRe.F90 2160 2014-05-22 16:53:08Z gmcgarragh $
!
!-------------------------------------------------------------------------------

subroutine Int_LUT_TauSatReOnSol(F, Grid, GZero, Ctrl, FInt, FGrads, icrpr, &
   i_chan_to_ctrl_offset, i_chan_to_spixel_offset, status)

   use CTRL_def
   use GZero_def
   use Int_Routines_def
   use SAD_LUT_def

   implicit none

   ! Argument declarations

   real, dimension(:,:,:,:), intent(in)  :: F
                                	      ! The array to be interpolated.
   type(LUT_Grid_t),         intent(in)  :: Grid
                                              ! LUT grid data
   type(GZero_t),            intent(in)  :: GZero
                                              ! Struct containing "zero'th" grid
                                              ! points
   type(CTRL_t),             intent(in)  :: Ctrl
   real, dimension(:),       intent(out) :: FInt
                                              ! Interpolated value of F at the
					      ! required Tau, SatZen, Re values
					      ! (1 value per channel).
   real, dimension(:,:),     intent(out) :: FGrads
                                	      ! Gradients of F wrt Tau and Re at
					      ! required Tau, SatZen, Re values
					      ! (1 value per channel).
   integer,                  intent(in)  :: icrpr
   integer,                  intent(in)  :: i_chan_to_ctrl_offset
   integer,                  intent(in)  :: i_chan_to_spixel_offset

   integer,                  intent(out) :: status

   ! Local variables

   integer                       :: i, ii, ii2, j, jj, k, kk
   integer                       :: NChans    ! Number of channels in LUT arrays
                                              ! etc
   real, dimension(-1:2,-1:2)    :: G         ! A Matrix of dimension NTau,Nre
                                              ! used to store array only
                                              ! interpolated to current viewing
                                              ! geometry
   real, dimension(size(FInt),4) :: Y         ! A vector to contain the values
 					      ! of F at (iT0,iR0), (iT0,iR1),
					      ! (iT1,iR1) and (iT1,iR0)
					      ! respectively (i.e. anticlockwise
					      ! from the bottom left)
   real, dimension(size(FInt),4) :: dYdTau    ! Gradients of F wrt Tau at the
					      ! same points as Y
   real, dimension(size(FInt),4) :: dYdRe     ! Gradients of F wrt Re at the
					      ! same points as Y
   real, dimension(size(FInt),4) :: ddY       ! 2nd order cross derivatives of
					      ! F wrt Tau and Re at the same
					      ! points
   real, dimension(4)            :: Yin, Yinb, dYdTauin, dYdRein, ddYin
                                              ! Temporary store for input of
					      ! BiCubic subroutine
   real                          :: a1, a2, a3
                                              ! Temporary store for output of
					      ! BiCubic subroutine

   integer, parameter       :: iXm1 = -1
   integer, parameter       :: iX0  =  0
   integer, parameter       :: iX1  =  1
   integer, parameter       :: iXp1 =  2

   integer, dimension(-1:2) :: T_index
   integer, dimension(-1:2) :: R_index

   NChans = size(F,1)

   ! Construct the input vectors for BCuInt: Function values at four LUT points
   ! around our X

   do i = 1, NChans
      ii = i_chan_to_ctrl_offset + i
      ii2 = i_chan_to_spixel_offset + i

      T_index(-1) = GZero%iTm1(ii2,icrpr)
      T_index( 0) = GZero%iT0 (ii2,icrpr)
      T_index( 1) = GZero%iT1 (ii2,icrpr)
      T_index( 2) = GZero%iTp1(ii2,icrpr)
      R_index(-1) = GZero%iRm1(ii2,icrpr)
      R_index( 0) = GZero%iR0 (ii2,icrpr)
      R_index( 1) = GZero%iR1 (ii2,icrpr)
      R_index( 2) = GZero%iRp1(ii2,icrpr)

      do j = iXm1, iXp1
         jj = T_index(j)
         do k = iXm1, iXp1
            kk = R_index(k)
            G(j,k) = (GZero%SaSo1 (ii2,icrpr) * F(i,jj,GZero%iSaZSoZ0(ii2,icrpr),kk)) + &
                     (GZero%dSaZSoZ(ii2,icrpr) * F(i,jj,GZero%iSaZSoZ1(ii2,icrpr),kk))
         end do
      end do

      Y(i,1) = G(iX0,iX0)
      Y(i,4) = G(iX0,iX1)
      Y(i,3) = G(iX1,iX1)
      Y(i,2) = G(iX1,iX0)

      if (Ctrl%LUTIntflag .eq. LUTIntMethBicubic) then
         ! Function derivatives at four LUT points around our X....

         ! WRT to Tau
         dYdTau(i,1) = (G(iX1,iX0) - G(iXm1,iX0)) / &
                       (Grid%tau(ii,GZero%iT1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iTm1(ii2,icrpr),icrpr))
         dYdTau(i,2) = (G(iXp1,iX0) - G(iX0,iX0)) / &
                       (Grid%tau(ii,GZero%iTp1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iT0(ii2,icrpr),icrpr))
         dYdTau(i,3) = (G(iXp1,iX1) - G(iX0,iX1)) / &
                       (Grid%tau(ii,GZero%iTp1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iT0(ii2,icrpr),icrpr))
         dYdTau(i,4) = (G(iX1,iX1) - G(iXm1,iX1)) / &
                       (Grid%tau(ii,GZero%iT1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iTm1(ii2,icrpr),icrpr))

         ! WRT to Re
         dYDRe(i,1) = (G(iX0,iX1) - G(iX0,iXm1)) / &
                      (Grid%re(ii,GZero%iR1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iRm1(ii2,icrpr),icrpr))
         dYDRe(i,2) = (G(iX1,iX1) - G(iX1,iXm1)) / &
                      (Grid%re(Ii,GZero%iR1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iRm1(ii2,icrpr),icrpr))
         dYDRe(i,3) = (G(iX1,iXp1) - G(iX1,iX0)) / &
                      (Grid%re(Ii,GZero%iRp1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iR0(ii2,icrpr),icrpr))
         dYDRe(i,4) = (G(iX0,iXp1) - G(iX0,iX0)) / &
                      (Grid%re(Ii,GZero%iRp1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iR0(ii2,icrpr),icrpr))

         ! Cross derivatives (dY^2/dTaudRe)
         ddY(i,1) = (G(iX1,iX1) - G(iX1,iXm1) - G(iXm1,iX1) + G(iXm1,iXm1)) / &
                    ((Grid%tau(ii,GZero%iT1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iTm1(ii2,icrpr),icrpr)) * &
                     (Grid%re(Ii,GZero%iR1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iRm1(ii2,icrpr),icrpr)))
         ddY(i,2) = (G(iXp1,iX1) - G(iXp1,iXm1) - G(iX0,iX1) + G(iX0,iXm1)) / &
                    ((Grid%tau(ii,GZero%iTp1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iT0(ii2,icrpr),icrpr)) * &
                     (Grid%re(Ii,GZero%iR1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iRm1(ii2,icrpr),icrpr)))
         ddY(i,3) = (G(iXp1,iXp1) - G(iXp1,iX0) - G(iX0,iXp1) + G(iX0,iX0)) / &
                    ((Grid%tau(ii,GZero%iTp1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iT0(ii2,icrpr),icrpr)) * &
                     (Grid%re(Ii,GZero%iRp1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iR0(ii2,icrpr),icrpr)))
         ddY(i,4) = (G(iX1,iXp1) - G(iX1,iX0) - G(iXm1,iXp1) + G(iXm1,iX0)) / &
                    ((Grid%tau(ii,GZero%iT1(ii2,icrpr),icrpr) - Grid%tau(ii,GZero%iTm1(ii2,icrpr),icrpr)) * &
                     (Grid%re(Ii,GZero%iRp1(ii2,icrpr),icrpr) - Grid%re(Ii,GZero%iR0(ii2,icrpr),icrpr)))
      endif
   enddo

   ! Now call the adapted Numerical Recipes BCuInt subroutine to perform the
   ! interpolation to our desired state vector [Or the equivalent linint
   ! subroutine - Oct 2011]
   if (Ctrl%LUTIntflag .eq. LUTIntMethLinear) then
      do i = 1,NChans
         ii = i_chan_to_ctrl_offset + i
         ii2 = i_chan_to_spixel_offset + i
         Yin=Y(i,:)
         call linint(Yin,Grid%tau(ii,GZero%iT0(ii2,icrpr),icrpr), &
                         Grid%tau(ii,GZero%iT1(ii2,icrpr),icrpr), &
                         Grid%re(ii,GZero%iR0(ii2,icrpr),icrpr), &
                         Grid%re(ii,GZero%iR1(ii2,icrpr),icrpr), &
                         GZero%dT(ii2,icrpr),GZero%dR(ii2,icrpr),a1,a2,a3)
         FInt(i) = a1
         FGrads(i,1) = a2
         FGrads(i,2) = a3
      enddo
   else if (Ctrl%LUTIntflag .eq. LUTIntMethBicubic) then
      do i = 1,NChans
         ii = i_chan_to_ctrl_offset + i
         ii2 = i_chan_to_spixel_offset + i
         Yinb=Y(i,:)
         dYdTauin=dYdTau(i,:)
         dYdRein=dYdRe(i,:)
         ddYin=ddY(i,:)
         call bcuint(Yinb,dYdTauin,dYdRein,ddYin,&
                     Grid%tau(ii,GZero%iT0(ii2,icrpr),icrpr), &
                     Grid%tau(ii,GZero%iT1(ii2,icrpr),icrpr), &
                     Grid%re(ii,GZero%iR0(ii2,icrpr),icrpr), &
                     Grid%re(ii,GZero%iR1(ii2,icrpr),icrpr), &
                     GZero%dT(ii2,icrpr),GZero%dR(ii2,icrpr),a1,a2,a3)
         FInt(i) = a1
         FGrads(i,1) = a2
         FGrads(i,2) = a3
      enddo
   else
      status = LUTIntflagErr
      call Write_Log(Ctrl, 'IntLUTTauSatReOnSol.f90: LUT Interp flag error:', status)
   endif

end subroutine Int_LUT_TauSatReOnSol
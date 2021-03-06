$(OBJS)/Cholesky.o: InvertCholesky.F90 SolveCholesky.F90
$(OBJS)/Ctrl.o: $(OBJS)/ORACConstants.o DeallocCtrl.F90
$(OBJS)/Data.o: $(OBJS)/Ctrl.o $(OBJS)/IntRoutines.o $(OBJS)/ORACConstants.o \
        $(OBJS)/SADChan.o DeallocData.F90 DetermineIllum.F90 NullifyData.F90 \
        ReadALB_nc.F90 ReadCloudFlags_nc.F90 ReadData_nc.F90 ReadGeometry_nc.F90 \
        ReadLSFlags_nc.F90 ReadLocation_nc.F90 ReadMSI_nc.F90 \
        sabotage_inputs.F90
$(OBJS)/Diag.o: $(OBJS)/Ctrl.o $(OBJS)/Data.o $(OBJS)/ORACConstants.o \
        $(OBJS)/SPixel.o SetDiag.F90 ZeroDiag.F90
$(OBJS)/FMRoutines.o: $(OBJS)/Ctrl.o $(OBJS)/GZero.o $(OBJS)/IntLUTRoutines.o \
        $(OBJS)/InterpolRoutines.o $(OBJS)/ORACConstants.o $(OBJS)/RTM_Pc.o \
        $(OBJS)/SADChan.o $(OBJS)/SADLUT.o $(OBJS)/SPixel.o $(OBJS)/planck.o \
        FM.F90 FMSolar.F90 FMThermal.F90 SetCRPSolar.F90 SetCRPThermal.F90
$(OBJS)/GZero.o: $(OBJS)/Ctrl.o $(OBJS)/IntRoutines.o $(OBJS)/ORACConstants.o \
        $(OBJS)/SADLUT.o $(OBJS)/SPixel.o SetGZero.F90
$(OBJS)/IntRoutines.o: $(OBJS)/ORACConstants.o Linint.F90 Locate.F90 \
        find_in_array.inc
$(OBJS)/InterpolRoutines.o: $(OBJS)/Ctrl.o $(OBJS)/IntRoutines.o \
        $(OBJS)/ORACConstants.o $(OBJS)/RTM_Pc.o $(OBJS)/SADChan.o \
        $(OBJS)/SPixel.o $(OBJS)/planck.o InterpolSolar.F90 \
        InterpolSolar_spline.F90 InterpolThermal.F90 InterpolThermal_spline.F90
$(OBJS)/IntLUTRoutines.o: $(OBJS)/Ctrl.o $(OBJS)/GZero.o $(OBJS)/IntRoutines.o \
        $(OBJS)/SADLUT.o IntLUTRe.F90 IntLUTTauRe.F90 IntLUTTauSatRe.F90 \
        IntLUTTauSatReOnSol.F90 IntLUTTauSatSolAziRe.F90 IntLUTTauSolRe.F90 \
        Interp3dLUT.F90
$(OBJS)/Inversion.o: $(OBJS)/Cholesky.o $(OBJS)/Ctrl.o $(OBJS)/Diag.o \
        $(OBJS)/FMRoutines.o $(OBJS)/GZero.o $(OBJS)/IntLUTRoutines.o \
        $(OBJS)/IntRoutines.o $(OBJS)/ORACConstants.o $(OBJS)/RTM_Pc.o \
        $(OBJS)/SADChan.o $(OBJS)/SADLUT.o $(OBJS)/SPixel.o $(OBJS)/planck.o \
        CalcCWP.F90 CalcCorrectedCTX.F90 CheckLimits.F90 InvertMarquardt.F90 \
        SetKx.F90 SetLimits.F90 SetSy.F90
$(OBJS)/parse_user.o: $(OBJS)/IntRoutines.o $(OBJS)/ORACConstants.o \
        parse_user_text.inc
$(OBJS)/planck.o: $(OBJS)/ORACConstants.o $(OBJS)/SADChan.o R2T.F90 T2R.F90
$(OBJS)/prepare_output.o: $(OBJS)/Ctrl.o $(OBJS)/Data.o $(OBJS)/Diag.o \
        $(OBJS)/ORACConstants.o $(OBJS)/RTM_Pc.o $(OBJS)/SPixel.o \
        prepare_output_primary.F90 prepare_output_secondary.F90
$(OBJS)/read_utils.o: $(OBJS)/Ctrl.o $(OBJS)/ORACConstants.o \
        read_config_file.F90 read_input_dimensions.F90
$(OBJS)/ReadDriver.o: $(OBJS)/Ctrl.o $(OBJS)/ORACConstants.o \
        $(OBJS)/parse_user.o $(OBJS)/read_utils.o switch.inc
$(OBJS)/ReadSAD.o: $(OBJS)/Ctrl.o $(OBJS)/ORACConstants.o $(OBJS)/SADChan.o \
        $(OBJS)/SADLUT.o
$(OBJS)/RTM.o: $(OBJS)/Ctrl.o $(OBJS)/ORACConstants.o DeallocRTM.F90 \
        ReadLwRTM_nc.F90 ReadPRTM_nc.F90 ReadSwRTM_nc.F90
$(OBJS)/RTM_Pc.o: $(OBJS)/Ctrl.o AllocRTMPc.F90 DeallocRTMPc.F90
$(OBJS)/SADChan.o: $(OBJS)/Ctrl.o $(OBJS)/ORACConstants.o $(OBJS)/sad_util.o \
        ReadSADChan.F90
$(OBJS)/SADLUT.o: $(OBJS)/Ctrl.o $(OBJS)/ORACConstants.o $(OBJS)/SADChan.o \
        $(OBJS)/sad_util.o AllocSADLUT.F90 DeallocSADLUT.F90 ReadSADLUT.F90
$(OBJS)/sad_util.o: $(OBJS)/Ctrl.o
$(OBJS)/SPixel.o: $(OBJS)/Ctrl.o $(OBJS)/ORACConstants.o $(OBJS)/RTM.o \
        AllocSPixel.F90 DeallocSPixel.F90
$(OBJS)/SPixel_routines.o: $(OBJS)/Ctrl.o $(OBJS)/Data.o $(OBJS)/FMRoutines.o \
        $(OBJS)/GZero.o $(OBJS)/IntLUTRoutines.o $(OBJS)/IntRoutines.o \
        $(OBJS)/ORACConstants.o $(OBJS)/RTM.o $(OBJS)/SADChan.o $(OBJS)/SADLUT.o \
        $(OBJS)/SPixel.o $(OBJS)/planck.o GetGeometry.F90 GetIndexing.F90 \
        GetLSF.F90 GetLocation.F90 GetLwSwRTM.F90 GetMeasurements.F90 GetRTM.F90 \
        GetSPixel.F90 GetSurface.F90 GetX.F90 IntCTP.F90 XMDAD.F90 XSDAD.F90
$(OBJS)/orac.o: $(OBJS)/Ctrl.o $(OBJS)/Data.o $(OBJS)/Diag.o $(OBJS)/Inversion.o \
        $(OBJS)/ORACConstants.o $(OBJS)/RTM.o $(OBJS)/RTM_Pc.o \
        $(OBJS)/ReadDriver.o $(OBJS)/ReadSAD.o $(OBJS)/SADChan.o \
        $(OBJS)/SADLUT.o $(OBJS)/SPixel.o $(OBJS)/SPixel_routines.o \
        $(OBJS)/prepare_output.o $(OBJS)/read_utils.o

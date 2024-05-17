pro getchi2_single, nprof, genstr, totchi2, normpar=parnorm, $
                    plt=plt, radrange=rangerad

 ;This program take the profiles, assumes not properly normalized,
                                ;assumes same binning, calculates
                                ;total chi2 in the given radius range

IF NOT keyword_set(plt) THEN plt=0
IF NOT keyword_set(rangerad) THEN rangerad=[90.,250.]

                                ;find indices

rad_img=findgen(genstr.noa)*genstr.mrad+(genstr.mrad/2.)
useind=where((rad_img GE rangerad[0]) AND (rad_img LE rangerad[1]))
rad_imc=findgen(600/genstr.mrad)*genstr.mrad+(genstr.mrad/2.)

;renormalize
totfc=total(nprof[0,useind])
totfg=total(genstr.sbr[useind])
parnorm=totfc/totfg

;calculate chi2

totchi2=0.
FOR i=0,n_elements(useind)-1 DO BEGIN
   chi2=((nprof[0,useind[i]]-genstr.sbr[useind[i]]*parnorm)/nprof[1,useind[i]])^2.
   totchi2=totchi2+chi2
ENDFOR


IF plt THEN BEGIN
   ploterror,rad_imc,nprof[0,*],nprof[1,*],psym=10,yr=[0,4e-9],/nohat
   oplot,indgen(22)*15+7.5,genstr.sbr*parnorm,psym=10,color=255
ENDIF

END

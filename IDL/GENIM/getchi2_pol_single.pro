pro getchi2_pol_single, poldistc, poldistg, totchi2, normpar=parnorm, $
                    plt=plt

 ;This program take the profiles, assumes not properly normalized,
                                ;assumes same binning, calculates
                                ;total chi2 in the given radius range

IF NOT keyword_set(plt) THEN plt=0

                                ;find indices

pie_angle=360./poldistc.noa
rad_im=findgen(poldistc.noa)*pie_angle+(pie_angle/2.)

;renormalize
totfc=total(poldistc.sbr)
totfg=total(poldistg.sbr)
parnorm=totfc/totfg

;calculate chi2

totchi2=0.
FOR i=0,poldistc.noa-1 DO BEGIN
   chi2=((poldistc.sbr[i]-poldistg.sbr[i]*parnorm)/poldistc.sbre[i])^2.
   totchi2=totchi2+chi2
ENDFOR


IF plt THEN BEGIN
   ploterror,rad_im,poldistc.sbr,poldistc.sbre,psym=10,yr=[0,5e-9],/nohat
   oplot,rad_im,poldistg.sbr*parnorm,psym=10,color=255
ENDIF

END

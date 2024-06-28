pro getchi2_pol_fitsingle, poldistc, poldist, res, chi2, $
                    plt=plt, radrange=rangerad

 ;This program take the profiles, assumes not properly normalized,
                                ;assumes same binning, calculates
                                ;total chi2 in the given radius range

IF NOT keyword_set(plt) THEN plt=0
IF NOT keyword_set(rangerad) THEN rangerad=[90.,250.]

                                ;find indices

ang_img=findgen(poldistc.noa)*(360./poldistc.noa)

noa=poldistc.noa
chansbr=fltarr(2,noa)
chansbr[0,*]=poldistc.sbr
chansbr[1,*]=poldistc.sbre
useind=findgen(poldistc.noa)

fitnormbkg_lin, chansbr, poldist.sbr, useind, res, chi2

IF chi2 eq 1 THEN chi2=32767 ;error in fitting

IF plt THEN BEGIN
;   ploterror,rad_imc,nprof[0,*],nprof[1,*],psym=10,yr=[0,4e-9],/nohat, xtitle='Radius (arcsec)',ytitle='Surface brightness (ph cm!E-2!N s!E-1!N asec!E-2!N)',charsize=1.5
;   oplot,indgen(22)*15+7.5,genstr.sbr*res[0]+res[1],psym=10,color=255
ENDIF

END

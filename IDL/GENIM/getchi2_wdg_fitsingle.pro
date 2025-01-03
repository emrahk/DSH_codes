pro getchi2_wdg_fitsingle, wdgdistc, wedstr, res, chi2, $
                           plt=plt, snlim=limsn, wdgnof=nofwdg, $
                           backlim=limback, addnoise=noiseadd
                           

 ;This program take the profiles, assumes not properly normalized,
                                ;assumes same binning, calculates
                                ;total chi2 in the given radius range

IF NOT keyword_set(plt) THEN plt=0
IF NOT keyword_set(limsn) THEN limsn=7.
IF NOT keyword_set(limback) THEN limback=[-0.3,0.9]
IF NOT keyword_set(noiseadd) THEN noiseadd=0.

                                ;find indices


usesn=where(wdgdistc.sn ge limsn)
nel=n_elements(usesn)
nofwdg=nel
chansbr=fltarr(2,nel)
chansbr[0,*]=wdgdistc.sbr[usesn]
chansbr[1,*]=wdgdistc.sbre[usesn]+noiseadd
gensbr=wedstr.sbr[usesn]

fitnormbkg_lin, chansbr, gensbr, findgen(nel), res, chi2, backlim=limback

IF chi2 eq 1 THEN chi2=32767 ;error in fitting

IF plt THEN BEGIN
   ploterror,findgen(nel),chansbr[0,*],chansbr[1,*],psym=10,yr=[0,4e-9],/nohat, xtitle='Wedge number',ytitle='Surface brightness (ph cm!E-2!N s!E-1!N asec!E-2!N)',charsize=1.5
   oplot,findgen(nel),gensbr*res[0]+res[1],psym=10,color=255
   oplot,!x.crange,res[1]*[1.,1.],line=2,color=100
ENDIF

END

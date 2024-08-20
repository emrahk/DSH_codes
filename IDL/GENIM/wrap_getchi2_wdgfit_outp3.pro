pro wrap_getchi2_wdgfit,dist,outstr,snlim=limsn, doplot=doplot,silent=silent,wdgnof=nofwdg

;This is a wrapper to calculate chi2 distributions for the given
;distance. Assumes in GENIM directory?

  IF NOT keyword_set(doplot) THEN doplot=0
  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(limsn) THEN limsn=7.

restore,'../../IDL/GENIM/trmap.sav'            ;restore generated image radius and polar angles

restore,'polwedgc_18_50.0000_90.0000.sav' ;fix this
restore,'rebin_chandra.sav'

;dist=11.5                       ;
;inpdir_base='~/GENIM/'
inpdir_base='/data3/ekalemci/DSH_Analysis/dsh_limited/'
sdist=strtrim(string(dist),1)
res=strsplit(sdist,'.',/extract)
dstring1=res[0]
dstring2=strmid(res[1],0,2)
dists=dstring1+'_'+dstring2
inpdir=inpdir_base+dists
                                ;
getchi2_dist_wdg,inpdir,dist,outstr,wedstrc1,trmap, useind1, snlim=limsn, silent=silent,wdgnof=nofwdg ;This is default en1 energy



;plot results?

IF doplot THEN BEGIN
   plot,histogram(outstr.rchi,min=0),xr=[0,50.],psym=10,xtitle='Reduced chi!E2!N',ytitle='number of models',chars=1.5
ENDIF

;write best result

IF NOT silent THEN BEGIN
   xx=where(outstr.rchi eq min(outstr.rchi))
   cloudnames='MC'+['20','35','39','42','47','56','61','68','73','80','100','105','109','114','117']

   IF n_elements(xx) GT 1 THEN BEGIN
      FOR j=0, n_elements(xx)-1 DO BEGIN
          FOR i=0,14 DO BEGIN
      IF outstr[xx[j]].clouds[i] EQ 0 THEN nf=' NEAR' ELSE nf=' FAR'
      print,cloudnames[i]+nf
   ENDFOR
       ENDFOR
          ENDIF ELSE BEGIN
   FOR i=0,14 DO BEGIN
      IF outstr[xx].clouds[i] EQ 0 THEN nf=' NEAR' ELSE nf=' FAR'
      print,cloudnames[i]+nf
   ENDFOR
ENDELSE
ENDIF


END

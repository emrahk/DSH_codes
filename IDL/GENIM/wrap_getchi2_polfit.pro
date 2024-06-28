pro wrap_getchi2_polfit,dist,outstr,doplot=doplot,silent=silent, radrange=rangerad, ano=noa

;This is a wrapper to calculate chi2 distributions for the given
;distance. Assumes in GENIM directory?

  IF NOT keyword_set(doplot) THEN doplot=0
  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(rangerad) THEN rangerad=[90.,250.]
  IF NOT keyword_set(noa) THEN noa=12

  restore,'../../IDL/GENIM/trmap.sav'            ;restore generated image radius and polar angles

restore,'poldistc_12_90.0000_250.000.sav' ;fix this

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
getchi2_dist_pol,inpdir,dist,outstr,poldistc1,trmap,radrange=rangerad, ano=noa ;This is default en1 energy

;Note we have too many free parameters. 15 clouds varied
;independently. Distance is varied, as well as normalization.

;plot results?

IF doplot THEN BEGIN
   plot,histogram(outstr.tchi,min=0),xr=[100,500.],psym=10,xtitle='Total chi!E2!N',ytitle='number of models',chars=1.5
ENDIF

;write best result

IF NOT silent THEN BEGIN
   xx=where(outstr.tchi eq min(outstr.tchi))
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

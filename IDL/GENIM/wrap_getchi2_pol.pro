pro wrap_getchi2_pol,dist,outstr,doplot=doplot,silent=silent
;This is a wrapper to calculate chi2 distributions for the given
;distance. Assumes in GENIM directory

  IF NOT keyword_set(doplot) THEN doplot=0
  IF NOT keyword_set(silent) THEN silent=0
 

restore,'trmap.sav'            ;restore generated image radius and polar angles
restore,'../../CHANDRA_POLAR/poldistc_all.sav' ;restore                          Chandra distribution, this is for 80 250 12 wedges, not sure exp threshold?

                    ;
;inpdir_base='~/GENIM/'
;inpdir_base='../../efe_ahmed_analysis/NEWGEN/'
inpdir_base='/home/efeoztaban/ahmet_code/outputs3/'
sdist=strtrim(string(dist),1)
res=strsplit(sdist,'.',/extract)
dstring1=res[0]
dstring2=strmid(res[1],0,2)
dists=dstring1+'_'+dstring2
inpdir=inpdir_base+dists
                                ;
getchi2_pol_dist,inpdir,dist,outstr,POLDISTC_12_250_2,trmap ;

;Note we have too many free parameters. 15 clouds varied
;independently. Distance is varied, as well as normalization.

;plot results?


IF doplot THEN BEGIN
   plot,histogram(outstr.tchi,min=0),xr=[0,1000.],psym=10,xtitle='Total chi!E2!N',ytitle='number of models',chars=1.5
ENDIF

;write best result
IF NOT silent THEN BEGIN

   xx=where(outstr.tchi eq min(outstr.tchi))
   cloudnames='MC'+['20','35','39','42','47','56','61','68','73','80','100','105','109','114','117']

IF N_ELEMENTS(xx) GT 1 THEN BEGIN
   print,'More than one minima detected, could be a bug?'
   FOR j=0,n_elements(xx)-1 DO BEGIN
      print,xx[j]
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

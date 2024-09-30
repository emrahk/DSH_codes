pro wrap_getchi2_radfit,dist,outstr,doplot=doplot,silent=silent, $
                        radrange=rangerad, base_inpdir=inpdir_base,$
                        cloud_seq=seq_cloud, erange=rangee, newdust=newdust

;This is a wrapper to calculate chi2 distributions for the given
;distance. Changed to get rebin chandra image created profiles.

  IF NOT keyword_set(doplot) THEN doplot=0
  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(rangerad) THEN rangerad=[90.,250.]
  IF NOT keyword_set(inpdir_base) THEN inpdir_base='/data3/efeoztaban/E2_simulations_corrected/'
  IF NOT keyword_set(seq_cloud) THEN seq_cloud=''
  IF NOT keyword_set(rangee) THEN rangee=2 ;E2 is the default energy
  IF NOT keyword_set(newdust) THEN newdust=0
  
  restore,'../../IDL/GENIM/trmap.sav'            ;restore generated image radius and polar angles
  restore,'rebin_chandra.sav'

;restore,'prof_rgbc67mrad15_deflare_REG_c7inring_c6simexp.sav'

restore,'radprofc_29_15.sav' ;still magic numbers

;snoa=strtrim(string(noa),1)
;sdelr=strsplit(strtrim(string(delr),1),'.',/extract)
;consav='radprofc_'+snoa+'_'+sdelr[0]+'.sav'


case rangee of
   1: BEGIN
      cradstr=radstrc0
      useind=useind0
   END
   2: BEGIN
      cradstr=radstrc1
      useind=useind1
   END
   3: BEGIN
      cradstr=radstrc2
      useind=useind2
   END
   4: BEGIN
      cradstr=radstrc_t
      useind=useind1
   END
ENDCASE

  
;dist=11.5                       ;
;inpdir_base='~/GENIM/'
;inpdir_base='/data3/efeoztaban/E2_simulations_corrected/'
sdist=strtrim(string(dist),1)
res=strsplit(sdist,'.',/extract)
dstring1=res[0]
dstring2=strmid(res[1],0,2)
dists=dstring1+'_'+dstring2
inpdir=inpdir_base+dists
                                ;
getchi2_dist_rad,inpdir,dist,outstr,cradstr,trmap,useind,$
                 radrange=rangerad, cloud_seq=seq_cloud, newdust=newdust

;Note we have too many free parameters. 15 clouds varied
;independently. Distance is varied, as well as normalization.

;plot results?

IF doplot THEN BEGIN
   plot,histogram(outstr.rchi,min=0,binsize=0.1)/10.,xr=[2,20.],psym=10,xtitle='Reduced chi!E2!N',ytitle='number of models',chars=1.5
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

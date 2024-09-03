pro wrap_getchi2_wdgfit,dist,outstr,snlim=limsn, doplot=doplot,silent=silent,wdgnof=nofwdg, base_inpdir=inpdir_base, limrad=radlim, ano=noa,rdel=delr

;This is a wrapper to calculate chi2 distributions for the given
;distance. Assumes in GENIM directory
;
;INPUTS
;
; dist: distance
;
;OUTPUTS
;
; outstr: an output structure with cloud and fit information
;
; OPTIONAL INPUTS
;
; doplot: IF set, plot best image
; silent: IF set supress messaged
; snlim: signal to noise ratio to include in fitting
; base_inpdir: directory where the generated images are
; wdgnof: IF set provide number of wedges
;
; USES
;
; getchi2_dist_wdg
;
; USED BY
;
; wrap_getchi2_wdgfit_all
;
; COMMENTS
;
; Created by EK, July 2024
; August 2024: removing magic sav file and now checks actual .sav file
; September 2024: parameters not coming correctly for checking .sav file, now passed correctly


  IF NOT keyword_set(doplot) THEN doplot=0
  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(limsn) THEN limsn=7.
  IF NOT keyword_set(delr) THEN delr=50.
  IF NOT keyword_set(radlim) THEN radlim=90.
  IF NOT keyword_set(noa) THEN noa=18

restore,'../../IDL/GENIM/trmap.sav'            ;restore generated image radius and polar angles
restore,'rebin_chandra.sav'

;restore,'polwedgc_18_50.0000_90.0000.sav' ;fix this
snoa=strtrim(string(noa),1)
sdelr=strsplit(strtrim(string(delr),1),'.',/extract)
srlim=strsplit(strtrim(string(radlim),1),'.',/extract)
consav='polwedgc_'+snoa+'_'+sdelr[0]+'_'+srlim[0]+'.sav'

;check if exists

chfile=file_test(consav)

IF NOT chfile THEN BEGIN
   print, consav+' does not exist, creating'
   wrap_chandra_wedge, noa, delr, radlim
ENDIF

restore,consav
   
;dist=11.5                       ;
;inpdir_base='~/GENIM/'
IF NOT keyword_set(inpdir_base) THEN inpdir_base='/data3/ekalemci/DSH_Analysis/dsh_limited_v0/'
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

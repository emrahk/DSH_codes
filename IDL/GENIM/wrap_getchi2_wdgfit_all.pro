pro wrap_getchi2_wdgfit_all, outwchi2, $
                             rdel=delr, limrad=radlim, ano=noa, $
                             snlim=limsn, base_inpdir=inpdir_base

;This is a wrapper for wedge array creation and fitting
;
;INPUTS
;
; NONE
;
;OUTPUTS
;
; outwchi2: an output structure with cloud and fit information
;
; OPTIONAL INPUTS
;
; rdel: delta radius of wedges
; limrad: starting radius
; ano: number of angles to divide 360 degrees
; snlim: signal to noise ratio to include in fitting
; base_inpdir: directory where the generated images are
;
; USES
;
; wrap_getchi2_wdgfit
;
; USED BY
;
;NONE
;
; COMMENTS
;
; Created by EK, July 2024
; Adding inpdir as an outside option
;
  
  IF NOT keyword_set(delr) THEN delr=50.
  IF NOT keyword_set(radlim) THEN radlim=90.
  IF NOT keyword_set(noa) THEN noa=18
  IF NOT keyword_set(limsn) THEN limsn=7.
  IF NOT kwyword_set(inpdir_base) THEN inpdir_base='/data3/ekalemci/DSH_Analysis/dsh_limited_v0/'
  
  outstr1=create_struct('dist',0.,'clouds',intarr(32768L,15L),$
                        'norm',fltarr(32768L), 'back',fltarr(32768),$
                        'delr',delr,'radlim',radlim,$
                        'tchi',fltarr(32768L),'snlim',limsn,'noa',noa,$
                        'rchi',fltarr(32768),'nofwdg',0)
  

  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outwchi1=replicate(outstr1,ndir)
 
  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     resdist=strsplit(resdir[4],'_',/extract)
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_wdgfit,dist,outstr,/silent,snlim=limsn,wdgnof=nofwdg
     outwchi1[i].dist=dist
     outwchi1[i].nofwdg=nofwdg
     FOR j=0L, 32767L DO BEGIN
        outwchi1[i].clouds[j,*]=outstr[j].clouds
        outwchi1[i].norm[j]=outstr[j].norm
        outwchi1[i].tchi[j]=outstr[j].tchi
        outwchi1[i].back[j]=outstr[j].back
        outwchi1[i].rchi[j]=outstr[j].rchi
     ENDFOR
     print,dist, min(outstr.rchi)
  ENDFOR

outwchi2=outwchi1[sort(outwchi1.dist)]  
END

  

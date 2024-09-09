pro wrap_getchi2_radfit_all, outrchi2, radrange=rangerad, base_inpdir=inpdir_base
;This is a wrapper for radial array creation and fitting
;
;INPUTS
;
; NONE
;
;OUTPUTS
;
; outwrhi2: an output structure with cloud and fit information
;
; OPTIONAL INPUTS
;
; rdel: delta radius of wedges
; rangerad:  radius range for fitting
; base_inpdir: directory where the generated images are
;
; USES
;
; wrap_getchi2_radfit
;
; USED BY
;
;NONE
;
; COMMENTS
;
; Created by EK, July 2024
; Adding inpdir as an outside option
; September 2024 fixed magic number in determining distances from string
;

  IF NOT keyword_set(rangerad) THEN rangerad=[60.,300.]
  IF NOT keyword_set(inpdir_base) THEN inpdir_base='/data3/efeoztaban/E2_simulations_corrected/'
  
  outstr1=create_struct('dist',0.,'clouds',intarr(32768L,15L),'norm',fltarr(32768L),$
                        'back',fltarr(32768),'rchi',fltarr(32768),$
                        'tchi',fltarr(32768L),'radrange',rangerad)
;  inpdir_base='/data3/ekalemci/DSH_Analysis/dsh_limited_v0/'



  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outrchi1=replicate(outstr1,ndir)
 
  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     nelrd=n_elements(resdir)
     resdist=strsplit(resdir[nelrd-1],'_',/extract) 
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_radfit,dist,outstr,radrange=rangerad,base_inpdir=inpdir_base,/silent
     outrchi1[i].dist=dist
     FOR j=0L, 32767L DO BEGIN
        outrchi1[i].clouds[j,*]=outstr[j].clouds
        outrchi1[i].norm[j]=outstr[j].norm
        outrchi1[i].tchi[j]=outstr[j].tchi
        outrchi1[i].back[j]=outstr[j].back
        outrchi1[i].rchi[j]=outstr[j].rchi
     ENDFOR
     print,dist, min(outstr.rchi)
  ENDFOR

outrchi2=outrchi1[sort(outrchi1.dist)]  
END

  

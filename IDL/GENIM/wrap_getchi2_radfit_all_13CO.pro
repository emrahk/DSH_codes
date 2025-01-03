pro wrap_getchi2_radfit_all_13CO, outrchi2, radrange=rangerad

  IF NOT keyword_set(rangerad) THEN rangerad=[60.,300.]
  
  outstr1=create_struct('dist',0.,'clouds',intarr(32768L,15L),'norm',fltarr(32768L),$
                        'back',fltarr(32768),'rchi',fltarr(32768),$
                        'tchi',fltarr(32768L),'radrange',rangerad)
;  inpdir_base='/data3/ekalemci/DSH_Analysis/dsh_limited_v0/'
  inpdir_base='/data3/efeoztaban/E2_simulations_13CO_corrected/'
  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outrchi1=replicate(outstr1,ndir)
 
  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     resdist=strsplit(resdir[3],'_',/extract) ;depends on inpdir!
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_radfit,dist,outstr,radrange=rangerad,/silent,base_inpdir=inpdir_base
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

  

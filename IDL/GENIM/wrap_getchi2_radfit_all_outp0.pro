pro wrap_getchi2_radfit_all, outrchi2, radrange=rangerad

  IF NOT keyword_set(rangerad) THEN rangerad=[60.,300.]
  
  outstr1=create_struct('dist',0.,'clouds',intarr(32768L,15L),'norm',fltarr(32768L),$
                        'back',fltarr(32768),$
                        'tchi',fltarr(32768L),'radrange',rangerad)
  inpdir_base='/home/efeoztaban/ahmet_code/outputs3/'
  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outrchi1=replicate(outstr1,ndir)
 
  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     resdist=strsplit(resdir[4],'_',/extract)
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_radfit,dist,outstr,radrange=rangerad,/silent
     outrchi1[i].dist=dist
     FOR j=0L, 32767L DO BEGIN
        outrchi1[i].clouds[j,*]=outstr[j].clouds
        outrchi1[i].norm[j]=outstr[j].norm
        outrchi1[i].tchi[j]=outstr[j].tchi
        outrchi1[1].back[j]=outstr[j].back
     ENDFOR
     print,dist, min(outstr.tchi)
  ENDFOR

outrchi2=outrchi1[sort(outrchi1.dist)]  
END

  

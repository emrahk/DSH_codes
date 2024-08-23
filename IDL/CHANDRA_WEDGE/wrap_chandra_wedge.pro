pro wrap_chandra_wedge, noa, delr, minr, plwedges=plwedges

;
; This is a collection of calls to create wedge distribution of
;chandra surface brightness in the given radius range and number of angles
;
;

restore,'rebin_chandra.sav'
restore,'trmap.sav'

IF NOT keyword_set(plwedges) THEN plwedges=0

;noa=18
;delr=50.
;minr=90.


 wedge_create,  OUTIM0BC, CTSOUT0, USEIND0, TRMAP, noa, delr, wedstrc0, $
                   rmin=minr, plwedges=plwedges

 wedge_create,  OUTIM1BC, CTSOUT1, USEIND1, TRMAP, noa, delr, wedstrc1, $
                   rmin=minr, plwedges=plwedges

 wedge_create,  OUTIM2BC, CTSOUT2, USEIND2, TRMAP, noa, delr, wedstrc2, $
                   rmin=minr, plwedges=plwedges

    ctsout_t=ctsout0+ctsout1+ctsout2

    wedge_create,  OUTIM_TOTAL, CTSOUT_T, USEIND_TOTAL, TRMAP, noa, delr, $
                   wedstrc_t, $
                   rmin=minr, plwedges=plwedges, $
                ps=ps, fname=namef


snoa=strtrim(string(outstr[0].noa),1)
sdelr=strsplit(strtrim(string(delr),1),'.',/extract)
srlim=strsplit(strtrim(string(minr),1),'.',/extract)

fname='polwedgc_'+snoa+'_'+sdelr[0]+'_'+srlim[0]+'.sav'

save, wedstrc0,wedstrc1,wedstrc2, wedstrc_t,noa,delr,minr,filename=fname

END

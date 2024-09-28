pro wrap_chandra_radial, noa, delr, plrads=plrads

;
; This is a collection of calls to create wedge distribution of
;chandra surface brightness in the given radius range and number of angles
;
;

restore,'rebin_chandra.sav'
restore,'trmap.sav'

IF NOT keyword_set(plrads) THEN plrads=0

;noa=18
;delr=50.
;minr=90.


radial_create,  OUTIM0, OUTIM0BC, CTSOUT0, USEIND0, TRMAP, noa, delr, $
               radstrc0, plrads=plrads

radial_create,  OUTIM1, OUTIM1BC, CTSOUT1, USEIND1, TRMAP, noa, delr, $
               radstrc1, plrads=plrads

radial_create,  OUTIM2, OUTIM2BC, CTSOUT2, USEIND2, TRMAP, noa, delr, $
               radstrc2, plrads=plrads

    ctsout_t=ctsout0+ctsout1+ctsout2

    outim_total_bbc=outim0+outim1+outim2
    
radial_create,  OUTIM_TOTAL_BBC, OUTIM_TOTAL, CTSOUT_T, USEIND_TOTAL, $
                   TRMAP, noa, delr, $
                   radstrc_t, $
                plrads=plrads

snoa=strtrim(string(noa),1)
sdelr=strsplit(strtrim(string(delr),1),'.',/extract)

fname='radprofc_'+snoa+'_'+sdelr[0]+'.sav'

save, radstrc0,radstrc1,radstrc2, radstrc_t,noa,delr,filename=fname

END

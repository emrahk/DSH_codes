;wrap chandra
;
; This is a collection of calls to create polar distribution of
;chandra surface brightness in the given radius range and number of angles
;
; mappolcoordc, chandrapoldist
;

restore,'rebin_chandra.sav'
restore,'trmap.sav'

noa=12
limrad=[90.,250.]

   chandrapoldist_rebin, OUTIM0BC, CTSOUT0, USEIND0, TRMAP, noa, poldistc0, radlim=limrad
   chandrapoldist_rebin, OUTIM1BC, CTSOUT1, USEIND1, TRMAP, noa, poldistc1, radlim=limrad
   chandrapoldist_rebin, OUTIM2BC, CTSOUT2, USEIND2, TRMAP, noa, poldistc2, radlim=limrad

   ctsout_t=ctsout0+ctsout1+ctsout2
   
   chandrapoldist_rebin, OUTIM_TOTAL, CTSOUT_T, USEIND_TOTAL, TRMAP, noa, poldistc_t, radlim=limrad

fname='poldistc_'+strtrim(string(noa),1)+'_'+strtrim(string(limrad[0]),1)+$
         '_'+strtrim(string(limrad[1]),1)+'.sav'

save, poldistc0,poldistc1,poldistc2,poldistc_t,noa,limrad,filename=fname

END

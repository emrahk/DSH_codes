;wrap chandra
;
; This is a collection of all calls to create APEX related outputs
;
; make sure these are compiled
; mappolcoordc, chandrapoldist
;

ch_file1='band1_flux_img_eq.img'
ch_file2='band2_flux_img_eq.img'
ch_file3='band3_flux_img_eq.img'

noa=12
limrad=[100.,250.]

doprep=0
IF doprep THEN BEGIN
   corb=1
   expof='band2_thresh.expmap' ;current version does not need exposure correc
   chandrapoldist, ch_file1, noa, poldistc_12_250_1, radlim=limrad,corb=corb
   chandrapoldist, ch_file2, noa, poldistc_12_250_2, radlim=limrad,corb=corb
   chandrapoldist, ch_file3, noa, poldistc_12_250_3, radlim=limrad,corb=corb
ENDIF

docombine=0

IF docombine THEN BEGIN
   areas=poldistc_12_250_1.areas
   ch_comb=create_struct('noa',noa, $
      'radlim',limrad, 'areas',areas, $
      'sbr',fltarr(noa), 'sbre', fltarr(noa), 'normb',0.)
   totsbr= poldistc_12_250_1.sbr+poldistc_12_250_2.sbr+poldistc_12_250_3.sbr
   nelt=(poldistc_12_250_1.sbr/poldistc_12_250_1.sbre)^2+$
        (poldistc_12_250_2.sbr/poldistc_12_250_2.sbre)^2+$
        (poldistc_12_250_3.sbr/poldistc_12_250_3.sbre)^2
   errf=sqrt(nelt)/nelt
   totnormb=poldistc_12_250_1.normb+poldistc_12_250_2.normb+$
            poldistc_12_250_3.normb
   ch_comb.sbr=totsbr
   ch_comb.sbre=totsbr*errf
   ch_comb.normb=totnormb
ENDIF


END

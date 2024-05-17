pro plotpoldistc, poldistc, ps=ps, fname=namef

;This program plots Chandra polar distribution of brightess,
;
;
; INPUTS
;
; poldistc: already calculated brightness values
;
; OPTIONAL INPUTS
;
; ps: IF set, postscript output
; fname: IF set, use namef for the postscript file
;
; OUTPUTS
;
; image
;
; USES
;
;
; USED BY
;
; APEX and CHANDRA analysis polar distribution codes
;
; CREATED by Emrah Kalemci, Jan 2023
;


IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(namef) THEN namef='poldistc.eps'


loadct,5
if ps then begin
   set_plot, 'ps'
   device,/color
;   loadct,5
   device,/encapsulated
   device, filename = namef
   device, yoffset = 2
   device, ysize = 20.
   device, xsize = 20.
   !p.font=0
   device,/times
   backc=0
   axc=0
endif

IF NOT ps THEN BEGIN
   window, 1, retain=2, xsize=600, ysize=350
   backc=0
   axc=255
   device,decomposed=0
ENDIF

cs=1.3


;IF NOT ps THEN window, 2, retain=2, xsize=600, ysize=300
noa=poldistc.noa
sbr2pl=poldistc.sbr
sbr2ple=poldistc.sbre
angvar=findgen(noa)*360./noa
ploterror, angvar, sbr2pl*1E9, sbr2ple*1E9,psym=10, xrange=[0.,360.],/xstyle,$
      xtitle='Polar angle',ytitle='Brightness x 10!E9!D',/nohat
END

pro cloudstat, inpstr, dist, chi2lim, cloudstat, ps=ps, fname=namef

;This program plots the cloud near/far distribution for all images
;with reduced chi2 less than the input limit
;
; INPUTS
;
;inpstr: input structure with fit results
;dist: source distance
;chi2lim: limit chi2
;
;OUTPUTS
;
;cloudstat: an array showing the percentages of near and far
;
;OPTIONAL INPUTS
;
;ps: if set postscript output
;fname: If set change the name of output postscript file
;
;USES
;
; boxc?
;
;USED BY
;
;NONE
;
;COMMENTS
;
;created by EK DEC 2024
;

  IF NOT keyword_set(ps) THEN ps=0
  IF NOT keyword_set(namef) THEN namef='cloudstat.eps'
  

loadct,5
if ps then begin
   set_plot, 'ps'
   device,/color
;   loadct,5
   device,/encapsulated
   device, filename = namef
   device, yoffset = 2
;   device, ysize = 20.
;   device, xsize = 20.
   !p.font=0
   device,/times
;   backc=0
;   axc=0
endif
  
;find items with rchi2 less than the limit

  distin=where(inpstr.dist eq dist)
  rchin=inpstr[distin].rchi
  xx=where(rchin LE chi2lim,nxx)
  print, strtrim(string(nxx),1)+' clouds'
  cloudstat=fltarr(2,15)
  cloudsum=intarr(15)
  
  FOR i=0, nxx-1 DO cloudsum=cloudsum+inpstr[distin].clouds[xx[i],*]

  cloudstat[1,*]=cloudsum/float(nxx)
  cloudstat[0,*]=1.-cloudstat[1,*]


  ;plot

  cloudn=['-20','-35','-39','-42','-47','-56','-61','-68','-73','-80','-100','-105','-109','-114','-117']
  
  plot, [0.,0],[0.,0], psym=4, xr=[0.,47],yr=[0.,1.1],/xstyle, /ystyle, $
        ytitle='Fraction', charsize=1.3,/nodata,xticks=1,$
        xtickname=[' ',' ']
  xyouts, 21.,-0.07,'Clouds',size=1.3
  FOR i=0, 14 DO BEGIN
     obox, 1+(i*3), 0., 2+(i*3),cloudstat[0,i]
     IF cloudstat[0,i] eq 0. THEN ypos=0.02 else ypos=cloudstat[0,i]-0.05
     xyouts, 1.02+(i*3),ypos,'N'
     obox, 2+(i*3), 0., 3+(i*3),cloudstat[1,i]
     IF cloudstat[1,i] eq 0. THEN ypos=0.02 else ypos=cloudstat[1,i]-0.05
     xyouts, 2.1+(i*3), ypos,'F'
     xyouts, 1.08+(i*3), max(cloudstat[*,i])+0.03,cloudn[i]
  ENDFOR

  IF ps THEN BEGIN
     device,/close
     set_plot,'x'
  ENDIF
END

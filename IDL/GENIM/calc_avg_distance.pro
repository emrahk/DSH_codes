pro calc_avg_distance, x, y, res

    ;This program calculates average distance of each pixel from the
    ;source position. The critical pixel is the middle pixel. The rest is for
    ;checking. For large angles spherical coordinates should be used.

;INPUTS
;
; x: x position from the center
; y: y position from the center
;
; OUTPUTS
;
; res: result in arcsec
;
; OPTIONAL INPUTS
;
; NONE
;
; USED BY
;
; GENIM codes
;
; USES
;
; NONE
;
; COMMENTS
;
; Created by EK
; Aug 2024
;

  pixsize=13.635
;center belongs to 25, 27
  x0=-0.122                     ;24.878
  y0=-0.061                     ;26.938874

  xvals=x+findgen(1000)/1000. - 0.5 ;from -0.5 to 0.5
  yvals=y+findgen(1000)/1000. - 0.5

  totd=0.

  FOR i=0,999 DO BEGIN
     FOR j=0,999 DO BEGIN
        totd=totd+sqrt((xvals[i]-x0)^2. + (yvals[j]-y0)^2.)
     ENDFOR
  ENDFOR

  res=totd/1D6

  print, res, res*pixsize
END

pro getpandacoordinates, outind

;This program finds the indices of APEX or GENIM pixels for the panda
;shaped region used in Chandra fits.
;
;INPUTS
;
;NONE
;
;OUTPUTS
;
;outind: A one dimensional array that carries the indices of the
;region
;
;OPTIONAL INPUTS
;
;NONE
;
;USES
;
;trmap.sav file
;
;USED BY
;
;image generation programs
;
; COMMENTS
;
;Created by EK, 29 Apr 2024
;

  restore,'trmap.sav'
  xx1=where((trmap.mapr GE 90.) AND (trmap.mapr LE 170.) $
            AND (trmap.mapth GE 0.) AND (trmap.mapth LE 15.))
 
  xx2=where((trmap.mapr GE 90.) AND (trmap.mapr LE 170.) $
            AND (trmap.mapth GE 150.) AND (trmap.mapth LE 360.))

  outind=[xx1,xx2]
  checkres=1

  IF checkres THEN BEGIN
     xval=outind mod 49
     yval=(outind-xval)/49
     plot,xval,yval,psym=4,xr=[0,49],yr=[0,53],/xstyle,/ystyle
  ENDIF
END

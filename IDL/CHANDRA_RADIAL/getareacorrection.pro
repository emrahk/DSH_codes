function getareacorrection, expomap, poss, threshexp, uchip, objchip=chipobj, incexpo_prof=incprof_expo

;
; expomap: exposure map image
; poss: position of the source
; threshexp: threshold to accept data
; uchip: chip nimber to use, if 0, use entire detector
; objchip: chip boundaries if uchip is different than zero
; incexpo_prof: incremantal exposure map profile (grows with area)

  
;  out of chip boundary and exposure area 0 pixels should not
;  contribute to the area
  yy=where(expomap GT ((max(expomap)*threshexp)))
  
  sz=size(expomap)
  yexp=(yy/sz[1]);-poss[1]
  xexp=(yy-yexp*sz[1]);-poss[0]

  ;get chip correction  
  IF uchip NE 0 THEN BEGIN
     conpoint=chipobj->ContainsPoints(xexp, yexp)
     zz=where(conpoint EQ 1)
     xexp=xexp[zz]
     yexp=yexp[zz]
  ENDIF
  
  yexpc=yexp-poss[1]
  xexpc=xexp-poss[0]
  rexp=sqrt(xexpc^2+yexpc^2)
  expoarfrac=dblarr(1500)       ;returned, active area/pi r^2
  incprof_expo=dblarr(1500); incremental exposure map profile for the given radius
  ;assume first 100 is always ok
  ;expoarfrac[0:99]=1. ;then the pir2 counting ratio is very close to 1
  FOR i=0, 1499 DO BEGIN
     rlim=where(rexp LT i,ctrlim) ;find all elements less than given radius
     IF (ctrlim NE 0) THEN BEGIN
        IF (i GE 180) THEN expoarfrac[i]=ctrlim/(!PI*double(i)^2.) $
        ELSE expoarfrac[i]=1  ; below 180 exposure area is always > expthresh 
        incprof_expo[i]=total(expomap[xexp[rlim],yexp[rlim]]/max(expomap))
        diagx=0
        IF (diagx AND (i GT 800)) THEN begin
           cix=findgen(3600)*2*!PI/3600.
           plot,i*cos(cix),i*sin(cix)
           oplot,xexpc[rlim],yexpc[rlim],psym=3
           stop
        ENDIF
        
     ENDIF
     
  ENDFOR
  return,expoarfrac
END

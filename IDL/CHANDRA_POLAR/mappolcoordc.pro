pro mappolcoordc, hdr, nzi, pos, maprc, mapthetac

;This program uses the given FITS header and source position in
;decimal degrees and maps the given RA DEC positions (each element in
;image) to polar coordinates (r, theta) for the given center position
;(pos)
;
; INPUTS
;
; hdr: FITS header read by READFITS or HEADFITS
; pos: RA, DEC position of the source
;
; OUTPUTS
;
; map: r and theta values of each X,Y positions from the image
;
; USES
;
; idlastro library
;
; USED BY
;
; APEX and CHANDRA analysis polar distribution codes
;
; CREATED by Emrah Kalemci, Feb 2023
;
;

;get FITS header parameters

nxs1=sxpar(hdr,'NAXIS1')
nxs2=sxpar(hdr,'NAXIS2')

maprc=fltarr(n_elements(nzi))
mapthetac=fltarr(n_elements(nzi))

;get pos xy
adxy, hdr, pos[0], pos[1], xpos, ypos


;FOR i=0, nxs1-1 DO BEGIN
;   FOR j=0, nxs2-1 DO BEGIN
;      IF j mod 100 eq 0 THEN print,j
FOR i=0L, n_elements(nzi)-1L DO BEGIN
   xi=(nzi[i] mod nxs1)
   yi=(nzi[i]/nxs1)
   xyad, hdr, xi, yi, ra, dec  ;ds9 X, Y is i+1, j+1
   gcirc, 2, ra, dec, pos[0], pos[1], r
   dx=xi-xpos
   dy=yi-ypos
   ;to find the angle I can find the projected distance in x axis
   xyad, hdr, xi, ypos, rap, decp
   gcirc, 2, rap, decp, pos[0], pos[1], rp
   rr=sqrt(dx^2+dy^2)
   thetao=acos(abs(dx)/rr)*180D/!PI
   theta1=acos(abs(rp)/r)*180D/!PI ;use this
      IF (dx GE 0) and (dy GE 0) THEN theta=theta1 
      IF (dx LT 0) and (dy GE 0) THEN theta=180.-theta1
      IF (dx LT 0) and (dy LT 0) THEN theta=180.+theta1
      IF (dx GE 0) and (dy LT 0) THEN theta=360.-theta1 
    maprc[i] = r
    mapthetac[i]=theta
    ENDFOR
;ENDFOR

END

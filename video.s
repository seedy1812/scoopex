    seg     CODE_SEG


LAYER2_CLIP_WINDOW   equ $18

num_c_1 equ 118
num_c_2 equ 90*2


r1Y:    dw    0
r2Y:    dw    (num_c_2)
r3Y:    dw    (num_c_2/3)*2
r4Y:    dw    0
r5Y:    dw    (num_c_2/4)*2
r6Y:    dw    0
r7Y:    dw    (num_c_2/5)*2
r8Y:    dw    0
r9Y:    dw   0
r10Y:   dw   (num_c_2/8)*2

columns_init:
       ld de,rasters_1_start
       ld bc,rasters_1_end - rasters_1_start
.loop1
       ld a,(de)
       ld h,0
       ld l,a
       add hl,rasters_1_pal
       ld a,(hl)

       ld (de),a
       inc de

       dec bc
       ld a,b
       or c
       jr nz,.loop1

       ld de,rasters_2_start
       ld bc,rasters_2_end - rasters_2_start
.loop2
       ld a,(de)
       ld h,0
       ld l,a
       add hl,rasters_2_pal
       ld a,(hl)

       ld (de),a
       inc de

       dec bc
       ld a,b
       or c
       jr nz,.loop2


       ret

oops: ds 256

columns_update:
;       border 1

       ld hl,(r1Y)
       add hl,2
       ld (r1Y),hl
       add hl,-num_c_1*2
       bit 7,h
       jr nz,.nwrap1
       ld (r1Y),hl
.nwrap1:

      ld hl,(r2Y)
       add hl,-2
       ld (r2Y),hl
;       add hl,-(rasters_2_mid-rasters_2_start)
       bit 7,h
       jr z,.nwrap2
       add hl,+num_c_2*2
       ld (r2Y),hl
.nwrap2:

       // stationary
 ;      ld hl,r3Y
 ;      ld a,(hl)
 ;      and $7f
 ;      ld (hl),a

       // up twice as fast
       ld hl,(r4Y)
       add hl,4
       ld (r4Y),hl
       add hl,-num_c_1*2
       bit 7,h
       jr nz,.nwrap4
       ld (r4Y),hl
.nwrap4:


       // down standard
       ld hl,(r5Y)
       add hl,-2
       bit 7,h
       jr z,.nwrap5
       add hl,+num_c_2*2
.nwrap5:
       ld (r5Y),hl

       // stationary
;       ld hl,r6Y
;       ld a,(hl)
;       and $7f
;       ld (hl),a

       // up standard
       ld hl,(r7Y)
       add hl,2
       ld (r7Y),hl
       add hl,-num_c_2*2
       bit 7,h
       jr nz,.nwrap7
       ld (r7Y),hl
.nwrap7:

       // up double
       ld hl,(r8Y)
       add hl,4
       ld (r8Y),hl
       add hl,-num_c_1*2
       bit 7,h
       jr nz,.nwrap8
       ld (r8Y),hl
.nwrap8:


       // down standard
       ld hl,(r9Y)
       add hl,-2
       bit 7,h
       jr z,.nwrap9
       add hl,+num_c_1*2
.nwrap9:
       ld (r9Y),hl


       // down double
       ld hl,(r10Y)
       add hl,-4
       bit 7,h
       jr z,.nwrap10
       add hl,num_c_2*2
.nwrap10:
       ld (r10Y),hl

       call rasters_fill
       ret

rasters_fill:

       border 2

       ld hl,rasters_1_start
       ld bc,(r1y)
      
       ld de,line_col+3+0*4                  // next reg op,r,v
       call raster_column

       border 1

       ld hl,rasters_2_start
       ld bc,(r2y)
       ld de,line_col+3+1*4                  // next reg op,r,v
       call raster_column

       border 2

       ld hl,rasters_2_start
       ld bc,(r3y)
       ld de,line_col+3+2*4                  // next reg op,r,v
       call raster_column

       border 3

       ld hl,rasters_1_start
       ld bc,(r4y)
       ld de,line_col+3+3*4                  // next reg op,r,v
       call raster_column

       border 4

       ld hl,rasters_2_start
       ld bc,(r5y)
       ld de,line_col+3+4*4                  // next reg op,r,v
       call raster_column

       border 7

       ld hl,rasters_1_start
       ld bc,(r6y)
       ld de,line_col+3+5*4                  // next reg op,r,v
       call raster_column



       border 6
       ld hl,rasters_2_start
       ld bc,(r7y)
       ld de,line_col+3+6*4                  // next reg op,r,v
       call raster_column

       border 7
       ld hl,rasters_1_start
       ld bc,(r8y)
       ld de,line_col+3+7*4                  // next reg op,r,v
       call raster_column


       border 6
       ld hl,rasters_1_start
       ld bc,(r9y)
       ld de,line_col+3+8*4                  // next reg op,r,v
       call raster_column

       border 5
       ld hl,rasters_2_start
       ld bc,(r10y)
       ld de,line_col+3+9*4                  // next reg op,r,v
       call raster_column

      border 3

       ret

ras_volume: equ (line_end-line_col)
ras_item: equ (line_0-line_col)


remainder equ (ras_volume/ras_item)

raster_column:
       sra b
       rr c
       add   hl,bc

       ld a, 0
       ld b, +(ras_volume/ras_item) & 7
       cp b
       jr z, .loopb
       inc b
.loopa:
       ldi
       add de,ras_item-1
       inc a  
       djnz .loopa
.loopb:
       ldi
       add de,ras_item-1
       ldi
       add de,ras_item-1
       ldi
       add de,ras_item-1
       ldi
       add de,ras_item-1
       ldi
       add de,ras_item-1
       ldi
       add de,ras_item-1
       ldi
       add de,ras_item-1
       ldi
       add de,ras_item-1
       add a,8
       cp ras_volume/ras_item
       jr nz,.loopb

       ret


video_setup:

       nextreg $43,%01100000   ; select tilemap 1st palette
       nextreg $40,1           ; palette index
       nextreg $4c,$0           ; 0 is transparent

       nextreg $68,%00000000   ;ula disable
       nextreg $6b,%10100011    ; Tilemap Control 512 tiles + above ula
       nextreg $6c,%00000010

       nextreg $1c,%00001000 ; Clip Window control : reset tilemap index

       nextreg $15,%00000111 ; no low rez , LSU , no sprites , no over border

       ret


 ReadNextReg:
       push bc
       ld bc,$243b
       out (c),a
       inc b
       in a,(c)
       pop bc
       ret


;; Detect current video mode:
;; 0, 1, 2, 3 = HDMI, ZX48, ZX128, Pentagon (all 50Hz), add +4 for 60Hz modes
;; (Pentagon 60Hz is not a valid mode => value 7 shouldn't be returned in A)
DetectMode:
       ld      a,$05 ; PERIPHERAL_1_NR_05
       call    ReadNextReg
       and     $04             ; bit 2 = 50Hz/60Hz configuration
       ld      b,a             ; remember the 50/60 as +0/+4 value in B
       ; read HDMI vs VGA info
       ld      a,$11 ; VIDEO_TIMING_NR_11
       call    ReadNextReg
       inc     a               ; HDMI is value %111 in bits 2-0 -> zero it
       and     $07
       jr      z,.hdmiDetected
       ; if VGA mode, read particular zx48/zx128/pentagon setting
       ld      a,$03
       call    ReadNextReg
       ; a = bits 6-4: %00x zx48, %01x zx128, %100 pentagon
       swapnib
       rra
       inc     a
       and     $03             ; A = 1/2/3 for zx48/zx128/pentagon
.hdmiDetected:
       add     a,b             ; add 50/60Hz value to final result
       ret

VideoScanLines: ; 1st copper ,2nd irq
       dw 312-32                           ; hdmi_50
       dw 312-32                           ; zx48_50
       dw 311-32                           ; zx128_50
       dw 320-32                           ; pentagon_50

       dw 262-32                           ; hdmi_60
       dw 262-32                            ; zx48_60
       dw 261-32                            ; zx128_60
       dw 262-32                            ; pentagon_60

GetMaxScanline:
       call DetectMode:
       ld hl, VideoScanLines
       add a,a
       add hl,a
       ret

if 0
StartCopper:


	ld      hl,copper_line_start
	ld      bc,+(copper_the_end-copper_line_start+2)
 
do_copper:
	nextreg $61,0   ; LSB = 0
	nextreg $62,0   ;// copper stop | MSBs = 00

@lp1:	ld	a,(hl)  ;// write the bytes of the copper
	nextreg $60,a
	inc	hl
       dec bc
	ld	a,b
	or	c
	jr	nz,@lp1		

;       border 1

	nextreg $62,%01000000 ;// copper start | MSBs = 00

	ret
endif 

  
		// copper WAIT  VPOS,HPOS
COPPER_WAIT	macro
		db	HI($8000+(\0&$1ff)+(( (\1/8) &$3f)<<9))
		db	LO($8000+(\0&$1ff)+(( ((\1/8) >>3) &$3f)<<9))
		endm
		// copper MOVE reg,val
COPPER_MOVE		macro
		db	HI($0000+((\0&$ff)<<8)+(\1&$ff))
		db	LO($0000+((\0&$ff)<<8)+(\1&$ff))
		endm
COPPER_NOP	macro
		db	0,0
		endm

COPPER_HALT     macro
                db 255,255
                endm

COPPER_SET_PAL_INDEX macro
                     COPPER_MOVE(PAL_INDEX,\0)
                     endm

COPPER_SET_COLOR     macro
                     COPPER_MOVE(PAL_VALUE_8BIT,\0)
                     endm

PAL_LAYER2  macro
             COPPER_MOVE($43,%10010001)
              endm

PAL_LAYER2_PAL2  macro
             COPPER_MOVE($43,%01010101)
              endm


PAL_LAYER3  macro
             COPPER_MOVE($43,%10110001)
              endm

PAL_LAYER3_2  macro
             COPPER_MOVE($43,%10110101)
              endm



DNA_FADE_PAL_X equ 256
; pass Y
;1__4_6_89_

;_23_5_7__0

rasters_1_start:
       incbin "gfx/1__4_6_89_.nxi"
rasters_1_mid
       incbin "gfx/1__4_6_89_.nxi"
rasters_1_end:

rasters_1_pal:
       incbin "gfx/1__4_6_89_.nxp"

rasters_2_start:
       incbin "gfx/_23_5_7__0.nxi"
rasters_2_mid
       incbin "gfx/_23_5_7__0.nxi"
rasters_2_end:

rasters_2_pal:
       incbin "gfx/_23_5_7__0.nxp"

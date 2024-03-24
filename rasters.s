if 0
;var copper=[];
;for (var c=1; c<13; c++){
;	copper[c]=new image(basepath+'copperbar'+(13-c)+'.png');
;	}
;var copper_i=[];
;var c_i=0;
;for (var cc=1; cc<13; cc++){
;	copper_i[cc]=c_i;
;	c_i+=2.5;
;	}
;
; 	for (var cpr=1; cpr<13; cpr++){
;		copper[cpr].draw(mycanvas,0,(270+(168)*Math.cos(copper_i[cpr]/30)),1,0,72,1);
;		copper_i[cpr]+=0.6;
;		}
endif

ras_angles: ds 32

ANG_INIT_STEP:  equ 9
ANG_ADD_STEP:   equ 2

rasters_init:
    ld de, 0
    ld b,12+1
    ld hl,ras_angles
.loop:
    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    add de,ANG_INIT_STEP
    res 1,d
    djnz .loop,b
    ret

rasters_ang_update:
    ld de, 0
    ld b,12+1
    ld ix,ras_angles

.loop
    ld e,(ix+0)
    ld d,(ix+1)
    add de,ANG_ADD_STEP
    res 1,d
    ld (ix+0),e
    ld (ix+1),d
    inc ix
    inc ix
    djnz .loop
    ret

RASTERS_RADIUS:     equ     40
RASTER_CENTRE_Y:    equ     64   

 rasters_set_y:
    ld b ,12+1
    ld de,ras_angles
    ld hl,ras_table_start
.lp: 
    push bc
    push hl
    ld a,(de)
    ld l,a
    inc de
    ld a,(de)
    ld h,a
    inc de
    push de

    call get_sin_hl_to_de

    ld hl,RASTERS_RADIUS
    call mul_hl_de 

    ld h,a
    add RASTER_CENTRE_Y

    pop de
    pop hl
    ld (hl),a
    add hl,3
    pop bc
    djnz .lp
    ret


ras_table_start:
    db 'X'
    dw c12_gfx_start
    db 'X'
    dw c11_gfx_start
    db 'X'
    dw c10_gfx_start
    db 'X'
    dw c9_gfx_start
    db 'X'
    dw c8_gfx_start
    db 'X'
    dw c7_gfx_start
    db 'X'
    dw c6_gfx_start
    db 'X'
    dw c5_gfx_start
    db 'X'
    dw c4_gfx_start
    db 'X'
    dw c3_gfx_start
    db 'X'
    dw c2_gfx_start
    db 'X'
    dw c1_gfx_start
    db 'X'
    dw c0_gfx_start
ras_table_end:

rasters_update:
    ret
    
    call rasters_ang_update 
    call rasters_set_y

    ld iy ,ras_table_start
    ld b,+(ras_table_end-ras_table_start)/3
.lp:

    ld a,(iy+0)
    ld l,(iy+1)
    ld h,(iy+2)

    push bc

    call raster_ouput

    ld de,3
    add iy,de

    pop bc
    djnz .lp:
    ret

raster_pal:
    push af
    ld a,(de)

    ld h,b
    ld l,c
    add hl,a
    ld a,(hl)
    ld (de),a
    inc de

    pop af
    dec a
    jr nz ,raster_pal
   
    ret


raster_ouput:
; hl - copper bar_gfx
; a = y

    ld d, ras_item
    ld e, a
    mul
    ld ix , line_col
    add ix,de

    ld de, ras_item
    ld b , c1_gfx_end-c1_gfx_start
.lp:
    ld a,(hl)
    inc hl
    ld (ix +3+0*4 ),a
    ld (ix +3+2*4 ),a
    ld (ix +3+4*4 ),a
    ld (ix +3+5*4 ),a
    ld (ix +3+7*4 ),a
    ld (ix +3+9*4 ),a
    add ix ,de
    djnz .lp
    ret


R2_R macro
     db   (\0 <<5)
        endm
R2_G macro
      db  (\0 <<2)
        endm

R2_B macro
      db  (\0/2)
        endm

R2_RG macro
     db   (\0 <<5) + (\0 <<2)
        endm

R2_RB macro
      db  (\0 <<5) + (\0/2)
        endm

R2_BG macro
      db  (\0 <<2) +(\0/2)
        endm

R2RGB macro
       db  (\0 <<5 ) + (\0 <<2 ) +(\0/2)
        endm

gfx_entry_x macro
    \5 \4
    \5 \3
    \5 \2
    \5 \1
    \5 \0
    \5 \1
    \5 \2
    \5 \3
    \5 \4
    endm

c0_gfx_start:   gfx_entry_x 7,6,5,4,3,R2_R
c1_gfx_start:   gfx_entry_x 7,6,5,4,3,R2_G
c1_gfx_end:
c2_gfx_start:   gfx_entry_x 7,6,5,4,3,R2_B

c3_gfx_start:   gfx_entry_x 7,6,5,4,3,R2_BG
c4_gfx_start:   gfx_entry_x 7,6,5,4,3,R2_RB
c5_gfx_start:   gfx_entry_x 7,6,5,4,3,R2_RG
c6_gfx_start:   gfx_entry_x 7,6,5,4,3,R2RGB
c7_gfx_start:   gfx_entry_x 5,4,3,2,1,R2_RG
c8_gfx_start:   gfx_entry_x 5,4,3,2,1,R2_RB
c9_gfx_start:   gfx_entry_x 5,4,3,2,1,R2_BG

c10_gfx_start:   gfx_entry_x 5,4,3,2,1,R2_B
c11_gfx_start:   gfx_entry_x 5,4,3,2,1,R2_G
c12_gfx_start:   gfx_entry_x 5,4,3,2,1,R2_R

    seg CODE_SEG

logo_init:
    nextreg $12,bank(logo_image_start)/2
    nextreg $43, %00010001
    nextreg PAL_INDEX,0

    ld b, 255
    ld hl,logo_pal_start
.loop:
    ld a,(hl)
    nextreg PAL_VALUE_8BIT,a
    inc hl
    djnz .loop

    ld a,%00000010
    ld bc, LAYER2_OUT  
	out (c), a
    ret



logo_period: dw 0

logo_period_step: equ 6

logo_update:

    ld hl ,(logo_period)
    add hl,logo_period_step
    ld (logo_period),hl

    call get_sin_hl_to_de

    ld hl,16
    call mul_hl_de 

    add 24

    bit 7,a
    jr z,.plus
    add 192
.plus:
    nextreg LAYER_2_Y_OFFSET , a

    ret

get_cos_hl_to_de
    add hl,512/4
get_sin_hl_to_de
    ld a,h
    and 1   ; sine table of 512 entries 0 -> 1ff
    ld h,a
    add hl,hl
    add hl,sine_table

    ld e,(hl)
    inc hl
    ld d,(hl)
    ret

mul_hl_de:       ; (uint16)HL = (uint16)HL x (uint16)DE
    ld      c,e
    ; HxD xh*yh is not relevant for 16b result at all
    ld      e,l
    mul             ; LxD xl*yh
    ld      a,e     ; part of r:8:15
    ld      e,c
    ld      d,h
    mul             ; HxC xh*yl
    add     a,e     ; second part of r:8:15
    ld      e,c
    ld      d,l
    mul             ; LxC xl*yl (E = r:0:7)
    add     a,d     ; third/last part of r:8:15
    ; result in AE (16 lower bits), put it to HL
    ld      h,a
    ld      l,e
    ret             ; =4+4+8+4+4+4+8+4+4+4+8+4+4+4+10 = 78T


logo_pal_start:
		incbin "gfx/logo.nxp"
logo_pal_end:

sine_table:
        include "sine.s"
sine_table_end:


   	seg LAYER2_SEG
logo_image_start:
	incbin "gfx/logo.nxi"
logo_image_end:

    seg     CODE_SEG

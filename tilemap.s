tileMap_addr    equ $4000
tileAttr_addr   equ $4c00

tilemap_init:

	nextreg $6b,%10100001           ; enable tilemap, 40x32, elim attrib, ula on top
	nextreg $6c,%00000000           ; default attrib
	nextreg $6e,HI(tileMap_addr)    ; tilemap at $4000
	nextreg $6f,HI(tileAttr_addr)   ; tile definitions $4c00

    ld hl,$4000

    ld a,0
.loop1
    ld (hl),a      ; 10 * ( 4 bytes same value [0 to 9])
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    inc a
    cp 10
    jr nz,.loop1

    ld d,h      ; copy over all tilemap
    ld e,l
    ld l,0
    ld bc,40*31
    ldir

    ; now fill in the 10 tiles
    ld hl,tileAttr_addr
    ld a,0
.lp0:
    ld b,8*8/2
.lp1:
    ld (hl),a
    inc hl
    djnz .lp1
    add $11
    cp $bb
    jr nz,.lp0


    ret


USE_NXMOD equ 1



LINE_INT_LSB		 equ $23
LAYER_2_Y_OFFSET 	 equ $17
PAL_INDEX            equ $40
PAL_VALUE_8BIT       equ $41

border: macro
           ld a,\0
            out ($fe),a
            endm


MY_BREAK	macro
        db $dd,01
		endm

	LAYER2_OUT			equ	$123B	; TBBlue layer 2 control

	LAYER2_RAM_BANK		equ $12
	LAYER2_SHADOW_BANK	equ $13
	DISP_CTRL_1			equ $69
	MMU_7				equ	$57
	DMA_PORT    		equ $6b ;//: zxnDMA

	OPT Z80
	OPT ZXNEXTREG    

    seg     CODE_SEG, 			 4:$0000,$8000
	seg		LAYER2_SEG,			 18:$0000,$0000

    seg     CODE_SEG

start:
;; set the stack pointer
	ld sp , StackStart

	call logo_init

	call tilemap_init

	call rasters_init
	
	call video_setup

	call init_vbl



	nextreg 7,%11 ; 28mhz


	nextreg $4c,$ff ; set transparent colour outside the 0 to 9

    nextreg $68,%00000000   ;ula disable

    nextreg $15,%00000111 ; no low rez , LSU , no sprites , no over border

    nextreg $43,%00110000   ; select tilemap 1st palette
 
frame_loop:
	call wait_vbl
	border 4
	call rasters_update
	call logo_update

	border 1

	jp frame_loop

StackEnd:
	ds	128
StackStart:
	ds  2

include "logo.s"

include "irq.s"
include "video.s"
include "tilemap.s"


    seg     CODE_SEG

THE_END:

 	savenex "player.nex",start


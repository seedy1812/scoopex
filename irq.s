	code_seg

irq_counter: db 0
irq_last_count: db 0


   align 32

IM_2_Table:
        dw      linehandler     ; 0 - line interrupt
        dw      inthandler      ; 1 - uart0 rx
        dw      inthandler      ; 2 - uart1 rx
        dw      ctc0handler     ; 3 - ctc 0
        dw      inthandler      ; 4 - ctc 1
        dw      inthandler      ; 5 - ctc 2
        dw      inthandler      ; 6 - ctc 3
        dw      inthandler      ; 7 - ctc 4
        dw      inthandler      ; 8 - ctc 5
        dw      inthandler      ; 9 - ctc 6
        dw      inthandler      ; 10 - ctc 7
IM_2_Table_VBL:
        dw      vbl             ; 11 - ula
        dw      inthandler      ; 12 - uart0 tx
        dw      inthandler      ; 13 - uart1 tx
        dw      inthandler      ; 14
        dw      inthandler      ; 15

init_vbl:
    di

    ld a,IM_2_Table>>8
    ld i,a

    nextreg $c0, 1+(IM_2_Table & %11100000) ;low byte IRQ table  | base vector = 0xa0, im2 hardware mode
   	
	nextreg $c4,1				; ULA interrupt ; line not disbled
	nextreg $c5,0               ; disable CTC channels
	nextreg $c6,0               ; disable UART

    ; not dma
    nextreg $cc,%10000000    ; NMI will interrupt dma
    nextreg $cd,0            ; ct 0 no interrupt dma
    nextreg $cd,0            ; ct 0 no interrupt dma

    im 2

    ei
    ret


vbl:
	di

	push af


	nextreg $c4,3				; ULA interrupt

    nextreg $22,2
    nextreg $23,0

	push hl
    ld hl,line_col
    ld (IM_2_Table),hl

	ld hl,irq_counter
	inc (hl)
	pop hl

	border 5

	pop af

    NextReg $c8,1
    ei
    reti

linehandler:
	my_break
    NextReg $c8,2
    ei
    reti

ctc0handler:
	my_break
    NextReg $c9,1
    ei
    reti

inthandler:
	my_break
    ei
    reti

wait_vbl:
    ld hl,irq_counter 
	ld a,(hl)
.loop:
	halt
    cp (hl)
    jr z,.loop
	ret
    

    INT_OFFSET equ 1
    
a_line  macro 
        nextreg PAL_VALUE_8BIT,1
        nextreg PAL_VALUE_8BIT,2
        nextreg PAL_VALUE_8BIT,3
        nextreg PAL_VALUE_8BIT,4
        nextreg PAL_VALUE_8BIT,5
        nextreg PAL_VALUE_8BIT,6
        nextreg PAL_VALUE_8BIT,7
        nextreg PAL_VALUE_8BIT,8
        nextreg PAL_VALUE_8BIT,9
        nextreg PAL_VALUE_8BIT,10
        nextreg PAL_INDEX,0
   
        di
        push hl
        ld hl,.next
        ld (IM_2_Table),hl
        pop hl

        nextreg $22,HI(INT_OFFSET+(\0))|2
        nextreg LINE_INT_LSB,LO(INT_OFFSET+(\0))
        NextReg $c8,2
        ei
        reti
.next:
        endm


a10_line macro
    a_line(\0+0)
    a_line(\0+1)
    a_line(\0+2)
    a_line(\0+3)
    a_line(\0+4)

    a_line(\0+5)
    a_line(\0+6)
    a_line(\0+7)
    a_line(\0+8)
    a_line(\0+9)
        endm

a50_line macro
    a10_line(\0+00)
    a10_line(\0+10)
    a10_line(\0+20)
    a10_line(\0+30)
    a10_line(\0+40)
    endm



line_col:
    a_line(0)
line_0:
    a_line(1)
    a_line(2)
    a_line(3)
    a_line(4)

    a_line(5)
    a_line(6)
    a_line(7)
    a_line(8)
    a_line(9)

    a10_line(10)
    a10_line(20)
    a10_line(30)
    a10_line(40)           ; 50

    a10_line(50)
    a10_line(60)
    a10_line(70)
    a10_line(80)           
    a10_line(90)

    a10_line(100)
    a10_line(110)
    a10_line(120)
    a10_line(130)           
    a10_line(140)

    a10_line(150)
    a10_line(160)
    a10_line(170)
    a10_line(180)           ; 50
    a_line(190)
    a_line(191)
line_end:
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_VALUE_8BIT,0
        nextreg PAL_INDEX,0
        ei
        reti


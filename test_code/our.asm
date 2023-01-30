;; Author - Rashen
	
	
	;;--- CODE START ---;;
	.inesprg 1
	.inesmap 0
	.inesmir 1
	.ineschr 1

	.bank 1     
	.org $FFFA
	.dw 0        ; no VBlank
	.dw Start    ; address to execute on reset
	.dw 0        ; no whatever

	.bank 0

    	.org $0000
Pointer_State  .db 0       ; a X position for our sprite, start at 20
Point_X        .db 0
Point_Y        .db 0


	.org $0300 ; OAM Copy location $0300
Sprite1_Y:     .db  0   ; sprite #1's Y value
Sprite1_T:     .db  0   ; sprite #1's Tile Number
Sprite1_S:     .db  0   ; sprite #1's special byte
Sprite1_X:     .db  0   ; sprite #1's X value

Sprite2_Y:     .db  0   ; same thing, same order for sprite #2
Sprite2_T:     .db  0   ; note that I numbered 1 2 ...
Sprite2_S:     .db  0   ; some people may actually prefer starting
Sprite2_X:     .db  0   ; 7the count at 0, but it doesn't really matter.

Sprite3_Y:     .db  0   ; 7same thing, same order for sprite #2
Sprite3_T:     .db  0   ; note that I numbered 1 2 ...
Sprite3_S:     .db  0   ; some people may actually prefer starting
Sprite3_X:     .db  0   ; the count at 0, but it doesn't really matter.

Sprite4_Y:     .db  0  ; 7same thing, same order for sprite #2
Sprite4_T:     .db  0   ; note that I numbered 1 2 ...
Sprite4_S:     .db  0   ; some people may actually prefer starting
Sprite4_X:     .db  0  ; 7the count at 0, but it doesn't really matter.


Pointer_Y:     .db  0  ; 7same thing, same order for sprite #2
Pointer_T:     .db  0   ; note that I numbered 1 2 ...
Pointer_S:     .db  0   ; some people may actually prefer starting
Pointer_X:     .db  0  ; 7the count at 0, but it doesn't really matter.

; this would just go on and on for however many sprites you have

	.org $8000  ; code starts at $8000 or $C000
Start:

	lda #%00001000  ;
	sta $2000       ; 
	lda #%00011110  ; Our typical PPU Setup code.
	sta $2001       ; 

	ldx #$00    ; clear X            ;; start of pallete loading code

	lda #$3F    ; have $2006 tell
	sta $2006   ; $2007 to start
	lda #$00    ; at $3F00 (pallete).
	sta $2006

loadpal:                ; this is a freaky loop
	lda tilepal, x  ; that gives 32 numbers
	sta $2007       ; to $2007, ending when
	inx             ; X is 32, meaning we
	cpx #32         ; are done.
	bne loadpal     ; if X isn't =32, goto "loadpal:" line.
	                                ;; end of pallete loading code

;Sprite positioning
;sprite 1
	lda #$10
    sta Sprite1_Y
    lda #$10
    sta Sprite1_T
    lda #$00
    sta Sprite1_S
    lda #$10
    sta Sprite1_X
;sprite 2
    lda #$10
    sta Sprite2_Y
    lda #$11
    sta Sprite2_T
    lda #$00
    sta Sprite2_S
    lda #$18
    sta Sprite2_X
;sprite 3
    lda #$18
    sta Sprite3_Y
    lda #$20
    sta Sprite3_T
    lda #$00
    sta Sprite3_S
    lda #$10
    sta Sprite3_X
;sprite 4
    lda #$18
    sta Sprite4_Y
    lda #$21
    sta Sprite4_T
    lda #$00
    sta Sprite4_S
    lda #$18
    sta Sprite4_X
;pointer sprite
    lda #$20
    sta Pointer_Y
    lda #$12
    sta Pointer_T
    lda #$00
    sta Pointer_S
    lda #$20
    sta Pointer_X

infinite:  ; a label to start our infinite loop
waitblank:         
	lda $2002  ; these 3 lines wait for VBlank, this loop will actually miss VBlank
	bpl waitblank ; alot, in a later Day, I'll give a better way.
    
	lda Pointer_State
    and #1
    beq Temp_Display
    bne Top_Down
    
Top_Down:
    lda Sprite1_Y
    cmp Point_Y
    beq Left_Right
    bpl Sprite_UP
    bmi Sprite_DOWN
    
Left_Right:
    lda Sprite1_X
    cmp Point_X 
    beq Temp_Display
    bpl Sprite_LEFT
    bmi Sprite_RIGHT
    
    
Sprite_UP:
	lda Sprite1_Y ; load A with Y position
	sbc #$1  ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite1_Y ; store back to memory

	lda Sprite2_Y ; load A with Y position
	sbc #$1  ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite2_Y ; store back to memory

	lda Sprite3_Y ; load A with Y position
	sbc #$1  ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite3_Y ; store back to memory

	lda Sprite4_Y ; load A with Y position
	sbc #$1  ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite4_Y ; store back to memory
    ;jmp DISPLAY
    jmp Left_Right
	 ; jump over the rest of the handling code.

Sprite_DOWN:
	lda Sprite1_Y ; load A with Y position
	adc #$1   ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite1_Y ; store back to memory

	lda Sprite2_Y ; load A with Y position
	adc #$1   ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite2_Y ; store back to memory

	lda Sprite3_Y ; load A with Y position
	adc #$1   ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite3_Y ; store back to memory

	lda Sprite4_Y ; load A with Y position
	adc #$1   ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite4_Y ; store back to memory
    ;jmp DISPLAY
    jmp Left_Right
Temp_Display:
    jmp DISPLAY
Sprite_LEFT:
	lda Sprite1_X
	sbc #$1  
	sta Sprite1_X

	lda Sprite2_X
	sbc #$1  
	sta Sprite2_X

	lda Sprite3_X
	sbc #$1  
	sta Sprite3_X

	lda Sprite4_X
	sbc #$1  
	sta Sprite4_X
    jmp DISPLAY

Sprite_RIGHT:
	lda Sprite1_X
	adc #$1  
	sta Sprite1_X

	lda Sprite2_X
	adc #$1  
	sta Sprite2_X

	lda Sprite3_X
	adc #$1  
	sta Sprite3_X

	lda Sprite4_X
	adc #$1  
	sta Sprite4_X
    jmp DISPLAY
DISPLAY:	
	; don't need to jump to NOTHINGdown, it's right below. Saved several bytes of
	; PRG-Bank space! :)
	lda #3
	sta $4014
	
	lda #$01   ; these
	sta $4016  ; lines
	lda #$00   ; setup/strobe the 
	sta $4016  ; keypad.

	lda $4016  ; load Abutton Status ; note that whatever we ain't interested
    and #1     ; AND status with #1
	bne PointerClick
	lda $4016  ; load Bbutton Status ; in we just load so it'll go to the next one.
	lda $4016  ; load Select button status
	lda $4016  ; load Start button status
	lda $4016  ; load UP button status
	and #1     ; AND status with #1
	bne UPKEYdown  ; for some reason (not gonna reveal yet), need to use NotEquals
	;with ANDs. So it'll jump (branch) if key was down.
	
	lda $4016  ; load DOWN button status
	and #1     ; AND status with #1
	bne DOWNKEYdown

	lda $4016  ; load LEFT button status
	and #1     ; AND status with #1
	bne LEFTKEYdown

	lda $4016  ; load RIGHT button status
	and #1     ; AND status with #1
	bne RIGHTKEYdown
	jmp NOTHINGdown  ; if nothing was down, we just jump (no check for conditions)
	; down past the rest of everything.
PointerClick:
    lda #1
    sta Pointer_State

    lda Pointer_X
    sta Point_X

    lda Pointer_Y
    sta Point_Y

    jmp NOTHINGdown

UPKEYdown:
	lda Pointer_Y ; load A with Y position
	sbc #1  ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Pointer_Y ; store back to memory

	jmp NOTHINGdown  ; jump over the rest of the handling code.

DOWNKEYdown:
	lda Pointer_Y ; load A with Y position
	adc #1   ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Pointer_Y ; store back to memory

	jmp NOTHINGdown ; jump over the rest of handling code.

LEFTKEYdown:
	lda Pointer_X
	sbc #1  
	sta Pointer_X

	jmp NOTHINGdown 


RIGHTKEYdown:

	lda Pointer_X
	adc #1  
	sta Pointer_X
	jmp NOTHINGdown 
	; don't need to jump to NOTHINGdown, it's right below. Saved several bytes of
	; PRG-Bank space! :)






NOTHINGdown:
	jmp infinite

tilepal:   .incbin "our.pal"  ; a label for our pallete data

	.bank 2
	.org $0000
	.incbin "our.bkg"
	.incbin "our.spr"

;;--- END OF CODE FILE ---;;

; INES Header
	.inesprg 1
	.inesmap 0
	.inesmir 1
	.ineschr 1

; configuring bank 1
	.bank 1     
	.org $FFFA
	.dw 0        ; no NMI
	.dw Start    ; address to execute on reset
	.dw 0        ; no whatever

; start writing main code to bank 0
	.bank 0

; defining variables
	.org $0000
X_Pos   .db 20       ; a X position for our sprite, start at 20
Y_Pos   .db 20       ; a Y position for our sprite, start at 20

; program code
	.org $8000  ; code starts at $8000 or $C000

Start:
	lda #%00001000  ;
	sta $2000       ; 
	lda #%00011110  ; Our typical PPU Setup code.
	sta $2001       ; 

;;;;; start of pallete loading code ;;;;;;;

	ldx #$00    ; clear X    

	lda #$3F    ; start loading palette at $3F00
	sta $2006   ; 
	lda #$00    ; 
	sta $2006

loadpal:             
	lda tilepal, x  ;
	sta $2007       ;
	inx             ;
	cpx #32         ;
	bne loadpal     ;

;;;;;; end of pallete loading code ;;;;;;;;


infinite:  ; a label to start infinite loop

; waiting for vblank
waitblank:         
	lda $2002
	bpl waitblank

;start writing OAM data to load sprites on screen

	lda #$00   ; these lines tell $2003
	sta $2003  ; to tell
	lda #$00   ; $2004 to start
	sta $2003  ; at $0000.

	lda Y_Pos  ; load Y value
	sta $2004 ; store Y value

	lda #$00  ; tile number 0
	sta $2004 ; store tile number

	lda #$00 ; no special junk
	sta $2004 ; store special junk

	lda X_Pos  ; load X value
	sta $2004 ; store X value

;;;;; keypad reading ;;;;;;;

; strobe the keypad
	lda #$01   ; 
	sta $4016  ; 
	lda #$00   ; 
	sta $4016  ; 

	lda $4016  ; load Abutton Status ; note that whatever we ain't interested
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

;; responding to key presses

UPKEYdown:
	lda Y_Pos ; load A with Y position
	sbc #1  ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Y_Pos ; store back to memory
	jmp NOTHINGdown  ; jump over the rest of the handling code.

DOWNKEYdown:
	lda Y_Pos 
	adc #1  ; add 1 to A. ADC (Add with Carry)((to A register))
	sta Y_Pos
	jmp NOTHINGdown ; jump over the rest of handling code.

LEFTKEYdown:
	lda X_Pos
	sbc #1  
	sta X_Pos
	jmp NOTHINGdown 
;the left and right handling code does the same as UP and Down except.. well.. with
; left and right. :)

RIGHTKEYdown:
	lda X_Pos
	adc #1
	sta X_Pos
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
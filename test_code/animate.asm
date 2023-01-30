;;Author -  Rahal

; INES header - configures banks
    .inesprg 1  ; no. of code banks - 1
    .ineschr 1  ; no of spr/bkg data banks - 1
    .inesmir 1  ; no f*cking clue
    .inesmap 0  ; using mapper 0

; configuring bank 1
    .bank 1     ; go to bank 1
    .org $FFFA  ; start at $FFFA
    .dw 0       ; NMI vector address set to 0
    .dw Start   ; Reset vector address "Start" location
    .dw 0       ; location of VBlank interrupt??

;Start writing main code to bank 0
    .bank 0

    .org $0000

X_Click   .db 0         ; a X position for our sprite
Y_Click   .db 0         ; stores values for sprite 5

X_Pos       .db 0       ; position of sprite 5
Y_Pos       .db 0
X_Pos2      .db 0       ; position of sprite 1
Y_Pos2      .db 0

Anim        .db 0       ; which animation to use

    .org $0300 ; OAM Copy location $0300

Sprite1_Y     .db  0   ; sprite #1's Y value
Sprite1_T     .db  0   ; sprite #1's Tile Number
Sprite1_S     .db  0   ; sprite #1's special byte
Sprite1_X     .db  0   ; sprite #1's X value

Sprite2_Y     .db  0   ;
Sprite2_T     .db  0   ;
Sprite2_S     .db  0   ;
Sprite2_X     .db  0   ;

Sprite3_Y     .db  0   ;
Sprite3_T     .db  0   ;
Sprite3_S     .db  0   ;
Sprite3_X     .db  0   ;

Sprite4_Y     .db  0   ;
Sprite4_T     .db  0   ;
Sprite4_S     .db  0   ;
Sprite4_X     .db  0   ;

Sprite5_Y     .db  0   ;
Sprite5_T     .db  0   ;
Sprite5_S     .db  0   ;
Sprite5_X     .db  0   ;

    .org $8000  ;code starts at $8000

Start:
;configure PPU control registers
    lda #%00001000  ;configuration byte for PPUCTRL register
    sta $2000       ;PPUCTRL register address
    lda #%00011110  ;configuration byte for PPUMASK register
    sta $2001       ;PPUMASK register address

    ldx #$00    ; clear X register

;load palette into PPU memory at $3F00 using PPUADDR register
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

;use loop to load 32 bytes into address starting at $3F00
loadpal:
    lda tilepal, x  ; load xth byte of pal file
    sta $2007       ; write to $2007
    inx
    cpx #$20        ; compare x to 32 ($20)
    bne loadpal

; load background into PPU memory
    lda $2002   ; reset PPU latch
    lda #$20
	sta $2006 ; give $2006 both parts of address $2000.
    lda #$00
	sta $2006 

	ldx #$00
loadNames:
	lda ourMap, X ; load A with a byte from address (ourMap + X)
	inx
	sta $2007
	cpx #255 ; map in previous section 64 bytes long
	bne loadNames ; if not all 64 done, loop and do some more


;;initialise
    lda #$32
    sta Sprite1_Y
    lda #$12
    sta Sprite1_T
    lda #$00
    sta Sprite1_S
    lda #$34
    sta Sprite1_X

    lda #$10
    sta Sprite2_T
    lda #$00
    sta Sprite2_S

    lda #$11
    sta Sprite3_T
    lda #$00
    sta Sprite3_S

    lda #$20
    sta Sprite4_T
    lda #$00
    sta Sprite4_S

    lda #$21
    sta Sprite5_T
    lda #$00
    sta Sprite5_S

    lda #$3A
    sta Y_Click
    lda #$1C
    sta X_Click

    lda #$3A
    sta Y_Pos
    sbc #08
    sta Y_Pos2
    lda #$1C
    sta X_Pos
    sbc #08
    sta X_Pos2

;;;;;;; start game loop ;;;;;;;;;;;;;;;

infin:

;wait for vblank to start writing
waitblank:
    lda $2002   ; this register tells if vblank is occuring
    bpl waitblank

;writing OAM data to load sprite onto screen
;write $3 to DMA register
;this copies memory $0300-$03FF to OAM memory
	lda #$03
	sta $4014

; strobe the keypad
	lda #$01   ; 
	sta $4016  ; 
	lda #$00   ; 
	sta $4016  ; 

	lda $4016  ; load Abutton Status ;
    and #1     ; AND status with #1
	bne AKEYdown

	lda $4016  ; load Bbutton Status ;
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

AKEYdown:
    lda Sprite1_X
    sta X_Click
    lda Sprite1_Y
    sta Y_Click
    jmp NOTHINGdown

UPKEYdown:
	lda Sprite1_Y ; load A with Y position
	sbc #1  ; subtract 1 from A. Only can do math on A register. SBC (Subtract with Borrow)
	sta Sprite1_Y ; store back to memory
	jmp NOTHINGdown  ; jump over the rest of the handling code.

DOWNKEYdown:
	lda Sprite1_Y 
	adc #1  ; add 1 to A. ADC (Add with Carry)((to A register))
	sta Sprite1_Y
	jmp NOTHINGdown ; jump over the rest of handling code.

LEFTKEYdown:
	lda Sprite1_X
	sbc #1  
	sta Sprite1_X
	jmp NOTHINGdown 
;the left and right handling code does the same as UP and Down except.. well.. with
; left and right. :)

RIGHTKEYdown:
	lda Sprite1_X
	adc #1
	sta Sprite1_X
	; don't need to jump to NOTHINGdown, it's right below. Saved several bytes of
	; PRG-Bank space! :)

NOTHINGdown:
; end of input section


; check X movement

    lda X_Pos
    cmp X_Click
    beq NoXMove
    bmi MoveRight
    bpl MoveLeft

MoveLeft:    
    lda X_Pos
    sbc #$01
    sta X_Pos
    lda X_Pos2
    sbc #$01
    sta X_Pos2

    lda #$01
    sta Anim
    
    jmp XMoveDone

MoveRight:   
    lda X_Pos
    adc #$01
    sta X_Pos
    lda X_Pos2
    adc #$01
    sta X_Pos2

    lda #$01
    sta Anim
    
    jmp XMoveDone

NoXMove:    
    lda #$00
    sta Anim
    jmp XMoveDone

XMoveDone:

; check Y movement

    lda Y_Pos
    cmp Y_Click
    beq NoYMove
    bmi MoveDown
    bpl MoveUp

MoveUp:    
    lda Y_Pos
    sbc #$01
    sta Y_Pos
    lda Y_Pos2
    sbc #$01
    sta Y_Pos2
    
    jmp NoYMove

MoveDown:   
    lda Y_Pos
    adc #$01
    sta Y_Pos
    lda Y_Pos2
    adc #$01
    sta Y_Pos2
    
    jmp NoYMove

NoYMove:

;;; update positions

    lda X_Pos
    sta Sprite5_X
    sta Sprite3_X
    lda X_Pos2
    sta Sprite4_X
    sta Sprite2_X

    lda Y_Pos
    sta Sprite5_Y
    sta Sprite4_Y
    lda Y_Pos2
    sta Sprite3_Y
    sta Sprite2_Y

    lda Anim
    cmp #$00
    beq CloseMouth
    bne OpenMouth

OpenMouth:
    lda #$23
    sta Sprite5_T
    lda #$22
    sta Sprite4_T
    jmp NoAnimate

CloseMouth:
    lda #$21
    sta Sprite5_T
    lda #$20
    sta Sprite4_T
    jmp NoAnimate

NoAnimate:

	jmp infin


tilepal: .incbin "our.pal"  ; include pallete file
ourMap: .incbin "our.map"   ; include background map

    .bank 2     ; switch to bank 2
    .org $0000  
    .incbin "our.bkg"
    .incbin "our.spr"

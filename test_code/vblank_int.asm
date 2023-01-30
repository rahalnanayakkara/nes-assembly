; INES header - configures banks
    .inesprg 1  ; no. of code banks - 1
    .ineschr 1  ; no of spr/bkg data banks - 1
    .inesmir 1  ; no f*cking clue
    .inesmap 0  ; using mapper 0


; configuring bank 1
	.bank 1
	.org $FFFA
	.dw VBlank_Routine ; NMI address to execute on VBlank
	.dw Start ; address to execute at RESET.
	.dw 0  ; address to execute during a BRK instruction (Another Day, Another time).

; bank 0 - code
	.bank 0

	.org $0000  ;variables
VBlankOrNo:  .db 0


    .org $0300 ; OAM Copy location $0300

Sprite1_Y:     .db  0   ; sprite #1's Y value
Sprite1_T:     .db  0   ; sprite #1's Tile Number
Sprite1_S:     .db  0   ; sprite #1's special byte
Sprite1_X:     .db  0   ; sprite #1's X value

Sprite2_Y:     .db  0   ;
Sprite2_T:     .db  0   ;
Sprite2_S:     .db  0   ;
Sprite2_X:     .db  0   ;

Sprite3_Y:     .db  0   ;
Sprite3_T:     .db  0   ;
Sprite3_S:     .db  0   ;
Sprite3_X:     .db  0   ;

Sprite4_Y:     .db  0   ;
Sprite4_T:     .db  0   ;
Sprite4_S:     .db  0   ;
Sprite4_X:     .db  0   ;

Sprite5_Y:     .db  0   ;
Sprite5_T:     .db  0   ;
Sprite5_S:     .db  0   ;
Sprite5_X:     .db  0   ;

Sprite6_Y:     .db  0   ;
Sprite6_T:     .db  0   ;
Sprite6_S:     .db  0   ;
Sprite6_X:     .db  0   ;

Sprite7_Y:     .db  0   ;
Sprite7_T:     .db  0   ;
Sprite7_S:     .db  0   ;
Sprite7_X:     .db  0   ;

Sprite8_Y:     .db  0   ;
Sprite8_T:     .db  0   ;
Sprite8_S:     .db  0   ;
Sprite8_X:     .db  0   ;

Sprite9_Y:     .db  0   ;
Sprite9_T:     .db  0   ;
Sprite9_S:     .db  0   ;
Sprite9_X:     .db  0   ;

Sprite10_Y:     .db  0  ;
Sprite10_T:     .db  0  ;
Sprite10_S:     .db  0  ;
Sprite10_X:     .db  0  ;

	.org $8000  ;code

VBlank_Routine:         ;start of function to execute on VBlank
	inc VBlankOrNo      ; add one (1) to VBlankOrNo, will be 1 if VBlank, 0 if not.
	rti                 ; RTI is (Interrupt RETurn or ReTurn from Interrupt)

Start:
	;start of main code

;configure PPU control registers
    lda #%10001000  ;configuration byte for PPUCTRL register
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

;;sprite positioning
    lda #$32
    sta Sprite1_Y
    lda #$01
    sta Sprite1_T
    lda #$00
    sta Sprite1_S
    lda #$14
    sta Sprite1_X

    lda #$32
    sta Sprite2_Y
    lda #$02
    sta Sprite2_T
    lda #$00
    sta Sprite2_S
    lda #$1C
    sta Sprite2_X

    lda #$32
    sta Sprite3_Y
    lda #$03
    sta Sprite3_T
    lda #$00
    sta Sprite3_S
    lda #$24
    sta Sprite3_X

    lda #$32
    sta Sprite4_Y
    lda #$04
    sta Sprite4_T
    lda #$00
    sta Sprite4_S
    lda #$2C
    sta Sprite4_X

    lda #$32
    sta Sprite5_Y
    lda #$05
    sta Sprite5_T
    lda #$00
    sta Sprite5_S
    lda #$34
    sta Sprite5_X

    lda #$32
    sta Sprite6_Y
    lda #$06
    sta Sprite6_T
    lda #$00
    sta Sprite6_S
    lda #$3C
    sta Sprite6_X

    lda #$3A
    sta Sprite7_Y
    lda #$07
    sta Sprite7_T
    lda #$00
    sta Sprite7_S
    lda #$4C
    sta Sprite7_X

    lda #$3A
    sta Sprite8_Y
    lda #$08
    sta Sprite8_T
    lda #$00
    sta Sprite8_S
    lda #$54
    sta Sprite8_X

    lda #$3A
    sta Sprite9_Y
    lda #$06
    sta Sprite9_T
    lda #$00
    sta Sprite9_S
    lda #$5C
    sta Sprite9_X

    lda #$3A
    sta Sprite10_Y
    lda #$03
    sta Sprite10_T
    lda #$00
    sta Sprite10_S
    lda #$64
    sta Sprite10_X

;wait for vblank to start writing

WaitForVBlank:
	lda VBlankOrNo ; A = VBlankOrNO
	cmp #1         ; if A == 1 then is VBlank
	bne WaitForVBlank ; if not VBlank, then loop and do again
	dec VBlankOrNo ; 1-- or VBlankOrNO - 1 . VBlankOrNo will be 0 again.

;writing OAM data to load sprite onto screen
;write $3 to DMA register
;this copies memory $0300-$03FF to OAM memory
	lda #$03
	sta $4014

infin:
    jmp infin   ; end with infinite loop

tilepal: .incbin "our.pal"  ; include pallete file

    .bank 2     ; switch to bank 2
    .org $0000  
    .incbin "our.bkg"
    .incbin "our.spr"

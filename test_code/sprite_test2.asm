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

;wait for vblank to start writing
waitblank:
    lda $2002   ; this register tells if vblank is occuring
    bpl waitblank

;writing OAM data to load sprite onto screen
;write address $0000 to OAMADRR register
    lda #$00
    sta $2003
    sta $2003

;writing 4 bytes of the first sprite
    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$01    ; tile number 1
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$14    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$02    ; tile number 2
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$1C    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$03    ; tile number 3
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$24    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$04    ; tile number 4
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$2C    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$05    ; tile number 5
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$34    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$06    ; tile number 6
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$3C    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$07    ; tile number 7
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$4C    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$08    ; tile number 8
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$54    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$06    ; tile number 6
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$5C    ; load X value of 20 ($14) to sprite
    sta $2004

    lda #$32    ; load Y value of 50 ($32) to sprite
    sta $2004
    lda #$03    ; tile number 3
    sta $2004
    lda #$00    ; special attributes
    sta $2004
    lda #$64    ; load X value of 20 ($14) to sprite
    sta $2004

infin:
    jmp infin   ; end with infinite loop

tilepal: .incbin "our.pal"  ; include pallete file

    .bank 2     ; switch to bank 2
    .org $0000  
    .incbin "our.bkg"
    .incbin "our.spr"

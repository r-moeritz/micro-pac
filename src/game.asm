        ;; ============================================================
        ;; Game-logic related routines
        ;; ============================================================

        ;; Start a new game
newgame:
        jsr fillmaze            ;fill maze with pellets
        jsr clrzp
        ldbimm maxpell, npelrem
        ldbimm maxmen, nmenrem
        jsr initpac
        jsr printmen
        jsr printlvl
        jmp gameloop

        ;; Setup next game level
nextlvl:
        inc lvlnum
        jsr fillmaze
        jsr fillcolmem
        jsr clrbuf
        ldbimm maxpell, npelrem
        ldbimm 0, frtena
        jsr initpac
        rts
        
        ;; Clear out ZP memory used to avoid garbage data
clrzp:  filmem $a3, 9, 0        ;$a3 - $ab
        filmem $f7, 9, 0        ;$f7 - $ff
        
        ;; Clear out temporary buffer to avoid garbage data
clrbuf: filmem buf, 15, 0       ;$16 - $24
        rts

printmen:
        lda nmenrem
        cmp #2
        bcc :+
        
        ;; Sprite 3
        ldbimm sp0loc+2, sp0ptr+3     ;set sprite 3 pointer
        lda sp0col
        sta sp0col+3                  ;set sprite 3 colour
        ldbimm 26, sp3x               ;set sprite 3 x loc
        ldbimm 0, sp3y                ;set sprite 3 y loc
        lda spena
        ora #%00001000
        sta spena                     ;enable sprite 3

        lda nmenrem
        cmp #3
        bcc :+
        
        ;; Sprite 4
        ldbimm sp0loc+2, sp0ptr+4     ;set sprite 4 pointer
        lda sp0col
        sta sp0col+4                  ;set sprite 4 colour
        ldbimm 38, sp4x               ;set sprite 4 x loc
        ldbimm 0, sp4y                ;set sprite 4 y loc
        lda spena
        ora #%00010000
        sta spena                     ;enable sprite 4

        lda nmenrem
        cmp #4
        bcc :+

        ;; Sprite 5
        ldbimm sp0loc+2, sp0ptr+5     ;set sprite 5 pointer
        lda sp0col
        sta sp0col+5                  ;set sprite 5 colour
        ldbimm 38, sp5x               ;set sprite 5 x loc
        ldbimm 0, sp5y                ;set sprite 5 y loc
        lda spena
        ora #%00010000
        sta spena                     ;enable sprite 5        
      
:       rts

printlvl:
        jsr lvlfrtspix          ;find fruit sprite index for level, store in .A
        clc
        adc #sp0loc
        sta sp0ptr+1            ;write to sprite 1 pointer
        ina                     ;increment .A
        sta sp0ptr+2            ;write to sprite 2 pointer
        ;; Set sprite colours
        jsr lvlfrtspof          ;find fruit sprite memory offset
        sty irqwrd1             ;save offset (lo) onto irqwrd (lo)
        sta irqwrd1+1           ;save offset (hi) onto irqwrd (hi)
        adcwimm sp0mem, irqwrd1
        ldy #$3f                ;index to sprite colour value
        lda (irqwrd1),y         ;load sprite colour value
        and #%00001111          ;mask out hi nybble
        sta sp0col+1            ;write to sprite 1 colour register
        adcwimm $0040, irqwrd1  ;Add $40 to offset to advance to next sprite
        lda (irqwrd1),y         ;load sprite colour value
        and #%00001111          ;mask out hi nybble
        sta sp0col+2            ;write to sprite 2 colour register
        ;; Set sprite 1+2 x,y locations
        lda #180
        sta sp1x
        sta sp2x
        lda #0
        sta sp1y
        sta sp2y
        ;; Enable sprites 1+2
        lda spena
        ora #%00000110
        sta spena
        ;; Return
        rts
        
        ;; Initialize Pac-Man
initpac:
        ;; Sprite 0: Pac-Man
        ldbimm sp0loc, sp0ptr   ;set sprite 0 pointer
        lda sp0mem+$3f          ;read byte 63
        and #%00001111          ;mask out hi nybble
        sta sp0col              ;set sprite 0 (Pac-Man) colour
        lda #pacstnd
        ldx #0
        jsr nodeadr             ;get address of Pac's starting node
        ldbptr wrd1, 0, sp0x    ;set Pac's x loc
        ldbptr wrd1, 1, sp0y    ;set Pac's y loc
        lda spena
        ora #%00000001
        sta spena               ;enable sprite 0 (Pac-Man)
        ;; Init Pac's direction & calc distance between source & target nodes
        ldbimm w, pacdir        ;set Pac's initial direction to west
        ldbimm pacstnd, pacsrc  ;set Pac's starting node as source node
        ldbptr wrd1, w, pactar  ;set western neighbour as target node
        jsr setnodis            ;calculate distance between source & target
        rts
        
        ;; Main game loop
gameloop:
        lda npelrem             ;check remaining pellets
        bne rdinpt              ;if != 0 read joystick input
:       ldx #$ff
:       dex
        bne :-                  ;delay
        lda lvlend              ;check if end level animation finished
        bne :--                 ;no? wait a bit longer
        jsr nextlvl 
rdinpt: jsr readjoy2
        lda #1
        cmp joyx
        beq move
        bcs chky
        ldbimm w, tmp
        jmp chkmov
move:   ldbimm e, tmp
        jmp chkmov
chky:   lda #1
        cmp joyy
        beq movs
        jcs setnsrc
        ldbimm n, tmp
        jmp chkmov
movs:   ldbimm s, tmp
chkmov: lda pacrem
        sec
        sbc #3
        jcs chkrvw
        jmp setnsrc
chkrvw: lda pacdir
        cmp #w
        bne chkrve
        lda tmp
        cmp #e
        jne setnsrc
        jmp reverse
chkrve: cmp #e
        bne chkrvn
        lda tmp
        cmp #w
        jne setnsrc
        jmp reverse
chkrvn: cmp #n
        bne revs
        lda tmp
        cmp #s
        jne setnsrc
        jmp reverse
revs:
        lda tmp
        cmp #n
        jne setnsrc
reverse:
        cpbyt tmp, pacdir
        swpbyt pacsrc, pactar
        lda pacdis
        sec
        sbc pacrem
        sta pacrem
        jmp gameloop

        ;; Check if Pac-Man arrived at target & set new target
setnsrc:
        lda pacrem
        jne gameloop            ;return to gameloop if pellets remaining
        cpbyt pactar, pacsrc    ;set target node as new source node
        ldx #blki
        jsr nodeadr             ;load node address into wrd1
        ldbptr wrd1, 0, sp0x    ;store node x loc into sp0x
        ldbptr wrd1, 1, sp0y    ;store node y loc into sp0y
        ldy tmp                 ;new direction?
        beq chkcon              ;no, check for node in current direction
        lda (wrd1),y            ;yes, load node in new dir
        cmp #$ff
        beq chkcon
        cmp #gsthmnd
        beq chkcon
        sta pactar
        sty pacdir
        jsr setnodis
        jmp gameloop
chkcon: ldy pacdir
        lda (wrd1),y
        cmp #$ff
        jeq gameloop            ;if nowhere to go, return to gameloop
        sta pactar              ;set new target...
        jsr setnodis            ;... and calculate distance
        jmp gameloop

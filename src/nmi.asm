        ;; ============================================================
        ;; NMI handler sub-routines
        ;; ============================================================

        ;; Setup handler for CIA2 timer NMI.
setupnmi:
        sei
        ldwimm $740d, ti2a              ;timer A fires every ~30ms (PAL)
        ldwimm 8, ti2b                  ;timer B fires every ~240ms (PAL)
        ldbimm %00010001, ci2cra
        ldbimm %01010001, ci2crb
        lda ci2icr
        ldbimm %10000011, ci2icr        ;allow interrupts from both timers
        ldbimm 0, pacaix                ;init Pac-Man's animation index
        ldbimm 0, enzraix               ;init energizer animation index
        ldwimm procnmi, nminv
        cli
        rts

        ;; NMI handler. Here we animate the various in-game objects such as:
        ;;  - Pac-Man (in-game and death animations)
        ;;  - Energizers (phase)
        ;;  - The ghosts (regular, fright, and death animations)
        ;; We also handle timer events such as:
        ;;  - Fruit (appearance and disappearance)
        ;;  - Ghosts switching between scatter & chase mode
procnmi:
        pha
        phx
        phy                             ;push .A, .X, and .Y onto the stack
        lda ci2icr
        tay
        and #%00000010
        jne timbev
        tya
        and #%00000001
        jeq finnmi
        
        ;; Timer A fired: animate Pac-Man
timaev: lda npelrem
        jeq finnmi                      ;don't animate PM if all pellets eaten
        lda pacrem
        jeq finnmi                      ;don't animate PM if he's not moving
        inc pacaix
        ldy pacaix
        cpy #6                          ;past final animation?
        bcc :+
        ldbimm 0, pacaix                ;yes, reset animation index
        tay
:       lda pacdir                      ;no, check Pac-Man's direction
        cmp #n
        beq :+
        cmp #s
        beq :++
        cmp #w
        beq :+++
        ldwimm pacalste, nmiwrd1        ;east
        jmp ldanim
:       ldwimm pacalstn, nmiwrd1        ;north
        jmp ldanim
:       ldwimm pacalsts, nmiwrd1        ;south
        jmp ldanim
:       ldwimm pacalstw, nmiwrd1        ;west
ldanim: clc
        lda (nmiwrd1),y
        adc #sp0loc
        sta sp0ptr
        jmp finnmi
        
        ;; Timer B fired:
        ;;  - animate energizers
        ;;  - flash maze on level end
        ;;  - hide fruit
timbev: lda frtena
        beq :++                         ;fruit enabled?
        cmp #frttim
        bne :+                          ;yes, fruit timer expired?
        jsr hidefrt                     ;yes, hide fruit
        jmp :++
:       inc frtena                      ;no, increment timer
:       lda npelrem
        jeq flshmaz                     ;all pellets eaten, flash maze
        lda enzraix
        beq tic
        dec enzraix
        ldy #3
tocloop:
        jmi finnmi
        phy                             ;save loop counter onto stack        
        lda enzrlst,y                   ;load energizer pelltbl index into .A
        ldx #nmiblki
        jsr pelladr                     ;load pellet address into nmiwrd1
        ldy #2
        lda (nmiwrd1),y                 ;load pellet state
        bne :+                          ;has the pellet been eaten?
        ply                             ;yes, next energizer
        dey
        jmp tocloop
:       ldwptr nmiwrd1, 0, nmiwrd2      ;energizer not eaten
        ldy #ltgrey
        ldx #nmiblki+2
        jsr printcol                    ;colour energizer light grey
        ply                             ;pop loop counter off the stack
        dey
        jmp tocloop
tic:    inc enzraix
        ldy #3
ticloop:
        jmi finnmi
        phy                             ;push loop counter onto stack
        lda enzrlst,y                   ;load energizer pelltbl index into .A
        ldx #nmiblki
        jsr pelladr                     ;load pellet address into nmiwrd1
        ldwptr nmiwrd1, 0, nmiwrd2
        ldy #dkgrey
        ldx #nmiblki+2
        jsr printcol                    ;colour energizer dark grey
        ply                             ;pop loop counter off the stack
        dey
        jmp ticloop
flshmaz:
        lda lvlend                      ;read number of flashes remaining
        jeq finnmi
        ror
        jcc flshwht                     ;flash white on even, blue on odd
        ldx #0
setblu1:
        lda colmem,x                    ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$01
        bne :+                          ;is colour = white?
        lda #$06
        sta colmem,x                    ;yes, make it blue
:       inx                     
        cpx #250
        bne setblu1
        ldx #0
setblu2:
        lda colmem+250,x                ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$01
        bne :+                          ;is colour = white?
        lda #$06
        sta colmem+250,x                ;yes, make it blue
:       inx                     
        cpx #250
        bne setblu2
        ldx #0
setblu3:
        lda colmem+500,x                ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$01
        bne :+                          ;is colour = white?
        lda #$06
        sta colmem+500,x                ;yes, make it blue
:       inx                     
        cpx #250
        bne setblu3
        ldx #0
setblu4:
        lda colmem+750,x                ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$01
        bne :+                          ;is colour = white?
        lda #$06
        sta colmem+750,x                ;yes, make it blue
:       inx
        cpx #250
        bne setblu4
        jmp flshfin
flshwht:
        ldx #0
setwht1:
        lda colmem,x                    ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$06
        bne :+                          ;is colour = blue?
        lda #$01
        sta colmem,x                    ;yes, make it white
:       inx                     
        cpx #250
        bne setwht1
        ldx #0
setwht2:
        lda colmem+250,x                ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$06
        bne :+                          ;is colour = blue?
        lda #$01
        sta colmem+250,x                ;yes, make it white
:       inx                     
        cpx #250
        bne setwht2
        ldx #0
setwht3:
        lda colmem+500,x                ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$06
        bne :+                          ;is colour = blue?
        lda #$01
        sta colmem+500,x                ;yes, make it white
:       inx                     
        cpx #250
        bne setwht3
        ldx #0
setwht4:
        lda colmem+750,x                ;load value in colmem at pos
        and #%00001111                  ;mask out high nybble
        cmp #$06
        bne :+                          ;is colour = blue?
        lda #$01
        sta colmem+750,x                ;yes, make it white
:       inx                     
        cpx #250
        bne setwht4
flshfin:
        dec lvlend                      ;decrement flashes remaining
        
        ;; Restore machine state & return from NMI
finnmi: ply
        plx
        pla                             ;restore .Y, .X, and .A from stack
        rti

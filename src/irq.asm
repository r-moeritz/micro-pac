        ;; ============================================================
        ;; IRQ handler sub-routines
        ;; ============================================================

        ;; Setup handler for raster IRQ.
setupirq:
        sei
        ldbimm $7f, ci1icr
        ldbimm $03, irqmsk ;enable raster IRQ & mob-data collision
        ldbimm $1b, scroly
        ldbimm raslin, raster
        ldwimm procirq, cinv
        cli
        rts

        ;; IRQ handler. Here we implement logic for events such as:
        ;;  - Pac-Man's movement (player controlled but we need to 
        ;;    update sprite coordinates, distance remaining to target
        ;;     node, set new target on reaching target node, etc.)
        ;;  - Pac-Man's dying & updating remaining lives
        ;;  - Ghosts going into/out of fright mode, or being eaten
procirq:
        lda npelrem
        bne chkirq              ;don't handle IRQ when no pellets left
        ldbimm $0f, vicirq      ;acknowledge IRQ
        jmp sysirq              ;return from interrupt
        
chkirq: lda spbgcl              ;clear collision register by reading it
        lda vicirq
        and #$02                ;check for sprite-background collision
        jeq rasirq
       
        ;; Handle sprite-background collision IRQ
        jsr findpel             ;find pellet collided with & mark as eaten
        lda irqwrd1+1           ;load pellet address hi-byte
        cmp #$ff                ;pellet found?
        jeq fincol              ;no, do nothing
        ldx #irqblki+4
        jsr isenzr              ;yes, is it an energizer?
        bne :+
        ldx #irqblki+2
        jsr screnzr             ;yes, score it
        jmp rmpel
:       ldx #irqblki+2
        jsr scrpell             ;no, score as regular pellet
rmpel:  ldwptr irqwrd1, 0, irqwrd2
        ldy #spcechr
        jsr printchr            ;erase pellet
        jsr printscr            ;print score
        ldbimm 6, irqtmp        ;set number of flashes in irqtmp
        dec npelrem             ;decrement pellets remaining
        jne fincol
        jsr dissprt
fincol: lda vicirq
        and #$01
        bne rasirq
        ldbimm $0f, vicirq      ;acknowledge IRQ
        jmp sysirq              ;return from interrupt

        ;; Handle raster IRQ
rasirq: lda npelrem
        jeq finras              ;don't process IRQ if all pellets eaten
        lda pacrem
        beq setnsrc
        lda pacdir
        cmp #w
        bne chkpde
        dec sp0x
        jmp decrem
chkpde: cmp #e
        bne chkpdn
        inc sp0x
        jmp decrem
chkpdn: cmp #n
        bne pdsouth
        dec sp0y
        jmp decrem
pdsouth:
        inc sp0y
decrem: dec pacrem
        lda pacrem
        beq setnsrc
        jmp finras
setnsrc:
        cpbyt pactar, pacsrc    ;set target node as new source node
        ldx #irqblki
        jsr nodeadr             ;load node address into irqwrd1
        ldbptr irqwrd1, 0, sp0x ;store node x loc into sp0x
        ldbptr irqwrd1, 1, sp0y ;store node y loc into sp0y
        ldy pacnxd              ;new direction?
        beq chkcon              ;if not, check for node in current direction
        lda (irqwrd1),y         ;yes, load node
        cmp #$ff
        beq chkcon
        cmp #gsthmnd
        beq chkcon
        sta pactar
        sty pacdir
        jsr setnodis
        jmp finras
chkcon: ldy pacdir
        lda (irqwrd1),y
        cmp #$ff
        beq finras
        sta pactar              ;set new target...
        jsr setnodis            ;... and calculate distance
finras: ldbimm 0, pacnxd        ;clear out next direction
        ldbimm $0f, vicirq      ;acknowledge IRQ
        jmp sysirq              ;return from interrupt

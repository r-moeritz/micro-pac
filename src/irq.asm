        ;; ============================================================
        ;; IRQ handler sub-routines
        ;; ============================================================

        ;; Setup handler for raster IRQ.
setupirq:
        sei
        ldbimm $7f, ci1icr
        ldbimm $01, irqmsk ;enable raster IRQ
        ldbimm $1b, scroly
        ldbimm linset, raster
        ldwimm procirq, cinv
        cli
        rts

        ;; IRQ handler
procirq:
        lda raster
        cmp #linset
        beq setbit
        ;; Clear bit 3 of scroly
        lda scroly
        and #%11110111
        sta scroly
        lda #linset
        sta raster              ;next IRQ at linset
        jmp movpac
        ;; Set bit 3 of scroly
setbit: lda scroly
        ora #%00001000
        sta scroly
        lda #linclr
        sta raster              ;next IRQ at linclr
        
        ;; Update sprite 0 (Pac-Man) x & y coordinates
movpac: lda pacrem
        beq finras
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
        bne pds
        dec sp0y
        jmp decrem
pds:    inc sp0y
decrem: dec pacrem
finras: asl vicirq              ;acknowledge IRQ
        jmp sysirq              ;return from interrupt

        ;; ============================================================
        ;; Program startup
        ;; ============================================================

        .org $0801

        ;; BASIC header
        .word nxl,10
        .byte $9e
        .string "2061"
nxl:    .word 0

        ;; Program initialization
        jsr initvic
        jsr fillcolmem
        jsr setupirq
        jsr newgame

        ;; Include program modules
        include macros.asm
        include symbols.asm
        include maths.asm
        include io.asm
        include maze.asm
        include irq.asm
        include game.asm
        include score.asm
        include fruit.asm

        ;; Include tables
        .include tables.asm
        
        ;; Include assets
        .org charset
        .incbin assets/charset,2

        .org mazegfx
        .incbin assets/mazegfx,2

        .org sp0mem
        .incbin assets/sprites,2

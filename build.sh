#!/usr/bin/env bash

NAME=micropac64

mkdir -p ./build

vasm6502_oldstyle -cbm-prg -Fbin -chklabels -nocase -dotdir \
                  src/startup.asm -o build/$NAME.bin -L build/$NAME.lst \
    && exomizer sfx sys -t 64 -o build/$NAME.prg build/$NAME.bin

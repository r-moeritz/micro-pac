        ;; ============================================================
        ;; Symbol definitions
        ;; ============================================================

        
        ;; Zero page memory locations
        ;; ------------------------------------------------------------

        ;; 15-byte buffer for use in sub-routines,
        ;; divided into 3x blocks of 5 bytes each.
buf:            .ezp $16         ;$16-$24
        
        ;; Block for game loop
wrd1:           .ezp buf
wrd2:           .ezp buf+$02
tmp:            .ezp buf+$04
        
        ;; Block for IRQ handler
irqwrd1:        .ezp buf+$05
irqwrd2:        .ezp buf+$07
irqtmp:         .ezp buf+$09
        
        ;; Block for NMI handler
nmiwrd1:        .ezp buf+$0a
nmiwrd2:        .ezp buf+$0c
nmitmp:         .ezp buf+$0e

        ;; Joystick data
joybtn:         .ezp $92         ;button value
joyx:           .ezp $96         ;x axis value
joyy:           .ezp $97         ;y axis value

        ;; Pac-Man data
pacsrc:         .ezp $9e         ;source node
pactar:         .ezp $9f         ;target node
pacdir:         .ezp $a3         ;facing direction
pacdis:         .ezp $a4         ;distance to target
pacrem:         .ezp $a5         ;distance remaining to target

        ;; Scoring, gameplay
npelrem:        .ezp $a6          ;number of pellets remaining
nmenrem:        .ezp $a7          ;number of remaining "men"
lvlnum:         .ezp $a8          ;level number
frtena:         .ezp $a9          ;whether or not fruit is enabled        
score:          .ezp $fc          ;player's score in BCD (4 bytes: $fc-$ff)

        ;; Animation
pacaix:         .ezp $aa          ;Pac-Man animation frame index
enzraix:        .ezp $ab          ;energizer animation frame index
lvlend:         .ezp $9b          ;level end flashes

        ;; Still available: $f7-$fb (5 bytes)
        
        ;; Memory-mapped hardware registers
        ;; ------------------------------------------------------------
        
        ;; VIC II registers
vic:            .equ $d000
sp0x:           .equ vic
sp0y:           .equ vic + $01
sp1x:           .equ vic + $02
sp1y:           .equ vic + $03
sp2x:           .equ vic + $04
sp2y:           .equ vic + $05
sp3x:           .equ vic + $06
sp3y:           .equ vic + $07
sp4x:           .equ vic + $08
sp4y:           .equ vic + $09
sp5x:           .equ vic + $0a
sp5y:           .equ vic + $0b
sp6x:           .equ vic + $0c
sp6y:           .equ vic + $0d
sp7x:           .equ vic + $0e
sp7y:           .equ vic + $0f
scroly:         .equ vic + $11
raster:         .equ vic + $12
spena:          .equ vic + $15
vmcsb:          .equ vic + $18
vicirq:         .equ vic + $19
irqmsk:         .equ vic + $1a
spspcl:         .equ vic + $1e
spbgcl:         .equ vic + $1f
extcol:         .equ vic + $20
bgcol0:         .equ vic + $21
sp0col:         .equ vic + $27

        ;; CIA1 registers
cia1:           .equ $dc00
ci1pra:         .equ cia1
ci1icr:         .equ cia1 + $0d

        ;; CIA2 registers
cia2:           .equ $dd00
ci2pra:         .equ cia2
c2ddra:         .equ cia2 + $02
ti2a:           .equ cia2 + $04
ti2b:           .equ cia2 + $06
ci2icr:         .equ cia2 + $0d
ci2cra:         .equ cia2 + $0e
ci2crb:         .equ cia2 + $0f


        ;; Operating system memory locations
        ;; ------------------------------------------------------------
        
        ;; Interrupt vectors
cinv:           .equ $0314       ;IRQ vector
nminv:          .equ $0318       ;NMI vector

        ;; Interrupt routines
sysirq:         .equ $ea7e       ;kernal IRQ handler


        ;; Program memory locations
        ;; ------------------------------------------------------------
        
charset:        .equ $4000       ;character set definition
coltab:         .equ $4800       ;colour table
mazegfx:        .equ $4bf0       ;Pac-Man maze
scnmem:         .equ $4c00       ;screen memory
colmem:         .equ $d800       ;colour memory
sp0mem:         .equ $5000       ;sprite 0 address
sp0ptr:         .equ $4ff8       ;sprite 0 pointer
sp0loc:         .equ $1000/$40   ;sp0mem
border:         .equ $7999       ;border byte

        ;; Constants
        ;; ------------------------------------------------------------

        ;; Misc.
linmov:         .equ 1
linclr:         .equ 248
linset:         .equ 254
spxscog:        .equ 24          ;sprite x screen origin
spyscog:        .equ 50          ;sprite y screen origin
maxpell:        .equ 182         ;maximum number of pellets (incl. energizers)
maxmen:         .equ 3           ;maximum number of "men"

        ;; Fruit
frxpos:         .equ $67          ;fruit x loc
frypos:         .equ $a2          ;fruit y loc
frttim:         .equ 38           ;fruit timer: 39 x 240ms = 9.1s
maxftx:         .equ $48          ;maximum fruit table index

        ;; Screen memory indexes
scrmsdi:        .equ $185        ;most significant digit of score
        
        ;; Node indexes
wrpnixw:        .equ $1b         ;western warp tunnel node index
wrpnixe:        .equ $21         ;eastern warp tunnel node index
pacstnd:        .equ $31         ;Pac-Man's starting node index        
gsthmnd:        .equ $1e         ;ghost home node        

        ;; Character constants
spcechr:        .equ $20         ;space char
pellchr:        .equ $53         ;pellet char
enzrchr:        .equ $54         ;energizer char

        ;; Colour constants
dkgrey:         .equ $0b         ;dark grey
ltgrey:         .equ $0f         ;light grey
        
        ;; Compass directions
n:              .equ 2
s:              .equ 3
w:              .equ 4
e:              .equ 5

        ;; Scores, expressed as BCD pairs
pellpts:        .equ $10        ;10 pts for pellets
enzrpts:        .equ $50        ;50 pts for energizers

        ;; Index into buf to access memory block
        ;; reservedf for gameloop
blki:           .equ $00
        
        ;; Index into buf to access memory block
        ;; reserved for IRQ handler
irqblki:        .equ $05

        ;; Index into buf to access memory block
        ;; reserved for NMI handler
nmiblki:        .equ $0a

        ;; The number of pellets that need to be eaten for bonus items
        ;; to appear the 1st and 2nd time
nbonpel1:       .equ 52
nbonpel2:       .equ 127

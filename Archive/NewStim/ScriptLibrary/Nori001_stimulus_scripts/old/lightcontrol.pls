            SET      1.000 1 0     ;Get rate & scaling OK

            VAR    V45,BGpre=1     ;Stimulus BGpretime in seconds
            VAR    V46,stimtime=2  ;Stimulus time in seconds



E0:     'S  DIGOUT [......00]
            WAIT   [.......0]      ;                   >Wait DIGIN 0 low for start of trial
            WAIT   [.......1]      ;                   >Wait DIGIN 0 low for start of trial
			DAC    0,0
            DAC    1,0
STIM:       WAIT   [.......0]      ;                   >Wait DIGIN 0 low
            DELAY  s(2)-1          ;BGpretime
            DIGOUT [......11]
            DELAY  s(2)-1          ;stimulus time
            DIGOUT [......00]
            JUMP   STIM

OFF:    '0  DIGOUT [......00]
            HALT   


ON:     '1  DIGOUT [......11]
            HALT   

E1:         HALT   
EA:         HALT   
EB:         HALT   
EC:         HALT   
ED:         HALT   
EE:         HALT   
EF:         HALT   
EG:         HALT   
EH:         HALT   
EI:         HALT   
EJ:         HALT   
EK:         HALT   
EL:         HALT   
EM:         HALT   
EN:         HALT   
EO:         HALT   
EP:         HALT   
EQ:         HALT   
ER:         HALT   
ES:         HALT   
ET:         HALT   
EU:         HALT   
EV:         HALT   
EW:         HALT   
EX:         HALT   
EY:         HALT   
EZ:         HALT   

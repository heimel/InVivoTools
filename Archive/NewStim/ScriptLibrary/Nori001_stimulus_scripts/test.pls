            SET    1,1,0           ; Get rate & scaling OK

            VAR    V45,LoopC=0     ; Define variable for section loops
            VAR    V46,RampC=0     ; Define variable for ramp loops
            VAR    V47,DelayC=0    ; Define variable for delay loops
            VAR    V48,Delay2=0    ;  and another one
            VAR    V49,Delay3=0    ;  and another one
            VAR    V50,Delay4=0    ;  and another one
            VAR    V51,Delay5=0    ;  and another one

E0:         DIGOUT [......00]
            DAC    0,0
            DAC    1,0
            DELAY  s(0.046)-1
E1:         MARK   49              ; Generate digital marker
            DELAY  s(0.041)-1
            WAIT   [.......1]      >Wait DIGIN 0 high
            DELAY  s(0.687)-1
            MARK   50              ; Generate digital marker
            DELAY  s(0.029)-1
            WAIT   [.......0]      >Wait DIGIN 0 low
            DELAY  s(0.069)-1
            MARK   51              ; Generate digital marker
            DELAY  s(0.119)-1
			JUMP   E1
            HALT                   ; End of this sequence section

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

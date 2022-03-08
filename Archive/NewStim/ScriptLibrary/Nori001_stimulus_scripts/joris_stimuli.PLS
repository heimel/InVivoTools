            SET    1,1,0           ; Get rate & scaling OK

            VAR    V45,LoopC=0     ; Define variable for section loops
            VAR    V46,RampC=0     ; Define variable for ramp loops
            VAR    V47,DelayC=0    ; Define variable for delay loops
            VAR    V48,Delay2=0    ;  and another one
            VAR    V49,Delay3=0    ;  and another one
            VAR    V50,Delay4=0    ;  and another one
            VAR    V51,Delay5=0    ;  and another one

E0:         DAC    1,0
            WAIT   [.......1]      >Wait DIGIN 0 high
            DAC    1,1.2
			MARK   1
            DELAY  s(0.99)-1
            WAIT   [.......0]      >Wait DIGIN 0 high
            DAC    1,0
			MARK   2
            DELAY  s(0.99)-1
			JUMP E0
            HALT                   ; End of this sequence section

EA:'S       DIGOUT [......00]
            DAC    1,0
            DIGIN   [.......0]      >Wait DIGIN 0 high
			BNZERO MARK1
			MARK   2
            DAC    1,-1.1
            DELAY  s(0.99)-1
            DAC    1,0
            HALT  

MARK1:      MARK   1
			HALT

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

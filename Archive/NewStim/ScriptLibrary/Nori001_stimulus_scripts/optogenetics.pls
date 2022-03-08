            SET      1.000 1 0     ;Get rate & scaling OK

        '4  DIGOUT [......00]	   ;		
            WAIT   [.......0]      ;   		>4s, Awaiting trial start
            WAIT   [.......1]      ;	   
			DAC    0,0
            DAC    1,0
STIM4:      WAIT   [.......0]      ;        >Awaiting stim start
            DIGOUT [......11]      ;        >Light on (4s)
            DELAY  s(4)-1          ;       
            DIGOUT [......00]      ;        >Light off
            JUMP   STIM4

        '3  DIGOUT [......00]	   ;		>Light off
            WAIT   [.......0]      ;   		>3s, Awaiting trial start
            WAIT   [.......1]      ;	   
			DAC    0,0
            DAC    1,0
STIM3:      WAIT   [.......0]      ;        >Awaiting stim start
            DIGOUT [......11]      ;        >Light on (3s)
            DELAY  s(3)-1          ;       
            DIGOUT [......00]      ;        >Light off
            JUMP   STIM3

	    '5  DIGOUT [......00]	   ;		
            WAIT   [.......0]      ;   		>5s, Awaiting trial start
            WAIT   [.......1]      ;	   
			DAC    0,0
            DAC    1,0
STIM5:      WAIT   [.......0]      ;        >Awaiting stim start
            DIGOUT [......11]      ;        >Light on (5s)
            DELAY  s(5)-1          ;       
            DIGOUT [......00]      ;        >Light off
            JUMP   STIM5

	    '6  DIGOUT [......00]	   ;		
            WAIT   [.......0]      ;   		>6s, Awaiting trial start
            WAIT   [.......1]      ;	   
			DAC    0,0
            DAC    1,0
STIM6:      WAIT   [.......0]      ;        >Awaiting stim start
            DIGOUT [......11]      ;        >Light on (6s)
            DELAY  s(6)-1          ;       
            DIGOUT [......00]      ;        >Light off
            JUMP   STIM6

	    '2  DIGOUT [......00]	   ;		
            WAIT   [.......0]      ;   		>2s, Awaiting trial start
            WAIT   [.......1]      ;	   
			DAC    0,0
            DAC    1,0
STIM2:      WAIT   [.......0]      ;        >Awaiting stim start
            DIGOUT [......11]      ;        >Light on (6s)
            DELAY  s(2)-1          ;       
            DIGOUT [......00]      ;        >Light off
            JUMP   STIM2

ON:     'N  DIGOUT [......11]	; >Light on
            HALT   				; >Light on

OFF:    'F  DIGOUT [......00]	; >Light off
            HALT   				; >Light off

	    'D  DIGOUT [......00]	   ;		
            WAIT   [.......0]      ;   		>2s, Awaiting trial start
            WAIT   [.......1]      ;	   
			DAC    0,0
            DAC    1,0
STIMD:      WAIT   [.......0]      ;        >Awaiting stim start
            DELAY  s(2)-1          ;        >Pretime (2s)
            DIGOUT [......11]      ;        >Light on (2s)
            DELAY  s(2)-1          ;       
            DIGOUT [......00]      ;        >Light off
            JUMP   STIM2

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

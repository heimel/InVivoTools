            SET    0.04,1,0           ; set ticktime 40 us
            VAR    V35,V=0;        ; define variable for stimulus voltage
            VAR    V45,LoopC=0     ; Define variable for section loops
            VAR    V46,ITI     ; Define variable for intertrain interval
            VAR    V47,IBI    ; Define variable for delay loops
            VAR    V48,ISI         ; Define variable for interstimulus interval
            VAR    V49,pulsew ;  and another one
			VAR    V50,loop1       ;
            VAR    V51,loop2       ; 


STOP:     'S  DAC    0,0
            HALT                   ; End of this sequence section

IOCurve:'I  MOVI   V,VDAC32(0.1)   ;pulses
            MOVI   LoopC,6        ; Set section loop count
			MOVI   ISI,s(15)-1    ; set interstimulus interval
			MOVI   pulsew,ms(0.2)-1 ; set pulsewidth
			DELAY  ISI	
IO1:		MOVI   loop1,3          ; each stimulus run LOOP1 times
IO2:        DIGOUT [.......1]
			DIGOUT [.......0]
			DAC    0,V
            DELAY  pulsew
            DAC    0,0
            DELAY  ISI
            DBNZ   loop1,IO2
            MULI   V,2              ; Adjust varying amplitudes
            DBNZ   LoopC,IO1        ; Repeat required times
            JUMP   ES              ; Jump to next section

PP:      'P MOVI   V,VDAC32(0.8)    ; pulses are 100 uA * V 
			MOVI   loopC, 5			; each train is run LOOPC times
			MOVI   ISI,ms(40)-1		; set stimulus interval, 25Hz = 40ms
			MOVI   ITI,s(15)-1       ;set intertrain interval	
			MOVI   pulsew,ms(0.2)-1 ; set pulsewidth
			DELAY  ITI
PP1:		MOVI   loop1, 5			; each train is LOOP1 pulses 
            DIGOUT [.......1]
			DIGOUT [.......0]
PP2:		DAC    0,V
            DELAY  pulsew
            DAC    0,0
            DELAY  ISI
            DBNZ   loop1,PP2
			DELAY  ITI
            DBNZ   LoopC,PP1        ; Repeat required times
			HALT						


Baseline:'B MOVI   V,VDAC32(0.8)    ; pulses are 100 uA * V  
			MOVI   ISI,s(15)-1		; set stimulus interval
			MOVI   pulsew,ms(0.2)-1 ; set pulsewidth
			DELAY  ISI
B1: 		DIGOUT [.......1]
			DIGOUT [.......0]
     		DAC    0,V
            DELAY  pulsew
            DAC    0,0
            DELAY  ISI
            JUMP   B1


LTP:	 'L MOVI   V,VDAC32(1.6)    ; pulses are 100 uA * V, twice test intensity 
			MOVI   ISI,ms(10)-1		; set stimulus interval, 100Hz = 10ms
			MOVI   IBI,ms(200)-1       ;set interburst interval, 5Hz = 200ms	
			MOVI   ITI,s(10)-1       ;set intertrain interval	
			MOVI   pulsew,ms(0.2)-1 ; set pulsewidth
			DELAY  ITI
			MOVI   loopC, 5			; each train is 5 sequences
            DIGOUT [.......1]
			DIGOUT [.......0]
LTP1:		  MOVI   loop1, 10		; each sequence is 10 bursts
LTP2:		    MOVI   loop2, 5			; each burst is 5 pulses 
LTP3:		      DAC    0,V
                  DELAY  pulsew
                  DAC    0,0
                  DELAY  ISI
                DBNZ   loop2,LTP3
                DELAY  IBI
              DBNZ   loop1,LTP2
			  DELAY  ITI
            DBNZ   LoopC,LTP1        ; Repeat required times
			HALT						

			HALT
EC:         HALT
EE:         HALT
EF:         HALT
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
ES:        	HALT
ET:         HALT
EU:         HALT
EV:         HALT
EW:         HALT
EX:         HALT
EY:         HALT
EZ:         HALT

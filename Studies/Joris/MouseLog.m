%20110916_B7
%Centre gratign @ 275, 25;
%800 trials
%B8 - larger gabors (20,40,60,80,100,120), no spike threshold.

%20111216
%Next attempt, demo electrode, one broken channel
%Too noisy

%20120119
%Electrode was 3DF8
%Block 4 - Flash CSD
%Block6 - Moving Bar @ 48,-165
%Block8 - Grating
%Block11 - Grating (called Block10 for tdt file)
%Moved screen, remapping RF
%Block12 RF @ 200,
%Block14 - Grating
%Block16 - Spontan0
%Block17 - RC rf map (RF flash) - strange
%Block19 - Centre at new location - grating.
%Block22 - CentreSurround (some bugs with occluder of surround)
%Pre-amp battery gone at end of block (10T) or so
%Block 23 and agin (all spiking gone at end of block (10T or so)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120203
%Block3 - Flash - strange photovoltaic effect on chans out of brain, nice
%spiking, Mouse was ' blind' 
%Block5 - Flash, we still here PV effect
%NEw TAnk afetr TDT crash
%20120203B
%Block2 - Flash, first 3 trials screwed by black bar, PV effect still
%present from 14 up.
%Block 4 - Moved up 200, flash
%block-5 - RF flash @ 0.0
%Block-7 - RF bar @ 0,-150
%Block-8 - Centre Surround 50% contrast, mean lum 
%Block-9 - Centr, low luminance.
%Block-11 - Cnetre-Surround
%Channels 6-9 give goos spikes, good SUA on 9, though sparse.
%Block -12 CS - low luminance
%Block13 - Lidocaine! Total knockdown....
%Block-14 - wash-out
%B15 - 1/4 dilution, very short block
%B16 - drop sucked-off, quicker recover
%B17 - Flash CSD



%%%START ANALYSIS HERE


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120209 %First time with fast tuning sessions
%Electrode - 4084
%B3 - FlashRF @ 60,-180 (mobile noise) (60,-200)
%B4 - Flash
%Moved electrode up, mover projector down...
%B6 - Flash
%B7 = RF flas @ 60,-180
% -25,-150 was the value returned for us by the RF program
%B8 - Ori
%B14 - Size tuning
%B15 - CRF
%B16 - Speed
%B17 - SptFreq
%B20 - Surround - black-screen partailly covered right eye at some point.
%Still has -1 problem with word, removign that now
%B21 - Surround again
%MAjor TDT issues, started new tank%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120209C%%%%%%%%%%%%%%%%%%%%%%%%
%B2 - Flash
%B3 - Surround Tuning 
%B4 - FastSurround
%Lots of spikign on all channels, probably reference, restting reference
%B5 - Flash
%moved reference, anesthesia given, responses now very small but CSD good.
%B8 - RF flash @ 60,-180 (Doesn't agree with Par file, which says,
%-25,-150, which is wrong).
%Actually later Par files say -50,-100 which is well-centerd
%B9 - size tuning - Good laminar profile...
%BX (12?) - FAst Surround - reference in circuit after t300 trials.
%B16 - Fast Surround - Lots of SUA!
%B17 - Lidocaine after 1 minute from recording, 10X dilution, FastSurround
%B19 - 'Recovery' excellent SUA 
%B20 - Size tuning
%B21 - Ori tuning (for SUA)
%B22 - Bried pre-drug  (10T)
%B23 - Lidocaine, 8xa t 40s, Knockdown (LONG)
%B24 - 1 minute exposure (1:15-2:15) 8x


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120309B
%Very quiet at this time
%B3 - Flash, L4 on 8,9,10,11
%B4 - RF at 16,-158  (Actually it was 16,156)
%Looks like 0,-150 is good.
%B5 - same again with thresholdks set, SUA on 5/6, otherwise MUA
%B6 - Ori tune
%B7 - Size tune
%B8 - SpatFreq tune
%B9 - Speed tune (@225) lokes fast sppeds (18degpersec)
%Previous blocks have some light-noise on...
%B10 - size again, better light shield, now 18Deg per sec
%B11 - Better ori tuning
%B12 - Sourround, centre at 180 (abandoned after spike died)
%Chan 10 is SUA, others still noisy, can hear heartbeat
%B13 - surround at 270
%Much better spiking now, esp on 10, 5, 6 ,7 
%This is the data to use, nice ori and size tunings here.
%B14 - surround at 270 (1300T)
%B15 - Ori tunign with same cells as B14
%B16 - Size tuning as above (270 deg)
%B17 - Size @ 180deg
%B18 - 10x lidocaine drop at T0, 270 surround (>1300T)
%Drug too effective, slowly reduced resposne across all layers exceot chan
%5/6
%B19 - Washed with saline, 5/6 gone now, maybe electrode knocked?? 
%Starting to come back after 3 mins but slow
%Long pause here - more anesthetic
%B20 - Pre-drug surround session (270), (100T)
%Toom much heartbeat, stopping
%B21 - Pre-drug surround session (270), (280T)
%B24 - 20x lidocaine, shielding fell at end (last < 20 trials).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120315
%No chlorproxywhatnot
%Lots of SUA
%B3 - Flash (MUA not so amazing, CSD OK)
%B4 - RF flash @ (-20,-100)
%B5 - RF (Wrong - this was Ori) @ -50,-140 (400T)
%B6 - Speed @ -30,-140 (Ori?)
%B8 - Speed (high contrast, 90 deg), oxygen fell-off, abandoned
%B9 - ""
%B10 - SpatFreq
%B11 - Ori again, now at -30,-140, USE THIS
%B12 - Size tuning
%Much spikier now....
%B14 - Surround
%B15 - Size tune with same thresh, lots of SUA, 5, 9 
%B16 - Lidocain x20 dilute at t-1, too much knockdown
%B18 - Washed with saline, 5 min gap
%Didn't come back
%MOved to a new spot
%20 - Flash
%Started new tank 20120315C
%Abandoned

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120319
%Electrode 3DF9, younger mouse (4 weeks)
%Changes to code:
%Size is now exactly right (Period not used)
%Surround only condition added, centre is now ay 80% con
%B2 - Flash, very quiet except chan 5
%OOPS - electrode killed by evil microscope.
%Making new craniotomy on other side.
%Mouse died


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120329
%No Dex, thick electrode (50 micron)
%B4 - Flash, very quick at this tsgae
%B5 n- flash
%POOR signal, moving electrode
%B7 - Flash at new posiition
%B8 - Moved electrode down more, Flash
%B9 - RF @ (-60,40) =  -30,-100
%B10 - Speed tuning @ -30,-100
%B11 - SF tuning
%B12 - Ori tuning, good SUA on ch.5 (6+10 OK as well)
%B13 - Size tuning
%B14 - Surround, 90 (grating drifts up, i.e. it is really 270).  5 + 6 SUA (T1300)
%B16 - Surround, same as above but with 40 degree surround
%Recording got spikier during the last session, more spiking overal and
%higher RMS noise
%B18 - Size tuning (MEGA spiking now, esp 11, 6 , 7, 8, 10)...
%B19 - Ori
%B20 - Surround (30 degree), super spiky, esp 11.
%Can function as pre-drug for lidocaine block below (except chan 11!)
%TANK crashed
%NEw tank%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120329B
%B2 - RF Moving bar
%Shit, lost channel 11 SUA when applying lidocaine x40
%Other channels are OK
%B3 - Surround, 30 deg with Lidocaine x40, no obvious effect
%B4 - Washout
%1 hour break for anesthesia
%B5 - Surround (30deg)
%Injection of 20x lidocaine, uncertain of success
%Anesthesia very light here, gave Isoflurane
%Responses flat, either due to iso or lido....
%Unitl now the tunings used an orientation map oin which 0 was
%left-to-right and 90 was top-to-bottom
%However for the centre of the surround, the reverse was true in the vertical plane i.e.
%90 was bottom-to-top.  The surround was correctly aligned to this.
%This is now corrected so that the orientation of the surround-condition is
%the same as the ori condition.  Previous data should take account of
%this...
%Very light anetshesia, hour break while more Urethane given
%responses still OK, but not very driven sounding
%Ch.6 is prob. sortable
%B6 - Surround again, 30deg, 90ori (i.e. up, i.e. 270) (260T)
%B7 - Test for horizontal dominance, Surround with 0 centre (right to left)
%(260T)
%B8 - Quick ori tune to try and understand above results...
%B9 - Surround , 90deg (bot-top), 20x lidocaine (Ch 5,6,7 and maybe 10
%sortable).  No obvious effect, infact things got slowly spikier..
%B10 - Washout, Ch 5,6,7,8 spiky
%B!1 - flash to check vis resp
% B12- Surround pre-drug, VERY SPIKY!
%B13 - Surround Lidocaine x10, may have to remake wordbit for B12 (above)
%Logfile is called Block-12....change this
%Some knock-down here,and some strange electrical noise occasionally.
%Otherwise good, deep-channels coming-up
%B14 - abandoned (javav error)
%B15 - washout, 2-8 still spiky, 9 coming back...full recovery
%B16 - Lidocaine x15, a little strong Ch.9 down, but not entirely, deeper
%chans less spiky
%B17 - WAshout, full recovery
%B18 - Lidocaine x20
%B19 - Washout - good recovery
%B20 - Ori tune for previous drug blocks
%B21 - Moving bar
%B22 - Size tune
%B23 - Flash to finish with....


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120424
%Electrode 3DF8, younger mouse again (4 weeks)
%Blocks1-5, very flat, flash only (2,4,5), moving to a new spot.
%Too deep anesthesia, lots of up/down state, no clear RF
%Hours later....better now.
%Spiking on 7,8 very strong (prob layer 5/layer 4c border)
%Channel 1 is weird, it switches between being very noisy and a SU.
%The response is still a little sluggish and there isn;t much superF stuff,
%but hey- off we go...
%B15 - Flash (a little hard to interpret)
%B17 - RF @ (0,-100), the screen is a little high here
%B18 - Lowered screen, RF @ (0, -100), 
%still sluggish so used extra long check time of 0.4s plus 0.25 for IT> 
%Weird RFs, look large, double, or oriented
%B19 - trying Ori tune at lower left RF (50 deg).
%B20 - Otri again, at 0,0 and 100 deg
%Mouse died

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120502
%Chlorproxywhatnot again, 5 weeks mouse
%Very spiky/bursty at this stage
%B2 - Flash
%B3 - RF @ -100,-150  = -150,-125
%B4 - Speed tune @ -150,-125 (90 deg) -30deg per sec
%B5 - SF Tune - 0.075 is good compromise
%Signal is excellentm, very spiky/bursty, though not many real obvious SUAs
%Chans 4-12 obviously active, 3 and 13 maybe. Chan 10 and 11 are now spiky too
%(they weren;t during the SF and Speed tunigns). Chan 11 is the best SUA.
%Chan 5-7 may be sortable, esp 5.
%B6 - Orientation tune @ -150,-125, occasional crackles here 270 preferred
%Chan 11 was gone for a while but is now back, threshold was switched to
%negative (dumb).
%B7 - Size tuning @ -150,-125 (270 deg, 30 d/s, 0.075 SF, 80% con)
%Size tuning showed large (40deg) RFS in deep layers that show little
%suppression.  Chans 11 and 12 show nice suppression and are tuned for
%20/25 degs.  We'll first run a session at 25, then one at 40.
%B8 - SurroundFAst @ 25 degs, lots of phone noise
%B9 - Surround again at 40degs, some strange spiky-noise near the start
%B13 - HUPE
%More SUA now, rerunnign size tuning
%B14 - Size tuning - GOOD session - excellent ENV responses, deep layers
%show little suppression whereas superficial layers are clearly strongly
%suppressed.
%Nice ans spiky, SUA on 5,6,7,10,11
%B15 - Surround, 15 deg centre, surround size increased to 100deg or 160
%deg with 80 deg inner diameter. (500T)
%B16 - RF flash check with same thresholds as above (500T)
%B17 Surround - 30 deg, same thresh as B15
%B18 - Ori tune with same thresholds
%B19 - Contrast tune with same trhesh
%B20 - Surround (30deg) Pre-lido block2
%B21 - Lidocaine x40 (30s before block), ch.11 down, others quieter
%B22 - Flushed with saline
%B23 - Flushed again then waited 1 hour and recorded this block!
%B24 - Lidocaine x80, still knocks down ch.11!
%B25 - flushed
%B26 - recovery block, looks good, chan 13 is spiking!, layer 1?
%B28 - Flash
%CSD is  little hard to read but ch9 seems to be the best bet for layer
%4c, ch8 is also a possibility. ch4-13 can be included.
%B29 - Lidocaine x160, excellent in begin, only chan 13 down, later also 11
%down
%B30 - Sucked off lidocaine, recovery OK
%B31 - Saline to check

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%21st June i.e. 20120621
%Large RFs here, 40 deg (NOT V1?)
%Fast drop to 2mm at least
%Visually responsive, som efunny problems with static build-up.
%B2 - Flash - way too deep
%Moved up 700 microns
%B3 - Flash, nice, layer 4c is prob on chan 9 (maybe 8)
%B4 - RF flash, (50,0), lots of heavy spiking, and death-sounds.
%Waited an hour
%Nice and spiky, Chan 11 is SUA, maybe 10,12
%B6 - RF placed at 50,-50, RF location @ 50,-75
%Nice SUA on 10,11
%B7 - SPat. Freq, @ 50,-75 (0.05 pref)
%B8 - Speed tuni g (18 pref)
%B9 - Contrast tune 
%B10 -Orientation tuning
%B11 - Flash again (First few trials have the BLACK-BAR!!! (Chan 11 is L4)
%B12 - Size tuning
%B14 - FastSurround (Ch.10,11 are SUA)
%B15 - Size Tuning with same thresholds as B14, some spiky noise
%occasionally.
%Anesthesia given, response much worse now
%OH dear, SNR very low now
%B17 - Flash, CSD great but MUA awful, goodnight

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120627
%Smaller RFs, chans 2-12 OK
%B2 - Flash, quite spiky here, well-placed, chn.9 is layer 4c.
%B4 - RF flas @ 90,-50, some hum someyimes placed at 15,-100
%B5 - Spat Freq tune @ 15,-100 (0.1 pref)
%Now chan.12 and chan.13 are spiking!
%Very high amplitude spiking, 7 is insane, others more normal, 3 is SUA.
%B6 - Speed tune (24 degs/sec)
%!2 and 13 are now much higher, thresholds are not fgreat for tehse chanms.
%B7 - Contrast tune
%Rethresholded SUA on 4,7,12, maybe others
%B8 - Orient tune (270 deg, quelle surprise)
%B9 - Size tuning, lots of spiking, Niiice
%Not much size tuining, some in deep layers and ' notch' in super layers
%B10 - SurroundFast - 15deg, for 'notch'
%B11 - SurroundFast - 30deg, for plateau in tuning
%SOme TDT errors here, so rerunnign block (dat is actually OK)
%B12, same as B11, 839T
%B14 - Hupe
%Not much modulation in teh surround data so we waited a while
%Excellent signal, SUA almost everywhere
%Anesthetic is somewhat lighter here, less up-and-down
%B15 - Size tuning again -Now tuned to 15deg!
%Reset thresholds - even less bursty now
%B16 - FAstSurround at 15deg
%B17 - Orient tune with same thresh as B16
%B18 - FastSurround (20/40 Near/Far) (same thresh as B16)
%B19 - Lidocaine x200, chans 13+12 down, later 11+10 lower than normal
%Washed off with saline
%B20 recovery - no clear recovery (1000T)
%B21 recovery x 2, recovered at the end (1500T)!
%B22 - Hupe
%B23 - Flash
%Mouse died

%20120719
%Some breathing problems
%B8 - Flash -Still quite quiet at this stage and CSD ius a little hard to read.  
%B9 - Exploratrory RF flash, no clear idea where RF is at this tsage..(0,0)
%Looks like there is something there at (30,-190)
%Slowly becoming spikier - not optimal yet though
%B10 - Flash - Much clearer now, L4c on chan.9
%B11 - RF flash @ 30,-190 - NOT GOOD, noisy, maybe RF is more at (-100,0)
%Signal not good enough to tell at this moment.
%B!2 - RF @ -50,-50
%REsponse is till pretty poor, moving the electrode....
%Changing the Tank as well - now:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120719B
%B2 - Flash , much nicer, L4 on 9 or 10
%B3 - RF flash @ (-50,-30) (oops stimdur was set to 0.525s!)
%B4 - Rf flash @ (-50, -30) with normal durations, nice RFs bang-on at
%(-50,-30)
%At this stage (B5-B9) we have nice spiking on many channels, possible SUA on
%5,7,9,10,11,12.  Earlier 11 was a bit funny, seems OK now, also spiking
%from ch4 upto ch.14 (weakly)
%B5 - SpatFreq tune at -50,-30 (0.05)
%B6 - Speedtuning (18)
%B7 - Contrast
%B8 - Orientation tuning (135 preferred!)
%B9 - Size tuning - signal still nice
%Some size tyuning, tuned for 40, althought there's a bump at 20
%Stronger in SuperF layers
%B10 - Surround 40degs (oops, no farsurround here)
%B11 - Surround (40 near/60 far) 
%B12 - Surround (20/40) Error
%Anesthesia too weak , giving anesthetic
%B14 - Spontaneous
%Still good spiking, same SUAs as before, rechecking size tune...
%B16 - Size tune (T360) - Now it really is 20
%B18 - Surround (20/40) (T400)
%B19 - Surround (40/60) (T400)
%B20 - Pre-drug (20/40) (saline added)
%B21 - 1000x Lidocaine (20/40), channel 12 has gone weird, otherwsie maybe
%a small effect down to ch.11
%Bit weird as the salien seemed to have an effect on B21
%B22 - Sucked-off :)
%B23 - More recovery, back to normal by end
%B24 - Now RINGER solution inbstead (Pre-drug)
%B25 - 1000x Lido in Ringer - complete knockdown!
%B26 - Washed with Ringer
%No recovery - which is weird, ending experiment...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120809
%Pretty spiky straight away
%B1 - Recording- nothing
%B2 - Flash ,prettys luggish responses
%B6 - Flash, getting better, still sluggish. (L4 prob 8 or 9)
%B7 - Flash, clear CSD, chan.9 = L4
%Probably still too deep anesth here, but very spiky esp ch.7
%B8 RF mapping at 50,-50, nice RFs, (50,-30) looks like a good choice
%B9 - SF tuning @ (50,-30) (0.05 pref)
%B10 - Speed tune @ (50,-30) (30 pref)
%B12 - Contrast tune @ (50,-30)
%B13 - Orientation tune, deep layers prefer 90, upper layers prefer 135
%some direction tuning, take average?  (112.5)
%Still spiky, ch 7,8,9, prob sortable, responses go upto at least 13
%B14 - Size tunign at 112.5 - not much size tunign at this stage...
%Maybe 40 deg if any tuning, also the 'dip' is tehre in deep layers...
%B15 - We procede anyway with surround (40/60).
%Nice iso-suppression here
%Ringer added
%Seems a little less up and down now
%B16 - Size tunign again, more tuning now, superF layers tuned more for
%20-25 degs.
%Ch.11 and above are weaker now for some reason (Ringer?)
%B17 - Surround with 20/40
%Added more urethane (`17.30/18.30)
%B18 - Recording- nothing
%Responses in SuperF layers are now back - is Ringer lowering responses??
%B20 - Size Tuning (1/2 length)
%There is size tuning, less than B16, but OK, 30 pref
%B21 - Surround pre-drug (400T, 30/50)
%We're going to try a brief application of Ringer (30s)
%B22 - Surround after 30s Ringer - looks OK, ch.11 still good
%Now going to use same approach for Lidocaine pulse 10x dilution
%B23 - Lidocaine 10x 30s pulse (no effect, actually some effect)
%B24 - Ringer pulse recovery
%B25 - Repeat 10x Lidocaine
%Mouse moving after 250T, end experiment...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120816
%6-week old e4084
%B3 - Checkerboard flash, not very active right now.
%Moved electrode to new location
%B6 - Flash - not super active
%B7 - Flash - L4 is on ch.9
%Still recovering here, rough RF map
%B8 - RF (0,-110) placed at (-30,-100), (3)4:14 look OK
%Nice and spiky now, ch 8,9,10,11,12 in particular
%B9 - Spat Freq tuning at (-30,-100) [0.05]
%B10 - Speed tuning [18]
%B11 - Contrast tuning
%B12 - check RFs with threshold - Nice, 4:14
%B13 - Orientation- 135 preferred
%B!4 - Size tune
%Noise level increased a lot during last block - response is lookign more
%asynchronous and awke-looking!
%B15 - Surround (20/40) Mouse awake at 690T
%And, crap crap crap, stimulus was in the wrong place (50,-30)!
%anetshesia given - 0.06 urthane%chlorproxywhatnot
%B17 - Much later, new electrode, flash, some 50Hz but OK
%L4 is prob chan 9
%B18 - RF @ (140,-40), limited no. of RFs at this time, centred at
%[100,-50]
%Spiky on 10,11,12, but 'deep' looking
%B19 - SF tuning [0.1]
%B20 - Speed tuning [12]
%B21 - Orientation [180]
%B22 - size T
%B23 - Flash, getting quieter here after wetting the dura
%B24 size T - v.quiet now
%B25 - contrast

%%%%%%%%%%%%%%%%%%%%%%
%20120829B
%e4080D - 6 weeks
%Nice and spiky here, good visual response
%B2 - FLash, clear L4 at chan 9.
%SUA on several chans, 6,12 particularly good
%B3 - RF @ [0,-15], placed at [0,0], slight drift
%B4 - SpatFreq @ [0,0] - 0.05 pref
%B5 - SpeedTune at [0,0] - 30 deg/s
%B6 - Orientation tuning. Bit of a mix of 0 and 45
%B7 - Contrast tuning
%B8 - Size Tuning - Ori = 0 (6 and 12 still SUA)
%L4 tuned for 10! Superf for 15, Deep for 20 or bigger, excellent tuning
%B9 - Surround (15/40) 0 degree center
%B10 - Surround (20/40) now 90 degrees
%Chan 12 is a lot less spiky now - drying out...?
%B11 - Hupe (40 deg)
%%%%%%%%%%%%%
%TDTcrashed started new block
%20120829D
%Signal still good
%B4 - Lido pre size = 20, ori = 90
%This is a new lido pre-drug.  It is like the SurroundFast except no far
%surround and now we intermix size tuning stimuli [10 15 20 30 40]
%Use the new analysis code.
%Changed it again for B6
%B6 - size = 15, ori = 0
%Changed again, now two oris and size tunes
%B7 - With Size Tune
%After lots of messing about we're now doing two oris but no size-tune = 9
%conditions
%B8 - Pre-drug, no size tune (T450)
%B9 - Lidocaine 10x pulse (30s) (T450)
%B10 - Ringer recovery (T450)
%B11 - Lidocaine x10 - not much obvious effect (T300)
%B12 - Liodocaine x10 again (some effect + recovery)
%B13 - Lidocaine full strength (30s, good knockdonw+recovery)
%B14 - Recovery ringer(30s)
%B15 - Lidocaine full strength (30s)similar to B13.
%B16 - Final recovery
%B17 - Flash

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120830
%lots of pops and clicks, and not great SUA
%B3 - Flas - kinda weird, maybe ch.9 or ch.8
%B5 - RF at [0,0], looks surprisignky good...
%Improved the groounding somewhat here, signal better
%B6 - Flash
%B7 - SF tune (0.05)
%Signal not too bad, some SUA, ch.2,3,7
%B8 - Speed, not very speed tuned, using 24
%B9 - Contrast - still popping occasionally
%B10 - Orientation - 150 tunign almost everywhere (ORI COLUMN EXAMPLE!)
%B11 - Size tuning (mix of 15, 20 and higher)
%B12 - RF map again
%Computer crashed
%B16 - Centre surround (15/30), glitch in the code!
%B19 - Orientation with IPSI -lateral eye shut
%Glitch was related to orientation, switching to 145 solves the problem
%B20 - PRe-lido version (2 oris, two sizes, (15/30))
%B22 - Same very long, seems to respond best to large stimuli.
%B23 - Quick size tune check, size-tunigns have shifted to larger stimuli,
%particularly in the superF layers.
%B24 - Ori check with 20 deg, weaker but still there
%B25 - Ori tune at 40 deg
%%%%%%%%
%MOVED ELECTRODE
%%%%
%B26 - Flash, nice reversal on 8.
%B28 - RF @ [0,0], now moved to [-80,0]
%B29 - Ori tune [0.05, 30 deg per sec], still 'columns' 
%B30 or B31 = Size tune, mile tuning
%B32 = LidoPre style surround, nice cross enhance
%B33 = Ori test (0.1,30,0.666 stimdur), still ' columns' 
%Signal is pretty nice, good SUA on ch.3,7,8,11
%B34 - LidoPre (20,40), full block, but mouse moving after 520T or so...
%%%%
%MOVING ELECTRODE
%B35 - Flash, good L4 on 8 or 9
%B36 - RF @ [0,0], still columny , [-100,100]
%B37 - Ori tune test (0.1,30,0.666 stimdur), still columned
%B38 - Size tune (155 deg), not much tuning here, 40 deg pref.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120905
%e4080D again
%Pretty decent signal directly after penetration
%B2 - Flash, little deeper than normal, Rev on ch.10
%B3 - RF @ [0,0], nicely centred at [0,0]
%B4 - SF tune = 0.05
%B5 - Speed tune = 24
%B6 - Conrast tune
%Signal good, some sortable SUA on 7,8, otherwise mostly MUA
%B7 - Orient Tune - Mostly 0
%B8 - Orient Tune (long version,1s on 1s off), some variation now, choosing
%0.
%B9 - Size tune, 20 preferred, quite mild, the 'dip' is there again
%B10 - 2 size surround (20,40) (T1141), nice contextual effect
%B11 - SLOW size tune (1s on, 0.5 off), signal improving
%Sounding more 'awake' during this block
%B12 - Pre-Lido 2 size (T540), 30 s ringer (definatey affected responses in
%upper channels!)
%Ch.5 now coming up as a SUA
%B13 - Lido x10, 30s (small effect)
%B14 - Ringer 30s (Recovery)
%B15 - 10x Lido (30s) (small effect)
%B16 - Recover (30s Ringer)
%Reset thresholds, renewed anesthesia
%Responses looking good, 5,7,8,11 SUA, others may be sortable
%B17 - 30s ringer, drop in response around T400 for unknown reasons
%B18 - 5x lido (30s), larger effect
%B19 - Ringer (30s)

%%%%%%%%%%%%%%%%%%%%%%%%
%20120905B
%Same day as above, but new penetartion (100M from above)
%B2 - Flash - L4 on ch.9 or ch.8
%B3 - RF flash @ -22,-68
%Signal is OK - possible SUA on 6,7,8,9
%BUT RF is weird, a double-RF, very extended vertically
%B4 - quick ori - anbandoned after T90
%B5 - RF with IPSI eye shut, does RF change?
%B6 - Check with CONTRA eye
%Both these show a large oriented RF with hot-spots (or two separate RFs)
%wtf?  Moving the elec slightly to see what happens (40 R, 40M)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120906
%e4080D again
%B2 - Flash, L4 on ch.9
%B3 - RF @ (0,0), pretty spiky here, but very up and down, some dying
%sounds on ch.7, 5,6,7,8 maybe sortable, RF @ [0,0]
%B4 - SF tune, [0,0], pretty deep anesth here I think = 0.05
%B5 - Speed tune = 24
%B6 - Contrast tune
%B7 - Ori tune slow (1s on, 0.5 off), another ori column tuned for 135...
%B8 - 2 mins resting state (NB, screen was blue)
%B9 - Size tune, deep ana, tuned to 30, but looks quite deep.
%B10 - Ori tune with high thresholds to check 'column',  
%B11 - RF flash again
%B12 - RF IPSI patched, ch.11 is SUA here (and the block before)
%There seems to be a smaller rogue RF in a llwer position.  We're moving
%teh RF centre to -50,100.
%B13 - Other pre-amp
%B14 - Size Tune @ -50, 100
%B17 - Two sizes, [40,60] - Nice context effect
%Sounding more awake now so rerunnign the size-tuning
%B18 - Size-tuning - Now tuned to 20, nice super/deep difference
%B19 - 1 minute resting state (Blue screen for comaprison)
%B21 - Pre-lido (30s ringer), now using (20/40)
%B22 - Lido (x5, 30s), good reduction
%TDT crashed here, so some time between lido and recover, plus thresholds
%changed
%B25 - Recover (Ringer, 30s)
%B26 - Lido (x5, 30s)
%B27 - Recover (Ringer, 30s)
%B28 - Flash - Nice, USE THIS, L4 is ch.8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Moved electrode 150L
%20120906B
%B1 = Flash - L4 on ch.9
%Very spiky at this stage
%SUA on almost all channels! 5 is amazing.
%B2 - RF flash @ (0,120) set to [0,150]
%Shifted projector as RF too high, remapping now
%B4 - RF @ (0,0)
%B5 - Orient (No need for SF or Speed as we're close to previous pen)
%Wow - still a column!  Even with all the SUA.  Tuned for 160ish or 0.
%choosing 0.
%B6 - Size tuning using 0 deg, everything tuned to 40, maybe too deep
%anesth?
%B7 - resting state 2 min
%B8 - Contrast tune
%B9 - SF tune, hmmm quite low-pass, 0.05 is still OK (not V1?)
%B10 - Speed tune, very unclear
%B11 - Speed tune at 0.05, 30 is as good as any
%B12 - Size tune again (30 deg/s)
%Still tuned for 40...
%B13 - Surround (2Sz) with 40/60, maybe sounding slightly less deep now.
%B16 - Ringer(30s) predrug
%B17 - 5x Lidocaine
%B18 - Ringer (30s)
%B19 - 10x Lidocaine knockdown
%B20 - REcover (Ringer 30s)
%B21 - Static ORI
%B22 - Check SZ tune
%B23 - StatOri + Lido (x10)
%Not much effect on sustained, but offset response is clearly reduced.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120912B
%diufferent electrode
%RF more inforn tof mouse today, moved projector to lower shelf
%Screen dimensions = 67cm
%Reasonably spiky already
%B2 - Flash, L4 on 9 or 10, LFP dodgy on 1, 14, 16
%Failry up down
%B3 - RF Flas @ [80,0] - mobile phonenosies, abandoned
%B4 - RF Flash @ [80,0], nice RFs, little large, centred at [40,0]
%These are very nicely aligned, example?
%B5 - SpatFreq tune at [40,0], 0.1 just above 0.05
%B6 - Speed tune at [40,0], likes 30 or 36, choosing 30
%B7 - Contrast
%Sounding a bit more dysynched now
%B8 - Oritune, (1s on 1s off), mostly tuned for 90
%B9 - Size tune (0.5,0.5), nice tunigns, 15 for L4/superF, deep layers are
%notched, havign a secondary peak at 40
%B11 - Surround (2 sizes, 90 degree, 15/35)
%B12 - Surround (40/60 to target deep layers)
%Pretty light sounding, SUA on ch.8,9 11
%B13 - Pre-lido, 30s ringer, 15/35 surrsz
%Ringer does eem to have an effect, maybe not fully warmed?
%B14 - Lido (x5, 30s), ch.11 knocked down...
%B15 - Recovery (30s ringer)
%B16 - Lido (x5, 30s), includes own recovery (effect was brief)
%B17 - Lido (x5 30s), plus recovery
%B18 - Ringer 30s
%B19 - 6 minutes spontaneous for Timo, low anesthesia

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120912C 
%New penetartion, moved 160 medial
%B1 - Flash, layer 4 looks like 10
%B3 - RF flash @ [0,0], placed at [20,80]
%Good, if large-ish
%B4 - SF [20,80], [0.05]
%B5 - Speed, 30 OK
%B6 - Contrast tune
%B7 - Ori tune
%OK spiking here, not super SUA or anything, noit majorly up or down though
%B8 - size tune, 15
%B9 - Surround (2size, 15/35, 90deg)
%B10-  Pre-drug (Ringer 30s) (270T)
%B11 - Lido (30s, 5x)
%B12 - Ringer 30s
%REset thresholds as chan 11 was a little high
%B13 - Ringer (30s)
%B14 - Lido (30s, x5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120912D
%150 medial from above pen
%B1 - flash - l4 = ch.9, 
%B2 - RF flash - [0,0] centred on [0,0] but very large drift present
%B3 - Ori tuning at [0,0]
%B4 - Size tuning - mouse moved at end
%End of DAY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120913
%Same electorde as yesterday
%RF is slighlty to right, and slightly up, but almsot direct ahead of
%mouse.
%B3 - Flash, funny looking ,though reversal pron on ch.9, 13-16 not good..
%Pretty spiky at this time, sounds good.
%B4 RF @ [0,0], all channels could have SUA here (well, 2-12 at least)
%Centere on [-50, 50]
%B5 - Sf @ [-50,50], veryu clear bandpass for 0.05-0.1, choosing 0.05
%B6 - Speed tune, likes fast speeds, choosing 36.
%B7 - COntrats
%B8 - Ori
%B9 - size tune, SUA on 5,6,7, maybe sortable of other chans.  Up and down
%Tunigns to 25-30
%B10 - Surround 2sz, [25,45], 90 deg.  Nice context effect at the small size.
%B12 - Check FLASH, still looks like ch.9
%B13 - Size tuning check (450T), improved, now a mix of 15 or 20.
%B14 - Surround (20/40) (Pre-frug, 30s ringer, also can be used as surround
%data), htough the ringer knocked down ch. 12.  Hmm, 11 is also less active
%annoyingly. We let it runt o T1100 at which point ch.12 was back
%B15 (5x lido, 30s), ch.11 knockdown. Includes own recovery.
%B16 (5x lido, 20s), inc recover
%B17 (5x lido, 20s), inc recover
%B18 Ringer (20s), still konocksdown a little, grrr, even when warmed to
%37oC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120913B
%Moved 150 literally
%B5 - Flash - bit quiet now. Ch.9 is L4.
%B6 - RF @ [-100 50], centred at [-40,50]
%B7 - SpatFreq 0.05
%B8 - Speedtune
%B9 - Speed with hgher top speed 30
%B10 - contrast
%B11 - ori, maybe DirTuned, bias for 180
%Spiking is better now, not much on ch.12 though, SUA on 11 (sparse), 6 ,
%8, 9.
%B12 - SizeTune, peaks around 25/30
%B13 - Surround (25/45) slowy sounding more light during this block.
%B14 - Size again, nope still tuned for 25...
%B15 - Surround (25/45: test for segregation, 90 phase shift added to iso-stimuli)
%Break and anesthesia
%B17 - Surround (normal, 25/45) (20 s ringer, some rduction)
%B18 - Lido (20s, 5x), incl recover
%B19 - Lido (20s, 5x), incl recover
%B20 - Lido (20s, 5x), incl recover
%B21 - Lido (20s, 5x), 90 deg phase
%B22 - Ringer (30s)
%And we're done, bedtime.............

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120919
%Electorde 3608 (Same as before)
%Mouse was cold for some reason.
%RF is pretty much on the vertical merdian, upper hemifield
%Screen width = 77.5
%B2 - Flash, nice spiking, good superF spiking, L4 on ch. 10
%B3 - RF @ [0,0], looks a bit 'doughnutty', some drift also.
%It's pretty up and down right now.  %Using [-50,40] for initial tunings,
%will recheck RFs later...actually I improived the RF analysis and teh RFs
%look good and [-50,40] is fine.
%B5 - SF tune @ [-50,40] = 0.05
%B6 - Speed tune, seems bimodal, 24 is a good choice.
%B7 - Ori tune, bit of a mix but bias is for 315 (chosen) or 135
%Possible SUA on chnas 3,4 7,8 ,9, 11, 12
%B8 - Contrast tune
%B9 - Size tune, pretty deep, tuned for 30/40
%B10 - Speed tune again to check bimodality
%B11 - Size tuning, still utned to 30/40.
%B12 - RF check (0,0)
%Now the RFs look a little more like [0,0] and are clearly oriented.
% Rerunnign size-tuning at [0,0];
%B13 - Size tune at [0,0], still not great, though 'notched' at 20
%B14 - Trying a Surround [40/60]
%B15 - 90 deg phase [40/60]
%B16 - Size tuning - NICE!  15 deg suddenly
%Ahhh - this was a mistake, wrong tank used for analysis
%Actually they were tuned for 25/30, so all subsequent data not very
%useful, except maybe 35 as a near surround...?
%Pretty awake now
%B17 - 11 mins of spontaneous
%B18 - Surround [15/35] 90 deg phase
%B19 - Surround [15/35] normal
%B20 - RF again - has it shrunk?
%B21 Pre-drug, no ringer, [15/35]
%B22 Lido (5x 30s), [15,35]
%%ARRRRRRRRRRRRRRRRFGHHHHHHHHHHHHH! TDT CRASHED
%Also quite a knockdown

%NEW TANK
%20120919B
%B2 - Continuation of lidocaine, still knocked down..
%All thresholds are of courtse, lost...

%NEW TANK
%20120919C
%Moved electrode 100 microns
%B2 - Flash, L4 on ch.9
%B3 - RF at [0,0], placed at [-75,100], bit elongated and strange
%PLenty of SUA though on 3,4,5 9
%B4 - SF tune at [-75,100], = 0.05
%B5 - Speed tune, pretty mixed, 3075
%B6 - Ori tuning, 180
%B7 - Contrast tuning
%B8 - Size tuning - not good, maybe 25, but plataued, mostly 40 and shit
%B9 - check RF, still massive
%B10 - size tune, still 40, hohum
%B11 - Surround, doing this anyway at [40,60], OK context at 40
%Anesthetic added
%b12 ringer 30s , [40/60], slow knockdown of 12, why? don;t know...
%B13 - Lido (5x 30s)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20120920C
%Electorde 3608 (Same as before)
%b3 - Flash, chn 9
%Sounds a ittle sluggish at this moment, responses OK though
%B4 - RF @ 0,-100.  Looks good
%B5 - SF = 0.1
%B6 - Speed = 24
%B7 - Orientation
%B8 - Contrast
%B9 - Size tuning
%Pretty weak at this stage, also sounds up and down.
%Bit of a bump at 30, otherwise peaking at 15/20
%B10 - Size tune. Waited 30 mins, size tuning again
%Pretty funky, L4 tuned for 10deg, others for 25.  
%Seem like L4 effect is very ealry, then it looks more normal late on...
%Spreading of surround effect maybe?
%B11 - Surround (2 sizes).  Now running the version called
%grating_suround_2sizes_add90
%This adds the out-of-phase iso conditions to the mix as conditions 18-21.
%B12 - RFmap with ipsilateral eye closed (T2000)
%B13 - RFmap with contralateral eye closed (T2000)
%TDT crasherooo

%NEw tank
%20120920D
%Hopefully a bit more awake now....
%B1 - Size tuining, weird bump at 40
%B2 - Size tuning again, better, stil not greta
%B3 - Surround (20/40), weak effect
%Waited an hour
%B4 - Size tuning again, less spikign now in superF layers...
%Mouse died

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20121106
%Mouse [0,0] was at 72,-176
%80D
%Set-up moved to new position
%B2 - Flash, good responses from 3-13, L4 prob on 10, could also be 9
%B3 - RF map at [0,0]. RF centred at [-70, 30]
%Signal is good. Clear SUA on 5 and 7, 6 and 8 should eb sortable, others
%maybe as well, 12 and 13 are OK
%B4 - SF tune @ -70,30 [0.05]
%B5 - Speed tune, 24 good compromise
%B6 - Contrast tune
%B7 - Ori tune (1s) 0 preferred
%Chn 5 and 7 still perfect sua
%SHIT - the beamer moved slightly, remapping RFs to be sure
%B8 - Rf @ [0,0], now RF is placed at [0,0].
%B9 - Size-tuning. (0.5 on 0.5 off)
%MEGA size-tuning here, especially 12,13. Choosing 20/40 to be fair to all
%chans.
%B10 - 2 size Surround (20/40), 5,7 still SUA.
%B11 - 2 size surround ONSET version (150T - no Correct bit at this stage)
%B12 - 2 size surround ONSET version, Correct bit (7) indicates surround
%onset)
%B13 - Pre-drug Ringer (30s), knocked down ch.13, using normal 2size
%surround (20/40)
%B14 - Lido (5x, 20s), includes recovery, 5+7 slowly dropping amplitude
%Looks like a reasonable knockdown
%B16 - Pre-drug, now using warm aCSF, no difference though, still knocks
%down top channels (12 and 13), responses a little weaker than earlier.
%B17 - Lido (x5, 20s).  Decent knockdown
%Moving electrode

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20121106B
%Moved 150mu medial to above
%Mouse has weird urethaure
%tdtcrashed

%%%%% moved ~50mu more posterior
%20121106C
%Mouse [0,0] was at 72,-176
%B2 flash, L4 = ch.8
%B3 RF @ [0,0], and placed at [0,0] (bit of a compromise, but OK)
%B4 - SpatFreq tuning - [0.05]
%B5 - Speed - [24]
%B6 - Ori
%B7 - Size tuning, some tuning for 25, strangely 'sharp' looking...
%B8 - Surround 2sz, [25,45]. Not a super great rec, ch.7 is SUA, but OK.
%B9 - Surround2Sz ONSET version
%B10 - Pre-lido aCSF surround (2sz)
%B11 - Lido (5x, 15s).
%B12 - Pre-lido aCSF surround
%B13 - Lido (5x 20s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20121129
%OPTO experiemtn - nice effect!
%Electrode 480D
%Starting in extra-striare area [1.6A, 2.4L]
%B2 - Flash
%B3 - RF placed at 0,-100, located lower at -50, -250
%THis works out to be eye-height, and slightly to the right (5-10degs
%estimated)
%B4 - Test of the optogenetics.  One trial has mobile-phne noise, T12-ish
%5s on 5s off.

%Now moving electrode to V1 craniotomy. [0.5A 2.9L]
%B6 - Flash
%B7 - Flahs again
%Bit crappy responses at this stage, very sluggish
%B9 - RF map, guess at -85, -17, place at [-75,0].
%Starng ebug, no wordbits over 99, tryign again
%B11 - RF again.  Wordbits visibly coming in OK. The guess is good.
%B12 - SpatFreq - 0.05
%B13 - Speed - 24
%B14 - OptoOri! - 180, plus some opto effect
%B15 - Size Tuning - nice effect! And nice opto effect!
%B16 - Contrast tuning - TDT crashed
%B18 - Contrast again
%B19 - Surround (2 sizes)
%B20 - Static surround + 3 stim times
%B21 - Hupe
%B23 - Checkerboard.

%%%Moving electrode to more medial posiiton (200mu)
%Also changing to electropde 3608
%Changed tank to %20121129B
%MOved again to anterior position from previous hole (200mu-ish)
%B3 - Flash, too shallow
%B4 - Flash 
%B5 - RF flash. my guess, -85,-75.  This was well=placed
%B6 - SF - 0.05
%B7 - Speed -24
%Responses are OK, quite spiky, SUA on chn 5, sortble on 6,7, maybe 11
%B8 - OptoORi, now using 30 degree spacings. = 12 stimuli. (120)
%B9 - contrast
%B10 - size tuning - 20 (20 40 20 40 in following scripts)
%B12 - surround (2 sizes) - had to change ORI to 130 deg because of jitter
%in surround bug
% gave the mouse extra dose of urethane, via subdural syringe in back,
% approx. 0.05 ml, but difficult to see because syringe covered by blanket
%B13 - static surround + 3 stim times - mouse slightly moving a few
%times...
%B15 - Hupe
%B16 - checkerboard

%%%Moving to new position, a bit more medial from previous V1 penetration
%same electrode, had to give extra urethane and chlorprothixene to mouse
%had to clean/dry throath because was starting to gasp a little bit
%tank changed to %20121129C
%B1 - flash: position ok, contact 8-9 = layer 4
%B2 - RF flash: guess -90 -120 ---- -120 -80 seems better
%B3 - SF: .05
%B4 - speed 24
%B5 - OptoORI, 30 degrees spacing: 150 deg optimal
%B6 - contrast 
%B7 - size tuning
%B8 - surround (2 sizes) --- bug in script, motion jitter 
%B9 - surround (2 sizes) but now with 140 deg ---- 1090 trials: mouse
%signal is improving, threshold setting not optimal, liberal units
%gasping heavily, also a Matlab quit because of Jave runtime error
%swapping the mouse throath 
%B10 - surround (rest), kept same thresholds: TDT crash (?), only 50 extra
%trials

%created new tank 20121129D
%B3: static surround
%mouse gasping again, end experiment
% DyeI has dried up, instead of that we insert Joris' electrode and hope we
% can see the damage


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20121206 - Direct FX then weird responses
%Good expression levels, starting on the right hemisphere, quite lateral
%electrode = 4080
%B3 - Optotest - strange bursting sometimes.
%b5 - Flash - nothing obvious
%B6 - Flash
%RF guess = 20,-200
%B7 - RF @ -20,-200
%RF is beteen 0 and 200 (some drift here).  Also it';s at -300 on the y
%axis, so quite low.  In relation to mouse it is 10 degs below and extends
%from midline to 20 degs out

%Moving to V1 now, 2.9L,0.4A (Lambda, 11178,9328)
%B9 - Flash, too shallow
%B11 - Flash
%RF guess = 50,-90
%B12 - RF @ 50,-90
%B13 - Sf tuning AT 50,-90 = 0.05
%B14 - Speed tuning = 36
%B15 - OptoORI
%B17 - Optotest

%It looks like thesre are direct effects here, particularly in th elower
%layers.  So we're moving more medial by 500 mu. Gave an extra dose of .05
%urethane

%B20 - Flash, too shallow
%B21 - Flash, nice SUA on ch.11!  Ch.9 is L4.
%Guess = 125,-60
%B22 - RF @ 125,-60.  Good SUA here on many channels from 4-11.  Actually
%at 100,-150
%B23 - SpatFRew @ 100,-150 [0.05]
%B24 - Speed tune, weird sqeaking sound occasionally (quite often
%actually).  No idea what it is... [30]
%Worked it out, the pre-amp was low on batteries.
%B25 - Ori-tune OPTO. Channels 11 and 12, the RMS has gone up for some
%reason meaning the thresholds aren;t any good anymore.  Dagnabbit.
%The increase in RMs was due to something in the ground circuit, we now
%move to a floating ground, much better RMS now. (And we're back with the
%other pre-amp)120 deg chosen
%B26 - Size tuning.
%B27 - Optotest
%B28 - Optotest (60T)
%B29 - contrast
%mouse started gasping, cleaned the throat, o2 a little bit higher, seems
%okay now, ch12 a big single unit
%B31 - size tuning, again, now mouse littler state of anesthesia (?)
%B33 - Size tuning quick with ipsi patched (Joris plotting: only 9 MUA
%channels????)))
%B34 - Same but with contra patched (Joris plotting:???)
%B36 - Flash
%REsponses are very sluggish and werid, giving up on this pen.

%new penetration, more posterior, LatMed in between the previous two holes
%B39 - flash
%B42 - better flash, still very sluggish, 8 is L4
%B43 - RF, guessing [0,0], bit weird lookign, centre maybe at [100,0]?
%B44 - Size tune quick at [100,0], some tuning, but for 40 degs
%B45 - Optotest (60T)
%B46 - REsponses still verrry slow, trying one last opto size tune...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%20121211 - Good effect
%Electord 408D
%Right hemisphere, quite lateral transfection

%Can;t measure RF at injection site as it's out at 90 degrees from the
%mouse, but clearly visual.
%B2 - Optotest at injection site, clear effect.

%Now moving to a V1 site at 2.9L 0.4A (Normal place)
%B3 - Optotest - artifact at around T50, but clearly no effect of the light
%B4 - Flash, weird looking
%B6 - Flash again, still weird
%B7 - RF @ 100,-100, actually at [110, -50]
%B8 - Flash, better, but still rubbish MUA, layer 4 on ch.9
%B9 - SF tune [0.05], MUA is quite low-pass
%B10 - Speed tune [24]
%Probably  bit deep anesth at this stage...
%B11 - OptoOri (760T), responses getting better.
%B12 - Size tuning - GREAT EFFECT!
%B13 - Cross Iso
%B14 - Hupe (problem with ori, abandoned)
%B16 - Contrast tune
%B18 - Stat Opto
%Signal is really very spiky, SUA almost everywhere here, niccce.
%B19 - Hupe again, working properly now (TDT crashed at some point)
%Such nice SUA here that we're rerunnign size tuning
%B21 - Size tune OPTO

%given extra anesthesia: .10 urethane and .10 chlorprothixene @ approx. 6pm

%Moving to a new location, other hemisphere
%No obvious visaul responses here, maybe auditory?
%B23 - optotest
%%Now moving to V1
%Not great responses
%B24 - Flash, mouse was 'blind' 
%B25 - flash again, OK, L4 on 9
%B26 - Optotest - some fx, runnign again to check
%B27 - optotesty
%B29 - RF flash at [0,0], 
% still weak responses here, but RF OK at -75,-50
%B30 - SF, [0.05, low-pass]
%B31 - speed [18]
%B32 - Ori tune 300 deg
%B33 - Size tune opto
%B34 - Surround 2Sz OPTO
%B35 - Hupe
%B36 - Stat opto

%went up, given extra anesthesia (urethane and chlorprothixene) @ 1.15 am
%got the DiL (checked papers on probes, was okay, no damage both on laminar
%and grid probes
%went down in second penetration in Right Hemisphere, more anterior hole
%B37 - flash - not really good response, cortex very rhythmic across all
%layers identical weak synchronized activity
%lowered electrode another 100 mu
%B38 - flash again: slow responses ch9 L4
%B39 - optotest
%low responses because of pre-amp battery almost empty? other pre-amp was
%not charged, charging now...
%moving bar: x=274 y=-117
%B42 - RF flash at 100 0 --- 110 -105
%B43 - OptoORI, went straight to this test to quickly check whether there
%are any modulatory effects, responses are still low almost no single unit,
%unclear results weak tuning

%dip first two penetrations with DiL on single electrode
%try to do optical imaging to get V1 border


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20121220 - Durect FX or weird responses
%4080D
%left hemisphere, quite lateral expression pattern
%REcording first in 'extra-striate', though no visual responses, and probably sensory 
%B1 - Optotest
%Moving to V1 to check it out...
%Responses are very sluggish
%B2 - Flash, CSD good, ch8 is L4
%B3 - RF at [0,0], [0,-60] chosen, RFs OK given sluggish signal
%Up (30deg?) and slightly to right (5deg?) of mouse
%B4 - SPatFreq - [0.05]
%B5 - Speed - [30]
%B6 - Optotest- abandoned as light not switching on
%B7 - Optotest
%B9 - Ori test (Quick)
%B10 - Size tune

%
%Moving over to the other hemishpere
%Better transefection
%B11 - Flash Limit, sounds responsive
%RF is pretty much right in front of mouse
%B13 - Optotest
%Now moving to V1
%B14 - Flash, unclear if responding.
%Too temporal, moving to a new hole
%B15 flash

%Moving more lateral and changing electrode to 3608
%Changed tank to 20121220B
%Flash, block-2, weak responses
%B3 - RF, [0,0]

%Now 20121220C
%B1 - Flash, ch.10 prob L4
%B2 - Optotest
%B3 - Optotest
%B5 - Optotest

%Anesth given, chlorwhatnot + urethane
%Moving again to another site
%More anterior
%B7 - flash - too shallow
%B9 - Flash
%B10 - RF flash at [0,0], weird bu t[115,-80] ok fro superF channels
%(13,14).  oNly Rfs on upper channels and very deep sounding spiking.
%B11 - SpatFreq [0.05]
%B!2 - Speed [24]
%B15 - QuickOri, some java errors at around T30
%B!6 - Size tune, clearly there are direct effects here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MOuyse J63,, the end of the wporld 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20121221 - No soze tuning
%Injected at an angle (27/11), lateral and anterior
%Large craniotomy, electrode 3608
%Recording fromt ransfected zone
%Sounds like it might be auditory...and visual?
%B2 - Flash
%B3 - Flash again, doesn;t give a response
%It's definately audoitory coretx
%B6 - Optotest, nice knockdown
%Now moving over to V1
%B7 - Flash - Niiice, 8 and 9 ae L4
%B8 - Optotest
%B9 - RF,[0,0], placed at [100,30]
%B10 - SpatFReq
%B11 - SpeedTune
%B!2 - OptoORi - quite nice and spiky now.
%Not necessarily SUA though
%B!3 - Size tune
%BOLLOX, mouse moving afte T36, anesth given
%HAd to remove electrode, arrrrghhh!
%Back in now, not so awake sounding anymore...
%B14 - Flash, 8 and 9 = L4
%B15 - Optotest, increases
%B16 - RF
%B17 - Orientation (quick)
%B18 - Size tune opto
%No soze tuning and no effect
%Recording is OK, but not much SUA.
%B19 - OptoOri: no effect light on...
%B20 - quick contrast tuning
%B21 - QUick ori with contralateral eye patched
%B22 - And with ipsi patched
%B23 - Size tunes, still nothing
%B24 - REchecking RF
%B25 - STILL no size tuning, screw it, let's go somewhere else....
%Moved 50/50 L/A
%B26 - Flash, ch.9 is L4
%B27 - testOpto - response
%B28 Optotest, patched, 
%B31 - RF, @ [60,50]
%B32 - QuickOri
%B34 - Size Tune, nothing
%Waited
%B35 - Size Tune

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20130110 - Direct FX
%Electrode 4080
%B2 - extra-striate optotest
%Probably only first four chans in here, they were affected by light.  No
%obvious visual or aud responses.
%Moving to V1 now
%Also changing to electrode 3608
%B3 - Optotest, large reductions in spiking
%B4 - Flash, between 8 and 9
%B5 - RF at [0,0], very lateral
%B6 - RF at [0,0], still lateral and ver rubbish looking
%Moving more lateral, 0.3 extra urethane given
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changing tank to 20130110B
%B2 - Optotest - looks liek direct effects
%B3 - Flash, good example!, Ch.9 is layer 4
%B4 - RF @ [0,0] placed at [0.-100]
%B5 - SF - 0.05
%B6 - Speed, unclear, 30 is fine1
%B7 - Ori (0.5s, 30deg sep), tuned for 60
%Orient skipping fro 60 so changing to 55
%B9 - Size tuning opto
%B10- Size tuyning opto
%MOved 100 posterior
%B11 - Flash, too deep
%B13 - Flash. Ch.10 is layer 4.
%Responses are crap, abandoning this mouse

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20130117 - Not OPTO
%Trying a new electrode 
%This is a 177 square micron electrode
%Brand new, it has a broken channel #3
%Normal black 6 mouse (i.e. no virus)
%Signal is much better!  Goosd spiking overall, including layer 1!
%B2 - Flash - layer 4 is on ch.10
%B3 - Rf flash @ [0,0], some shifting, OK, [50,-80]
%B4 - SF tune @ [50,-80], [0.05]
%B5 - Speed tune - Good tuning, 30deg
%B6 - Ori tune, 1s stims and 30 deg seps, 220 os good comporomise
%SUA on many channels here, deffo 9,12,13 and 14,
%B7 - Size Tune (1s stims), slightly odd, some SUA tuning, not much MUA
%B8 - RF check
%B9 - Size tine again, moving RF centre to [80,-80]
%Better now, lot sof great sua tunings to 15 degs pr lower, 20 is best
%compromise.
%B10 - Two sz SUrround, [20 40]. 810T
%B11 - Onset surround [20 40]: lower quality of SUA on channel 14 (but
%maybe this was already the case in previous test? - comment Joris)
%Finishing up with this pen
%Now moving to  new site, extra Urethane goiven, moving unknown dist
%lateral, probably 180.

%2013017B
%NEw pen - not as spiky as before, but OK
%B1 - Flash, layer 4 is on ch.10
%B2 - RF, [0,0] = [50,-100]
%B3 - Ori, 240
%Signal is OK, mutli-unit, no obvious SUA candidates, so not great.
%B5 - Size-tune, a little weak. Using 245deg.
%B8 - 2 sz surround [15 35], had to change to 248 deg for jitter reduction
%And that's it for today...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 01 21: Joris test Gad2Cre - ChR2 mouse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%microfiber too weak to affect responses even at the same position as probe
%had to repair the old led-box, TTL pulses where missed
%ChR2 was present: clear effects when using the Doric system
%also clear effects but with big light induced artifacts when using the
%laser of Ralph
%ran one optotest
%signal was bad: re-used the crooked probe which I cleaned with the contact
%lens solution: maybe solution had an effect on the contact points?
%nice spiking on Ch1, in hippocampus

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013_01_22 - Small but OK effect
%Electrode is the 177 contact-size electrode (FB3)
%Optomouse, injection carried out under guidance of optical imaging.  It;s
%quite anterolateral.
%First recording from injection site (4 lat, 2.5 ant).
%B3 = Optotest
%Site is visually active, low down and central-ish
%Changing tank name to 20130122
%Dura is quite tough, shifting the elctrode to a 15deg angle and mving
%diag.
%Removing more skull
%B1 - Optotest
%Recording sounds quite crispy
%B2 - Flash, ch.11 is L4.
%B3 - RF @ [0,0]
%At the moment, 8, 11 and 13 look like SUA, 10,12 prob sortable
%B4 - SF tune - [0.05]
%B5 - Speed - [24]
%B6 - OptoOri - 1s
%B7 - Sizetuning Opto, audiblt tuned
%Tuning is good, a little broad between 20 and 30 max.  Opto has very small
%effect.
%B9 - Two size Surround, [30 50]
%This crashed after 830T, but rst of data OK.  Some pto effects, small but
%surround increases and cross/centre diff decreases.

%Moving electrode
%60lat, 30Ant
%New tank 20130122B
%B2 - Optotest
%Bad signal, stopping


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20130124B
%FB3 again
%Transfection looks good, two injections anetrolateral and lateral.
%First at transfeetcion site
%Signal has lots of spiky nopise in it , we dfon;t know hwy.
%Trying optotest anyway, the site is clearly visually responsive.
%B2 - Optotest, some interneurons here, channels above 8 not in.
%Now moving to V1
%Noise issues solved (crusty salt)
%B3 - Flash, L4 on ch.10.
%B4 - Optotest: transient responses to light, visual maybe?
%B5 - RF flash, abandoned
%B6 - Optotest again, now screening off the mouse
%Some reduction here, though maybe not direct as it's quite subtle.
%B7 - RF mapping [0,0], RFS are very strongly oriented and very large, are
%we in V! here?
%Moving 100mic posterior
%B8 - Flash, ch.10 is layer 4
%B9 - RF flash @ [ 0,0], still weitrd looking RFs
%Moving 100 lat, 50 post
%B10 - Flash, L4 on 9/10
%moving again 50  more posterior, because RF was very low...did we do
%something wrong with positioning probe? nope, eye covers were still on,
%could have been a reflection of the table top..
%B12 - Flash: L4 = ch9, drop another 100 um
%B13 - Flash: L4 = ch10.
%B14 - RF flash @ [0,0]
%RF's good, but too far to the right.  Shifting projector.
%B15 - RF again, [0,0], placed at [-40, 0];
%B16 - Optotest
%Skipping SF and speed today, just using [0.08 and 28 deg.s]
%This gives a cycle time of 446ms
%B17 - OptoOri, gasping after 350T, movement visible in recordings
%Reduced responses, but don;t seem to be direct
%Throat swabbed, seems OK
%B18 - OptoSizetune 
%Signal is pretty spiky, some SUA, ch.4, 5, 7, 10.  Others sortable inc 8,9
%However visyual response is not ideal.  Also size-tuning not great and
%little opto-effect.
%B19 - 2 sz surround

%Moving more lateral now
%B20 - Flash, L4 is 9/10
%B21 - RF flash (?)
%B22 - Optotest
%B23 - OptoOri: not particulary tuned for any orientation...a bit for ch8
%on SUA and MUA for 300 deg...very erratic tuning curves, more so for light
%on
%B25 - OptoContrast (not analyzed yet)
%B26 - OptoSize: nice size tuning with clear opto effects! selected 15 and
%thus also 35 deg
%B27 - two sizes surround: jitter on stimulus at 300 deg orientation 
%B28 - two sizes surround: switched to 298 deg, no jitter

%given extra anesthesia @ 2 AM

%screen position [0 0] at 10 cm hor 10 cm vert to the right of the front of
%the nose of the mouse, put projector back into the middle

%new penetration, more lateral, closer to the viral patch
%signal is not really good, maybe one sortable unit on ch 8
%B29 - Flash: L4=ch9, moved down by 100
%B31 - Flash
%B32 - RF flash: -100 0 
%B33 - Optotest: small effects only on 2-3 channels...not sure direct or
%not?
%B34 - OptoOri: nice orientation tuning 180 deg, nice opto effects:
%divisive scaling: some light effects on spontaneous but with latencies
%B35 - OptoSize: size tuning with suppressive effects for larger, more so
%in the super than deep channels, not massive, interesting light effect,
%similar responses for the small gratings, only when large enough responses
%between light on off start diverging, with the light on reponse curve
%below the light off curve: sort of close but not direct effects via
%horizontal connections, not feedback (you would expect release from suppression)
%B36 - two sizes susurround
% responses are getting better again, lighter anesthesia
% nice UNIT on ch 10 SUPERFICIAL channel: perfect unit, does not need
% sorting
% rerun the SizeOpto test
%B37 - OptoSize: nice suppression on ch 10, unit, effects light on on first
%sizes, not at the largest size, on neighboring channel, no effect of light
%on
%B38 - two sizes surround: response on ch 10 smaller...: run for approx 680
%trials, opto effects


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130131
%
%Started off with some computer crashes
%Electode FB3 again
%Expression was tested with intinsic imaging, is outside V1, quite large
%lateral-anterior.
%
%Starting at the injection site
%Not  agret signal, only signal on ch. 2 really, but enough to see its
%visual.
%B2 - Optotest, very low signals here
%Electrode is nbending, enlarging hole and redropping
%B4 - Optotest again, ch 1 and 2 OK, some crappy spieks elsewhere (noise)
%B7 - trying again. Ch.1 appears to have interneuron small spieks and
%pyrimidal large spikes. Only really see increases though
%Moving to V1
%Nice spikes on descent, but very quiet once we reached the right depth.
%B8 -  Flash - awful
%B10 - flash again with full grounding
%Mouse gasping, response rubbish, electrode looks very dirty, DiI?
%Changing to electrode 3E7E (477, 15micvr)
%Mouse OK again
%B15 - Flash, shallow and noisy
%B17 - Flash again
%B!8 - And again
%B20 RF, rubbish
%New PEN
%B21 - Flash

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mouse with congene ChR2 under GAD2Cre promotor
%test laser coupled microfiber: 62 um, laser from Ralph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%first penetration, close to microfiber, do optotest with different
%intensities, big artefacts of light, less for lower intensities
%B1 - Optotest, laser @ 0.77, knob @ 3.6
%B2 - Optotest, laser @ 0.89, knob @ 4.6
%B3 - Optotest, laser @ 1.00, knob @ 5.6
%B4 - Optotest, laser @ 1.14, knob @ 6.6
%B5 - Optotest, laser @ 1.31, knob @ 7.6
%B6 - Optptest, laser @ 1.51, knob @ 8.6
%B7 - Optotest, laser @ 1.78, knob @ 9.6
%%%%%%
%new penetration in same big hole, fiber closer positioned
%B8 - Optotest, laser @ .88, knob @ 4.6; less to no light artefact!!!
%B9 - Optotest, laser @1.14, knob @ 6.6; no artefact
%B10- Optotest, laser @1.51, knob @ 8.6; starting to see some artefact on
%upper channels
%B11- Optotest, Doric LED, very clear effects: inhibition, a lot more light....
%%%%%%%%%%%%%%%
%go down again, give extra shot of urethane
%at laser 5.4 strength 0.89 effects on ch1, 1-13 are in
%B12 - Optotest @ laser 0.89, knob @ 5.4: look at ch 1 TDT crash
%%%%%%%%%%%%%%%%
%new probe; small contact points but after cleaning with contact lens
%solution still has a lot of dirt on it
%B13 - Optotest @ laser 1.91, knob @10.0 MAX laser: no artefact
%%%%%%%%%
%tried again with another probe and in another hole, good responses but
%probe was very light sensitive...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130205
%4E7E, checked and it's clean.
%Expression is good. Lateral, large, so running close to V1 as well.
%
%B2 - Optotest, clearly auidble effects, ch.6 changing amplitude a lot, but
%very clear effect
%B3 - Flash, it is visual but no effect.
%Now moving to V1
%with LED Doric direct effects, also viral expression spreading to V1
%use LASER and microfiber, put fiber over the anterior injection hole (?
%area AL)
%B5 - Optotest, laser @ 0.83: no effects
%B6 - Optotest, laser @ 1.89 (max): effects, facilitation?
%B7 - Flash
%B9 - Flash: lowered the probe by 200 um
%B11 - Flash: lowered: nice flash but 50 Hz...
%B12 - Flash, shut off laser: ch 10-11 L4
%B14 - RF Flash, -130,-80
%B16 - OptoOri, good spiky signal, esp 6, 7 and 9: laser @ .80
%B17 - OptoSize - weak effect, and opposite to before..
%Some gasping after this
%B21 - Surround, [40 60]
%Mysteriuous blocks 22 and 23 here...was it a ghost?
%B24 - Flash
%B27 - Optotest
%%%%%%%%%%
%new penetration in V1, repositioned microfiber over the posterior higher
%area craniotomy
%B29 - Optotest: some direct like effects but long latencies...
%B30 - RF flash:[-130 -40] rf better, smaller, ch9 big unit RF is elongated 
%mouse started waking up had to give extra shot of urethane @ 11 pm
%went back up and back down
%B33 - Optotest: direct effects in the deeper layers
%B34 - Optoteststim: again direct effects in the deeper layers with 0.83
%B35 - Optoteststim: laser @ 0.66 (decreased intensity): no direct effects
%anymore, but is the intensity strong enough to shut down higher????
%B36 - Optotest: no direct effects
%B37 - Flash: nice CSD 
%B38 - RF Flash [-80 -40]: looks quite good on SUA pract no long RF
%B39 - OptoOri:150  strong onset effect light on, for few ms light much
%stronger: effects, tuning sharpened
%B40 - OptoSize: small effects release from suppression...for 60 and 100
%degs
%B41 - surround [40 60]: ipsi eye turned bad: white 'substance', dried
%mucus? covering eye...contra eye looks okay: small sizes = with light red
%lines shift up to orange lines, and orange closer to gray; large sizes =
%no effects at first sight, mouse started to wake up at the end of test
%%%%finished recording in V1
%%%%move probe to extrastriate, first in posterior hole, to check whether
%%%%laser power of .66 is sufficient to drive the cells here, this
%%%%intensity had no effect in V1
%B42 - Optotest: no effect (?), strange because this same intensity while
%recording in V1 did show direct effects...cortical activity is very
%rhytmical...
%B43 - Optotest:no effects
%B45 - Optotest laser @ 0.82: effects on superficial layers
%B46 - Optoteststim laser @ 0.82: more clear effects
%B47 - Optoteststim laser @ 0.66: no effects...
%%%%%%%
%%%%%made 2 new holes in between the anterior extrastriate injection site
%%%%%and V1, first recording optotest in the hole closest to extrastriate
%B48 - Optotest laser @ .66: effects light on
%B49 - Optoteststim : effects light on
%%%%%%went down with probe in other hole made on the line between
%%%%%%extrastriate and V1 but no activity more 
%B50 - Optoteststim: after a long wait small spikes on ch 5,7,10, up till
%ch11 in brain, no effects

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130212   fully expressing ChR2 mouse: test laser coupled microfiber
%new laminar probe #4147
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%probe in cranio 1,
%fiber in cranio 1
%%%%%%%%%%%%%%%%%%%
%B1 - Optotest, laser @ 0.78; ch14, 15, 16 not in....word bits not read in:
%loose connection ribbon to desktop
%B3 - Optotest, laser .78
%B5 - Optotest, laser .99
%probe very light sensitive, try with Alex's system and single elec


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130220: J69
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%New electrode, leftmost in batch: 2B76
%Only 12 days after injection, expression is restricted.
%Some high-frequency pops-and-clicks are present on all channels, unclear
%what the source is.
%B2 - Optotest in extrastriate
%Works well
%Moving to V1
%B3 - Optotest in V1
%LArge visual response, shielding off the eyes more carefully
%B5 - Optotest, better now, though still some late effect (~100ms)
%B6 - Flash - L4 on ch.9 (or 8)
%B7 - RF Flash, []shifted the projector somewhat up and to the left, inspired
%by moving bar mouse
%RFs are multiple and in diff pos
%Some Urethane effects, more urethane given
%Moving anterolateral
%Still got shitty pops and clicks
%B8 - Flash, not deep enough, moving down 300.
%B9 - RF, [0,0], looks better, moving projector screen over
%B10 -Flash, could be ch.10 or ch.9
%B11 -Optotest, oh-oh, looks direct.
%Going to carry on here anyway to look at horiz conns.
%B!2 - RF, drifitng, [0,0] is a compromise
%B13 - Ori tune (10x T)
%B14 - Size tuning: nice effects in the sense that prestim clear effects,
%500 ms no difference light on vs off and just after 500 ms inhibitory
%cells activated by the ChR2 DOMINATE again
%%%%other hemisphere
%%%extrastriate
%B15 - Optotest: effects but low spiking, only on Ch5
%B16 - OptotestStim
%B17 - OptotestStim went down deeper: clear effects light on
%%%in V1
%B18 - Optotest: no direct effects
%B19 - OptotestStim
%B20 - flash - L4 Ch10
%B21 - RF flash [160 -80]
%B22 - OptoOri 
%B23 - SizeTuneOpto: very nice effects!!!!!!!!!!! facilitating
%SurroundSuppression
%B25 - CrossIsoOpto 
%B26 - CrossIsoOptoStatics 390 trials
%B27 - ContrastOpto
%%%%%%%new penetration more lateral posterior position in same craniotomy
%B28 - Optotest: spontaneous bursting spikes, light had an effect
%B29 - OptotestStim: however here no effect of the light when stimulus
%driven, still reponsivity rather low, not a lot of spikes
%B30 - Flash: nice L4 Ch10 ish
%B31 - Flash again (shutting off Sutter, causing high freq noise in results
%previous flash
%B32 - RF Flash



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130222, J70
%probe leftmost in batch: 2B76
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OK expression local extrastriate, again not super obvious prob due to
%discrepancy in expression rates YFP and ChR2
%%%%first record in LEFT hemisphere
%%%%in higher region
%B01 - Optotest: very clear direct effects
%B02 - OptotestStim, also clear direct effects, 
%MOving to V1
%Channel 1 has strange rhythmic clicks (1Hz or so)
%Ch.13 sounds kind of broken
%B3 - Flash - noisy
%B4 - Flash again, still abit noisy but L4 on ch.9
%B5 - TestOpto
%B6 - RF flash, OK RFs though drifting, best compromise is -100,-30
%Signal is OK, but not many channels in, also no obvious SUA.
%B7 - OptoOri, light enhances tunign, 150 preferred
%B8 - SizeTune - nioce effect!
%B10  - 2 surroundopto, 20,40 sizes.
%B11 - CrossIsoStatOpto: mouse waking upish (but not actually awake)
%B12 - OptoContrast: sometimes big artefacts when light was turned on or
%off in the next door room (working on the two-photon set-up)
%B13 - HupeOpto
%%%%%%%%%%%%%
%made new tank 20130222B, other hemisphere: right, 2 injected sites, one
%expressing well
%%%%first in most anterior hole
%B01 - Optotest: clear direct effects
%%%%moved to V1 site
%B02 - Optotest: facilitation on some channels:
%B03 - Optotest with shielding to prevent ambient blue light causing
%facilitation: now perfect on top of each other, no effects
%TDT crash restarted new tank name Mouse_20130222C
%B01 - Flash L4 ch10-11 good CSD
%B03 - RF flash, noisy glitches unexplainable...strange and large RF, maybe
%due to the fact that we are going diagonal into brain?
%back out and now go straight
%B04 - Flash, weird ch 5 still too high
%%% going down another 100 um
%B05 - Flash - Ch9-10 still weird ch5
%B06 - RF Flash; ch 1-8 big rfs, seems abnormal, ch 9-13 okish, not
%perfectly small though...continue: [0 -50]
%single units on ch 7,8,9 and maybe 10
%B08 - OptoOri 150 degs: sharpened tuning for some in SUA, MUA: additive
%effect!!!!!!!!!! overall facilitation
%B09 - SizeOpto: nice effects, size tuning isnt super only for a few
%channels, superficial but this is related to the big RF on the deeper
%channels, you would not expect to see decent size tuning for such big RFs
%B10 - CrossIsoOpto: subtle effects but something is happening in the late
%interval after 500 msec for the small stim sizes gray further apart from
%black with light on, for the large stim sizes orange moves away from red
%B11 - CrossIsoOptoStatic
%B12 - ContrastOpto
%B13 - HupeOpto
%B14 - SizeOpto (again, interrupted early...no time)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130226 - J68 - good expression, FP clearly visible
%two hemispheres to test, RH best most local but maybe somewhat lateral?
%LH more spread out must ascertain no direct effects
%B01 - Optotest: shutting down activity on Ch6, rest facilitation...(light
%artefact or light hitting retina?)
%B02 - Optotest - went deeper: silencing on most of them strange ch10 super
%excitation: picking up light artefact??
%%%V1 hole
%B03 - Flash: deep enough? eye covers were still on
%B04 - Flash
%B05 - Optotest: ch9 l4
%B06 - OptotestStim + placed black cover shield: no direct effects, though
%long distance effects present, eg ch4 first 500 ms no difference, last 500
%ms differences, also a bit on ch9 and 10
%B07 - RF Flash
%B08 - RF Flash changed position of monitor [0,0]
%B09 - OptoOri 200 deg: sharpened tuning
%B10 - SizeOpto: trial 1 no Word bit, quick n dirty changed first trial into condition
%1: sizes 30 and 50, no release from suppression, substraction light on
%B11 - CrossIsoOpto trial 1 no Word bit
%B12 - CrossIsoStatOpto
%B13 - ContrastOpto
%B19 in Mouse_20130222C - HupeOpto
%%%%
%%%new penetration in V1 more anterior
%B16 - Optotest
%B17 - OptotestStim
%B18 - Flash, ch9 L4ish
%B19 - RF Flash at [0 0]
%B20 - OptoOri @ 210 deg
%B21 - OptoSize
%B23 - CrossIsoOpto


%%%%%%%
%left hemisphere, positioned in the middle, viral expression rather broad
%B25 - Optotest
%B26 - Optotest: went deeper then normal to get rid of heartbeat on ch13
%B27 - OptotestStim: both optotest show no (direct) effects, proceed
%B28 - Flash: ch12 - l4
%B29 - RF Flash: RF too low
%%%make new penetration more posteriorly and somewhat more lateral
%%%still too lateral rf, have to go more lateral on skull, enlarged 
%%%craniotomy
%B31 - RF Flash, too deep
%B32 - RF flash, okay [115 0]
%B33 - Optotest (no black cover)
%B34 - OptotestStim (with black cover
%B35 - Flash (still too deep)
%B36 - Flash 2
%B38 - OptoOri
%B39 - SizeOpto


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130503 - oops wrong name (changed after block 1)!

%Now using ARCH!
%Quite large expression with a lot of projection-like expression.
%Recording first in extra-striate area
%B1 - Optotest - visible effect

%Now changing name to Mouse_20130305.
%V1 recording site
%B1 - Optotest: no direct effects
%B3 - Flash - Layer 4 on ch.8
%B4 - RF, [0,0] is a good compromise.
%B5 - OptoOri - 300 preferred
%B6 - OptoSize
%B7 - CrossIsoOpto TDT CRASH - approx 1000 trials okay, crash at 1030
%%%move light fiber to V1 hole
%B8 - Optotest
%B9 - SizetuneOpto
%B10 - StimOpto
%B11 - CrossIsoOpto 1020 trials
%B12 - OriOpto

%NEw tank, Mouse_20130305B
%Now on the right hemisphere, V1.
%On this side, more restricted expression, though still quite large.
%B2 - Optotest, increases, (ambient light?)
%Covering and runnign stimopto
%B3 - Flash - L4 on 8.
%B4 - OptoStimTest
%B5 - RF flash, out of position
%go back up and more lateral, but mouse died
%perfusion done

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 03 07
%second Arch mouse J72
%green laser and microfiber
%pre-ephys Optical Imaging done on Daneel: only RH, clear that viral
%injection hole was not in V1, retmap however is not unequivocal that it is
%then in LM...injection is somewhat more posterior and could encompass LM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Right hemisphere
%in higher region, it is a visual region
%B2 - Optotest: direct effects
%B3 - OptoStimTest: effects but not complete shut down
%B4 - Optostimtest: good unit on ch7: complete shut down on 3 channels
%%%V1 location
%B5 - Optotest: no effects
%B6 - Optostimtest: no effects maybe something small on deep channels but
%super you get facilitation
%B7 - Flash: strange responses, unclear resul
%B8 - RF flash: bad result and with flashlight RF is too temporal and too
%high
%%%move probe more lateral and anterior in cranio
%B9 - flash: looks decent a lot better than previous penetration
%B10 - RF flash: nice RF moved the projector a bit now
%B11 - RF flash: [100 60]
%B12 - OptoOri: not tuned
%B13 - SizeOpto: TDT crash
%B15 - SizeOpto: strange effects but seem real, inducing surround
%suppression with light on.  Extra bump in light-off responses.
%B17 - CrossIsoOpto
%Moving fiber to over V1
%B19 - CrossIsoOpto
%B20 - RF again to check
%Sounding very spiky and awake right now, esp chans 7,8,9
%B21 - SIze Tuning - audibly strongly tuned.
%B23 - Statopto
%B24 - Contrast Opto

%%%%new penetration in the same V1 craniotomy, moved more anterior should
%%%%bring down the RF, did not move lat/med
%%%%new tank Mouse_20130307B
%B1 - Optotest: something on temporal profile, but do not believe it's
%direct
%B2 - Optoteststim: no effects 
%B3 - Flash: L4 = ch10 ish
%%%had to go back up, mouse waky, gave extra urethane and chlorprothixene
%B5 - Flash: crappy but good responses with moving bar mouse L4 = ch11?
%B6 - RF flash: [0 50] ok small RF
%B7 - Flash:L4 = ch12
%B8 - OptoOri: weak to no ori tunin, as in the previous penetration, 90
%strange lack of response but good spiking...
%B9 - Speedtune: 18
%B10 - SFtune: 0.01
%B11 - OptoOri...0.01 sf is really coarse, quiting
%B12 - OptoOri with .05 sf
%B13 - OptoSize: no size tuning...abandon this penetration

%%%%new penetration in Left Hemisphere: expression is quite large, more anteriorish, but not
%%%%totally clear whether these are somata or arbors...try anyway...mouse
%%%%still good condition and getting lighter again in anesthesia
%%%%straight into V1 cranio: maybe single unit on ch8, decent spiking 7-10
%B1 - Optotest: no direct effects
%B2 - OptoStimtest: no direct effects, good responses, good spiking
%B3 - Flash: 50 hz noise on csd plots: Sutter microdrive was still on...
%B4 - Flash, still noisy
%B5 - RF flash [-100 100]
%B6 - OptoOri: ok tuning 180 deg
%B7 - SizeOpto
%B8 - CrossIsoOpto
%B9 - CrossIsoStaticOpto
%%%move light fiber over to the V1 cranio
%B10 - SizeOpto: light induced artefacts
%B11 - CrossIsoOpto
%B12 - CrossisoOptoStatic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20130405 tank
%J74 ChR2 in Gad2Cre
%first recording after renovation
%no expression, epi fluoresence microscope light not strong enough
%do not know what the problem is
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%recording in higher area
%B1 - Optotest: clear direct effects, a number of interneurons
%B3 - Quick Ori test no light, ch8 interesting, interneuron, tuning? it is
%visual area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%V1: responses are sluggish and small, anesthesia still?
%B4 - Flash: L4 = ch10
%B5 - RF flash: [-150 -50]
%B6 - Optotest
%B9 - OptoOri
%B12 - Ori no Opto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%new penetration in V1
%B14 - Flash: nice CSD, L4 - ch9
%B17 - Optotest 
%B18 - RF flash at -100 -150: rf a bit low
%B19 - OptoOri: 150 deg ok tuning
%move the projector down
%B20 - RF Flash -100 0
%B21 - SizeOpto: very nice surround suppression, small effects light but
%present and opposite effects across layers
%B22 - CrossIsoOpto [20 and 40]
%B23 - CrossIsoStaticOpto
%B24 - ContrastOpto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20130409 tank
%J74 ChR2 in Gad2Cre
%new probes 6.2.2013 probe #4, 4174: not really happy with this probe, a few
%channels not working properly? 
%%%%%
%RH
%%%%
%in higher area
%B3 - Optotest clear effects: reductions mostly, ch12 nice effect: bursts
%after light off, light induced artifact on MUA or real physiological
%effect? seems to be physiol
%B5 - OptotestStim, stimulus with empty space at around 1/4 during whole
%duration
%%%%
%V1 penetration
%%%%
%B6 - Optotest: effects but rather late, more than .5 s after light
%on...network effects rather than direct effects?
%B7 - OptotestStim: no direct effects!!
%B8 - Flash
%lowering the probe
%B9 - Flash: L4-ch10-11
%B12 - RF flash: rf [50, -100]
%B13 - OptoOri
%B14 - SizeOpto
%B15 - CrossIsoOpto
%B16 - CrossIsoStaticOpto
%B17 - ContrastOpto
%B18 - HupeOpto
%B19 - CenterSurroundStat different TIMINGS: -.5 to .75 (full duration),
%-.25 to 0, 0.05 to 0.15, 0.15 to 0.25, 0.25 to 0.35, 0.35 to 0.45
%uncertain whether showed all conditions?...also not correct position
%%%%%%%%%%%%%%%
%new penetration in V1, more posterior
%new tank 20130409B
%nice unit on ch12, ch10 and 11 also goodish
%B1 - Optotest: clear direct effects
%B2 - Optostimtest: no effects anymore, big discrepancy with optotest
%without visual stimulation...continue
%B3 - RF flash [0 0]
%B4 - Flash
%B5 - OptoOri
%B6 - SizeOpto: clear temporal effects: no difference beginning of
%responses only in the late part, tuning was not that pronounced, no sharp
%decline, selected 30 and 50 although 40 and 60 would maybe even be
%better...
%B7 - CrossIsoOpto: sizes 30 and 50 and positioned at 0 -100
%B8 - CrossIsoOpto: sizes 20 and 40 and positioned at 0 0 
%B9 - CrossIsoStatOpto
%B10 - ContrastOpto
%B11 - HupeOpto
%B12 - CrossIsoStatOptoDifferentTimes: .05 to .2 and .35 to .5 

%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 04 11, MOUSE J75, ChR2-dio in Gad2Cre
%optical imaging in RH on Daneel, nice visual maps, ran 2 runs 15 blocks
%and 20 blocks should be averaged, clear that craniotomy of viral
%injcetions was outside of V1, border could be derived from images
%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%%%%%%%%%%%%%%%%%%%%%%%%
%higher region recording: virus in anterior part
%def visual region
%%%%%%%%%%%%%%%%%%%%%%%%
%B3 - Optotest: clear direct effects
%B4 - OptoStimtest: clear direct effects
%%%%%%%%%%%%%%%%%%%%%%%
%recording in V1
%%%%%%%%%%%%%%%%%%%%%%%
%B5 - Optotest
%B6 - Optoteststim no direct effects, nice visual responses
%B7 - Flash: nice sharp ch8 L$
%B8 - RF Flash [50 -100]
%B9 - OptoOri: nice ori tuning, a bit of direction tuning, 210 deg
%B10 - OptoSize way too much trials, confused with crossiso, nice effects
%B11 - CrossIsoOpto:general increase in response, effects on ISO
%conditions, difference CrossIso stays the same
%B12 - CrossIsoStaticOpto:
%B13 - CrossIsoStaticDiftimings: #2: [0.050 - 0.200;.350 - .500], wanted to
%select more but was not sure that program was correct, clear artefacts
%light on and off
%B14 - ContrastOpto
%%%%%%%%%%%%%%%%%%%%%%
%LH: new tank Mouse_20130411B
%%%%%%%%%%%%%%%%%%%%%
%recording in higher region, posterior
%%%%%%%%%%%%%%%%%%%%%
%B2 - Optotest: silencing + clear interneuron on ch8
%B3 - OptotestStim
%%%clear visual responses
%%%%%%%%%%%%%%%%%%%%
%recording in V1
%%%%%%%%%%%%%%%%%%%%
%B4 - Optotest: seems direct-ish
%B5 - Optoteststim: clear direct effects
%%%%%%%
%moved to a new more medial location in V1
%B6 - Optotest: almost on every ch more responses
%B7 - Optoteststim: MUA no differences, mixed sometimes more sometimes
%less, but non consistent silencing, still quite high
%B8 - Flash: sluggish responses
%B9 - Flash: still sluggish
%B10 - RF flash: too low, moving more posterior
%%%%
%gave extra urethane, mouse waky
%%%another hole in V1, more post-lateral
%B12 - RF flash
%%%%moved back up and went more anterior-medial: from here: warning sign
%%%%LAMP USAGE 1000 HOURS on screen in upper left corner
%ch 14 15 16 light induced noise, ch6 no signal
%B13 - RF flash, moved projector a bit
%B14 - RF flash [-100 0]
%B16 - Optotest: enhancement
%B17 - Optostimtest: reductions....possibly direct effects...
%B18 - Flash
%B19 - OptoOri: direct effects light on...nice tuning wo light
%B20 - SizeOpto: do not expect a lot here
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 04 16 Mouse J76
%probe #4
%tank Mouse_20130416
%pre-exp OPTICAL IMAGING, nice map on Andrew, viral injection is outside V1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%%%%%%%%%%%%%%%%%%
%in higher region
%%%%%%%%%%%%%%%%%
%B1 - Optotest: direct effects, not a visual region
%B2 - Optotest
%bursts along all channels
%%%%%%%%%%%%%%%%%
%V1
%%%%%%%%%%%%%%%%%
%B4 - Flash nice responses! L4 = ch8, very localized CSD
%B5 - Optotest: facilitation
%B7 - Optostimtest: no direct effects if effects than due to network
%connections, in the later part facilitation
%B8 - RF flash [60 0]
%B9 - OptoOri, nice tunings! 200 chosen
%B12 - OptoSize: modest size tuning and no effect light on tuning
%B14 - CrossIsoOpto
%B15 - CrossIsoStaticOpto - wrong naming on stimPC (B18): abort after 239
%trials, waking up
%given more anesthesia
%%%%%%%%%%%%%%%%
%new penetration same hemisphere in V1
%made new tank Mouse_20130416B
%%%%%%%%%%%%%%%%
%B1 - Optotest
%B2 - Optostimtest
%B3 - flash: ch11 L4
%B4 - RF nice restricted [60 0]
%B5 - OptoOri: super single unit on Ch8: nice ORI tuning, big effects
%light: increases, additive
%B6 - OptoSize: release from suppression, 
%B8 - CrossIsoOpto
%B9 - CrossIsoStaticOpto
%B10 - ContrastOpto
%B12 - Flash

%%%%%
%tried other hemisphere (LH) but mouse started gasping, unable to solve...
%perfusion

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 04 30
%ARCH mouse injected on 29 03
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%images both hemispheres with Micromanager Fluorescence microscope
%green laser
%OI on Andrew
%RH
%higher
%B1 - Optotest nice single unit on Ch11 rest quite, laser on produces big
%artefact onset but also constant artefact continuously, clear drop ch11
%V1
%B2 - Optotest: no fx
%B3 - OptotestStim: nice visual evoked responses no direct fx: seems some
%indirect late effects on SUA 7-8-9, onset light causes artefact esp on ch
%12-16
%B4 - RF flash: L4 - ch9-10
%B5 - RF flash [-80 -120]
%B6 - Speed tune: likes slower speeds
%B7 - OptoOri: speed 20 and SF 0.05, weak tuning, effects light: increases
%in responses
%B8 - OptoSize: waking up abort 80 trials...
%extra shots urethane and chlorprothixene
%swabbed throath, fluid removal
%%%went down again, broke probe #4 (new box) by placing shield pusher to
%%%position microfiber
%%%took new probe #5 (new box), but constant respiration in signal, mouse
%%%gasping. Weak responses...
%%%%perfusion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 05 09
%Arch mouse 11.51.01.85, green laser Ralph
%optical imaging done on 2013 05 03
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%%%%%%%%%%%%%%%%%%%%%
%higher: visual area
%%%%%%%%%%%%%%%%%%%%%
%big light induced artefact on Ch16 not in the brain
%B02 - Optotest
%B03 - OptoStimtest
%lowered probe
%B04 - Optotest
%B05 - Optotest, increasing laser power, now clear drop inhibition previous
%tests unclear or even no inhibition
%B06 - Optostimtest - silencing but not 100 %
%B07 - Optostimtest - laser almost at max
%%%%%%%%%%%%%%%%%%%%%
%V1
%%%%%%%%%%%%%%%%%%%%%
%B08 - RF quick measurement to get indication of RF, ch1-3 are in, big unit
%on ch1: too low, go back up and move more posterior should get the RF
%higher
%B09 - Optoteststim: seems like direct effects
%B10 - Flash
%B11 - RF flash [-130 -180]
%B12 - Flash nice CSD
%B13 - OptoOri wrong RF: psth does not seem to be direct effects very weak ori
%tuning 60 deg selected
%B14 - OptoOri at -130 -180: still bad tuning, but now strangely seems to
%be more directish effects however some of the channels it completely
%overlaps
%B15 - OptoSize: extra surround suppression
%B17 - CrossIsoOpto
%%%wanted to do a more posterior penetration but bleeding
%%%%%%%%%%%%%%%%%%%%%%%%
%Left hemisphere: new tank 20130509B
%%%%%%%%%%%%%%%%%%%%%%%%
%given urethane and chlorprothixene
%higher region
%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Optotest clear silencing on ch8, only ch with some sua
%%%%%%%%%%%%%%%%%%%%%%%
%V1
%%%%%%%%%%%%%%%%%%%%%%
%B02 - RF flash [-80 -150]
%B03 - Optotest: facilitations
%B04 - OptoStimtest: nice overlaps ok not direct
%B05 - Flash
%B06 - OptoOri - 270 deg
%B08 - OptoSize nice release but not a lot of size tuning...anesthesia
%still too deep?
%B09 - CrossIsoOpto: smaller cross-iso difference even reversed in deep 
%%%fiber over V1
%B10 - OptoSize
%...mouse died...perfusion done

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 05 14
%ChR2
%tank Mouse_20130514
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LH
%higher
%B01 - Optotest: 9 channels in clear silencing, 100 % reduction on all of them
%B02 - OptoStimtest: still reduction but not 100%, visually driven here
%V1
%B05 - Optotest: no reductions ok not direct
%B06 - OptoStimtest: no reductions perfectly overlapping very very small
%differences
%B07 - Flash: unclear where L4 is, nice bursty and responsive MUA and SUA,
%50 Hz noise, Sutter still on
%B08 - Flash, Sutter off:
%B09 - RF Flash, nice small RF but a little bit too low, changed projector
%position a bit facing more downward
%B10 - Rf Flash [25 -100]
%B12 - OptoOri, SUA on ch8 [150] deg most optimal 
%B13 - OptoSize [15] optimal size nice size tuning not a lot effect of light
%B15 - CrossIsoOpto
%B16 - CrossIsoStatOpto problems analyses
%B17 - CrossIsoStatDifTimingsOpto: [-.500 .600;.050 .200;.350 .500]
%problems analyses
%B18 - ContrastOpto not yet analysed
%B19 - CrossIsoOpto again now [240] deg and [15] and [25]
%%%given extra urethane and chlorprothixene
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%new penetration same hemisphere but more medial
%new tank 20130514B
%B01 - OptoStimtest no direct fx maybe something late-ish feedback?
%B02 - Flash
%B03 - RF Flash [0 -100]
%B04 - OptoOri deg [210] or [120]
%B05 - OptoSize at 210 deg [15 35]
%B06 - CrossIsoOpto
%B07 - CrossIsoStatOpto - not analyzed yet
%B08 - CrossIsoStatDiftimingsOpto - not analyzed yet
%B11 - CrossIsoOpto VARIABLE PRESTIM DURATIONS, added randperm(50)/100
%B12 - ContrastOpto - not analyzed yet
%B14 - HupeOpto - not analyzed yet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%higher
%bursty activity, strange responses
%B01 - Flash - a little bit deep
%B02 - RF Flash [-50 -120]
%B3 - OptoOri, light induced artefact [60] [240] deg
%B5 - OptoSize, waking up [30 50]
%B7 - CrossIsoOpto
%B8 - Optoteststim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%new tank 20130514D
%only in to channel 11, def out: 12,13,14,15,16
%B01 - Optotest - large response enhancements
%B02 - OptoStimtest: almost perfectly on top of each other, again if any
%some facilitation with light on
%B03 - flash 
%B05 - RF flash [-75 -120]
%B06 - OptoOri [180]
%B07 - SizeOpto [] no surround suppression, nice effect light on,
%differences in lightON-lightOFF response profile: small sizes early,
%larger sizes differences late
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%new tank 20130514E new penetration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B47 - Optotest wrong name 20130222C 
%B01 - OptoStimtest ok no direct effets
%B02 - Flash
%B03 - RF Flash [50 -25]
%B04 - OptoOri [210]
%B05 - OptoSize, again very little surround suppression [30 50]
%B06 - CrossIsoOpto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B1 - RF Flash [0 -75]
%B2 - OptoOri [180]
%B3 - OptoSize
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse 20130523
%Gad2Cre, nice expression in both hemispheres
%LH
%higher
%B01 - Optotest absolute clear reductions, one channel 
%B02 - Optostimtest visually driven absolute reduction light on
%V1
%B03 - Optotest reductions seems direct effects
%B04 - OptoStimtest facilitations???? only Ch 3 reductions
%B05 - Flash a lot of 50 Hz noises...
%B06 - RF Flash nice restricted RF [50;-100]
%B07 - OptoOri at [120] deg
%B08 - SizeOpto, massive SUA on Ch 7, nice results sharply tuned [15 35]
%B09 - CrossIsoOpto
%%%%%%%%%%%%%
%new penetration more medial
%new tank Mouse_20130523B
%B01 - Optotest
%B02 - Optostimtest
%B03 - Flash: too high and a lot of 50 hz
%B04 - Optotest, went deeper
%B05 - OptoStimtest ch5 direct rest okay
%B06 - Flash, depth okay still 50 hz, reason?
%B07 - RF Flash [-50 -80]
%B08 - OptoOri [180]
%B09 - OptoSize [20 40]
%B10 - CrossIsoOpto
%%%%
%new penetration more medial
%new log 20130523C
%B01 - Optotest
%B02 - OptoStimtest in both direct fx
%%%new penetration more medial
%B03 - Optotest
%B05 - OptoStimtest
%%%%%%%%
%%%%%%%%
%RH
%V1
%new tank Mouse_20130523D
%new probe #3 very light sensitive
%B01 - Optotest
%B02 - OptoStimtest
%B03 - Flash
%B04 - RF Flash [-50 -120]
%%%changed pre-amp strange noise
%B06 - OptoStimtest, still big light induced artefacts
%not light induced artefacts but electrical interference, placed the LED
%small connector piece from which the small fiber starts outside the Cage
%now no artefacts anymore!
%B07 - OptoStimtest now only small reductions in the later parts looks
%feedback
%B08 - flash: ch 1 -5 not visual
%B09 - RF Flash [25 -120]
%B10 - OptoOri ch 12 SUA [90]
%B11 - SizeOpto; no or just a tiny bit of suppression but nice opto effect
%more suppression
%B12 - CrossIsoOpto
%%%
%new penetration
%B13
%B14 - OptoStim
%B15 - OptoStimtest
%B16 - Flash
%B17 - RF Flash [-50 -150]
%B18 - OptoOri [180]
%B19 - OptoSize [20 40]
%B20 - CrossIsoOpto


%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20130527 GAd2Cre ChR2 
%RH
%higher
%V1
%B02 - Optotest
%B03 - OptoStimtest nice visually driven responses, facilitation light on
%B04 - Stimtest no opto (not analyzed)
%B05 - Flash ch 11 [L4]
%B06 - RF Flash [50 -20]
%B07 - OptoOri (ch 9 and 10 def SUA) [210] very sharply OR tuned
%B08 - OptoSize very nice surround suppression very big effect, small but
%present effect light on: release of suppression [20 40]
%B09 - CrossIsoOpto nice effects! corroboration population findings, but
%not 100 % sure that LED was modulated...based on the differences in
%responses would be so...will do again
%B10 - CrossIsoStatOpto light: (off,-0.5 to 0.6, 0.05 to 0.25, 0.25 to
%0.50) not yet analyzed
%B11 - CrossIsoOpto
%B13 - HupeOpto problem with one stimulus condition figure stays on screen
%after stim, during Lamme motion? 25 reps
%B14 - ContrastOpto
%B15 - OptoSize at the end mouse really awake...
%%%
%new penetration same hemisphere given extra urethane and chlorprothixene
%Mouse_20130527B
%B01 - Optotest
%B03 - OptoStimTest
%B04 - RF Flash, still some 50 HZ noise, Sutter was on, turned off
%B05 - RF Flash sluggish responses
%B06 - RF [0 -75]
%B07 - OptoOri [180]
%B08 - OptoSize [20 40]
%B09 - CrossIsoOpto with 20 and 40, maybe stimulation too big, next run 10 and 30
%B10 - CrossIsoStatOpto light (off,-0.5 to 0.6, 0.05 to 0.25, 0.25 to
%0.50) not yet analyzed
%B11 - HupeOpto
%B12 - ContrastOpto
%B13 - ContrastOpto with cover in front...quite similar results so effects
%not due to ambient light scattering
%B14 - CrossIsoOpto with [10 and 30]; enhancing cross vs iso difference in
%a bit later part of stimulus
%B15 - OptoSize
%B16 - OptoOri
%B17 - CrossIsoStatOpto light (off,-0.5 to 0.6, 0.05 to 0.25, 0.25 to
%0.50) not yet analyzed
%B18 - Hupe Opto

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2013 06 24
%Arch mouse
%green laser and microfiber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%in V1
%light over V1
%B01 - Optotest; clear reductions
%B03 - OptotestStim; clear increases, nice visual responses
%B04 - Flash not enough channels with responses, some 50 hz went deeper
%B05 - Flash also reduced the heart beat in signal by disconnecting ground
%and reference; ch 8?
%B06 - RF [-120 -100]
%B07 - OptoOri [120] nice and sharp tuning even sharper with light on, ch [8,11] single other ch sua after sorting
%B08 - OptoSize
%B10 - CrossIsoOutofPhaseOpto - @ 2.24; moderate #40
%B11 - CrossIsoOutofPhaseOpto - @ 1.88; dim #40
%B12 - CrossIsoOutofPhaseOpto - @ 2.60; bright #40
%B13 - CrossIsoStatOpto - @ 2.60; bright #30
%B14 - CrossIsoStatOpto - @ 2.24; moderate #30
%light over higher, craniotomy
%B15 - CrossIsoOutofPhaseOpto - @ 2.24; moderate #30
%%%probe over higher light fiber over V1, started gasping unable to record
%%%responses here..., perfusion done...iPhone images expression and
%%%obducted brain images MicroManager

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse 20130627
%Arch mouse
%green laser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LH
%higher
%fiber over higher
%B04 - Optotest @ 2.30 no effect
%B05 - Optotest @ 3.30
%B06 - OptoStimTest @ 3.30
%fiber over V1
%B07 - Optotest @ 3.30
%B08 - Optostimtest @ 3.30
%B09 - Optostimtest @ 2.30
%B10 - Optostimtest @ 3.30
%V1
%fiber over V1
%B11 - Optotest @ 3.30
%B12 - Optoteststim @ 3.30 no effect light whatsoever, Sutter was still on,
%noise?
%B13 - RF Flash ch10 - L4
%B14 - RF [-75 -150]
%nice SUA on ch11, 7
%B15 - OptoOri untuned...[150] maybe @ 3.30
%B16 - OptoSize at [-50 -150] @ 3.30
%B17 - CrossIsoPhaseOpto up to 1198 trials then crash because hitting wrong
%button on TDT gui... @ 3.30
%B18 - CrossIsoPhaseOpto again... @ 3.30
%B19 - CrossIsoPhaseOpto again... @ 2.30
%B20 - CrossIsoPhaseSTATICOpto @ 3.30
%B21 - CrossIsoPhaseSTATICOpto @ 2.30
%fiber over higher
%B22 - CrossIsoPhaseOpto @ 2.30 #30
%B22 - CrossIsoPhaseOpto @ 3.30 #30 
%B23 - CrossIsoPhaseSTATICOpto @ 3.30 approx 30 reps, probe broke
%given extra anesthesia
%%%
%%%
%RH; new tank Mouse_20130627B
%higher region
%fiber over higher
%B01 - Optotest
%B02 - OptoStimTest - 2 3.3 %clear silencing
%fiber over V1
%B03 - Optoteststim @ 3.30 no effect
%B04 - Optoteststim @ 2.30
%fiber terug over higher want nu wel visuele responsen
%B05 - Optoteststim @ 2.30
%B05 - Optoteststim @ 2.30
%B06 - Optoteststim @ 3.30
%in V1 recording
%fiber over V1
%B07 - Optotest @ 3.30
%B08 - Optostimtest @ 3.30
%B09 - Flash nice CSD!
%B10 - RF Flash [80 -150]
%B11 - OptoOri [60]
%B12 - OptoSize [30 50]
%B13 - CrossIsoPhaseOpto @ 3.30
%B14 - CrossIsoPhaseOpto @ 2.30
%B15 - OptoSize @ 2.00 quite dim, strange results...
%light over higher
%B17 - OptoSize light over #20 @ 2.10
%B18 - CrossIsoPhaseOpto #30 @ 2.30
%perfusion done

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20130701
%Arch in KazuCre in higher regions
%green laser with microfiber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%higher
%fiber higher
%B01 - Optotest @ 2.1; clear reductions
%B02 - Optostimtest @ 2.1  visual responsive clear reductions although not massive
%B03 - Optostimtest @ 3.0 already more reduction
%fiber over V1
%B04 - Optotest @ 3.0
%B05 - Optostimtest @ 3.0 no effect okay!!!
%to V1...mouse died...


%%
%20130708
%transgene ChR2-Gad2Cre mouse
%multiple craniotomies, #5 
%probe in V1 (cranio #5) at 2.9 L, 0 A position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%light in cranio #1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%light fiber 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B02 - Optotest @ 4.0 = 1.41 read-off
%B04 - Optostimtest @ 4.0 = 1.41 read-off
%B05 - Optostimtest @ 5.0 = 1.64 read-off
%black mask in front of fiber reducing ambient light
%B07 - Optostimtest @ 5.0 = 1.64 read-off
%B08 - Optostimtest @ 6.0 = 1.91 read-off
%B08 - Optostimtest @ 5.0 = 1.91 read-off
%%%%%%%%problems with laser read off
%B10 - Optostimtest @ 3.0 = read-off 0.90
%B11 - Optostimtest @ 4.0 = read-off 1.02
%B12 - Optostimtest @ 5.0 = read-off 1.16
%B13 - Optostimtest @ 6.0 = read-off 1.33
%B14 - Optostimtest @ 7.0 = read-off 1.39
%light fiber moved...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%light fiber in 3rd hole
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B15 - Optostimtest @ 4.0 read-off 0.83
%B16 - Optostimtest @ 5.0 read-off 0.95
%B16 - Optostimtest @ 6.0 read-off 1.08
%B17 - Optostimtest @ 6.0 read-off 1.08
%B18 - Optostimtest @ 7.0 read-off 1.23
%B19 - Optostimtest @ 8.0 read-off 1.41
%B20 - Optostimtest @ 8.0 read-off 1.42? laser very unstable should be 1.50
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%light fiber in 2nd hole
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B21 - Optostimtest @ 4.0 read-off 0.83
%B22 - Optostimtest @ 5.0 read-off 0.95
%B23 - Optostimtest @ 6.0 read-off 1.08
%B24 - Optostimtest @ 7.0 read-off 1.23
%B25 - Optostimtest @ 8.0 read-off 1.41
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%light fiber close to 1st hole, next to probe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B26 - Optostimtest @ 4.0 read-off 0.83
%B27 - Optostimtest @ 5.0 read-off 0.95
%B28 - Optostimtest @ 6.0 read-off 1.08
%B29 - Optostimtest @ 7.0 read-off 1.22
%B30 - Optostimtest @ 8.0 read-off 1.40
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%blue LED as close as possible to V1 cranio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B31 - Optostimtest
%%%%NO EXPRESSION epi-fluorescence
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse 2013 07 11
%tank name Mouse_20130711
%SST Cre SOM somatostatin with Arch
%expression but faint
%injected on 21 06
%green laser, 50 um probe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%V1
%%%%%%%%%%%%%%%%%%%%%%%%
%LH
%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash: nice spiky responses nice CSD
%laserknob @ 3.6;  
%B02 - Optotest; facilitation
%B03 - OptoStimtest 
%B04 - RF Flash [75 -80]
%B05 - OptoOri [180]
%B06 - OptoSize [10 30] very sharp tuning some effect of light on but
%small
%B07 - CrossIsoPhaseOpto
%B08 - OptoSize, again
%B09 - CrossIsoPhaseOpto, again
%%%%%%%%%%%%%%%%%%%%%%%%
%LH: new hole more anterior viral injections
%new tank name Mouse_20130711B
%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash ch9 L4
%B02 - Optostimtest; reductions and enhancements
%B03 - RF [75 -125]
%B04 - OptoOri with speed (20) and SF (0.05) SUA on ch11 [70]
%B05 - OptoSize [10 30] for superficial ch [20] on deeper channels 
%B07 - CrossIsoOpto up to x (1000 trials estimated) numbers of trials then mouse started to move,
%probe broke
%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%new tank Mouse_20130711C
%bad quality penetration
%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash ch10 L4 nice brisky responses
%B02 - Optostimtest release of responses in late part
%laserknob @ 5.4; a lot higher
%B03 - Optostimtest: more response increases
%B04 - RF [-50 -100]
%B05 - OptoOri [100] very weakly tuned
%B06 - OptoSize: weak unclear effects
%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%new tank Mouse_20130711D
%new penetration more medial, fresh cortex
%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash
%went too deep
%B02 - Optostimtest
%going up
%B03 - Flash, still too deep
%B04 - Flash
%bit more
%B05 - Flash
%B06 - RF [-100 -100]
%B07 - OptoOri [240]
%B08 - OptoSize [30 50] more suppression????
%B09 - CrossIsoPhaseOpto
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130715
%SST-Cre mouse with Cre-dep Arch in V1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LH best expression
%%%%%%%%%%%%%%%%%%%%%
%B02 - Flash very nice CSD
%B03 - Optostimtest @ 4.1
%B05 - Optostimtest @ 8.2 some effects but not all increased responses
%B06 - Flash
%B07 - RF Flash [-75 -60]
%B08 - OptoOri [240]
%B09 - OptoSize [25 45]
%B10 - CrossIsoPhaseOpto 
%%%%
%new penetration in same hemi
%20130715B
%B02 - Flash
%B03 - Optostimtest
%B04 - RF Flash [-75 -110]
%B05 - OptoOri [180]
%B06 - OptoSize [20 40]
%B07 - CrossIsoPhaseOpto
%B08 - OptoSize again
%B09 - CrossIsoPhaseOpto again up to 820 trials
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130718A
%SSTCre with ArchCre in V1
%nice expression RH
%green laser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%V1
%B01 - Flash: ch10
%B03 - Optostimtest good responses
%increased laser intensity: responses DISAPPEARED....?apoptosis?
%B04 - Flash
%%%constant new locations, bad visual cortex...nice spikes deeper
%B07 - Flash
%B08 - Flash
%bad visual cortex, stop expt, sack mouse
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130718B
%SSTcre with ArchCre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash nice brisk CSD ch9 L4
%B02 - Optostimtest nice visual drive, little effects light on though
%B03 - RF flash [80 -100]
%B04 - OptoOri [180] super nice tuning for ch7 good but shifted tuning
%other channels
%B05 - OptoSize [20 40]
%B06 - CrossIsoPhaseOpto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%new penetration
%%%Mouse_20130718C
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B02 - Flash nice and crips ch8 L4
%B03 - Optostimtest more suppression
%B04 - RF [80 -75]
%B05 - OptoOri [240] massive SUA on ch9 also very good ch8
%B06 - OptoSize [20 40]
%B07 - CrossIsoPhaseOpto
%B08 - OptoSize < 540 trials movement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%new penetration
%%%Mouse_20130718D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash ch10 L4
%pre-amp low on batteries had to switch to other with broken channels 2 and
%10
%B04 - Optostimtest
%B05 - RF [80 -50]
%B06 - OptoOri [180]
%B07 - OptoSize [20 40]
%B08 - CrossIsoPhaseOpto 1350
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash: bad pre-amp a lot of channels down
%B02 - Flash: good pre-amp
%B03 - Optostimtest
%B04 - RF projector too high
%B05 - RF [-100 -60]
%B06 - OptoOri [180]
%B07 - OptoSize [25 45]
%B08 - CrossIsoPhaseOpto
%B09 - OptoSize laser at almost full force

%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130723
%SSFO dio-ChR2 nice localized expression both hemis
%Gad2Cre
%blue and amber DORIC leds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
%Left hemisphere
%%%%%%%%%%%%%%%%%
%B07 - OptotestSSFO 30 trials one blue pulse at trial 16
%B11 - OptotestSSFO 30 trials blue pulses after each trial from trial 16
%B13 - OptotestSSFO 30 trials no pulses, after 30 min or so
%B14 - OptoStimtestSSFO 30 trials no pulses

%B15 - OptoStimtestSSFO 60 trials no pulses
%B16 - OptoStimtestSSFO 60 trials one blue pulse at trial 31
%B17 - OptoStimtestSSFO 60 trials pulses each trials after trial 31
%B18 - OptoStimtestSSFO 60 trials one blue pulse at trial 31
%amber led on
%B19 - OptoStimtestSSFO 30 trials one blue pulse at trial 16
%B20 - OptoStimtestSSFO 30 trials blue pulse > trial 16
%B21 - OptoStimtestSSFO 30 trials blue pulse > trial 16
%amber led on
%B22 - OptoStimtestSSFO 30 trials blue pulse > trial 16
%B23 - OptoStimtestSSFO 30 trials blue pulse > trial 16
%B24 - OptoStimtestSSFO 30 trials constant blue pulse analog mode
%%%%%%%%%%%%%%%%%
%Right hemisphere
%%%%%%%%%%%%%%%%%
%B26 - OptoStimtestSSFO 60 trials no light
%B27 - OptoStimtestSSFO 30 trials one pulse at 16
%amber pulse
%B29 - OptoStimtestSSFO 30 trials each trial after 15
%amber pulse
%B30 - OptoStimtestSSFO 30 trials no light
%amber pulse
%B31 - OptoStimtestSSFO 30 trials no light
%amber pulse
%B32 - OptoStimtestSSFO 30 trials no light
%amber pulse
%B33 - OptoStimtestSSFO 30 trials one pulse
%amber pulse
%B34 - OptoStimtestSSFO 30 trials one pulse
%amber pulse
%B36 - OptoStimtestSSFO 30 trials pulses > 15
%amber pulse
%B37 - OptoStimtestSSFO 30 trials no light
%long wait eye patches still on
%
%B39 - OptoStimtestSSFO 30 trials no light
%B40 - OptoStimtestSSFO 30 trials one pulse light
%B41 - OptoStimtestSSFO 30 trials pulses after trial 15
%B42 - OptoStimtestSSFO 30 trials constant pulses on analog

%B43 - OptoStimtestSSFO 30 trials no stim pulses after trial 15
%B44 - OptoStimtestSSFO 30 trials no stim pulses after trial 15
%B45 - OptoStimtestSSFO 30 trials no stim no pulses
%B46 - OptoStimtestSSFO 30 trials no stim no pulses
%B47 - OptoStimtestSSFO 30 trials no stim one pulse at tr15
%B48 - OptoStimtestSSFO 30 trials no stim one pulse at tr15
%B49 - OptoStimtestSSFO 30 trials no stim pulses after tr15



%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130827A
%pilot test ChR2-GAD2Cre transgene
%very nice expression epi-fluorescence, picture
%blue laser from Ralph with microfiber
%made multiple cranios, 5 from V1 each approx 1 mm, picture with scale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%in V1 hole probe
%over V1 hole fiber
%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Optostimtest - @5.3 moderate effects
%B02 - Optostimtest - @7 better effects clear now
%go in deeper
%B03 - Optostimtest - @7    - standard - full reduction est 100
%B04 - Optostimtest - @6    - standard - considerable reduction est 80
%B05 - Optostimtest - @5    - standard - no or very little reduction est 5
%B06 - Optostimtest - @5.5  - standard - reduction est 30
%B07 - Optostimtest - @5.75 - standard - reduction est 50
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fiber first position neighbor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B08 - Optostimtest - @5.75
%B09 - Optostimtest - @5
%B10 - Optostimtest - @4.5
%B11 - Optostimtest - @6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fiber second position neighbor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B12 - Optostimtest - @6
%B13 - Optostimtest - @5.5
%B14 - Optostimtest - @5
%B15 - Optostimtest - @4.5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fiber third position neighbor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B16 - Optostimtest - @4.5
%B17 - Optostimtest - @5
%B18 - Optostimtest - @5.5
%B19 - Optostimtest - @6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fiber fourth position neighbor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B20 - Optostimtest - @6
%B21 - Optostimtest - @5.5
%B24 - Optostimtest - @5
%B25 - Optostimtest - @6.5
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130906A
%GAD2Cre - ChR2 injections
%nice expression bilateral, RH post, LH ant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RH
%problems penetrating with 15um probe bending the whole time, had to use
%drill to enlarge craniotomy, multiple tries, maybe damaged cortex somewhat
%no nice single units
%B01 - Flash; ch10-11
%B02 - Flash; better signal ch10
%B03 - RF Flash [-50 -100]
%B05 - OptoOri [240]
%B06 - OptoSize ch11 SUA no size tuning abandon penetration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130906B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Flash 50 Hz
%B02 - Flash better still 50 Hz ch8
%B04 - Flash
%B05 - RF Flash [-50 -50]
%B06 - Optotest
%B07 - OptoStimtest no effect ok
%B08 - OptoOri [90] weak tuning
%B09 - OptoSize
%B10 - mouse died

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130920
%cre-dependent Arch in KAZUCre
%nice viral expression extrastriate both hems
%Ralph green laser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130920A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%probe in V1
%fiber over higher region
%nice SUAs on multiple channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - Optotest @ 1.85
%B02 - Optostimtest @ 1.85
%B03 - Optostimtest @ 2.75
%B04 - Optostimtest @ 3.50
%B05 - Optotest @ 3.50
%B06 - Flash a lot of 50 hz
%B07 - Flash very nice CSD L4 around channel 6 added some more shielding in
%front of mouse
%B08 - RF Flash [75 -125]
%B09 - OptoOri [90] nice and sharp tuning orientation not direction no
%effect light on
%B10 - OptoSize no length suppresion yet too deep too early post anesth
%induction? clicking breathing tried to swap throath but movement..
%B11 - OptoSize no suppression
%B12 - CrossIsoPhaseOPto but bad test no better resp center only 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LH: %Mouse_20130920B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B07 - RF Flash ch11 L4
%B08 - RF [-155 -75]
%B09 - OptoOri [120]
%B10 - OptoSize [25 45]
%B11 - CrossIsoPhaseOpto
%B12 - CrossIsoPhaseSTATICOpto dif timings: no, full -.500 to 600,early 50 to 250, late 250 to 500
%B13 - OptoSize great suppression!!!
%B14 - CrossIsoPhaseOpto
%B15 - CrossIsoPhaseSTATICOpto dif timings
%B16 - Flash
%B17 - OptoStimTest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%light fiber over V1, probe stays in V1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B18 - OptoStimTest
%B19 - OptoSize
%B20 - CrossIsoPhaseOpto
%B21 - CrossIsoPhaseSTATICOpto dif timings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%light @ 2.1 quite dim now
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B22 - CrossIsoPhaseOpto: light pulses start with a big surge and after
%intial burst of light goes down to desired level



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130924 SSFO test
%very bursty recording, physiological problem?
%no technical artefact
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - RF flash
%B02 - Optostimtest no light
%B04 - OT no light: differences? li=randperm(30);li=li>15;light=0;if
%li(n)=1 Word=2
%B05 - OT again now LED power off
%one blue light pulse given
%B06 - OT
%one amber pulse given
%B07 - OT
%one blue pulse given
%B08 - OT
%B09 - OT blue pulse every trial
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse_20130926A Arch in Kazu
%left hem
%checked expression after penetration was good
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%B01 - RF Flash
%B02 - RF [25 -45]
%B04 - RF Flash
%B05 - RF Flash
%B06 - RF Flash
%B07 - OptoOri [150] not sharply tuned
%B08 - OptoSize [15 35]
%B09 - CrossIsoPhaseOpto
%B10 - CrossIsoPhaseOptoStatic different timing
%laser full open
%B11 - OptoSize laser full open
%change pre-amp low battery
%B12 - CrossIsoPhaseOpto
%
%Mouse_20130926B, right hem
%B01 - Flash
%B05 - Flash
%B06 - RF Flash [-100 -75]
%B07 - OptoOri [270]
%B08 - OptoSize []

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mouse 20131018A
%Arch in Kazu old injected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%only expression RH
%B07 - RF [0 -100]
%B08 - RF Flash nice CSD ch8 
%B09 - OptoOri [200]
%B10 - OptoSize [15 35] mouse moved at last trials not exact when
%B12 - CrossIsoPhaseOpto slightly different cells [15 35]
%B13 - CrossIsoPhaseSTATOpto dif timings
%B14 - OptoSize
%laser higher intensity
%B15 - CrossIsoPhaseOpto [20 40] 
%B16 - CrossIsoPhaseSTATOpto dif timings
%B17 - OptoSize
%light fiber over V1 cranio moderate light
%B18 - OptoSize very nice and sharp size tuning
%sounding very awake
%B19 - CrossIsoPhaseOpto
%laser higher
%B20 - OptoSize
%B21 - CrossIsoPhaseSTATOpto

%%
%Mouse_20140122 - Right hemisphere
%Sounds crispy!
%B1 = Flash - no stimbits!
%B2 - Flash, unusual LFP
%B5 - Flash again
%B6 - RF, very nice, no drift, small size at [50, -125]
%B7 - Rapid RF map (four flash)
%B9 - Ori tune (Slow), columns again, at 60 degrees
%B10 - Size and annulus tuning (Annulus sizes are doubled!)
%B12 - Two size surround +90, 20,50 chosen
%VEry nice resps at small size, but large surround response at 50!
%Trying 40 and 80 now
%B13 - Two size surround, [40 80]
%Mouse vrey awake sounding now
%B14 - Size/Annulus mapping
%B15 - [20,40] surround
%%%%%
%new penetration other hems Left
%B1 - Flash 14-16 50 hz noise rerun
%B2 - Flash nice CSD frisky respons
%B3 - RF Flash [0 -140] OK drift.
%B4 - Oritune slow
%B6 - Size tuning + annulus
%Nice specific single unit on channel 8
%B7 - [20 40] two size surround. ch.8 still awesome! cross iso effect on
%MUA CH8 #2015 trials, 65 reps
%B8 - RF Flash idem [0 -140]
%B09 - Ori tune slow still 100 pref ch 8 however sua broad tuning
%B10 - Flash
%B11 - Size tune + annulus #1080, 60 reps 
%B12 - Two sizes statics 20 40 script grating_surround_2sizes_STAT.m 585 trials 45
%reps
%all along perfect isolation of big SUA on ch8!!!


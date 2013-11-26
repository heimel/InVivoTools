function [mlscript,pos] = mlstims(M,N,monx,mony,span,numdirs,shape,rad,ec,speed,fps)

% MLSTIMS - Produce a script for stimulating ML like Paolini/Sereno 1998
%
%  [MLSCRIPT,POS] = MLSTIMS(M,N,MONX,MONY,SPAN,NUMDIRS,SHAPE,RAD,ECC,SPEED,FPS)
%
%  Creates a set of motion stimuli similar to stimuli used by Paolini and
%  Sereno, Cerebral Cortex, 1998.  See this paper for a description of the
%  stimuli.  In brief, stimuli are shown in M x N equally-spaced imaginary
%  circles in NUMDIRS directions.
%  
%  MLSCRIPT is a stimscript containing all of the stimuli described above.
%  There will be NUMDIRS * M * N stimuli in total.
%
%  MONX is the monitor width in pixels, MONY is the monitor height in pixels.
%  SPAN is the diameter of each imaginary circle, in degrees assuming 57cm dist
%    SPAN must be larger than twice the object radius
%  SHAPE is 1 for circular stimuli, 3 for oval
%  RAD is radius for circular stimuli, RAD and ECC are radius and eccentricity
%  (deformity) for oval stimuli; units are degrees assuming a 57cm distance
%  SPEED is speed in degrees/second
%  FPS is frames per second to show on monitor
%
%  POS is the position of each imaginary circle.  They are added to the script
%  in order going across and then down, so that all NUMDIRS directions for
%  the upper-left circle are added first, then all NUMDIR directions for
%  its neighbor to the right, and so on.
%
%  Ex:  [MYMLSTIM,POS]=mlstims(4,4,640,480,11,8,1,4,1,50,60);

NewStimGlobals;

radpix = rad*NewStimPixelsPerCm;
spanpix = span*NewStimPixelsPerCm;
pos = [];

if M>1, xlocs = linspace(0+spanpix/2,monx-spanpix/2,M);
else, xlocs = monx/2; end;
if N>1, ylocs = linspace(0+spanpix/2,mony-spanpix/2,N);
else, ylocs = mony/2; end;
speedpix = round(speed * NewStimPixelsPerCm / fps);
numframes = ceil(max([( (spanpix-2*radpix)/speedpix) 1]));
if isinf(numframes),numframes=1;end;
if shape==1,ec=1;end;

thedirs = 0:(360/numdirs):(360-(360/numdirs));

mlscript = stimscript(0);

inc = 0;
for n=1:N,
  for m=1:M,
   inc=inc+1;
   for k=1:numdirs,
	   rect = round([xlocs(m)-spanpix/2 ylocs(n)-spanpix/2 ...
	           xlocs(m)+spanpix/2 ylocs(n)+spanpix/2]);
	mlshapemovie = shapemoviestim(struct('rect',rect,'BG',[128 128 128]*0,...
		'scale',1,'fps',fps,'N',numframes,'isi',inc/1000,'dispprefs',{{}})); 
	nframemovie.speed.x=speedpix*sin(thedirs(k)*pi/180)*(1);
	nframemovie.speed.y=speedpix*cos(thedirs(k)*pi/180)*(-1);
	nframemovie.position.x=spanpix/2+(spanpix/2-radpix)*sin(thedirs(k)*pi/180)*(-1);
	nframemovie.position.y=spanpix/2+(spanpix/2-radpix)*cos(thedirs(k)*pi/180);

	nframemovie.type=shape;
	nframemovie.onset = 1;
	nframemovie.duration = 13;
	nframemovie.size=radpix;
	nframemovie.color.r=255;
	nframemovie.color.g=255;
	nframemovie.color.b=255;
	nframemovie.contrast = 1;
	nframemovie.orientation=thedirs(k)+90;
	nframemovie.eccentricity=ec;

	nfm = {nframemovie};

	mlshapemovie = addshapemovies(mlshapemovie,nfm);
	mlscript = append(mlscript,mlshapemovie);
	pos = [pos ; xlocs(m) ylocs(n)];
	end;
  end;
end;



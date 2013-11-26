function [outstim] = loadstim(PSstim)

%% zmr 31/01/01: adjusted to accept parameter 'distance' and convert wavelength of gratings from degrees
%% of visual angle to pixels on screen using the distance from the screen
%%
%% zmr 08/02/01: adjusted flashing/blinking for animType case 5 so that the fixed on-duration fliker is 
%% exactly half the time on for every temporal cycle.
%%
%% sdv 18/02/01: removed orientClipRect, changed rect format to be consistent with other stims

NewStimGlobals;
PSstim = unloadstim(PSstim);
PSparams = PSstim.PSparams; 
StimWindowGlobals;


 % if we have the capability of using DrawTextures, let's do it

if NS_PTBv>=3&(NewStimPeriodicStimUseDrawTexture|isfield(PSstim.PSparams,'maskps')),
	outstim = loadstimPTB3(PSstim);
	return;
end;

 % otherwise we've got to use color table animation


	dfs = struct(getdisplayprefs(PSstim));
	if 1|dfs.fps<0,  % work around for no fps on server
		tRes = round( (1/PSparams.tFrequency) * StimWindowRefresh);
		% screen frames / cycle
	
		%compute displayprefs info
	
		fps = StimWindowRefresh;
        if isfield(PSparams,'loops'), loops = PSparams.loops; else, loops = 0; end;

		frames = (1:(PSparams.nCycles*tRes));
		loopdir = 1;
		while loops>0,
			loopdir = loopdir * -1;
			if loopdir>0,
				frames = [frames 1:(PSparams.nCycles*tRes)];
			else,
				frames = [frames PSparams.nCycles*tRes:-1:1];
			end;
			loops = loops - 1;
		end;
		frames,
	
		% Special case: animType == 1   %% on second thought forget this as a special case
  		%if (PSparams.animType == 1) % if a square wave, only 2 frames
		%	fps = tRes;
		%	frames = repmat(1:2,1,PSparams.nCycles);
		%end;
	end;
        
    oldRect = PSparams.rect;
    width=oldRect(3)-oldRect(1); height=oldRect(4)-oldRect(2);
    dims = max(width,height);
    newrect = [oldRect(1) oldRect(2) oldRect(1)+dims oldRect(2)+dims];
    if PSparams.windowShape>=2&PSparams.windowShape<=5,
        extra = 0; if PSparams.windowShape>=4, extra = 90; end;
        angle = mod(PSparams.angle+extra,360)/180*pi;
        trans = [cos(angle) -sin(angle); sin(angle) cos(angle)];
        ctr = [mean(oldRect([1 3])) mean(oldRect([2 4]))];
        cRect=(trans*([oldRect([1 2]);oldRect([3 2]);oldRect([3 4]);oldRect([1 4])]-repmat(ctr,4,1))')'+repmat(ctr,4,1);
        dimnew = [max(cRect(:,1))-min(cRect(:,1)) max(cRect(:,2))-min(cRect(:,2))];
        ID = max(dimnew);
        newrect = ([-ID -ID ID ID]/2+repmat(ctr,1,2));
    end;	
    dp={'fps',fps, 'rect',newrect,'frames',frames,PSparams.dispprefs{:} };
    PSstim = setdisplayprefs(PSstim,displayprefs(dp));


% 	% Special case: Bar-type stims
% 	if (PSparams.imageType >= 6)
%      	% Scale barWidth from cm units to its proportion of the sFrequency
%      	PSparams.barWidth = PSparams.barWidth/(PSparams.distance * tan((pi/180)/PSparams.sFrequency));
%	
%     	% Fix color levels to allow for manual setting of bar/backdrop colors
%      	PSparams.contrast=1;
%      	PSparams.background=.5;
%    end

  tRes = round( (1/PSparams.tFrequency) * StimWindowRefresh);  % screen frames / cycle
  
  % all PSstims are color table animations, so let's now create the image
  
  % unit constants
  %PIXELS_PER_CM = 33.333333;
  global pixels_per_cm;
  %PIXELS_PER_CM = 45.4545; % 1600x1200 resolution

  % Convert argument units
  angle = 2*pi-mod(PSparams.angle,360)/180*pi;	% Correct for overlarge angles, Convert angle to radians
  % Flip direction (increasing angle progresses *clockwise*)

  % determine wavelength of grating in pixels per cycle by converting first sFrequency (spatial frequency of gratings 
  % expressed in cycles per degrees of visual angle) into centimiters per cycle by taking its tangent and multiplying by the 
  % distance from screen (cm), then this value of wavelength in cm is converted to pixels per cycle by the conversion factor.
  % changed to cycles/degree 5/2/2001 SDV
  wLeng = (PSparams.distance * tan((pi/180)/PSparams.sFrequency)) * pixels_per_cm;

  rect = PSparams.rect;
  
  height = rect(4)-rect(2); width = rect(3)-rect(1);
  imageDims = max(height,width);
  
  cRect = [rect];
  if (PSparams.windowShape==1), mkClp = 2;     % non-oriented oval
  elseif (PSparams.windowShape==0), mkClp = 1; % non-oriented rectangle
  elseif (PSparams.windowShape>=2&PSparams.windowShape<=5), % clip to grating orientation
	  mkClp = 3;
	  ctr = [mean(rect([1 3])) mean(rect([2 4]))];
	  extra = 0; if PSparams.windowShape>=4, extra = 90; end;
	  effangle= -2*pi+(mod(PSparams.angle+extra,360))/180*pi, %-angle;
	  trans = [cos(effangle) -sin(effangle); sin(effangle) cos(effangle)];
	  cRect=(trans*([rect([1 2]);rect([3 2]);rect([3 4]);rect([1 4])]-repmat(ctr,4,1))')'+repmat(ctr,4,1);
	  dimnew = [max(cRect(:,1))-min(cRect(:,1)) max(cRect(:,2))-min(cRect(:,2))];
	  imageDims = ceil(max(dimnew));
	  if (PSparams.windowShape==3|PSparams.windowShape==5), % make oval rect
		xx=linspace(-width/2,width/2,100);
		yyp=(height/width) * sqrt(width*width/4-xx.*xx); yyn=-yyp(end:-1:1);
		cRect=((trans*[xx' yyp' ; xx(end:-1:1)' yyn']')'+repmat(ctr,100*2,1));
		%figure(5); plot(cRect(:,1),cRect(:,2)); axis equal;
	  end;
  end;
  cRect=(cRect); % make sure contains only pixel values

  %%%%% Make theImage
  if(PSparams.imageType==0)    %field
    theImage = 255*ones(imageDims,imageDims);
  else	
	% Preallocate space for the big variables
	theImage = zeros(imageDims,imageDims);
	ramp = zeros(imageDims);
	
	% Make an array steadily increasing across imageDims pixels
	pixelIncrement = 255/wLeng;						% Find proper pixel-to-pixel increment value
	rampEndValue = imageDims * pixelIncrement;	% Find the max value of the ramp reached by the last pixel in the array
	ramp = 0:pixelIncrement:rampEndValue;			% Make a ramp from 0 to that max value using the increment value as the step size
	ramp(imageDims+1:length(ramp))=[]; 				% Clip any extra elements
	
	[x,y]=meshgrid(ramp,ramp);								% Create vertical- and horizontal-ramp matrices
	theImage=( x.*(sin(angle)) + y.*(cos(angle)) ); % Do weighted sum of component matrices to handle range of angles
	theImage=theImage-254*floor(theImage/254)+1; 	% Squish the range of indices to lie in 8-bit range (i.e. valid clut values)
	theImage = uint8(theImage);
  end

  numFrames = 0;
  if PSparams.windowShape==6, mkClp = 1;
  elseif PSparams.windowShape==7, mkClp = 2;
  end; % this won't be defined yet under these cases

  if NS_PTBv<3,
	  offscreen = screen(-1,'OpenOffscreenWindow',255,[0 0 imageDims imageDims]);
	  screen(offscreen,'PutImage',theImage,[0 0 imageDims imageDims]);
  else,   % need to make a texture and fill in the alpha
	if mkClp==2, % need to convert this to polygon
		ctr = [mean(rect([1 3])) mean(rect([2 4]))];
		extra = 0; 
		effangle= 0; %-2*pi+(mod(PSparams.angle+extra,360))/180*pi, %-angle;
		trans = [cos(effangle) -sin(effangle); sin(effangle) cos(effangle)];
		polyrect=(trans*([rect([1 2]);rect([3 2]);rect([3 4]);rect([1 4])]-repmat(ctr,4,1))')'+repmat(ctr,4,1);
		xx=linspace(-width/2,width/2,100);
		yyp=(height/width) * sqrt(width*width/4-xx.*xx); yyn=-yyp(end:-1:1);
       		cRect=((trans*[xx' yyp' ; xx(end:-1:1)' yyn']')'+repmat(ctr,100*2,1));
		mkClp = 3;
	end;
	[theImage,maskImage] = NewStimMasker(theImage,newrect,mkClp,cRect,0); % newrect is position of theImage on screen in global coords
	offscreen = screen('MakeTexture',StimWindow,theImage);
	mkClp = 0; cRect = maskImage;
  end;

  if PSparams.windowShape>=6, % need to remove center aperature
	  if isfield(PSparams,'aperature'),
		  ap = PSparams.aperature;
	  else,
		  ap = [10 10];
	  end;
	  if NS_PTBv<3, mkClp = 1; end;
	  switch PSparams.windowShape,
		% PTB compatibility mode should handle this in NS_PTBv==3
	    case 7,
			screen(offscreen,'FillOval',0, [-ap(1) -ap(2) ap(1) ap(2)]/2 + [width height width height]/2);
			[myNewImage,newmask] = NewStimMasker(theImage,newrect,2,...
				[-ap(1) -ap(2) ap(1) ap(2)]/2 + ...
				 [mean(newrect([1 3])) mean(newrect([2 4])) mean(newrect([1 3])) mean(newrect([2 4])) ],0);
			% now newmask is _opposite_
			maskImage = 255-(((255-maskImage).*(newmask))/255);
	  		if NS_PTBv>=3, cRect = maskImage; end;
	    case 6,
			screen(offscreen,'FillRect',0,[-ap(1) -ap(2) ap(1) ap(2)]/2 + [width height width height]/2);
			[myNewImage,newmask] = NewStimMasker(theImage,newrect,1,...
				[-ap(1) -ap(2) ap(1) ap(2)]/2 + ...
				 [mean(newrect([1 3])) mean(newrect([2 4])) mean(newrect([1 3])) mean(newrect([2 4])) ],0);
			% now newmask is _opposite_
			maskImage = 255-(((255-maskImage).*(newmask))/255);
	  		if NS_PTBv>=3, cRect = maskImage; end;
	  end;
  end;
  
  % now to make the color tables

  offstate = PSparams.background;
  maxOffset	= min ( (abs(1-offstate)), abs(offstate) );
  dark      = offstate - maxOffset*PSparams.contrast; % luminance of darkest shade
  light     = offstate + maxOffset*PSparams.contrast; % luminance of brightest shade
  % Determine flicker range for stationary gratings
  switch PSparams.flickerType
    case 0 % light -> background -> light...
      hoffset=(light+offstate)/2; hamp=(light-offstate)/2;
      loffset=(offstate+dark)/2;  lamp=-(offstate-dark)/2;
    case 1 % dark -> background -> dark
      hoffset=(dark+offstate)/2; hamp=(dark-offstate)/2;
      loffset=(offstate+light)/2;  lamp=-(offstate-light)/2;
    case 2 % counterphase
      hoffset=(light+dark)/2; hamp=(light-dark)/2;
      loffset=(light+dark)/2; lamp=-(light-dark)/2;
  end
  % Convert from proportion values (0.0-1.0) to clut values (0-255)
  dark=dark*255;
  light=light*255;
  background = offstate*255;
  if size(PSparams.backdrop,2)==1,
	  backdrop = PSparams.backdrop*255;
  else, backdrop = PSparams.backdrop;
  end;
  barColor = PSparams.barColor*255;
  barwidth = PSparams.barWidth;
  
	switch PSparams.imageType
		
		%Field¦¦Single luminance across field
		case 0
			ourClut = light*ones(1,255);
	
		%%% Simple Periodic Stimuli
		%  'spaceCycles' variable determines number of periods repeated in field
	
		% Square¦¦Field split into light and dark halves
		case 1
			amp = .5*(light-dark);
			center = .5*(light+dark);
			ourClut = [ones(1,ceil(255/2)) zeros(1,floor(255/2))];
			%ourClut = round(.5+.5*sin(2*pi*(1:255)/(255)));
			% set middle of clut to half value:
			ourClut(ceil(length(ourClut)/2))=(max(ourClut)+min(ourClut))/2;
			filtVec = ones(1,PSparams.nSmoothPixels+1);	% simple box filter
			ourClut = CONV(filtVec,ourClut); % smooothed square clut
%XR: Following is wrong, should delete maximun points instead of taking 1st 255 points 
			ourClut = ourClut(1:255)/max(ourClut(1:255));
			ourClut = (ourClut*2-1)*amp+center;
		
		% Sine¦¦Smoothly varying shades
		case 2
			amp = .5*(light-dark);
			center = .5*(light+dark);
			ourClut = round( center + amp*sin( 2*pi*(0:254)/255 ) ); 
		
		% Triangle¦¦Linear light->dark->light transition
		case 3
			ourClut = 2*linspace(dark,light,255) -2*255*floor(linspace(dark,light,255)/255);
			ourClut = ourClut-2*(ourClut-255).*floor(ourClut./(255)); % will make the triangle shape
			ourClut = 1+ourClut/max(ourClut)*254; % normalize for a1 extra-good full delicious spectrum
		
		% Lightsaw¦¦Linear light->dark transition
		case 4
			ourClut = linspace(light/255,dark/255,255);
			filtVec = ones(1,PSparams.nSmoothPixels+1);	% simple box filter
			ourClut = CONV(filtVec,ourClut); % smooothed square clut
			ourClut = ourClut(1:255)/max(ourClut(1:255));
			ourClut = ourClut*255;
		
		% Darksaw¦¦Linear dark->light transition
		case 5
			ourClut = linspace(dark/255,light/255,255);
			filtVec = ones(1,PSparams.nSmoothPixels+1);	% simple box filter
			ourClut = CONV(filtVec,ourClut); % smooothed square clut
			ourClut = ourClut(1:255)/max(ourClut(1:255));
			ourClut = ourClut*255;


	%%% Bar-oriented stimuli

		% Bar¦¦Bars of <barwidth> width and <barColor> luminance
		case 6
			% Make basic bars clut
 			barwidth = round(barwidth*255);
 			%ourClut = backdrop*ones(1,255);  % changed sdv 2005-10-13, making backdrop 1x1 or 1x3
 			ourClut = background*ones(1,255);
  			ourClut(1:barwidth) = barColor*ones(1,barwidth);

			% Anti-alias the bar edges
			filtVec = ones(1,PSparams.nSmoothPixels+1);	% simple box filter
			ourClut = CONV(filtVec,[repmat(ourClut(1),1,PSparams.nSmoothPixels+1) ... % correct for edges
				ourClut repmat(ourClut(end),1,PSparams.nSmoothPixels+1)]); % smooothed square clut
			theInds = [ 1 : 255 ] + fix((length(ourClut)-255)/2);
			ourClut = ourClut(theInds)/max(ourClut(theInds));
			ourClut = ourClut*255;
		
		% Edge¦¦Like Lightsaw but with bars determining width of saw
		case 7
			barwidth = round(barwidth*255);
			ourClut = background*ones(1,255);
			%ourClut = backdrop*ones(1,255);
			%ourClut(1:barwidth) = linspace(barColor,backdrop,barwidth);
			ourClut(1:barwidth) = linspace(barColor,background,barwidth);

			
		% Bump¦¦Bars with internal smooth dark->light->dark transitions
		case 8
			barwidth = round(barwidth*255);
			%ourClut = backdrop*ones(1,255);
			ourClut = background*ones(1,255);
			ourClut(1:barwidth) = barColor*sin(pi*(0:barwidth-1)/barwidth);
	end

%barwidth;
%figure;colormap(gray);subplot(2,1,1);imagesc(ourClut);subplot(2,1,2);plot(ourClut);

	tRes = floor(tRes); % round tRes down to be safe
	
	% flashing/blinking
	switch PSparams.animType	
	
		% Square
		case 1		%XR fixed this. the last frame was wrong. see makeClutsoriginal.m
			% if using square-wave animation for counterphase dispaly
			if PSparams.flickerType == 2
				highVal = zeros(1,tRes*PSparams.nCycles)+hoffset-hamp;
				lowVal  = zeros(1,tRes*PSparams.nCycles)+loffset-lamp;
%% zmr: following adjustment made so that the fixed on-duration 
%% fliker is exactly half the time on for every temporal cycle.
				highVal(find(0<=sin(2*pi*(0:tRes*PSparams.nCycles)/tRes))) = hamp+hoffset;
				lowVal(find(0<=sin(2*pi*(0:tRes*PSparams.nCycles)/tRes))) = lamp+loffset;
%rubu = 'counterphase';
			% for all other flicker types
			else
%				highVal = hamp*2*(1-floor((0:tRes-1)/tRes*2))+hoffset-hamp;
%				lowVal  = lamp*2*(1-floor((0:tRes-1)/tRes*2))+loffset-lamp;
				highVal = hamp*2*((sin(2*pi*(0:PSparams.nCycles*tRes-1)/tRes))>=0.5)+hoffset-hamp;
				lowVal  = lamp*2*((sin(2*pi*(0:PSparams.nCycles*tRes-1)/tRes))>=0.5)+loffset-lamp;
%rubu = 'other';
			end

		% Sine
		case 2
			highVal = hamp*(sin(2*pi*(0:PSparams.nCycles*tRes-1)/tRes))+hoffset;
			lowVal  = lamp*(sin(2*pi*(0:PSparams.nCycles*tRes-1)/tRes))+loffset;
		% Ramp
		case 3
			highVal = 2*hamp*((1+mod(0:tRes*PSparams.nCycles-1,tRes))/tRes)+hoffset-hamp;
			lowVal  = 2*lamp*((1+mod(0:tRes*PSparams.nCycles-1,tRes))/tRes)+loffset-lamp;
		% Drifting
		case 4
			highVal=ones(1,tRes*PSparams.nCycles)*hoffset+hamp; 
			lowVal =ones(1,tRes*PSparams.nCycles)*loffset+lamp;
		%fixed on-dur square	XR implement on 4/6/2000
		case 5
			highVal = zeros(1,tRes*PSparams.nCycles)+hoffset-hamp;
			lowVal  = zeros(1,tRes*PSparams.nCycles)+loffset-lamp;
			highVal(1:PSparams.fixedDur) = hamp+hoffset;
			lowVal (1:PSparams.fixedDur) = lamp+loffset;
		% Standing, no change
		otherwise 
			highVal=ones(1,tRes*PSparams.nCycles)*hoffset+hamp; 
			lowVal =ones(1,tRes*PSparams.nCycles)*loffset+lamp;
	end	
	
	boost = 255*lowVal;
%figure;colormap(gray);subplot(2,1,1);imagesc(boost)
	gain  = highVal-lowVal;
%subplot(2,1,2);imagesc(gain);
 	len   = length(ourClut);
	isMoving = (PSparams.animType == 4); % By default, grating is stationary, if drifting, set to true (see case 4 below)

%% zmr: get the phase shift value in radians
	phs = mod(PSparams.sPhaseShift,2*pi); % Correct for overlarge angles
	
%	if (isMoving) % for moving grating
			G = repmat(1:len,PSparams.nCycles*tRes,1);
			H = repmat(round(phs*len/(2*pi)+isMoving*len*(0:PSparams.nCycles*tRes-1)/tRes)',1,len);
			J = mod(G+H,len); J(find(J==0))=len;
			clutEntries = ourClut(J).*repmat(gain',1,len)+repmat(boost',1,len);
			%clutEntries(find(clutEntries>255)) = 255;
	% above replaces the following slower code
	%	for i = 0:(PSparams.nCycles*tRes)-1
	%		if i == 0
	%			ourClutIndex = 1:len;
	%		else
	%			ourClutIndex = [round(len*i/tRes):len 1:round(len*i/tRes)-1];
	%		end
	%		clutEntries(i+1,:) = ourClut(ourClutIndex)*gain(i+1)+boost(i+1);
	%	end
	%
	%elseif (isMoving) & (phs ~= 0)	% for moving grating with a phase shift offset at start
	%	for i = 0:tRes-1
	%		if i == 0
	%			shftd = [ceil((len*phs) / (2*pi)):len 1:ceil((len*phs) / (2*pi))-1];
	%			ourClutIndex = shftd;
	%		else
	%			indx = [ceil(len*i/tRes):len 1:ceil(len*i/tRes)-1];
	%			ourClutIndex = shftd(indx);
	%		end
	%		clutEntries(i+1,:) = ourClut(ourClutIndex)*gain(i+1)+boost(i+1);
	%	end
		
%% zmr: this condition checks whether a spatial phase shift is required
%% it adjusts the clutEntries lookup table so that the apropriate phase shift effect is achieved
%	else,
%
%	elseif phs ~= 0	% for static grating with a spatial phase shift of phs radians
%		
%		ourClutIndex = [ceil((len*phs) / (2*pi)):len 1:ceil((len*phs) / (2*pi))-1];
%		gain	= meshgrid(gain,1:len)';
%		boost	= meshgrid(boost,1:len)';
%		clutEntries = meshgrid(ourClut(ourClutIndex),1:tRes*PSparams.nCycles) .* gain + boost;
%rubu = 'two'
%	else 			% for static grating without a spatial phase shift
%		ourClut=meshgrid(ourClut,1:tRes*PSparams.nCycles);
%		gain   =meshgrid(gain,1:len)';
%		boost  =meshgrid(boost,1:len)';
%		clutEntries = ourClut.*gain+boost;
%rubu = 'three'
%	end
%clutEntries
%figure;colormap(gray);imagesc(clutEntries);

	% assemble all the cluts
if size(backdrop,2)==1, 
	offClut = backdrop*ones(256,3);
	clut_bg = repmat(PSparams.chromlow,256,1)+repmat(PSparams.chromhigh-PSparams.chromlow,256,1).*offClut/255;
	backdropRGB = PSparams.chromlow+(PSparams.chromhigh-PSparams.chromlow).*backdrop/255;
elseif size(backdrop,2)==3,
	offClut = ones(256,1)*backdrop;
	clut_bg = offClut;
	backdropRGB = backdrop;
end;
	
theCluts = zeros(255,PSparams.nCycles*tRes); 
	
%theCluts(1,:)=ones(1,tRes);	% will be re-written as backdrop
	
for i = 1:PSparams.nCycles*tRes
	theCluts(1:255,i) = clutEntries(i,:)'; % b/w
end

clut = {};
clut_usage = ones(size(clut_bg));

for i=1:size(theCluts,2),
	clut{end+1} = [backdropRGB; repmat(PSparams.chromlow,255,1)+...
                        repmat(PSparams.chromhigh-PSparams.chromlow,255,1).*theCluts(:,i*[1 1 1])/255];
end;
	
dS = { 'displayType', 'CLUTanim', 'displayProc', 'standard', ...
         'offscreen', offscreen, 'frames', length(clut), ...
		 'clut_usage', clut_usage, 'depth', 8, ...
		 'clut_bg', clut_bg, 'clut', clut, 'clipRect', cRect , ...
		 'makeClip', mkClp,'userfield',[] }; 
		 
outstim = PSstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);
		 
%-----------------------------------
% makeClip
function cRect = makeClip(rect, angl,windowShape)
% Preconditions: óxPixels & yPixels are widths and xCenter & yCenter are coords
%				 óangle is orientation (in radians) w/ 0 == up and increasing
%				   values rotate clockwise
% Postcondition: Returns a set of four coords tracing a rect with the proper
%				  height & width, oriented at angle and centered over [x,y]Center
%				 
%    xPixels = rect(1); yPixels = rect(2); xCenter = rect(3); yCenter = rect(4);
%	angl = pi/2 - angl; % Keeps meaning of angles constant b/t image and clip (clockwise rotation)
%	length = xPixels/2; 
%	width = yPixels/2;
%	cangl=cos(angl);
%	sangl=sin(angl);
%
%if(windowShape)		% oval
%	xx=-length+1:length; 
%	yy=sqrt((1-xx.*xx/length^2)*width^2);
%	cRect(1:xPixels,1)=[-xx*cangl+yy*sangl+xCenter]';
%	cRect(1:xPixels,2)=[-xx*sangl-yy*cangl+yCenter]';
%	cRect(2*xPixels:-1:xPixels+1,1)=[-xx*cangl-yy*sangl+xCenter]';
%	cRect(2*xPixels:-1:xPixels+1,2)=[-xx*sangl+yy*cangl+yCenter]';
%else				% rectagle
%	cRect= [xCenter-length*cangl+width*sangl	yCenter-width*cangl-length*sangl ; ...
%			xCenter+length*cangl+width*sangl	yCenter-width*cangl+length*sangl ; ...
%	    	xCenter+length*cangl-width*sangl	yCenter+width*cangl+length*sangl ; ...
%	    	xCenter-length*cangl-width*sangl	yCenter+width*cangl-length*sangl];
%end
%return								

function [outstim] = loadstim(SMSstim)

 % no error handling yet

SMSstim = unloadstim(SMSstim);  % unload old version before loading

if ~haspsychtbox, outstim = SMSstim; return; end;

p = getparameters(SMSstim);
width  = p.rect(3) - p.rect(1); height = p.rect(4) - p.rect(2);

vheight = round(height / p.scale); vwidth = round(width / p.scale);

offscreen = screen(-1,'OpenOffscreenWindow',0,[0 0 width height]);
clut_bg = repmat(p.BG,256,1);
depth = 8;
clut_usage = [ 1 ones(1,255) ]';
  %colortable entry 0 is bg color
clut = SMSstim.clut;

dP = getdisplayprefs(SMSstim.stimulus);
dPs = struct(dP);
displayType = 'Movie';
displayProc = 'standard';

% compute number of frames for pause
StimWindowGlobals;
numPause = max([1 round(p.fps * p.isi)]);

frames = repmat(1,numPause,1); nfr = (1:p.N)';

nf = getshapemovies(SMSstim);
for i=1:length(nf),
  for k=1:p.N, % make each frame
		tmpscn=screen(-1,'OpenOffscreenWindow',0,[0 0 vwidth vheight]);
		shape=nf{i};
		for j=1:length(shape), % draw the shapes
			if k>=shape(j).onset&k<=(shape(j).duration+shape(j).onset),
				% check/adjust color table
				col=[shape(j).color.r shape(j).color.g shape(j).color.b];
				rcol = p.BG+(col-p.BG)*shape(j).contrast;
				[a,ai]=intersect(clut,rcol,'rows');
				if isempty(a), % use bg, shouldn't happen
					colnum = 0; %
				else, colnum = ai - 1;
				end;
				colnum,
				pos=[shape(j).position.x shape(j).position.y]+...
						(k-shape(j).onset)*...
						[shape(j).speed.x shape(j).speed.y];
				switch shape(j).type,
				case 1, % disk
					rct = pos([1 2 1 2])+shape(j).size*[-1 -1 1 1];
					screen(tmpscn,'FillOval',colnum,rct);
				case 2, % gaussian
				case 3, % oval
					z = shape(j).size; e=shape(j).eccentricity;
					xx=linspace(-z,z,30);
					yyp=e*sqrt(z*z-xx.*xx);
					yyn=-yyp(end:-1:1);
					o=shape(j).orientation*pi/180; c=cos(o); s=sin(o);
					pts=([c -s;s c]*[xx' yyp'; xx(end:-1:1)' yyn']')' +...
						repmat(pos,30*2,1);
					screen(tmpscn,'FillPoly',colnum,pts);
				end;
			end;
		end;
		offscreen(end+1)=screen(-1,'OpenOffscreenWindow',...
		  				0,[0 0 width height]);
		% blow up the image
		screen('CopyWindow',tmpscn,offscreen(end),[0 0 vwidth vheight],...
		  		[0 0 width height]);
		screen(tmpscn,'Close');
	end;
	  % must add frames to displayprefs
	frames = cat(1,frames,1+(i-1)*(p.N)+nfr);
	frames = cat(1,frames,repmat(1,numPause,1));
end;

dS = {'displayType', displayType, 'displayProc', displayProc, ...
              'offscreen', offscreen, 'frames',max(frames), 'depth', 8, ...
			  'clut_usage', clut_usage, 'clut_bg', clut_bg, 'clut', clut};
dP = getdisplayprefs(SMSstim);
dP = setvalues(dP,{'frames',frames});

outstim = SMSstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = setdisplayprefs(outstim.stimulus,dP);
outstim.stimulus = loadstim(outstim.stimulus);

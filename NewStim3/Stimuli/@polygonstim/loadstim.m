function [outstim] = loadstim(LBs)


NewStimGlobals; StimWindowGlobals;

LBs = unloadstim(LBs);
LBp = LBs.LBparams;

% calc colors, in 3-space
offstate = mean([LBp.background/255; LBp.foreground/255;]);
dark=offstate+LBp.contrast*(LBp.background/255-offstate);
light=offstate+LBp.contrast*(LBp.foreground/255-offstate);
width=diff(LBp.rect([1 3])); height=diff(LBp.rect([2 4]));

if LBp.shape==0,
	w=(LBp.points(2)); h=(LBp.points(1)); % backwards
	pol=[h w; h -w; -h -w; -h w; h w];
	wr=(LBp.remove(2)); hr=(LBp.remove(1)); % backwards
	polr = [hr wr; hr -wr; -hr -wr; -hr wr; hr wr];
else,
	pol =LBs.points;
	polr=LBs.remove;
end;

if prod(double((size(LBp.points)==[1 2])&(LBp.points==[0 0]))),XY=zeros(width,height);
else, XY=drawpoly(LBp,pol); end;
if prod(double((size(LBp.remove)==[1 2])&(LBp.remove==[0 0]))),XYr=zeros(width,height);
else, XYr=drawpoly(LBp,polr); end;
inds=find(XY);
XY(find(XY==0))=1; XY(inds)=255; XY(find(XYr))=0; filt=ones(fix(LBp.smooth));
XY = conv2(XY,filt,'same');XY=round(255*XY/max(max(XY)));
t1=dark(1):(light(1)-dark(1))/254:light(1);  % make color table
t2=dark(2):(light(2)-dark(2))/254:light(2);
t3=dark(3):(light(3)-dark(3))/254:light(3);
if isempty(t1),t1=zeros(1,255);end;
if isempty(t2),t2=zeros(1,255);end;
if isempty(t3),t3=zeros(1,255);end;
clut = [LBp.backdrop; [ t1; t2; t3;]'*255];

if haspsychtbox,
	if NS_PTBv<3,
		offscreen = screen(-1,'OpenOffscreenWindow',255,[0 0 width height]);
		screen(offscreen,'PutImage',XY,[0 0 width height]);
	else,
		offscreen = screen('MakeTexture',StimWindow,XY);
	end;
	displayType = 'CLUTanim'; % doesn't really matter since only 1 frame
	displayProc = 'standard';
	dS = {'displayType',displayType,'displayProc',displayProc,...
		'offscreen',offscreen,'frames',1,'depth',8,...
		'clut_usage',ones(1,256),'clut',{clut},...
		'clut_bg',repmat(LBp.backdrop,256,1)};
	outstim = LBs;
	outstim.stimulus = setDisplayStruct(outstim.stimulus,displayStruct(dS));
	outstim.stimulus = loadstim(outstim.stimulus);
else,
	outstim = LBs;
end;

function XY = drawpoly(LBp,pol)  % find points in polygon
width=diff(LBp.rect([1 3])); height=diff(LBp.rect([2 4]));
xCtr = width/2; yCtr = height/2;

[TH,R]=cart2pol(pol(:,1),pol(:,2));
TH = TH + LBp.orientation*pi/180; % shift it
global pixels_per_cm;
[x,y] = pol2cart(TH,R);
if LBp.units==0,
	u=pixels_per_cm*LBp.distance; otr=u*tan(LBp.offsettheta*pi/180);
	ox=u*tan(LBp.offsetxy(1)*pi/180);
	oy=u*tan(LBp.offsetxy(2)*pi/180);
else,   
	u=1; ox=LBp.offsetxy(1); oy=LBp.offsetxy(2); otr = LBp.offsettheta;
end;
[xo,yo]=pol2cart((LBp.orientation-90)*pi/180,otr);
% shift to real location
x=round(x+xCtr+ox+xo);y=round(y+yCtr+oy+xo);
X=repmat((1:width),height,1);Y=repmat((1:height)',1,width);
XY=ceil(double(inpolygon(X,Y,x,y)));

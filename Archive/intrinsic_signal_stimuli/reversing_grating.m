function w=reversing_grating(par)
%REVERSING_GRATING produces offscreenwindows with one cycle of a contrast reversing grating
%
%  W=REVERSING_GRATING(PAR)
%     PAR.ANGLE = orientation (deg) (0-180)
%                  0 is vertical bar 
%                  45 is oblique bar 
%     PAR.TF = temporal frequency (Hz)
%     PAR.SF = spatial frequency (cpd)
%     PAR.COLOR_HIGH = high color index
%     PAR.COLOR_LOW = low color index
%     PAR.CONTRAST = contrast (0-1)
%     PAR.RECT = [ x_left y_top x_right y_bottom ];
%     PAR.PHASE=0;
%     PAR.FUNCTION = function applied to values,
%                    e.g. 'sign' to get square wave grating
%
%  See SHOW_ORIENTATIONS for an example of its use
%  2004, Alexander Heimel
%
% 2007-04-20 AH Added optional gabor

global whichScreen monitorframerate 

gray=(par.color_high+par.color_low)/2;
inc=(par.color_high-gray)*par.contrast;

if ~isfield(par,'phase')
    par.phase=pi/2;
end

% compute each frame of the movie
frames=round(monitorframerate/par.tf); % temporal period, in frames, of the drifting grating
par.tf=monitorframerate/frames
for i=1:frames
	phase=par.phase;
    tphase=(i/frames)*2*pi;
	% grating
	%[x,y]=meshgrid(-200:200,-200:200);
    width=par.rect(3)-par.rect(1);
    height=par.rect(4)-par.rect(2);
	[x,y]=meshgrid( 0:(width-1), 0:(height-1) );
	angle=par.angle*pi/180; 
	%f=0.05*2*pi; % cycles/pixel    
	f=2*pi*par.sf/pixels_per_degree;
    a=cos(angle)*f;
	b=sin(angle)*f;
	%m=exp(-((x/90).^2)-((y/90).^2)).*sin(a*x+b*y+phase);
	m=sin(a*x+b*y+phase)*sin(tphase);
    hwidth=width/4;
    hheight=height/4;
    if isfield(par,'gabor')
        m=m.*min(1, exp(1 -(x-width/2).^2/hwidth^2)) ;
        m=m.*min(1, exp(1-(y-height/2).^2/hheight^2)) ;
    end    
    if ~isempty(par.function)
        m=feval(par.function,m);
    end
% 	Screen(window,'PutImage',gray+inc*m);


w(i)=Screen(whichScreen,'OpenOffscreenWindow',0,[0 0 size(m')]);
	Screen(w(i),'PutImage',gray+inc*m);
end

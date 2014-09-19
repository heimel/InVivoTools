function w=drifting_grating(par)
%DRIFTING_GRATING produces offscreenwindows with one cycle of a drifting grating
%
%  W=DRIFTING_GRATING(PAR)
%     PAR.ANGLE = orientation (deg)
%                  0 is vertical bar moving leftward
%                  45 is oblique bar moving up-left
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
	phase=(i/frames)*2*pi + par.phase;
	% grating
	%[x,y]=meshgrid(-200:200,-200:200);
	[x,y]=meshgrid( 0:(par.rect(3)-par.rect(1)-1), 0:(par.rect(4)-par.rect(2)-1) );
	angle=par.angle*pi/180; 
	%f=0.05*2*pi; % cycles/pixel    
	f=2*pi*par.sf/pixels_per_degree;
    a=cos(angle)*f;
	b=sin(angle)*f;
	%m=exp(-((x/90).^2)-((y/90).^2)).*sin(a*x+b*y+phase);
	m=sin(a*x+b*y+phase);
    if ~isempty(par.function)
        m=feval(par.function,m);
    end
% 	Screen(window,'PutImage',gray+inc*m);
size(m)
	w(i)=Screen(whichScreen,'OpenOffscreenWindow',0,[0 0 size(m')]);
	Screen(w(i),'PutImage',gray+inc*m);
end

function y=top(x)
   y = max(x(:))*(x> (0.95*max(x(:))));

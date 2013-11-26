function w=plaid(par)
%PLAID produces offscreenwindow with a plaid phase reversing
%
%  W=PLAID(PAR)
%     PAR.ANGLE1 = orientation (deg)
%                  0 is vertical bar 
%                  45 is oblique bar moving up-left
%     PAR.ANGLE2
%     PAR.TF = temporal frequency (Hz)
%        if TF = 0 then only one image, no sequence
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
%  2006, Alexander Heimel
%

global whichScreen monitorframerate 

gray=(par.color_high+par.color_low)/2;
inc=(par.color_high-gray)*par.contrast;

if ~isfield(par,'phase')
    par.phase=pi/2;
end

% compute each frame of the movie
if par.tf==0
    frames=1;
else
    frames=round(monitorframerate/par.tf); % temporal period, in frames, of the drifting grating
    par.tf=monitorframerate/frames
end
for i=1:frames
	phase=(i/frames)*2*pi + par.phase;
	% grating
	%[x,y]=meshgrid(-200:200,-200:200);
	[x,y]=meshgrid( 0:(par.rect(3)-par.rect(1)-1), 0:(par.rect(4)-par.rect(2)-1) );
	angle1=par.angle1*pi/180; 
	angle2=par.angle2*pi/180; 
	%f=0.05*2*pi; % cycles/pixel    
	f=2*pi*par.sf/pixels_per_degree;
    a1=cos(angle1)*f;
	b1=sin(angle1)*f;
    a2=cos(angle2)*f;
	b2=sin(angle2)*f;
	%m=exp(-((x/90).^2)-((y/90).^2)).*sin(a*x+b*y+phase);
	m=sin(a1*x+b1*y+phase).*sin(a2*x+b2*y+phase);
    if ~isempty(par.function)
        m=feval(par.function,m);
    end
% 	Screen(window,'PutImage',gray+inc*m);
size(m)
	w(i)=Screen(whichScreen,'OpenOffscreenWindow',0,[0 0 size(m')]);
	Screen(w(i),'PutImage',gray+inc*m);
end

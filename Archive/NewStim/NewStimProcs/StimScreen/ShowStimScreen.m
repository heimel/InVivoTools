function ShowStimScreen
StimWindowGlobals

if isempty(StimWindow),
    if isnumeric( PsychtoolboxVersion) % i.e. version 2 or below
        StimWindow = Screen(0,'OpenWindow',0);
        Screen(StimWindow,'PixelSize',8,1);
        StimWindowDepth = 8;
    else
        % Enable compatibility mode to old PTB-2:
       Screen('Preference', 'EmulateOldPTB', 1);
%        StimWindow = Screen(0,'OpenWindow',0,[0 0 640 480]);
        StimWindow = Screen(0,'OpenWindow',0);
        StimWindowDepth = Screen(StimWindow,'PixelSize');
    end
	StimWindowRect = Screen(StimWindow,'Rect');
	StimWindowRefresh = Screen(StimWindow,'FrameRate',[]);
end;

switch host
        case '3dstim'

        % added 2007-07-19 by Alexander Heimel
        % to calibrate MAC-setup on Damian's Rig
        x=255*(0:0.1:1);
        %y=[85.5 155.45 270.8 448.5 693.5 1118.5 1815 2636 3395.5 3940 4093];
        %x=[x 270];
        %y=[y y(end)]
        %to measure uncorrected gammatable
        %x=255*[0 1];
        %y=[0 1];

        x=255*(0:.2:1);
        % y=[4.99 5 10.46 41.93 138.4 364]; (damian's rig)
        y =[0.427 0.427 0.792 14.26 43.31 89.06]; % 2010-10-14 3dstim
        y=y/max(y)*255;
        fitx=(0:255);
        fity=(fitx/255).^3.5*max(y);
        
        disp('SHOWSTIMSCREEN: AUTOMATE GAMMA FITTING');
        %fity=FitGammaSpline(x',y',fitx);
        gx=(0:255);
        gy=gx(findclosest(fity,gx))';
        gy=[gy gy gy];
        
        [newGammaTable,oldBits]=Screen(StimWindow,'Gamma',gy);
        
    case 'mac'
        %to measure uncorrected gammatable
        %x=255*[0 1];
        %y=[0 1];

        x=255*(0:.2:1);
        y=[4.99 5 10.46 41.93 138.4 364];% (damian's rig)
        y=y/max(y)*255;
        fitx=(0:255);
        fity=FitGammaSpline(x',y',fitx);
        gx=(0:255);
        gy=gx(findclosest(fity,gx))';
        gy=[gy gy gy];
        
        [newGammaTable,oldBits]=Screen(StimWindow,'Gamma',gy);
    otherwise
        warning('SHOWSTIMSCREEN: no gamma correction');
end
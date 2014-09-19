function gamma_corrected_clut( window )
%GAMMA_CORRECTED_CLUT calculates and sets gamma corrected CLUT for EIZO F784-T
%
%  Dec 2004, Alexander Heimel
%  2006-01-03: JFH: Added new stimulus computer
%  2008-04-25: JFH: recalibrated stim monitors of daneel and andrew

switch host
    case 'nori999' 
        % no longer used as pc died
        % stimulus pc of first imaging setup
        % linearized long ago:
        %r_gamma_corr=255*( (0:1:255) /(255)).^(1/2.75);
        %g_gamma_corr=255*( (0:1:255) /(255)).^(1/3.2);
        %b_gamma_corr=255*( (0:1:255) /(255)).^(1/2.75);
         % background intensity for retinotopy stimulus was 2.5cd/m2
         
          % relinearized on 2008-04-25, JFH
        r_gamma_corr=255*( (0:1:255) /(255)).^0.44;
        g_gamma_corr=255*( (0:1:255) /(255)).^0.38;
        b_gamma_corr=255*( (0:1:255) /(255)).^0.44;
        
    case 'nori002', % new stimulus pc = oude desktop Damian
        % measured on 19 January 2006
        %luminance_corr=0.705;%5.0/10.67; % to agree with EIZO
        % 2008-04-25 luminance correction multiplied with 2.5/3.5
        %luminance_corr=0.705*2.5/3.5;%5.0/10.67; % to agree with EIZO
        % 2009-09-09:
        luminance_corr=0.67;% to set retinotopy background to 3cd/m2
        r_gamma_corr=luminance_corr*...
            255*( (0:1:255) /(255)).^(1/2.27);
        g_gamma_corr=luminance_corr*...
            255*( (0:1:255) /(255)).^(1/2.18);
        b_gamma_corr=luminance_corr*...
            255*( (0:1:255) /(255)).^(1/2.22);
        % checked on 2008-04-25: still linear
        % monitor background level for retinotopy stimulus:3.5cd/m2
    case {'nin-pc86'}, % stimulus pc for daneel imaging setup
         
        % relinearized on 2009-09-09, JFH
%        r_gamma_corr=255*( (0:1:255) /(255)).^0.44;
 %       g_gamma_corr=255*( (0:1:255) /(255)).^0.38;
  %      b_gamma_corr=255*( (0:1:255) /(255)).^0.44;
        % monitor background level for retinotopy stimulus:0.84 cd/m2
        r_gamma_corr=255*( (0:1:255) /(255)).^0.357;
        g_gamma_corr=255*( (0:1:255) /(255)).^0.357;
        b_gamma_corr=255*( (0:1:255) /(255)).^0.357;
        
        
    otherwise
        disp('Unknown computer')
        return
end

        
        
clut=[r_gamma_corr;g_gamma_corr;b_gamma_corr]';
Screen(window,'SetClut',clut);

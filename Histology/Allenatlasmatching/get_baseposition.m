function ud = get_baseposition(ud)
% best matched slice coordinates for Vangeneugden et al.
%
% 2018, Alexander Heimel
%

ud.phi = -98/180*pi; % angle in AP-LR plane (radii) sagittal =0 ; coronal = pi/2;
ud.axis_ap = 315;
ud.axis_lr = 112;
ud.theta = 0; % angle to DV axis (radii) vertical = 0; horizontal = pi/2
ud.slice_angle = 0; % in degrees
ud.slice_scale = 1;
ud.slice_shift = [0 0];
ud.slice_gamma = 1;
ud.slice_prctile = 99.9;
ud.slice_threshold = 4; % minimum brain intensity, slice dependent
ud.slice_base = 10; % mininum visual cortex level, slice dependent
ud.slice_diis = []; % list of dii from electrode track

switch ud.slice_name
    case 'ignace1'
        ud.phi = -100/180*pi;
        ud.axis_ap = 311;
        ud.axis_lr = 113;
        ud.theta = 0;
        ud.slice_angle = 0; % in degrees
        ud.slice_scale = 0.51;
        ud.slice_shift = [0 -28];
        ud.slice_diis = [251 116 7];
        ud.slice_threshold = 7;
        ud.slice_base = 18;
    case 'ignace2' % need to be redone, because swapped rotation and shift
        ud.phi = -99/180*pi;
        ud.axis_ap = 323;
        ud.axis_lr = 111;
        ud.theta = 0;
        ud.slice_angle = -5; % in degrees
        ud.slice_scale = 0.46;
        ud.slice_shift = [0 -25];
        ud.slice_diis = [215 110 8;214 120 5];
        ud.slice_base = 18;
    case 'ignace3'
        ud.phi = -96/180*pi;
        ud.axis_ap = 326;
        ud.axis_lr = 111;
        ud.theta = 0;
        ud.slice_angle = -14; % in degrees
        ud.slice_scale = 0.40;
        ud.slice_shift = [-24 -49];
        ud.slice_threshold = 10.0;
        ud.slice_diis = [267 127 8;380 152 16;130 157 10;122 172 5;135 142 5;151 127 5; 164 115 5;362 134 10;373 135 5];
        ud.slice_base = 20.0;
    case 'ignace3_2chanc'
        ud.phi = -97/180*pi;
        ud.axis_ap = 321;
        ud.axis_lr = 112;
        ud.theta = 0;
        ud.slice_angle = 2; % in degrees
        ud.slice_scale = 0.85;
        ud.slice_shift = [3 -13];
    case 'louise'
        ud.phi = -96/180*pi;
        ud.axis_ap = 340;
        ud.axis_lr = 109;
        ud.slice_angle = 10; % in degrees
        ud.slice_scale = 0.32;
        ud.slice_shift = [0 -7];
        ud.slice_threshold = 3;
        ud.slice_base  = 3.4;
    case 'ovide4'
        ud.phi = -83/180*pi;
        ud.axis_ap = 369;
        ud.axis_lr = 110;
        ud.theta = 0;
        ud.slice_angle = -27; % in degrees
        ud.slice_scale = 0.61;
        ud.slice_shift = [-103 -70];
        ud.slice_gamma = 1.3;
        ud.slice_threshold = 5;
        ud.slice_base  = 10;
        ud.slice_diis = [323 108 13];
    case 'raoul0'
        ud.phi = -87/180*pi;
        ud.axis_ap = 364;
        ud.axis_lr = 115;
        ud.theta = 0;
        ud.slice_shift = [-84 -80];
        ud.slice_angle = -27; % in degrees
        ud.slice_scale = 0.77;
        ud.slice_gamma = 1.0;
        
        ud.slice_threshold = 8;
        ud.slice_base  = 10;
        ud.slice_diis = [337 110 22];
    case 'ulyssee5'
        %         ud.phi = 70/180*pi;
        %         ud.axis_ap = 340;
        %         ud.axis_lr = 109;
        %         ud.slice_angle = -20; % in degrees
        %         ud.slice_scale = 0.33;
        %         ud.slice_shift = [7 -30];
        
        ud.phi = 84/180*pi;
        ud.axis_ap = 344;
        ud.axis_lr = 105;
        ud.slice_angle = -23; % in degrees
        ud.slice_scale = 0.32;
        ud.slice_shift = [16 -33];
        ud.slice_threshold = 6;
        ud.slice_diis = [198 116 10;199 146 12];
        ud.slice_base = 12.3;
    case 'walter0'
        ud.phi = 70/180*pi;
        ud.axis_ap = 340;
        ud.axis_lr = 109;
        ud.slice_angle = -25; % in degrees
        ud.slice_scale = 0.6;
        ud.slice_shift = [-20 -40];
        ud.slice_diis = [ 235 91 13; 233 116 10;233 140 8;231 152 7];
        ud.slice_base = 9.4;
    case 'NatComm_Mouse_01_plate2_slice09_small_flip'
        ud.phi = -98/180*pi;
        ud.axis_ap = 315;
        ud.axis_lr = 112;
        ud.slice_angle = -19; % in degrees
        ud.slice_scale = 0.26;
        ud.slice_shift = [-12 -71];
        ud.slice_diis = [236 93 10;231 110 10;220 142 20 ];
        ud.slice_base = 7;
    case 'NatComm_Mouse_02_plate5_slice09_small_flip'
        ud.phi = -87/180*pi;
        ud.axis_ap = 357;
        ud.axis_lr = 115;
        ud.slice_angle = -30; % in degrees
        ud.slice_scale = 0.30;
        ud.slice_shift = [-45 -86];
        ud.slice_diis = [240 126 20;223 89 7;230 93 7;251 96 7;249 106 6;244 118 6];
        ud.slice_base = 13;
        ud.slice_gamma = 1.3;
end

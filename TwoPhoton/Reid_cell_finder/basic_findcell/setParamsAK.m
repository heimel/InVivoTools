function [min_area, win_size, noise_radius, junk_radius, ratio_th, min_center, con_ratio, breakup_factor, clear_border, fast_breakup, do_manual, show_flag]  = setParamsAK(s,nf)
% set the parameters for cellfinding, inputs:
% s  structure (or array of structures) with filenames etc.
% nf:  index of array of structures.  Optional.  If s is a single structure than function is called with single argument.

if nargin < 2
   if length(s) > 1
       error('parameter nf not sent to setparamsAK and s is NOT a single structure but an array (ask Clay or Aaron)');
   end
   nf = 1
end
out = zeros(12);
no_name_found = 0;
expname = char(s(nf).expdir);

switch(expname)
    case 'Cat040726'
        out = [230 61 2 7 0.17 200 0.7 5 0 1 0 1];
    case 'Cat040804'
        out = [230 61 2 7 0.18 200 0.65 3 0 1 0 1];
    case 'Cat040813'
        out = [80 31 1 3 0.18 60 0.7 3 2 1 0 1];
    case 'Cat040819'
        out = [95 35 2 3 0.17 85 0.65 3 0 1 0 1];
    case 'Cat040826'
        if s(nf).FOV == 300
            out = [80 31 1 3 0.22 60 0.6 3 2 1 0 1];
        else
            no_name_found = 1;
        end
%     case 'Cat050309'
%         out = [80 31 1 3 0.18 65 0.6 6 0 1 0 1];        
    case 'rCat040830'
        out = [80 31 1 3 0.19 70 0.65 3 2 1 0 1];
    case 'Cat040902'
        out = [80 31 1 3 0.15 70 0.65 3 2 1 0 1];
    case 'Cat040907'
        out = [80 31 1 3 0.14 60 0.65 3 2 1 0 1];
    case 'Cat040910'
        out = [80 31 1 3 0.21 60 0.65 3 2 1 0 1];  
    otherwise    
        no_name_found = 1;
end

if no_name_found == 1
    imgtype = sprintf('%i%i', s(nf).FOV, s(nf).MATsize);
    switch(imgtype)
        case '150512'
            out = [230 61 2 7 0.18 200 0.65 3 0 1 0 1]; 
        case '300512'
            out = [80 31 1 3 0.18 65 0.6 3 2 1 0 1];        
        case '150256'
            out = [70 31 1 3 0.2 50 0.85 4 1 1 0 1];      
        case '300256'
            out = [30 15 1 1 0.15 16 0.85 3 1 1 0 1];
        case '200256'
            out = [30 45 1 2 0.23 25 0.65 3 0 1 0 1];
        otherwise
            disp('No parameter settings found - using 512um resolution, 150um FOV defaults');
            out = [250 61 2 7 0.18 200 0.65 3 0 1 0 1];
    end
end

%override


min_area = out(1);
win_size = out(2);
noise_radius = out(3); 
junk_radius = out(4);
ratio_th = out(5);
min_center = out(6);
con_ratio = out(7);
breakup_factor = out(8);
clear_border = out(9);
fast_breakup = out(10);
do_manual = out(11);
show_flag = out(12);

if no_name_found == 1
disp(sprintf('\nUsing cell detection default values for %i by %i pixels (%i um by %i um).', s(nf).MATsize, s(nf).MATsize, s(nf).FOV, s(nf).FOV));
else
disp(sprintf('\nUsing stored cell detection values for experiment %s', expname));
end

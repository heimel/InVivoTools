function [dr,howoften,avgframes] = tpdriftcheck_lucaskanade(record, channel)
%  TPDRIFTCHECK - Checks two-photon data for drift
%
%  DR = TPDRIFTCHECK(DIRNAME,CHANNEL,REFDIRNAME, HOWOFTEN, AVGFRAMES, VERBOSE)
%  
%  CHANNEL is the channel to be read.
%
%  The fraction of frames to be searched is specified in HOWOFTEN.  If
%  HOWOFTEN is 1, all frames are searched; if HOWOFTEN is 10, only one
%  of every 10 frames is searched.
%
%  AVGFRAMES specifies the number of frames to average together.
%
%  DR is a struct containing shifts corrected with NoRMCorre and the
%  Lucas-Kanade method
%      dr.x_rigid       linear x shifts (array) computed by NoRMCorre
%      dr.y_rigid       linear y shifts (array) computed by NoRMCorre
%      dr.x_nonrigid    non-rigid x shifts computed by Lucas-Kanade
%      dr.y_nonrigid    non-rigid y shifts computed by Lucas-Kanade
%
% 2019 Laila Blomer

if nargin<2 || isempty(channel)
    channel = 1;
end

logmsg('Performing drift correction using Lucas-Kanade method. WARNING: this will double your data size');

% dr = [];

params = tpreadconfig(record);
processparams = tpprocessparams(record);
howoften = 1;
avgframes = 1;
numberofframes = params.number_of_frames;
fov_margins = processparams.drift_field_of_view_margins;
driftfilename = tpscratchfilename( record, [], 'lucaskanade', '.tif');

skipframes = processparams.drift_correction_skip_firstframes;
dr = struct('x_rigid', {}, 'y_rigid', {}, 'x_nonrigid', {}, 'y_nonrigid', {});

% prepare data for motion correction
data_uncor = zeros(params.lines_per_frame,params.pixels_per_line,numberofframes,'single');
wait_size = size(data_uncor,ndims(data_uncor));

dividerWaitbar = 10^(floor(log10(wait_size))-1);
h = waitbar(0,'Reading in frames for motion correction');
opt = 'lucas';

for fr = 1:numberofframes
    data_uncor(:,:,fr) = tpreadframe(record,channel,fr,opt);
    
    if (round(fr/dividerWaitbar) == fr/dividerWaitbar)
        waitbar(fr/wait_size, h);
    end
end

delete(h);

data = data_uncor(fov_margins(3)+1:end-fov_margins(4),fov_margins(1)+1:end-fov_margins(2),:);
file_size = size(data,ndims(data));

template1 = mean(data(:,:,skipframes:numberofframes),3);

% perform rigid motion correction based on NoRMCorre
options_rigid = NoRMCorreSetParms(...
    'd1',size(data,1),...
    'd2',size(data,2),...
    'bin_width',200,...
    'max_shift',[100 100],...
    'us_fac',50,...
    'init_batch',200,...
    'method',{'mean', 'mean'},...
    'shifts_method', 'FFT',...
    'correct_bidir', 0);

gcp;

logmsg('Starting rigid NoRMCorre correction');
[data_rigid,shifts_data,~,~] = normcorre_batch(data,options_rigid,template1);

% perform non-rigid motion correction (Lucas-kanade method)]
ppm = ParforProgressStarter2('Applying non-rigid correction', file_size);

data_nonrigid = ones(size(data_rigid), 'single');
template2 = mean(data_rigid(:,:,skipframes:numberofframes),3);

logmsg('Starting non-rigid Lucas-Kanade correction...');
parfor i = 1:file_size
    [fr_cor,dpx,dpy] = doLucasKanade(template2,data_rigid(:,:,i));
    
    data_nonrigid(:,:,i) = fr_cor;
    
    dr(i).x_nonrigid = dpx;
    dr(i).y_nonrigid = dpy;
    
    dr(i).x_rigid = shifts_data(i).shifts(:,:,1,1);
    dr(i).y_rigid = shifts_data(i).shifts(:,:,1,2);

    ppm.increment(i);
end

logmsg('Done');

% clean up memory
delete(ppm);
poolobj = gcp('nocreate');
delete(poolobj);
clear data data_uncor data_rigid

% add margins
% data_uncor(fov_margins(3):end-fov_margins(4),fov_margins(1):end-fov_margins(2),:) = filenonrigid;
data_nonrigid = double(data_nonrigid);
data_nonrigid = padarray(data_nonrigid, [fov_margins(3) fov_margins(1)], nan, 'pre');
data_nonrigid = padarray(data_nonrigid, [fov_margins(4) fov_margins(2)], nan, 'post');

logmsg('Saving TIFF stack...');
saveastiff(data_nonrigid, driftfilename);
logmsg(['Saved drift corrected tiff stack as ' driftfilename]);

end
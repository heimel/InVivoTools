function oi_clusteringROIs_map( record )
%OI_CORRELATION_MAP
%
% 2013, Alexander Heimel
%

params.pick_starting_clusters = false;
params.average_over_trials = false;
params.remove_trial_average = true;
n_clusters = 9;

if nargin<1
    record = [];
end

if ~isempty(record)
    cd(oidatapath(record));
end

load('spontaneous_frames.mat')
data = zeros(size(ffrr{1},1),size(ffrr{1},2),length(ffrr));
for i=1:length(ffrr)
    data(:,:,i) = ffrr{i};
end

hfig = figure;
subplot(1,3,1)
imagesc(mean(data,3)');
axis image
%colormap gray

% take subimage
xl = [1 size(data,1)];
yl = [1 size(data,2)];

%xl = [20 120];
%yl = [50 140];
step = 3;

data = data(xl(1):step:xl(2),yl(1):step:yl(2),:);
subplot(1,3,2)
imagesc(mean(data,3)');
axis image
%colormap gray

[n_x n_y n_images] = size(data);

n_trials = 5;
n_conditions = 7;
n_frames = n_images / n_trials /n_conditions;
data = reshape(data,n_x,n_y,n_frames,n_conditions,n_trials);

data = mean(data,3); % average out frames

meandata = mean(data,5);
meandata = squeeze(meandata);
h=plotwta(-meandata,1:n_conditions,[],0,[],5,256);
title(pwd)

if isempty(n_clusters)
%    n_clusters = n_conditions + 1;
    n_clusters = n_conditions ;
end


if params.pick_starting_clusters
    disp(['OI_CORRELATION_MAP: Click on ' num2str(n_clusters) ...
        ' clustering starting points.']);
    
    [startpos(:,1),startpos(:,2)] = ginput(n_clusters);
    startpos = round(startpos);
end

figure(hfig)

data = reshape(data,n_x*n_y,n_conditions*n_trials);
signal = mean(data,1); % mean over all pixels
data = data ./ repmat(signal,n_x*n_y,1);

data = reshape(data,n_x,n_y,n_conditions,n_trials);
meandata = mean(data,4);
meandata = squeeze(meandata);
h=plotwta(-meandata,1:n_conditions,[],0,[],5,256);

function oi_correlation_map( record )
%OI_CORRELATION_MAP
%
% 2013, Alexander Heimel
%

params.pick_starting_clusters = false;
params.average_over_trials = false;
params.remove_trial_average = true;
n_clusters = 6;

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
n_conditions = 6;
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

if params.remove_trial_average
    mean_per_trial = mean(data,3);
    for i=2:size(data,3)
        mean_per_trial(:,:,i,:)=mean_per_trial(:,:,1,:);
    end
    data = data - mean_per_trial;
end

if params.average_over_trials
    data = mean(data,4); % mean over trials
end

data = reshape(data,n_x*n_y,numel(data)/(n_x*n_y));

data = data - repmat(mean(data,2),1,size(data,2)); % remove mean
data = data ./ repmat(std(data')',1,size(data,2)); % normalize std

%cols = retinotopy_colormap(n_clusters-1,1);
cols = retinotopy_colormap(n_clusters,1);

if params.pick_starting_clusters
    for i=1:size(startpos,1)
        startdata(i,:) = data((startpos(i,2)-1)*n_x+startpos(i,1),:);
    end
    ind = kmeans(data,[],'Start',startdata);
else
    ind = kmeans(data,n_clusters);
end

figure;
[inds,ii]=sort(ind);
imagesc([inds data(ii,:)])


ind = reshape(ind,n_x,n_y);
figure
image(ind');
axis image
colormap(cols);
title(pwd)
colorbar


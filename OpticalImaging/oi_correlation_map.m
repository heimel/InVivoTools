function oi_correlation_map( record )
%OI_CORRELATION_MAP
%
% 2013, Alexander Heimel
%

params.pick_starting_clusters = false;
params.average_over_trials = true;
params.remove_trial_average = true;
n_clusters = 9;

if nargin<1
    record = [];
end


data = oi_read_all_data( record );

[n_x n_y n_frames n_trials n_conditions] = size(data);

data = squeeze(mean(data,3)); % average out frames
meandata = squeeze(mean(data,3)); % average out trials


hfig = figure;
subplot(1,3,1)
imagesc(mean(mean(mean(data,5),4),3)');
axis image

% take subimage
xl = [1 size(data,1)];
yl = [1 size(data,2)];

%xl = [20 120];
%yl = [50 140];
step = 1;

data = data(xl(1):step:xl(2),yl(1):step:yl(2),:,:,:);
subplot(1,3,2)
imagesc(mean(mean(mean(data,5),4),3)');
axis image
%colormap gray




h = plotwta(-meandata,1:n_conditions,[],0,[],5,256,record);
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

data = reshape(data,n_x,n_y,n_trials,n_conditions);
meandata = squeeze(mean(data,3));
h=plotwta(-meandata,1:n_conditions,[],0,[],5,256);

if params.remove_trial_average
    mean_per_trial = mean(data,4);
    for i=2:n_conditions 
        mean_per_trial(:,:,:,i)=mean_per_trial(:,:,:,1);
    end
    data = data - mean_per_trial;
end

if params.average_over_trials
    data = mean(data,3); % mean over trials
end
data = reshape(data,n_x*n_y,numel(data)/(n_x*n_y));

data = data - repmat(mean(data,2),1,size(data,2)); % remove mean
data = data ./ repmat(std(data')',1,size(data,2)); % normalize std

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


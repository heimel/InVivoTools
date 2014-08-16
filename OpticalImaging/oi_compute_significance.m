function record = oi_compute_significance( record )
%OI_COMPUTE_SIGNIFICANCE computes pixels with significant response
%
% 2014, Alexander Heimel
%

[response_framenumbers,baseline_framenumbers] = oi_get_framenumbers(record);

data = oi_read_all_data( record );
%     DATA  = [X,Y,FRAMES,BLOCK,CONDITIONS]
% 
% hdata = zeros(size(data));
% hangle = zeros(size(data));
% for x=1:1:size(data,1)
%     for y=1:1:size(data,2)
%         for m=1:1:size(data,4)
%             for c=1:size(data,5)
%                 hdata(x,y,:,m,c) = hilbert(data(x,y,:,m,c));
%                 hdata(x,y,:,m,c) = hdata(x,y,:,m,c) -mean(hdata(x,y,:,m,c),3);
%                 hangle(x,y,:,m,c) = angle(hdata(x,y,:,m,c));
%             end
%         end
%     end
% end
% data=hangle;
% fdata = zeros(size(data));
% fp = 3;
% if ~isnan(fp)
%     filter=[];
%     logmsg(['Filter width set to ' num2str(fp) ' pixels.']);
%     filter.width = max(1,fp/2/1);
%     filter.unit = 'pixel';
%     for c=1:size(data,5)
%         fdata(:,:,:,:,c) = spatialfilter(data(:,:,:,:,c),filter.width,filter.unit);
%     end
% %     stddev = spatialfilter(stddev,filter.width,filter.unit)/sqrt(filter.width^2);
% end
% data=fdata;
% if ~isempty(record) && strcmp(record.stim_type,'significance')
%     % combine directions to single orientation
%     stim_parameters = uniq(sort(mod(record.stim_parameters,180)));
%     new_data = zeros( size(data,1),size(data,2),size(data,3),size(data,4),length(stim_parameters));
%     for i = 1:length(stim_parameters)
%         new_data(:,:,:,:,i) = max( data(:,:,:,:,[record.stim_parameters==stim_parameters(i) | record.stim_parameters==(stim_parameters(i)+180)]),[],5);
%     end
%     data = new_data;
%     stimlist = 1:size(data,5);
% end

% fdata = zeros(size(data));
% fp = 3;
% if ~isnan(fp)
%     filter=[];
%     logmsg(['Filter width set to ' num2str(fp) ' pixels.']);
%     filter.width = max(1,fp/2/1);
%     filter.unit = 'pixel';
%     for c=1:size(data,5)
%         fdata(:,:,:,:,c) = spatialfilter(data(:,:,:,:,c),filter.width,filter.unit);
%     end
% %     stddev = spatialfilter(stddev,filter.width,filter.unit)/sqrt(filter.width^2);
% end
% data=fdata;

if 0
    % combine conditions
    combine_conditions=[1,3];
    data = data(:,:,:,:,combine_conditions);
    logmsg('ONLY DOING GROUP 1 AND 3 AT THE MOMENT');
end

[n_x n_y n_frames n_blocks n_conditions] = size(data); %#ok<ASGLU>

response = data(:,:,response_framenumbers,:,:);
response = squeeze(mean(response,3)); 

baseline = data(:,:,baseline_framenumbers,:,:);
baseline = squeeze(mean(baseline,3));

cdata=squeeze(mean(response-baseline,3));
comp_conds=((cdata(:,:,1)>cdata(:,:,2)))+1;

signif_between_groups = zeros(n_x,n_y);
signif_response = zeros(n_x,n_y);
groups =  reshape(repmat(1:n_conditions,[n_blocks 1]),[n_blocks*n_conditions 1]);
h=waitbar(0,'Computing significance');
for x=1:1:n_x
    for y=1:1:n_y
        r = reshape(response(x,y,:,:),[n_blocks*n_conditions 1]);
        b = reshape(baseline(x,y,:,:),[n_blocks*n_conditions 1]);
        signif_between_groups(x,y) = myanova(r,groups);
        signif_response(x,y) = ...
            myanova([r;b],[groups repmat(0,[n_blocks*n_conditions 1])]);
    end % y
    waitbar(x/n_x,h);
end % x
close(h)

%fname = fullfile(oidatapath(record),[record.test '_significance' num2str(combine_conditions) '.mat']);
fname = fullfile(oidatapath(record),[record.test '_significance.mat']);
save(fname,'signif_between_groups','signif_response','comp_conds');

figure;
imagesc(double(((signif_between_groups<0.01).*comp_conds.*(signif_response<0.01)))',[0 5])

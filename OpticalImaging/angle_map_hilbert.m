function angle_map_hilbert( record )

data = oi_read_all_data( record );


[n_x n_y n_frames n_trials n_conditions] = size(data); %#ok<ASGLU>

data = squeeze(mean(data,4));


record.mouse = '13.61.2.13';
params = oiprocessparams( record );

fdata = zeros(size(data));
fp = params.spatial_filter_width;
if ~isnan(fp)
    filter=[];
    logmsg(['Filter width set to ' num2str(fp) ' pixels.']);
    filter.width = max(1,fp/2/1);
    filter.unit = 'pixel';
    for c=1:n_conditions
        fdata(:,:,:,c) = spatialfilter(data(:,:,:,c),filter.width,filter.unit);
    end
%     stddev = spatialfilter(stddev,filter.width,filter.unit)/sqrt(filter.width^2);
end

nfdata = zeros(n_x, n_y, n_frames, n_conditions/2);

for c = 1:size(fdata,4)/2
    for x=1:n_x
        for y=1:n_y
            for f=1:n_frames
                nfdata(x,y,f,c) = max( [fdata(x,y,f,c) fdata(x,y,f,c+size(fdata,4)/2)]);
            end
        end
    end        
    end
fdata = nfdata;

% for c = 1:size(fdata,4)/2
%     for x=1:n_x
%         for y=1:n_y
%             for f=1:n_frames
%                 nfdata(x,y,f,c) = [fdata(x,y,f,c)+fdata(x,y,f,c+size(fdata,4)/2)]/2;
%             end
%         end
%     end        
%     end
% fdata = nfdata;


figure;
plot((squeeze(data(91,91,:,1))));
hold on
plot((squeeze(data(91,91,:,2))),'r');
plot((squeeze(data(91,91,:,3))),'g')
plot((squeeze(data(91,91,:,4))),'k')

% data(91,91,:,1)= data(91,91,[9 10 1:8],1);
% fdata(91,91,:,1)= fdata(91,91,[9 10 1:8],1);
% figure;
% plot((squeeze(data(91,91,:,1))));
% hold on
% plot((squeeze(data(91,91,:,2))),'r');
% plot((squeeze(data(91,91,:,3))),'g')
% plot((squeeze(data(91,91,:,4))),'k')


% hdata = zeros(size(fdata));
% hangle = zeros(size(fdata));
for x=1:1:size(fdata,1)
    for y=1:1:size(fdata,2)
        for c=1:size(fdata,4)
            hdata(x,y,c,:) = hilbert(fdata(x,y,:,c));
            hdata(x,y,c,:) = hdata(x,y,c,:) -mean(hdata(x,y,c,:),4);
            hangle(x,y,c,:) = angle(hdata(x,y,c,:));
        end
    end
end




% figure;
% plot(angle(squeeze(hdata(91,91,1,:))));
% hold on;
% plot(angle(squeeze(hdata(91,91,2,:))),'r');plot(angle(squeeze(hdata(91,91,3,:))),'g')
% plot(angle(squeeze(hdata(91,91,4,:))),'k')
 
 plotwta(squeeze(hangle(:,:,:,8)))
 


function onlinemaps(avg,framezero_avg,fname,ledtest,record)
%ONLINEMAPS saves the single condition maps for imaging
%
% ONLINEMAPS(AVG,FRAMEZERO_AVG,FNAME,LEDTEST,RECORD)
%
% 2004-2014, Alexander Heimel
%

if nargin<5
    record = [];
end
if nargin<4 || isempty(ledtest)
    ledtest = 0;
end
if nargin<3
    fname = '';
end
if nargin<2
    framezero_avg=[];
end

params = oiprocessparams( record );

n_stims = size(avg,3);

% subtract zero-frames
if ledtest
    avg(:,:,2)=avg(:,:,2)-avg(:,:,1);
elseif ~isempty(framezero_avg)
    logmsg('Subtracting baseline frames, i.e. going to Delta F or R');
    for stim=1:n_stims
        avg(:,:,stim)=avg(:,:,stim)-framezero_avg(:,:,stim);
    end
end

if params.single_condition_normalize_response
    logmsg('Normalizing by the maximum level in the image for each stimulus independently');
    for stim=1:n_stims
        avg(:,:,stim)=avg(:,:,stim)/max(max(avg(:,:,stim)));
    end
end

if params.single_condition_differential
    logmsg('Computing differential single condition maps.');
    avgavg = mean(avg,3);
    avg = avg - repmat(avgavg,[1 1 n_stims]);
end

% clipping range
deviatie = std(avg(:));
gemiddelde = median(avg(:));
clip = params.single_condition_clipping;
if clip == 0
    rang = max(abs(min(avg(:))-gemiddelde),abs(max(avg(:))-gemiddelde));
    low = gemiddelde - rang;
    high = gemiddelde + rang;
elseif clip > 0 
    logmsg(['Clipping at median plus and minus ' num2str(clip) 'x the standard deviation']);
    low = gemiddelde-clip*deviatie;
    high = gemiddelde+clip*deviatie;
else % clip < 0 
    low = gemiddelde + clip; %-0.002
    high = gemiddelde - clip; % 0.001
end
switch params.average_image_normmethod
    case 'subtractframe_ror'
        meaning = ' Delta R/R_baseline';
    otherwise
        meaning = '';
end
logmsg(['Black =  ' num2str(low) ', white = ' num2str(high) ' ' meaning ]);

% for stim=1:n_stims
%     kaart = avg(:,:,stim);
%     kaart(kaart(:)>high) = high;
%     kaart(kaart(:)<low) = low;
%     kaart = (kaart -low)/(high-low);
%     maps{stim}=kaart;
% end

avg(avg>high) = high;
avg(avg<low) = low;
avg = (avg-low)/(high-low); 

filename=[fname 'single_cond*.png'];
delete(filename);

for stim=1:n_stims
    filename = [fname 'single_cond' num2str(stim) '.png'];
    imwrite(uint8(round(255*avg(:,:,stim)')),filename,'png')
end

filename = [fname 'single_cond_range.asc'];
save(filename,'low','high','-ascii'); % saving range for intensity bar

return





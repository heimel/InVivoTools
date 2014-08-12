function onlinemaps(avg,framezero_avg,n_x,fname,ledtest,record)
%ONLINEMAPS
%
%
% 2004-2014, Alexander Heimel
%

if nargin<6
    record = [];
end
if nargin<5
    ledtest=[];
end
if isempty(ledtest)
    ledtest=0;
end
if nargin<4
    fname=[];
end
if nargin<2
    framezero_avg=[];
end
if isempty(framezero_avg)
    framezero_avg=0*avg;
end
if nargin<3
    n_x=2;
end

params = oiprocessparams( record );
clip = params.single_condition_clipping;

%h1=figure;

n_stims=size(avg,3);
maxavg=-inf;
minavg=+inf;

% subtract zero-frames
if ledtest
    avg(:,:,2)=avg(:,:,2)-avg(:,:,1);
else
    logmsg('Subtracting baseline frames, i.e. going to Delta F or R');
    for stim=1:n_stims
        avg(:,:,stim)=avg(:,:,stim)-framezero_avg(:,:,stim);
    end
end

%avg=dccorrection(avg);
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
deviatie=std(avg(:));
gemiddelde=median(avg(:));

logmsg(['Clipping at median plus and minus ' num2str(clip) 'x the standard deviation']);
for stim=1:n_stims
    kaart=avg(:,:,stim);
    
    kaart(kaart(:)>gemiddelde+clip*deviatie) = gemiddelde+clip*deviatie;
    kaart(kaart(:)<gemiddelde-clip*deviatie) = gemiddelde-clip*deviatie;
    kaart = (kaart -(gemiddelde-clip*deviatie))/2./(gemiddelde+clip*deviatie);

    maxkaart=max(kaart(:));
    if maxkaart>maxavg
        maxavg=maxkaart;
    end
    minkaart=min(kaart(:));
    if minkaart<minavg
        minavg=minkaart;
    end
    maps{stim}=kaart;
end

if ~isempty(fname)
    filename=[fname 'single_cond*.png'];
    delete(filename);
    
    
    hh=figure;
    for stim=1:n_stims
        image(maps{stim}'*64);
        axis image;
        axis off;
        colormap gray
        filename=[fname 'single_cond' num2str(stim) '.png'];
        imwrite(uint8(round(255*maps{stim}')),filename,'png')
    end
    close(hh);
end


return





function Expsth( EVENT, data)
%Expsth( EVENT, data) 
%Usage call after Exsniptimes(EVENT, Trials) or Exd2(EVENT, Trials)
%data can be sign or snip data, 
%depending on EVENT.type = 'strms' or 'snips'

if strcmp(EVENT.type, 'strms')
    
   EvCode = EVENT.Myevent; 
   
   PSTH = nanmean(data,3);
%   PSTH = zeros(size(data{1},1), size(data,2));   
%    for i = 1 : size(data,2)
%        PSTH(:,i) = nanmean(data{i},2); %if cell array
%    end   
    Rt = strmatch(EvCode, {EVENT.strms(:).name} );


    sampf = EVENT.strms(Rt).sampf;
    Chn = size(PSTH,2);
    Xas = (1:size(PSTH,1))./sampf + EVENT.Start;
    SD = std(PSTH);
    MN = mean(PSTH);
    for i = 1:Chn
        if SD(i) > 0
            PSTH(:,i) = (PSTH(:,i) - MN(i))./(SD(i) * 5.0);
        end
    end
    Ysc = repmat((1:Chn), size(PSTH,1), 1);
    figure('Name',[EVENT.Mytank '_' EVENT.Myblock '_' EVENT.Myevent]) 
    plot(Xas, PSTH+Ysc)
    axis tight
   
elseif  strcmp(EVENT.type, 'snips') 


    binsz = 0.01;   %binsize in seconds
    nbins = floor(EVENT.Triallngth/binsz); %number of bins for trial length
    Xdist = (1:nbins).*binsz - binsz/2 + EVENT.Start;  %distribution of bins (centers) for histogram

    Nchans = size(data,1);
    Ntrials = size(data,2);

    PSTH = [];
    for i = 1:Nchans
        PSTH(i,:) = hist(data{i,1}, Xdist);
        for j = 2:Ntrials      
            PSTH(i,:) = PSTH(i,:) + hist(data{i,j}, Xdist);
        end
    end
    PSTH = PSTH.';
    PSTH = PSTH./(binsz * Ntrials);


    figure('Name',[EVENT.Mytank '_' EVENT.Myblock '_' EVENT.Myevent])
%Yas = repmat((0:Nchans-1)*Mx/2, nbins, 1);
    h = ceil(Nchans/4);
    for i = 1:Nchans
        subplot(4, h, i), plot(Xdist, PSTH(:,i)), axis tight, title(num2str(i))
    end
    
end

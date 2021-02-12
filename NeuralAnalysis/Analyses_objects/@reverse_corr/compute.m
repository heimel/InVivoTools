function newrc = compute(rc)

%  Part of the NeuralAnalysis package
%
%  NEWRC = COMPUTE(RC)
%
%  Compute the reverse correlation, receptive field maximum, and receptive
%  field rectangle.  These are returned via a call to GETOUTPUT.
%
%  See also:  REVERSE_CORR, GETOUTPUT

I = getinputs(rc);
p = getparameters(rc);
in = rc.internal;
c = rc.computations;

% did timing data or feature parameters change?
td = isempty(in.oldint)|(~eqlen(in.oldint,p.interval))|...
    isempty(in.oldtimeres)|(~eqlen(in.oldtimeres,p.timeres))|...
    isempty(in.oldfeature)|(~eqlen(in.oldfeature,p.feature));
if td % timing data difference
    offsets = p.interval(1):p.timeres:p.interval(2);
    if length(offsets)==1
        offsets = [p.interval(1) p.interval(2)];
    end
    n_bins = length(offsets)-1;
    in.edges = {};
    in.counts = {}; % in.counts{number of stimuli}{number of cells}(number of bins,number of frames)
    for m = 1:length(I.stimtime) % loop over stims
        frameTimes = I.stimtime(m).mti{1}.frameTimes;
        n_frames = length(frameTimes);
        % tmpa = matrix with on each row all frametimes plus the start of the bins in the columns
        % tmpb = matrix with on each row all frametimes and the end of the bins in the column
        tmpa = repmat(frameTimes,n_bins,1) + repmat(offsets(1:end-1)',1,n_frames);
        tmpb = repmat(frameTimes,n_bins,1) + repmat(offsets(2:end)',1,n_frames);
        mn = min(min(tmpa));
        mx = max(max(tmpb));
        for c = 1:length(I.spikes) % loop over cells? but only called for one cell 
            dat = get_data(I.spikes{c},[mn mx],2);
            in.counts{m}{c} = zeros(size(offsets,2)-1,n_frames); % will contain the number of spikes in each bin from each frame
            for o = 1:n_bins
                for dd = 1:length(dat) % loop over spikes
                    in.counts{m}{c}(o,:) = in.counts{m}{c}(o,:) + ((dat(dd)>=tmpa(o,:))&(dat(dd)<=tmpb(o,:)));
                end
            end % bin o
        end % cell c
    end % stim m
    [x,y,rect] = getgrid(I.stimtime(1).stim); % x,y are numbers of horzontal and vertical of patches

    fea = cell(length(I.spikes),length(offsets));
    rc_avg = zeros(length(I.spikes),n_bins,y,x,3); 
    rc_std = zeros(length(I.spikes),n_bins,y,x,3);
    rc_raw = zeros(length(I.spikes),n_bins,y,x,3);
    norms = zeros(length(I.spikes),n_bins);
    for m = 1:length(I.stimtime) % loop over stims
        [x,y,rect] = getgrid(I.stimtime(m).stim);
        v = getgridvalues(I.stimtime(m).stim);
        f = getstimfeatures(v,I.stimtime(m).stim,p,x,y,rect); % features
        for c = 1:length(I.spikes) % loop over cells
            for o = 1:n_bins
                [B,dummy,inds] = unique(in.counts{m}{c}(o,:)); %#ok<ASGLU>
                % i.e. in.counts{m}{c}(o,:) = B(inds)
                % B contains a vectors of all counts
                inds = inds(:)'; % necessary for change in unique behavior in MatlabR2014a
                
                indx = [];
                for jj = 1:length(B) % loop over all counts
                    if B(jj)~=0
                        for kk = 1:B(jj) % loop over spikes in count B(jj)
                            indx = cat(2,indx,find(inds==jj));
                        end
                    end
                end
                norms(c,o) = length(indx);
                try
                    fea{c,o} = cat(3,fea{c,o},f(:,:,indx,:));
                catch me
                    warning(['REVERSE_CORR/COMPUTE: ' me.message]);
                    newrc = rc;
                    return
                end
            end
        end % cell c
    end % stim m
    for c=1:length(I.spikes)
        for o=1:size(offsets,2)-1
            if ~isempty(fea{c,o})
                rc_avg(c,o,:,:,:) = mean(fea{c,o},3);
                rc_raw(c,o,:,:,:) =  sum(fea{c,o},3);
            end
        end
    end
    
    in.oldint = p.interval;
    in.oldtimeres = p.timeres;
    in.oldfeature = p.feature;
    
    r_c = struct('rc_avg',rc_avg,'rc_std',rc_std,'rc_raw',rc_raw,...
        'bins',{in.counts},'norms',norms);
else
    r_c = rc.computations.reverse_corr;
end

if p.crcpixel==-1  
    % max abs difference to p.feamean over bins for each pixel 
    % p.feamean is the mean color 
    % this code only works properly for gray!
    rr = max(r_c.rc_avg(1,:,:,:,:),[],5);  % take max color
    rr = squeeze(max(abs(rr - p.feamean),[],2)); % 

    % compute index of pixel with maximum abs difference to p.feamean
    [dum,p.crcpixel] = max(rr(:)); %#ok<ASGLU>
    in.selectedbin = p.crcpixel;
end

crcmethod = 1;

% if necessary, calculate continuous reverse correlation
centchanged = (in.crcpixel~=p.crcpixel)|(in.datatoview~=p.datatoview(1))|...
    (in.crctimeres~=p.crctimeres)|...
    (~eqlen(in.crctimeint,p.crctimeint))|...
    (~eqlen(in.crcproj,p.crcproj))|((crcmethod==2)&td);
if centchanged && (p.crcpixel>0)
    if exist('y','var')==0
        [x,y,rect] = getgrid(I.stimtime(p.datatoview(1)).stim);
        v = getgridvalues(I.stimtime(p.datatoview(1)).stim);
        f = getstimfeatures(v,I.stimtime(p.datatoview(1)).stim,p,x,y,rect);
    end
    x_ = fix((p.crcpixel-0.00001)/y) + 1;
    y_ = mod(p.crcpixel,y);
    if y_==0
        y_ = y;
    end
    fts = I.stimtime(p.datatoview(1)).mti{1}.frameTimes;
    if crcmethod==1
        F = reshape(f(y_,x_,:,:),[size(v,2) 3])-repmat(p.crcproj(1,:),size(v,2),1);
        % F has all RGB values of all frames for pixel [y_ x_] minus crcproj(1) color
        stats = F * p.crcproj(2,:)'; % apply projection of RGB to 1-D value
        
        mt = mean(diff(fts)); % mean timedifference between frames (s)
        
        % T starts at first frametime minus crctimeint start and ends at last
        % frametime plus crctimeint end
        T = (fts(1)+p.crctimeint(1)):p.crctimeres:(fts(end)+p.crctimeint(2));
        
        X = zeros(size(T)); % bins will be filled with stimuli
        for i=1:length(fts)-1
            strt = round((fts(i)-T(1))/p.crctimeres)+1;
            stp  = round((fts(i+1)-T(1))/p.crctimeres)+1;
            X(strt:stp) = stats(i);
        end
        Stp = min([stp+round(mt/p.crctimeres)+1 length(X)]);
        X(stp:Stp) = stats(end);
        
        % fill bins with spikes
        d = zeros(size(T)); % bins will be filled with spikes
        sts = get_data(I.spikes{p.datatoview(1)},[T(1) T(end)],2); % spiketimes
        pos = round((sts-T(1))/p.crctimeres)+1;
        % must use this form since bins may have more than one spike
        for i=1:length(pos)
            d(pos(i)) = d(pos(i))+1;
        end
        
        maxlags = ceil(max(abs(p.crctimeint))/p.crctimeres)*3;% times 3 to get more stdddev
        
        % compute cross-correlation between stimuli and spikes
        c1= xcorr(X,d,maxlags);
        % first half stimulus before spike, last half stimulus after spike
        
        c = c1 / (T(end)-T(1));
        % is equiv to: c = sum(d)/(T(end)-T(1)) * (c1/sum(d));
        
        lags = (-maxlags:1:maxlags)*p.crctimeres;
        lagbegin = findclosest(lags,p.crctimeint(1));
        lagend = findclosest(lags,p.crctimeint(2));
        c = c(lagbegin:lagend);
        lags = lags(lagbegin:lagend); % time stimulus - time spike (s)
        maxcalclags = ceil(max(abs(p.crccalcint))/p.crctimeres);
        calclags = (-maxcalclags:1:maxcalclags)*p.crctimeres;
        clagbegin = findclosest(calclags,p.crccalcint(1));
        clagend = findclosest(calclags,p.crccalcint(2));
        calclags = calclags(clagbegin:clagend);
    elseif crcmethod==2
        lags = p.interval(1):p.timeres:p.interval(2);
        lags = (lags(1:end-1) + lags(2:end))/2;
        h = r_c.rc_avg(p.datatoview(1),:,y_,x_,:);
        l = size(h,2);
        c = (reshape(h,[l 3])-repmat(p.crcproj(1,:),l,1))*p.crcproj(2,:)';
        c = c.*r_c.norms'/(p.timeres*length(fts));
        % if use this again need to fix calclags
    end
    [overlap,stddevinds] = setxor(lags,calclags); %#ok<ASGLU>
    [ov,otherinds] = intersect(lags,calclags); %#ok<ASGLU>

    cc = c(otherinds); % average projected feature value before and after spike
    
    stddev = sqrt(c(stddevinds)*c(stddevinds)'/length(stddevinds));
    [mm,peakind] = max(abs(cc)); %#ok<ASGLU> % location of peak
    onoff = cc(peakind)>0 ;    % onoff 1 = oncell, 0 = offcell, NaN = no signif STA
    if abs(cc(peakind))<3*stddev
        onoff = NaN;
        transience = NaN;
    else
        [mm,prepeakind] = max( (1-2*onoff)*cc(1:peakind-1));  %#ok<ASGLU>
        transience = -cc(prepeakind)/cc(peakind);
    end
    
    xcent = round(rect(1)+(x_-0.5)/x * (rect(3)-rect(1)));
    ycent = round(rect(2)+(y_-0.5)/y * (rect(4)-rect(2)));
    crc = struct('lags',lags,'crc',c,...
        'transience',transience,'onoff',onoff,...
        'pixel',p.crcpixel,'pixelcenter',[xcent ycent]);
    in.crctimeres = p.crctimeres;
    in.crcproj = p.crcproj;
    in.crctimeint = p.crctimeint;
    in.datatoview = p.datatoview(1);
    in.crcpixel = p.crcpixel;
elseif p.crcpixel<=0
    crc = [];
else
    crc = rc.computations.crc;
end

thecenter = 0;
thecenterrect = 0;
rc.internal = in;
rc.computations = struct('reverse_corr',r_c,...
    'center',thecenter,'center_rect',thecenterrect,'crc',crc);
newrc = rc;

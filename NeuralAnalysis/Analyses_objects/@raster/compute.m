function newra = compute(ra)
%  NEWRA = COMPUTE(RASTEROBJ)
%
%  Compute rasters, PSTH, and other internal data structures.  These are
%  returned via a call to GETOUTPUT.
%
%  See also:  RASTER, GETOUTPUT
%
% 200X Steve Van Hooser
% 200X-2019 Alexander Heimel

I = getinputs(ra);

p = getparameters(ra); % see RASTER for explanation of fields
% res [1x1] : time resolution of the analysis (in seconds)
% interval [1x2]: time around each trigger to show (in seconds)
% cinterval [1x2]: time around each trigger upon which to base computations 

trigs = I.triggers;

K = length(trigs);
cstart = cell(K,1); 
cstop = cell(K,1);
cind = cell(K,1); 
dt = NaN(K,1);
MI = NaN(K,1);
MX = NaN(K,1);
variation = cell(K,1); 
counts = cell(K,1); 
ansbins = cell(K,1);
bins = cell(K,1); 
edges = cell(K,1);


for k=1:K
    % cinterval variables
    if size(p.cinterval,1)>1
        kj = k; 
    else
        kj = 1;
    end
    if size(p.interval,1)>1
        ki = k; 
    else
        ki = 1;
    end
    mi = min(p.interval(ki,:)); 
    mx = max(p.interval(ki,:));
    edges{k} = (mi : p.res : mx); 
    bins{k} = edges{k}+p.res/2;
    
    mic = min(p.cinterval(kj,:));
    mxc = max(p.cinterval(kj,:));
    
    cstart{k} = round((mic-mi)/p.res)+1;
    cstop{k} = floor((mxc-mi)/p.res);
    
    if cstop{k}<cstart{k}
        cstop{k} = cstart{k}; % to at least have 1 bin
    end
    
    % force all number of bins to be of same size, if they are nearly so
    % to avoid rounding errors creating unequal bin numbers
    if k>1 && abs(cstop{k}-cstop{k-1})==1
        cstop{k} = cstop{k-1};
    end
    
    cind{k} = cstart{k}:cstop{k};
    
    dt(k) = mxc - mic;
    MI(k) = mi;
    MX(k) = mx;
    
    % answer variables
    variation{k} = zeros(1,cstop{k}-cstart{k}+1);
    counts{k} = zeros(1,cstop{k}-cstart{k}+1);
    ansbins{k} = bins{k}(cstart{k}:cstop{k});
end

ra.internals.cstart = cstart; 
ra.internals.cstop = cstop;

% answer variables
ncounts   = zeros(K,1);
ctdev     = zeros(K,1);

vals = cell(K,1);
N = zeros(K,1);
rast = cell(K,1);
fftvals = cell(K,1);
fftfreq = cell(K,1);
ccounts = cell(K,1);
nncounts = cell(K,1);
cvariation = cell(K,1);
fano = zeros(K,1);
fftmean = cell(K,1);
fftstd = cell(K,1);
fftstderr = cell(K,1);
for k=1:K
    if isempty(cind{k}) % no bins to use for computation
        continue
    end
    
    rast_x = []; rast_y = [];
    vals{k} = zeros(length(bins{k}),length(trigs{k}));
    fftvals{k} = zeros(length(cind{k}),length(trigs{k}));
    fftfreq{k} = (0:length(cind{k})-1)/(p.res*length(cind{k}));
    ccounts{k} = zeros(length(bins{k}),1);
    
    N(k) = length(trigs{k});
    for i=1:length(trigs{k})
        try
            g = get_data(I.spikes,[trigs{k}(i)+MI(k) trigs{k}(i)+MX(k)]);
        catch me
            g = []; 
            logmsg(['Could not get data: ' me.message]);
        end
        if ~isempty(g-trigs{k}(i))
            n = histc(g-trigs{k}(i),edges{k}); % fix for matlab 6
        else
            n = [];
        end
        if size(n,2)>size(n,1)
            n=n';
        end
        if ~isempty(n)
            fftvals{k}(:,i) = fft(n(cind{k}));
            % now convert to fourier coefficients
            fftvals{k}(1,i) = fftvals{k}(1,i)/(p.res*length(cind{k}));
            fftvals{k}(2:end,i) = (2/(p.res*length(cind{k})))*(real(fftvals{k}(2:end,i))-...
                sqrt(-1)*imag(fftvals{k}(2:end,i)));
            vals{k}(:,i) = n;
            ccounts{k} = ccounts{k} + n;
            rast_x = cat(1,rast_x,g-trigs{k}(i)); 
            rast_y = cat(2,rast_y,repmat(i,1,length(g)));
            zzzzz = sum(n(cind{k}));
            nncounts{k}(i) = zzzzz;
        else
            vals{k}(:,i) = 0;
            fftvals{k}(:,i) = 0;
            nncounts{k}(i) = 0;
        end
    end
    counts{k}(1,:) = ccounts{k}(cind{k})';
    ncounts(k) = sum(counts{k}(1,:));
    
    ctdev(k) = std(sum(vals{k}(cind{k},:)));
    %cvariation{k} = std(vals{k}')';
    cvariation{k} = std(vals{k},[],2);
        
    eps = 1e-10;
    fano(k) = mean((cvariation{k}.^2+eps) ./ (mean(vals{k}')' +eps));
    fftmean{k} = mean(fftvals{k}');
    fftstd{k} = std(fftvals{k}');
    fftstderr{k} = fftstd{k}/sqrt(N(k));
    if ~isempty(variation{k}) && N(k)>1
        variation{k}(1,:) = cvariation{k}(cind{k})';
    end
    rast{k} = [ rast_x'; rast_y]; 
    vals{k} = vals{k}(cind{k},:);
end

ra.internals.counts = ccounts;
ra.internals.variation = cvariation;
ra.internals.bins = bins;
ra.internals.fano = fano;

% ra.computations = struct('rast',{rast},'bins',{ansbins},...
%     'counts',{counts},'variation',{variation},...
%     'ncounts',ncounts./((dt.*N)'),'values',{vals},...
%     'ctdev',ctdev./dt','stderr',(ctdev./dt')./sqrt(N'),'N',N',...
%     'fftfreq',{fftfreq},'fftmean',{fftmean},'fftstd',{fftstd},...
%     'fftstderr',{fftstderr},'fftvals',{fftvals},'fano',fano);
ra.computations = struct('rast',{rast},'bins',{ansbins},...
    'counts',{counts},'variation',{variation},...
    'ncounts',ncounts./((dt.*N)),'values',{vals},...
    'ctdev',ctdev./dt,'stderr',(ctdev./dt)./sqrt(N),'N',N,...
    'fftfreq',{fftfreq},'fftmean',{fftmean},'fftstd',{fftstd},...
    'fftstderr',{fftstderr},'fftvals',{fftvals},'fano',fano);

newra = ra;

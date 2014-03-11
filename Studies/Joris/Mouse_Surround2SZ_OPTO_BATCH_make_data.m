%function whatever
close all
dbstop if error

doplot.condition_stats = 0;

%Analyse Flash to get CSD response
chnorder = 1:16;
spikeon = 0;
makedata =1;

%Data details
%library for extracting tdt data files
base = '/home/data/InVivo/Electrophys/Antigua_Cogent';

%addpath('D:\MouseLaminar\Analysis\TDT2ML')
datadir = fullfile(base,'Data');
logdir = fullfile(base,'StimuliandLogs');
suadir = 'D:\MouseLaminar\SUA\';
addpath(genpath('D:\MouseLaminar\Wavelet'))

info = log_surround2sz_opto;

%17 conditions, which can be grouped into 4 conds for each size
centconds = [2 3;4 5];
isoconds = [6 8;12 14];
crossconds = [7 9;13 15];
surronly = [10 11;16 17];
allconds(:,:,1) = centconds;
allconds(:,:,2) = isoconds;
allconds(:,:,3) = crossconds;
allconds(:,:,4) = surronly;

logmsg('centconds = [2 3;4 5];isoconds = [6 8;12 14];crossconds = [7 9;13 15];surronly = [10 11;16 17];');

mgISP = [];
mgISP2 = [];
mgISP2_det = [];
mgISP3 = [];
mgISP3_det = [];
mgMUA = [];
mgNMUA = [];
mgLFP = [];
mgPSTH = [];
mgNPSTH = [];
mgSNR = [];
mgSpkSNR = [];
details = [];
windetails = [];
w = 0;
makefilt = 0;
notch = 0;
figure
for N = 1:length(info)
    
    %Reversal?
    R = info(N).L4;
    
    %Includable channels, generally let's go for
    incchans = R-5:R+4;
    lowchan = R-5;
    highchan = R+4;
    
    Stem = info(N).name;
    Tankname = ['Mouse_',Stem];
    nblocks = length(info(N).surroundblocks);
    prevt = 0;
    MATBUF = [];
    Word = [];
    stimon = [];
    stimon4spk = [];
    clear EVENT,clear Env,clear Spikes
    
    %Average over blocks
    for B = 1:nblocks
        
        Blockno = num2str(info(N).surroundblocks(B));
        blocknames = ['Block-',Blockno];
        [pathstr,name,ext,versn] = fileparts(Tankname);
        
        %Load up the logfile for this session
        %Mh will make this into an automatic detection
        logfile = [Stem,'_B',Blockno];
        logfile = fullfile(logdir,logfile);
        load(logfile)
        MATBUF = [MATBUF;MAT];
        
        clear EVENT
        EVENT.Mytank = fullfile(datadir,Tankname);
        EVENT.Myblock = blocknames;
        %This will obtain the headers for the stream data (Env and LFP)
        %The word and stimulus bits (strons)
        %The trials structure (Trials)
        %And snips header
        
        EVENT = Exinf4_matt(EVENT);
        %EVENT = tdtread(EVENT);
        
        %Now we need to the ephys data
        EVENT.Myevent = 'Envl';  %must be a stream event
        EVENT.type = 'strms';   %must be a stream event
        EVENT.Triallngth =  2.5; %Total length
        EVENT.Start =      -1; %Time relative to stim bit
        EVENT.CHAN = [1:16];
        f = find(~isnan(EVENT.Trials.stim_onset)); %This is monkey related
        Trials = EVENT.Trials.stim_onset(f); %get stimulus onset times
        
        if nblocks > 1
            buf = Exd4(EVENT, Trials);   %This functions retrieves the data for each trial
            %Add to the env struct array
            for chn = chnorder
                for n = 1:length(Trials)
                    nn = n+prevt;
                    Env{chn,1}(:,nn) =  buf{chn}(:,n);
                end
            end
            
            EVENT.Myevent = 'LFPs';  %must be a stream event
            buf = Exd4(EVENT, Trials);
            %Add to the LFP struct array
            for chn = chnorder
                for n = 1:length(Trials)
                    nn = n+prevt;
                    Lfp{chn,1}(:,nn) =  buf{chn}(:,n);
                end
            end
            
            if spikeon
                EVENT.Myevent = 'Snip';  %must be a stream event
                EVENT.type = 'snips';   %must be a stream event
                %For 20120209 onwards this is fastsurround (1s exposure)
                buf = Exsnip1(EVENT, Trials);
                %Add to the spiks struct array
                for chn = chnorder
                    for n = 1:length(Trials)
                        nn = n+prevt;
                        Spikes{chn,nn} = buf{chn,n};
                    end
                end
                spchans = EVENT.snips.channels;
            end
            
            
            prevt = prevt+length(Trials);
        else
            Env = Exd4(EVENT, Trials);   %This functions retrieves the data for each trial
            
            EVENT.Myevent = 'LFPs';  %must be a stream event
            Lfp = Exd4(EVENT, Trials);
            
            if spikeon
                EVENT.Myevent = 'Snip';  %must be a stream event
                EVENT.type = 'snips';   %must be a stream event
                Spikes = Exsnip1(EVENT, Trials);
                %How many spike channels are there
                spchans = EVENT.snips.channels;
            end
            
        end
        
        %Sampling frequency
        Fs = EVENT.strms(1).sampf;
        
        if makefilt
            %Filters
            fc = [50 100 150];
            fw = 2;
            ord = 20;
            type = 'butter';
            for fnm = 1:length(fc)
                d = fdesign.bandstop('N,F3dB1,F3dB2',fw,fc(fnm)-fw,fc(fnm)+fw,Fs);
                eval(['Hd' num2str(fnm) ' = design(d,type);']);
            end
            makefilt = 0;
        end
        
        %Thesecare the times of the stimulus bits - the time of the
        %first stimulus...
        stimon = [stimon;EVENT.Trials.stim_onset-EVENT.Trials.stim_onset(1)];
        stimon4spk = [stimon4spk;EVENT.Trials.stim_onset];
        
        %Read in the word bit
        Word = [Word;EVENT.Trials.word];
        
        
        
    end
    
    %reassign MAT
    MAT = MATBUF;
    
    wn = find(isnan(Word));
    Word(wn) = [];
    
    %Save out the ITI
    ITI = stimon(2:1:end)-stimon(1:1:end-1);
    ITI = [NaN;ITI];
    
    %         if strmatch(Stem,'20120913') & B == 1
    %             MAT(1101:1104,:) = [];
    %         end
    
    if strmatch(Tankname,'Mouse_20130122') && Blockno == '9'
        Word(830:end) = [];
        MAT(830:end,:) = [];
    end
    
    if strmatch(Tankname,'Mouse_20130226') && Blockno == '11'
        Word = [30;Word];
        Word(1013:end) = [];
        stimon(1013:end) = [];
        stimon4spk(1013:end) = [];
        for chn = 1:16
            a = Env{chn};
            a(:,1013:end) = [];
            Env{chn} = a;
        end
    end
    
    
    if strmatch(Tankname,'Mouse_20130305') && Blockno == '7'
        MAT(1001:end,:) = [];
        Word(1001:end) = [];
        stimon(1001:end) = [];
        stimon4spk(1001:end) = [];
        for chn = 1:16
            a = Env{chn};
            a(:,1001:end) = [];
            Env{chn} = a;
        end
    end
    
    if strmatch(Tankname,'Mouse_20130305') && Blockno == '11'
        MAT(1022,:) = [];
    end
    
    if length(Word) ~= length(MAT)
        disp('Word/MAt length mismatch')
        a = 1;
        return
    end
    
    if sum(Word ~= MAT(:,4))
        disp('Word/MAt details mismatch')
        return
    end
    
    
    %Design notch - not used anymore
    
    %         if notch
    %             no = 2;
    %             wn = [48 52]./(Fs./2);
    %             [fb,fa] = butter(no,wn,'stop');
    %             Hd = dfilt.df2t(fb,fa);
    %         end
    
    %look for outliers%%%%%%%%%%%%
    for chn = chnorder
        
        
        
        %Look at mean across time
        a = Env{chn};
        %look at sample vals
        av = reshape(a,size(a,1).*size(a,2),1);
        %remove negative values
        av(av<0) = NaN;
        
        %remove outliers with double z-score removal
        zav = (av-nanmean(av))./nanstd(av);
        av(abs(zav)>4) = NaN;
        zav = (av-nanmean(av))./nanstd(av);
        av(abs(zav)>4) = NaN;
        
        %remove trials with extreme means
        a = reshape(av,size(a,1),size(a,2));
        amp = nanmean(a);
        zamp = (amp-mean(amp))./std(amp);
        a(:,abs(zamp)>4) = NaN;
        
        Env{chn} = a;
        
    end
    
    %read in sizes
    allwords = unique(Word);
    aws(N) = length(allwords)
    
    %Go through trialtypes and get neural data
    px = ((0:(Fs*EVENT.Triallngth))./Fs)+EVENT.Start;
    preT = find(px > -0.3 & px < 0);
    peakT = find(px > 0.05 & px < 0.25);
    anaT = find(px > 0 & px < 1);
    binwidth = 0.01;
    
    %PSTH timebase
    TB = EVENT.Start:binwidth:(EVENT.Start+EVENT.Triallngth);
    TB = TB(1:end-1);
    preTB = find(TB>-0.3 & TB<0);
    anaTB = find(TB>0 & TB<1);
    peakTB = find(TB>0.05 & TB<0.25);
    
    
    %this is the part that calculates the mean response to each size
    m = 0;
    clear TRIALLFP,clear TRIALMUA
    clear trialdetails
    for chn = chnorder
        
        ENV = Env{chn};
        FPT = Lfp{chn};
        
        if strmatch(Tankname,'Mouse_20130122') && Blockno == '9'
            ENV(:,830:end) = [];
        end
        
        meanMUA = [];
        meanLFP = [];
        SNR = [];
        statmua = [];
        statdets = [];
        
        for a = 1:length(allwords)
            
            %Find all the rows of the MAT matrix of a particular size
            f = find(Word == allwords(a));
            ntrials(a,N) = length(f);
            
            z = 0;
            MUA = [];
            LFP = [];
            %SUA, MUA, LFP
            Alltimes = [];
            for x = 1:length(f)  %repetitions of this size
                z = z+1;
                if spikeon
                    if chn <= spchans
                        buf = Spikes{chn,f(x)};
                        if ~isempty(buf)
                            T = [];
                            for u = 1:length(buf)
                                T(u) = buf(u).time;
                            end
                            Rast(z).T = T-stimon4spk(f(x));
                            Alltimes = [Alltimes,T-stimon4spk(f(x))];
                        end
                    end
                end
                v
                %Asign MUA data
                MUA(z,:) = ENV(:,f(x))';
            end
            
            %Makes PSTH, not currently baseline corrected
            if spikeon
                if ~isempty(Alltimes)
                    TB = EVENT.Start:binwidth:(EVENT.Start+EVENT.Triallngth);
                    PSTH = histc(Alltimes,TB)./binwidth./z;
                    TB = TB(1:end-1);
                    meanPSTH(a,:) = PSTH(1:end-1);
                    
                    %Make an SNR
                    %Number spikes in stimon time
                    PkSpk = length(find(Alltimes>0.05 & Alltimes < 0.35));
                    BkSpk = length(find(Alltimes<0));
                    RespSpk = PkSpk-BkSpk;
                    
                    BkSpkT = zeros(1,z);
                    for h = 1:length(Rast)
                        BkSpkT(h) = length(find(Rast(h).T<0));
                    end
                    SpkStd = std(BkSpkT);
                    
                    SpkSNR(a) = RespSpk./SpkStd;
                    
                else
                    meanPSTH(a,:) = ones(1,length(TB)).*NaN;
                    SpkSNR(a) = NaN;
                end
            end
            
            
            %Mean MUA
            meanMUA(a,:) = nanmean(MUA);
            
            %SAve out the MUA for individual channel stats
            statmua = [statmua;MUA];
            statdets = [statdets;ones(ntrials(a,N),1).*a];
            
            
            %Work out a SNR for this response
            %Currently the peak response divided by the std of the mean
            %baseline
            SNR(a) = mean(meanMUA(a,peakT))./std(meanMUA(a,preT));
            
        end
        
        %Measure baseline
        %USe baseline from the NONOPTO conditions
        base = nanmean(nanmean(meanMUA(1:17,preT),2));
        
        %Individual channel stats, subtract off across conditions
        %baseline
        statmua = statmua-base;
        
        %Normalise MUA to maximum smoothed MUA from teh centre only
        %condition.
        clear buf
        for a = 2:3
            buf(a) = max(smooth(meanMUA(a,peakT)-base,10));
        end
        mx = max(buf);
        normMUA = (meanMUA-base)./mx;
        
        %Normalize PSTH and subtract off baseline rate
        if spikeon
            
            %PSTH baseline
            TBbase = nanmean(nanmean(meanPSTH(1:17,preTB),2));
            
            clear buf
            h = 0;
            for a = 2:3
                h = h+1;
                buf(h) = max(smooth(meanPSTH(a,peakTB)-TBbase,4));
            end
            mx = max(buf);
            
            NPSTH = (meanPSTH-TBbase)./mx;
            
            mgPSTH = [mgPSTH;meanPSTH];
            mgNPSTH = [mgNPSTH;NPSTH];
            mgSpkSNR = [mgSpkSNR;SpkSNR'];
        end
        
        %Now add these mean values to the MEGA matrix
        mgMUA = [mgMUA;meanMUA];
        mgNMUA = [mgNMUA;normMUA];
        %             mgLFP = [mgLFP;meanLFP];
        mgSNR = [mgSNR;SNR'];
        
        %PEN no, channel number, adjusted channel number, cond
        details = [details;[repmat([N,chn,chn-R],length(allwords),1),[1:length(allwords)]']]; %#ok<*NBRAK>
        
        %STATS
        %Individual condition light on/off tests
        clear stat
        for a = 1:17
            f = find(statdets == a);
            on = nanmean(statmua(f,anaT),2);
            f = find(statdets == a+17);
            off = nanmean(statmua(f,anaT),2);
            
            %2 sample non-para test
            stat(a,1) = ranksum(on(~isnan(on)),off(~isnan(off)));
        end
        isp(chn,:,N) = stat';
        mgISP = [mgISP;[stat;NaN(17,1)]];
        
        %Grouped conditions
        q = 0;
        for a = 1:4
            for sz = 1:2
                q = q+1;
                f = find(statdets == allconds(sz,1,a) | statdets == allconds(sz,2,a));
                on = nanmean(statmua(f,anaT),2);
                f = find(statdets == allconds(sz,1,a)+17 | statdets == allconds(sz,2,a)+17);
                off = nanmean(statmua(f,anaT),2);
                
                %2 sample non-para test
                isp2(chn,q,N) = ranksum(on(~isnan(on)),off(~isnan(off)));
                mgISP2 = [mgISP2;isp2(chn,q,N)];
                mgISP2_det = [mgISP2_det;[N,chn,chn-R,q]];
            end
        end
        
        %Does light affect baseline?
        f = find(statdets < 18);
        off = nanmean(statmua(f,preT),2);
        f = find(statdets > 17);
        on = nanmean(statmua(f,preT),2);
        mgISP3 = [mgISP3;ranksum(on(~isnan(on)),off(~isnan(off)))];
        mgISP3_det = [mgISP3_det;[N,chn,chn-R]];
        
        
    end
    
    %End of channels
    subplot(6,4,N),imagesc(isp2(:,:,N)<0.05)
    
    if 0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Here we can do the LFP analysis
        %MEasure power in certain time range
        beg = 0.1; %#ok<*UNRCH>
        fin = 0.5;
        tf = find(px >= beg & px <= fin);
        
        %Build up the 3d data (samples x chans x trials)
        z = 0;
        clear RDS
        for chn = incchans
            z = z+1;
            f = find(trialdetails(:,1) == chn & trialdetails(:,2) == 9);
            slfp = TRIALLFP(f,:);
            %Subtract off mean LFP/MUA?
            slfp = slfp-repmat(nanmean(slfp),size(slfp,1),1);
            RDS(:,z,:) = slfp';
        end
        RDS = sinfit50(RDS,Fs);
        [TAChn frq] = GetPowerWavelet(RDS);
        frqs = frq.*Fs;
        
        %Save out for averaging
        TFP(:,:,N) = TAChn;
        FRQ(N,:) = frqs;
        
        if 0
            %%PLOTS
            figure; surf(px(tf),Fs*frq,mean(TAChn(:,tf,:),3),'EdgeColor','none')
            xlabel('Time from stimulus oNSaet (ms)');
            set(gca, 'yscale', 'log', 'ytick', [5.0 10.0 25.0 50.0 100.0 150.0])
            ylabel('Frequencies (Hz)');
            set(gca,'FontSize',22);
            axis tight; axis square; view(0,90);
            % shading interp
            
            % Line plot of LFP power in modulation period
            figure; plot(Fs*frq,squeeze(mean(mean(TAChn(:,tf,:),3),2))')
            xlabel('Frequencies (Hz)');
            set(gca, 'xscale', 'log', 'xtick', [5.0 10.0 25.0 50.0 100.0 150.0])
            ylabel('LFP Power');
            set(gca,'FontSize',22);
            axis tight; axis square; box off;
        end
        
        %Get power in certain bands
        Range = [1 3;8 12;13 19;30 80];
        for r = 1:size(Range,1)
            f = find(Fs*frq >= Range(r,1) & Fs*frq <= Range(r,2));
            Power(N,r) = mean(squeeze(mean(mean(TAChn(f,tf,:),3),2)));
        end
        Power
        
        N
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end  %On to next dataset

%First data pres: SurroundDataOpto_1

logmsg('Temporarily not saving');
% save SurroundDataOpto_1


function whatever

dbstop if error

%Analyse Flash to get CSD response
chnorder = [1:16];
spikeon = 0;
makedata =0;

%Data details
%library for extracting tdt data files
base = '/home/data/InVivo/Electrophys/Antigua_Cogent';

%addpath('D:\MouseLaminar\Analysis\TDT2ML')
datadir = 'D:\MouseLaminar\Data\';
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


if makedata
    
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
        
        if strmatch(Tankname,'Mouse_20130122') & Blockno == '9'
            Word(830:end) = [];
            MAT(830:end,:) = [];
        end
        
        if strmatch(Tankname,'Mouse_20130226') & Blockno == '11'
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
        
        
        if strmatch(Tankname,'Mouse_20130305') & Blockno == '7'
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
        
        if strmatch(Tankname,'Mouse_20130305') & Blockno == '11'
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
        px = ((0:(Fs.*EVENT.Triallngth))./Fs)+EVENT.Start;
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
            
            if strmatch(Tankname,'Mouse_20130122') & Blockno == '9'
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
            details = [details;[repmat([N,chn,chn-R],length(allwords),1),[1:length(allwords)]']];
            
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
            beg = 0.1;
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
else
    
    load SurroundDataOpto_1
end % makedata

% if makedata
%     return
% end

gt = find(px >= 0 & px <= 1);
cutoff = 0;

%Color
szcol = [0 0 0;0.5 0.5 0.5;0 0 0;0 1 1;0 0 1;1 0 0;1 0.6 0.2;1 0 0;1 0.6 0.2;0 1 0;0.2 0.8 0.2;1 0 0;1 0.6 0.2;1 0 0;1 0.6 0.2;0 1 0;0.2 0.8 0.2];
surrcol = [0 0 0;0.5 0.5 0.5;1 0 0;1 0.6 0.2;0 1 0];

incchans = [-5:1:4];
nchans = length(incchans);


%Plot otu significance effetcs
%FOR COND BY COND
figure
stat = NaN(10,17,N);
for n = 1:N
    for chn = 1:length(incchans)
        for a = 1:17
            f = find(details(:,3) == incchans(chn) & details(:,4) == a & details(:,1) == n);
            if ~isempty(f)
                stat(chn,a,n) = mgISP(f)<0.05;
            end
        end
    end
    subplot(6,4,n),imagesc(flipud(stat(:,:,n)))
end
figure,imagesc(flipud(nanmean(stat,3)))
title('Individual condition stats')

%FOR GROUPED CONDS
figure
stat = NaN(10,8,N);
for n = 1:N
    for chn = 1:length(incchans)
        for a = 1:8
            %N,chn,chn-R,cond
            f = find(mgISP2_det(:,3) == incchans(chn) & mgISP2_det(:,4) == a & mgISP2_det(:,1) == n);
            if ~isempty(f)
                stat(chn,a,n) = mgISP2(f)<0.05;
            end
        end
    end
    subplot(6,4,n),imagesc(flipud(stat(:,:,n)))
end
figure,imagesc(flipud(nanmean(stat,3)))
title('Grouped condition stats')


%Raw light indiced changes in response
figure
for n = 1:N
    clear Mn
    %Get mean responses to all conds
    tm = find(px>0 & px<1);
    for o = 1:2
        for chn = 1:length(incchans)
            for a = 1:17
                %PEN no, channel number, adjusted channel number, cond
                cond = a+((o-1)*17);
                f = find(details(:,3) == incchans(chn) & details(:,4) == cond & details(:,1) == n);
                %Take mean actitivity caross pens
                Mn(chn,a,o) = nanmean(nanmean(mgNMUA(f,tm)));
                Mns(chn,a,o) = std(nanmean(mgNMUA(f,tm)))./sqrt(length(f));
            end
        end
    end
    %Changes ion raw data
    change = Mn(:,:,2)-Mn(:,:,1);
    subplot(6,4,n),bar(incchans,change);
    title('Light induced changes in raw data')
    %     legend({'Spont','Sz 1, Ori 1','Sz 1, Ori 2','Sz 2, Ori 1','Sz 2, Ori 2'})
    
end

%SAme for PSTH, (also include SNR in the equation-not done yet)
figure
for n = 1:N
    clear Mn
    %Get mean responses to all conds
    tbm = find(TB>0 & TB<1);
    for o = 1:2
        for chn = 1:length(incchans)
            for a = 1:17
                %PEN no, channel number, adjusted channel number, cond
                cond = a+((o-1)*17);
                f = find(details(:,3) == incchans(chn) & details(:,4) == cond & details(:,1) == n);
                %Take mean actitivity caross pens
                Mn(chn,a,o) = nanmean(nanmean(mgNPSTH(f,tbm)));
                Mns(chn,a,o) = std(nanmean(mgNPSTH(f,tbm)))./sqrt(length(f));
            end
        end
    end
    %Changes ion raw data
    change = Mn(:,:,2)-Mn(:,:,1);
    subplot(6,4,n),bar(incchans,change);
    title('Light induced changes in raw data - PSTH')
    %     legend({'Spont','Sz 1, Ori 1','Sz 1, Ori 2','Sz 2, Ori 1','Sz 2, Ori 2'})
    
end

%Exclude any PENS?
%MAe another col of detauils (col 5) which contains an inclusion flag
exclude = [1 2 14 19];
details(:,5) = ones(size(details,1),1);
for e = 1:length(exclude)
    f = find(details(:,1) == exclude(e));
    details(f,5) = 0;
end


%PSTHS
legtext = ['Cent ';'Iso  ';'Cross';'Surr '];
for sz = 1:2
    figure
    for a = 1:4 %cent,iso,cross
        %size, inccchans
        cn1 = allconds(sz,1,a);
        cn2 = allconds(sz,2,a);
        f = find(details(:,5) & (details(:,4) == cn1 | details(:,4) == cn2 )  & (details(:,3) >= 0 & details(:,3) <= 2));
        buf = mean(mgNMUA(f,:));
        bufs = std(mgNMUA(f,:))./sqrt(length(f));
        h = errorbar(px(2:end),smooth(buf,5),smooth(bufs,5));
        errorbar_tick(h,0,'units')
        set(h,'Color',surrcol(a+1,:))
        hold on
    end
    legend(legtext);
    xlim([0 0.3])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get the mean response to allconditons
%Then plot out comparisons
incchans = [-5:4];
clear Mn
tm = find(px>0 & px<0.5);
for o = 1:2
    for chn = 1:length(incchans)
        for a = 1:17
            %PEN no, channel number, adjusted channel number, cond
            cond = a+((o-1)*17);
            f = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond);
            %Take mean actitivity caross pens
            Mn(chn,a,o) = nanmean(nanmean(mgNMUA(f,tm)));
            Mns(chn,a,o) = std(nanmean(mgNMUA(f,tm)))./sqrt(length(f));
        end
    end
end

%plot out raw data
figure,subplot(2,1,1),bar(incchans,Mn(:,1:5,1));
% hold on,errorbar(incchans,Mn(:,2:5,1),Mns(:,2:5,1))
title('Responses to center only condition')
subplot(2,1,2),bar(incchans,Mn(:,1:5,2))
% hold on,errorbar(incchans,Mn(:,2:5,2),Mns(:,2:5,2))
legend({'Spont','Sz 1, Ori 1','Sz 1, Ori 2','Sz 2, Ori 1','Sz 2, Ori 2'})
title('Normalized data')

%Spontaneuos activity
figure,errorbar(incchans,Mn(:,1,1),Mns(:,1,1),'k')
hold on,errorbar(incchans,Mn(:,1,2),Mns(:,1,2),'b')

%Changes ion raw data
change = Mn(:,1:5,2)-Mn(:,1:5,1);
figure,bar(incchans,change);
title('Light induced changes in normalized data (Centre only)')
legend({'Spont','Sz 1, Ori 1','Sz 1, Ori 2','Sz 2, Ori 1','Sz 2, Ori 2'})

% %Plot out normalized data
% figure,subplot(2,1,1),bar(incchans,Mn(:,2:5,1)./repmat(Mn(:,2,1),1,4))
% title('Responses to center only condition')
% subplot(2,1,2),bar(incchans,Mn(:,2:5,2)./repmat(Mn(:,2,1),1,4))
% legend({'Sz 1, Ori 1','Sz 1, Ori 2','Sz 2, Ori 1','Sz 2, Ori 2'})
% title('Normalized to no opto cond 1')

%Any effect on size tuniong?
%Small sz cent, large sz cent, iso
small = squeeze(mean(Mn(:,2:3,:),2));
large = squeeze(mean(Mn(:,4:5,:),2));
iso = squeeze(mean(Mn(:,[6 8 12 14],:),2));
small_s = squeeze(mean(Mns(:,2:3,:),2));
large_s = squeeze(mean(Mns(:,4:5,:),2));
iso_s = squeeze(mean(Mns(:,[6 8 12 14],:),2));
figure
title('Size tuning effects')
errorscatter(incchans',[small,large,iso],[small_s,large_s,iso_s])

%Let's make a more sophisticado version
clear Mn
tm = find(px>0 & px<0.5);
szconds = [2 3 4 5;6 8 12 14];
clear large,clear small
for o = 1:2
    for chn = 1:length(incchans)
        %PEN no, channel number, adjusted channel number, cond
        %SMALL SIZES
        buf = [];
        for j = 1:4
            cond = szconds(1,j)+((o-1)*17);
            f = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond);
            buf = [buf;nanmean(mgNMUA(f,tm))];
        end
        small = nanmean(nanmean(buf));
        %ISO SIZES
        buf = [];
        for j = 1:4
            cond = szconds(2,j)+((o-1)*17);
            f = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond);
            buf = [buf;nanmean(mgNMUA(f,tm))];
        end
        large = nanmean(nanmean(buf));
        
        SS(chn,o) = small-large;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get the mean response to the grouped conditions
%Then plot out comparisons
tm = find(px>0 & px<0.5);
for o = 1:2
    for sz = 1:2
        for chn = 1:length(incchans)
            for a = 1:4
                %PEN no, channel number, adjusted channel number, cond
                conds = allconds(sz,:,a)+((o-1).*17);
                f = find(details(:,5) & details(:,3) == incchans(chn) & (details(:,4) == conds(1) | details(:,4) == conds(2)));
                sp = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == 1);
                %Take mean actitivity across pens
                Gn(chn,a,sz,o) = nanmean(nanmean(mgNMUA(f,tm)));
                Gns(chn,a,sz,o) = std(nanmean(mgNMUA(f,tm)))./sqrt(length(f));
                %Take mean actitivity across pens subtracting off spont
                GnSp(chn,a,sz,o) = nanmean(nanmean(mgNMUA(f,tm))-nanmean(mgNMUA(sp,tm)));
                GnSps(chn,a,sz,o) = std(nanmean(mgNMUA(f,tm))-nanmean(mgNMUA(sp,tm)))./sqrt(length(f));
            end
        end
    end
end

%ERRORBAR PLOTS
%SIZE 1
figure,
subplot(2,1,1)
col = [0 0 0;0.5 0.5 0.5;1 0 0;1 0.5 0.5;1 0.5 0;1 0.8 0.5];
vec = [Gn(:,1,1,1),Gn(:,1,1,2),Gn(:,2,1,1),Gn(:,2,1,2),Gn(:,3,1,1),Gn(:,3,1,2)];
vecse = [Gns(:,1,1,1),Gns(:,1,1,2),Gns(:,2,1,1),Gns(:,2,1,2),Gns(:,3,1,1),Gns(:,3,1,2)];
errorscatter(incchans,vec,vecse,col)
title('Effects of light on Center,Iso,Cross, no spont sub, size 1')
%SIZE 2
subplot(2,1,2)
col = [0 0 0;0.5 0.5 0.5;1 0 0;1 0.5 0.5;1 0.5 0;1 0.8 0.5];
vec = [Gn(:,1,2,1),Gn(:,1,2,2),Gn(:,2,2,1),Gn(:,2,2,2),Gn(:,3,2,1),Gn(:,3,2,2)];
vecse = [Gns(:,1,2,1),Gns(:,1,2,2),Gns(:,2,2,1),Gns(:,2,2,2),Gns(:,3,2,1),Gns(:,3,2,2)];
errorscatter(incchans,vec,vecse,col)
title('Effects of light on Center,Iso,Cross, no spont sub, size 2')

%%ALSO WITH SPONT SUBTRACTED
%SIZE 1
figure,
subplot(2,1,1)
col = [0 0 0;0.5 0.5 0.5;1 0 0;1 0.5 0.5;1 0.5 0;1 0.8 0.5];
vec = [GnSp(:,1,1,1),GnSp(:,1,1,2),GnSp(:,2,1,1),GnSp(:,2,1,2),GnSp(:,3,1,1),GnSp(:,3,1,2)];
vecse = [GnSps(:,1,1,1),GnSps(:,1,1,2),GnSps(:,2,1,1),GnSps(:,2,1,2),GnSps(:,3,1,1),GnSps(:,3,1,2)];
errorscatter(incchans,vec,vecse,col)
title('Effects of light on Center,Iso,Cross,spont sub, size 1')
%SIZE 2
subplot(2,1,2)
col = [0 0 0;0.5 0.5 0.5;1 0 0;1 0.5 0.5;1 0.5 0;1 0.8 0.5];
vec = [GnSp(:,1,2,1),GnSp(:,1,2,2),GnSp(:,2,2,1),GnSp(:,2,2,2),GnSp(:,3,2,1),GnSp(:,3,2,2)];
vecse = [GnSps(:,1,2,1),GnSps(:,1,2,2),GnSps(:,2,2,1),GnSps(:,2,2,2),GnSps(:,3,2,1),GnSps(:,3,2,2)];
errorscatter(incchans,vec,vecse,col)
title('Effects of light on Center,Iso,Cross,spont sub, size 2')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate changes in mod
%This calculates (Cross-Iso] at the level of individual pens then takes the
%mean and std of teh difference.
%Also plot the timecourse of teh modulation
tm = find(px>0 & px<0.5);
optocol = [0 0 0;0 0.3 0.9];
fillcol = [0.7 0.7 0.7;0.4 0.7 1];
ci_stat = [];
ci_det = [];
cent_stat = [];
 iso_stat = [];
            cross_stat = [];
for sz = 1:2
    figure
    for o = 1:2
        for chn = 1:length(incchans)
            %Cross - Iso at the individual chan level
            %Should pre-avereage across orientations
            a = 3;
            conds = allconds(sz,:,a)+((o-1).*17);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            cross = (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            cst = mean(cross,2);
            
            a = 2;
            conds = allconds(sz,:,a)+((o-1).*17);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            iso = (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            ist = mean(iso,2);
            
            a = 1;
            conds = allconds(sz,:,a)+((o-1).*17);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            cent= (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            cnst = mean(cent,2);
            
            
            %statistics, the mean paired diff per chan, per pen
            cent_stat = [cent_stat;cnst];
            iso_stat = [iso_stat;ist];
            cross_stat = [cross_stat;cst];
            ci_stat = [ci_stat;cst-ist];
            ci_det = [ci_det;repmat([o,chn,sz],length(cst),1)];
            
            %Take mean actitivity across pens
            CIdf(chn,sz,o) = nanmean(nanmean(cross-iso));
            CIdfs(chn,sz,o) = std(nanmean(cross-iso,2))./sqrt(size(iso,1));
            
            %For ccent ionly
            CNTdf(chn,sz,o) = nanmean(nanmean(cent));
            CNTdfs(chn,sz,o) = std(nanmean(cent,2))./sqrt(size(cent,1));
            
             %For iso ionly
            ISOdf(chn,sz,o) = nanmean(nanmean(iso));
            ISOdfs(chn,sz,o) = std(nanmean(iso,2))./sqrt(size(iso,1));
            
             %For ross ionly
            CRSdf(chn,sz,o) = nanmean(nanmean(cross));
            CRSdfs(chn,sz,o) = std(nanmean(cross,2))./sqrt(size(cross,1));
            
            %Subtract and plot timecourse%%%%%%%%%%%%%%%
            subplot(2,5,chn)
            sub = nanmean(cross-iso);
            %Optional SE fill
            subse = nanstd(cross-iso)./sqrt(size(cross,1));
            fillx = [px(tm),fliplr(px(tm))];
            filly = [mattsmooth(sub+subse,20),fliplr(mattsmooth(sub-subse,20))];
            %             fill(fillx,filly,fillcol(o,:))
            hold on
            h = plot(px(tm),mattsmooth(sub,20));
            set(h,'Color',optocol(o,:))
            
            title(['Size ',num2str(sz),' - Cross-Iso'])
            xlim([0 0.5])
            
        end
    end
end

%Changes in modulation%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%No errorbars yet%%%%%%%%%%%%%%%
%Gn = [cent,iso,cross,surr]
off = CIdf(:,1,1);
on = CIdf(:,1,2);
offs = CIdfs(:,1,1);
ons = CIdfs(:,1,2);
col = [[0,0,0];[0,0.5,1]];
figure,subplot(2,1,1),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 1, change in modualtion')
off = CIdf(:,2,1);
on = CIdf(:,2,2);
offs = CIdfs(:,2,1);
ons = CIdfs(:,2,2);
subplot(2,1,2),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 2, change in modualtion')


%Change in centre response
off = CNTdf(:,1,1);
on = CNTdf(:,1,2);
offs = CNTdfs(:,1,1);
ons = CNTdfs(:,1,2);
col = [[0,0,0];[0,0.5,1]];
figure,subplot(2,1,1),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 1, change in cent only')
off = CNTdf(:,2,1);
on = CNTdf(:,2,2);
offs = CNTdfs(:,2,1);
ons = CNTdfs(:,2,2);
subplot(2,1,2),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 2, change in cent only')

%Change in centre response
off = ISOdf(:,1,1);
on = ISOdf(:,1,2);
offs = ISOdfs(:,1,1);
ons = ISOdfs(:,1,2);
col = [[0,0,0];[0,0.5,1]];
figure,subplot(2,1,1),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 1, change in iso only')
off = ISOdf(:,2,1);
on = ISOdf(:,2,2);
offs = ISOdfs(:,2,1);
ons = ISOdfs(:,2,2);
subplot(2,1,2),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 2, change in iso only')

%Change in centre response
off = CRSdf(:,1,1);
on = CRSdf(:,1,2);
offs = CRSdfs(:,1,1);
ons = CRSdfs(:,1,2);
col = [[0,0,0];[0,0.5,1]];
figure,subplot(2,1,1),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 1, change in cross only')
off = CRSdf(:,2,1);
on = CRSdf(:,2,2);
offs = CRSdfs(:,2,1);
ons = CRSdfs(:,2,2);
subplot(2,1,2),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 2, change in cross only')




%STATISTICS and scatter plot
clear p
figure
cvind = jet(length(incchans))
for sz = 1:2
    subplot(1,2,sz)
    for chn = 1:length(incchans)
        off = ci_stat(ci_det(:,3) == sz & ci_det(:,2) == chn & ci_det(:,1) == 1);
        on = ci_stat(ci_det(:,3) == sz & ci_det(:,2) == chn & ci_det(:,1) == 2);
        [h,p(sz,chn)] = ttest(off-on);
        [h,p2(sz,chn)] = ttest(off(off>0)-on(off>0));
        scatter(off,on,[],cvind(chn,:),'filled')
        hold on
    end
    plot(-0.2:0.1:0.3,-0.2:0.1:0.3)
    xlim([-0.2 0.3])
    ylim([-0.2 0.3])
    title(['Modulation, light off vs light on, Size = ',num2str(sz)])
end




%%%CENT vs CROSS
%This calculates (Cross-Iso] at the level of individual pens then takes the
%mean and std of teh difference.
%Also plot the timecourse of teh modulation
tm = find(px>0 & px<0.5);
optocol = [0 0 0;0 0.3 0.9];
fillcol = [0.7 0.7 0.7;0.4 0.7 1];
ci_stat = [];
ci_det = [];
for sz = 1:2
    figure
    for o = 1:2
        for chn = 1:length(incchans)
            %Cross - Iso at the individual chan level
            %Should pre-avereage across orientations
            a = 1;
            conds = allconds(sz,:,a)+((o-1).*17);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            cross = (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            cst = mean(cross,2);
            
            a = 3;
            conds = allconds(sz,:,a)+((o-1).*17);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            iso = (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            ist = mean(iso,2);
            
            %statistics, the mean paired diff per chan, per pen
            ci_stat = [ci_stat;cst-ist];
            ci_det = [ci_det;repmat([o,chn,sz],length(cst),1)];
            
            %Take mean actitivity across pens
            CIdf(chn,sz,o) = nanmean(nanmean(cross-iso));
            CIdfs(chn,sz,o) = std(nanmean(cross-iso,2))./sqrt(size(iso,1));
            
            %Subtract and plot timecourse%%%%%%%%%%%%%%%
            subplot(2,5,chn)
            sub = nanmean(cross-iso);
            %Optional SE fill
            subse = nanstd(cross-iso)./sqrt(size(cross,1));
            fillx = [px(tm),fliplr(px(tm))];
            filly = [mattsmooth(sub+subse,20),fliplr(mattsmooth(sub-subse,20))];
            %             fill(fillx,filly,fillcol(o,:))
            hold on
            h = plot(px(tm),mattsmooth(sub,20));
            set(h,'Color',optocol(o,:))
            
            title(['Size ',num2str(sz),' - Centre-Cross'])
            xlim([0 0.5])
            
        end
    end
end

%Changes in modulation%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%No errorbars yet%%%%%%%%%%%%%%%
%Gn = [cent,iso,cross,surr]
off = CIdf(:,1,1);
on = CIdf(:,1,2);
offs = CIdfs(:,1,1);
ons = CIdfs(:,1,2);
col = [[0,0,0];[0,0.5,1]];
figure,subplot(2,1,1),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 1, change in modualtion')
off = CIdf(:,2,1);
on = CIdf(:,2,2);
offs = CIdfs(:,2,1);
ons = CIdfs(:,2,2);
subplot(2,1,2),errorscatter(incchans,[off,on],[offs,ons],col)
title('Size 2, change in modualtion')


%Plot all ocnds
col = [0 0 0;0.5 0.5 0.5;0 0 0;0 1 1;0 0 1;...
    1 0 0;1 0.6 0.2;1 0 0;1 0.6 0.2;0 1 0;0.2 0.8 0.2;...
    1 0 0;1 0.6 0.2;1 0 0;1 0.6 0.2;0 1 0;0.2 0.8 0.2;...
    1 0 1;1 0 1;1 0 1;1 0 1];
col = [col;col];
 px = ((1:(Fs.*EVENT.Triallngth))./Fs)+EVENT.Start;
if 0
    %Plot out the centre only conditions
    % tm = find(px(tf)>0 & px(tf)<1)
   
    for s = 1:2
        figure
        for chn = 1:length(incchans)
            %orienttion
            subplot(3,4,chn)
            for a = [1 2 3 4 5]
                cond = a+((s-1)*17);
                f = find(details(:,3) == incchans(chn) & details(:,4) == cond);
                %Take mean actitivity caross pens
                buf = nanmean(mgNMUA(f,:));
                
                h = plot(px,mattsmooth(buf,10));
                set(h,'Color',col(a,:))
                hold on
            end
            xlim([-1 1.4])
        end
        legend({'Spont','Sz 1, Ori 1','Sz 1, Ori 2','Sz 2, Ori 1','Sz 2, Ori 2'})
    end
end

if 0
    %Plot out ISO condition with light on/light off overlaid
    figure
    for chn = 1:length(incchans)
        %orienttion
        subplot(2,5,chn)
        
        %Plot iso
        s = 1;
        cond1 = 6+(17*(s-1));
        cond2 = 8+(17*(s-1));
        cond3 = 12+(17*(s-1));
        cond4 = 14+(17*(s-1));
        f = find(details(:,5) & details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10));
        set(h,'Color',col(6,:))
        hold on
        
        %Plot iso (size irrelevant here) (blue)
        s = 2;
        cond1 = 6+(17*(s-1));
        cond2 = 8+(17*(s-1));
        cond3 = 12+(17*(s-1));
        cond4 = 14+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10));
        set(h,'Color',col(5,:))
        
        xlim([-1 1.4])
        ylim([-0.3 0.8])
    end
    
    %DO SAME for PSTH
    figure
    for chn = 1:length(incchans)
        %orienttion
        subplot(2,5,chn)
        
        %Plot iso
        s = 1;
        cond1 = 6+(17*(s-1));
        cond2 = 8+(17*(s-1));
        cond3 = 12+(17*(s-1));
        cond4 = 14+(17*(s-1));
        f = find(details(:,5) & details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = nanmean(mgNPSTH(f,:));
        h = plot(TB,mattsmooth(buf,4));
        set(h,'Color',col(6,:))
        hold on
        
        %Plot iso (size irrelevant here) (blue)
        s = 2;
        cond1 = 6+(17*(s-1));
        cond2 = 8+(17*(s-1));
        cond3 = 12+(17*(s-1));
        cond4 = 14+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = nanmean(mgNPSTH(f,:));
        h = plot(TB,mattsmooth(buf,4));
        set(h,'Color',col(5,:))
        
        xlim([-1 1.4])
        ylim([-0.3 0.8])
    end
end


%Conditions ar eas follows:
%1 - Baseline
%2 - ORI 1 SZ 1 Centre Only (grey)
%3 - ORI 2 SZ 1 Centre Only (blue)
%4 - ORI 1 SZ 2 Centre Only (cyan)
%5 - ORI 2 SZ 2 Centre Only (yellow)

%6 -  ORI 1 SZ 1 centre/surround (iso)   (red)
%7 -  ORI 1 SZ 1 centre/surround (cross) (orange)
%8 -  ORI 2 SZ 1 centre/surround (iso)   (red)
%9 -  ORI 2 SZ 1 centre/surround (cross) (orange)
%10 - ORI 1 SZ 1 (Surround only)
%11 - ORI 2 SZ 1 (Surround only)

%12 -  ORI 1 SZ 2 centre/surround (iso)
%13 -  ORI 1 SZ 2 centre/surround (cross)
%14 -  ORI 2 SZ 2 centre/surround (iso)
%15 -  ORI 2 SZ 2 centre/surround (cross)
%16 -  ORI 1 SZ 2 (Surround only)
%17 -  ORI 2 SZ 2 (Surround only)

if 0
    %Compare cross conditions across light
    for n = 1:N
        figure
        ccol = [0 0 0;0 0.3 1];
        for chn = 1:length(incchans)
            subplot(2,5,chn)
            for o = 1:2
                %Plot cross
                spont = 1+(17*(o-1));
                cond1 = 13+(17*(o-1));
                cond2 = 15+(17*(o-1));
                f = find(details(:,1) == n & details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
                f2 = find(details(:,1) == n & details(:,3) == incchans(chn) & details(:,4) == spont);
                buf = mean(mgNMUA(f,:))-mean(mgNMUA(f2,:));
                %             bufs = std(mgNMUA(f,:))./sqrt(length(f));
                %             h = errorbar(px,mattsmooth(buf,10),mattsmooth(bufs,10));
                %             set(h,'Color',ccol(o,:))
                h = plot(px,mattsmooth(buf,10));
                set(h,'Color',ccol(o,:))
                hold on
            end
            xlim([-1 1.4])
            title(['PEN = ',num2str(n)])
        end
    end
    
    %Same for PSTH
    for n = 1:N
        figure
        ccol = [0 0 0;0 0.3 1];
        for chn = 1:length(incchans)
            subplot(2,5,chn)
            for o = 1:2
                %Plot cross
                spont = 1+(17*(o-1));
                cond1 = 13+(17*(o-1));
                cond2 = 15+(17*(o-1));
                f = find(details(:,5) & details(:,1) == n & details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
                f2 = find(details(:,5) & details(:,1) == n & details(:,3) == incchans(chn) & details(:,4) == spont);
                buf = mean(mgNPSTH(f,:))-mean(mgNPSTH(f2,:));
                %             bufs = std(mgNMUA(f,:))./sqrt(length(f));
                %             h = errorbar(px,mattsmooth(buf,10),mattsmooth(bufs,10));
                %             set(h,'Color',ccol(o,:))
                h = plot(TB,mattsmooth(buf,4));
                set(h,'Color',ccol(o,:))
                hold on
            end
            xlim([-1 1.4])
            title(['PEN = ',num2str(n)])
        end
    end
    
end





%SAME FOR PSTH
%CROSS_ISO plot
tm = find(TB>0 & TB<0.5);
optocol = [0 0 0;0 0.3 0.9];
fillcol = [0.7 0.7 0.7;0.4 0.7 1];
figure
ci_stat = [];
ci_det = [];
for o = 1:2
    for chn = 1:length(incchans)
        %orienttion
        subplot(2,5,chn)
        
        %SIZE 1
        %Cross data -0 ISo data PSTH
        cond1 = 7+(17*(o-1));
        cond2 = 9+(17*(o-1));
        %We should pre-average both conditions
        f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond1);
        f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond2);
        cross =  (mgNPSTH(f1,tm)+mgNPSTH(f2,tm))./2;
        cst = mean(cross,2);
        
        %get iso
        cond1 = 6+(17*(o-1));
        cond2 = 8+(17*(o-1));
        cond3 = 12+(17*(o-1));
        cond4 = 14+(17*(o-1));
        %For stats we should pre-average all conditions
        f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond1);
        f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond2);
        f3 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond3);
        f4 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond4);
        iso =  (mgNPSTH(f1,tm)+mgNPSTH(f2,tm)+mgNPSTH(f3,tm)+mgNPSTH(f4,tm))./4;
        ist = mean(iso,2);
        
        ci_stat = [ci_stat;cst-ist];
        ci_det = [ci_det;repmat([o,chn],length(cst),1)];
        
        %Subtract
        sub = nanmean(cross-iso);
        subse = nanstd(cross-iso)./sqrt(size(cross,1));
        fillx = [TB(tm),fliplr(TB(tm))];
        filly = [mattsmooth(sub+subse,8),fliplr(mattsmooth(sub-subse,8))];
        %         fill(fillx,filly,fillcol(o,:))
        hold on
        h = plot(TB(tm),mattsmooth(sub,8));
        set(h,'Color',optocol(o,:))
        hold on
        title('Size 1 - Cross-Iso')
        
        xlim([0 0.5])
    end
end

%STATISTICS and scatter plot
clear p
figure
cvind = jet(length(incchans))
for chn = 1:length(incchans)
    off = ci_stat(ci_det(:,2) == chn & ci_det(:,1) == 1);
    on = ci_stat(ci_det(:,2) == chn & ci_det(:,1) == 2);
    [h,p(chn)] = ttest(off-on);
    [h,p2(chn)] = ttest(off(off>0)-on(off>0));
    scatter(off,on,[],cvind(chn,:),'filled')
    hold on
end
plot(-0.2:0.1:0.3,-0.2:0.1:0.3)
xlim([-0.2 0.3])
ylim([-0.2 0.3])



%SIZE 1
for s = 1:2
    figure
    for chn = 1:length(incchans)
        %orienttion
        subplot(3,4,chn)
        
        
        %plot baseline
        cond = 1+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & details(:,4) == cond);
        buf = nanmean(mgNMUA(f,:));
        %             h = plot(px,mattsmooth(buf,10));
        %             set(h,'Color',col(1,:))
        hold on
        base = mattsmooth(buf,10);
        
        %Plot centre only
        cond1 = 2+(17*(s-1));
        cond2 = 3+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(2,:))
        
        %Plot iso (size irrelevant here)
        cond1 = 6+(17*(s-1));
        cond2 = 8+(17*(s-1));
        cond3 = 12+(17*(s-1));
        cond4 = 14+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(6,:))
        
        
        %Plot cross
        cond1 = 7+(17*(s-1));
        cond2 = 9+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(7,:))
        
        
        %Plot surround
        cond1 = 10+(17*(s-1));
        cond2 = 11+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(10,:))
        
        
        xlim([-1 1.4])
        ylim([-0.3 0.8])
    end
end


%SIZE 2
for s = 1:2
    figure
    for chn = 1:length(incchans)
        %orienttion
        subplot(3,4,chn)
        
        
        %plot baseline
        cond = 1+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & details(:,4) == cond);
        buf = nanmean(mgNMUA(f,:));
        %             h = plot(px,mattsmooth(buf,10));
        %             set(h,'Color',col(1,:))
        hold on
        base = mattsmooth(buf,10);
        
        %Plot centre only
        cond1 = 4+(17*(s-1));
        cond2 = 5+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(2,:))
        
        %Plot iso (size irrelevant here)
        cond1 = 6+(17*(s-1));
        cond2 = 8+(17*(s-1));
        cond3 = 12+(17*(s-1));
        cond4 = 14+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(6,:))
        
        
        %Plot cross
        cond1 = 13+(17*(s-1));
        cond2 = 15+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(7,:))
        
        
        %Plot surround
        cond1 = 16+(17*(s-1));
        cond2 = 17+(17*(s-1));
        f = find(details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10)-base);
        set(h,'Color',col(10,:))
        
        
        xlim([-1 1.4])
        ylim([-0.3 0.8])
    end
end

% return




%Compare size-tuning and power analysis
if 0
    chanselect = [-6:1:4];
    chancol = jet(length(chanselect));
    for n = 1:N
        
        figure; subplot(1,3,1)
        surf(px(tf),FRQ(n,:),mean(TFP(:,tf,n),3),'EdgeColor','none')
        xlabel('Time from stimulus onset (ms)');
        set(gca, 'yscale', 'log', 'ytick', [5.0 10.0 25.0 50.0 100.0 150.0])
        ylabel('Frequencies (Hz)');
        set(gca,'FontSize',22);
        axis tight; axis square; view(0,90);
        title(num2str(n))
        
        for sz = 1:2
            subplot(1,3,sz+1)
            clear buf
            
            for chn = 1:length(chanselect)
                for a = 1:3 %cent,iso,cross
                    %size, snrcutoff, inccchans
                    cn1 = allconds(sz,1,a);
                    cn2 = allconds(sz,2,a);
                    f = find((details(:,4) == cn1 | details(:,4) == cn2 ) & details(:,1) == n & mgSNR > cutoff & details(:,3)== chanselect(chn));
                    if isempty(f)
                        buf(a,:) =zeros(1,length(px));
                    elseif length(f) == 1
                        buf(a,:) = smooth(mgNMUA(f,:),10);
                    else
                        buf(a,:) = smooth(mean(mgNMUA(f,:)),10);
                    end
                end
                buf = buf./max(max(buf));
                for a = 1:3
                    h = plot(px(gt),buf(a,gt)+chn);
                    set(h,'Color',surrcol(a+1,:))
                    hold on
                end
                
                %TAke cent-iso and icross-iso measures here
                %Can be used for statistics...
                cent_iso_pen(chn,n,sz) = mean(buf(1,gt))-mean(buf(2,gt));
                cross_iso_pen(chn,n,sz) = mean(buf(3,gt))-mean(buf(2,gt));
                context(chn,n,sz) = cross_iso_pen(chn,n,sz)./(mean(buf(3,gt))+mean(buf(2,gt)));
            end
        end
        title([info(n).name,' - ',num2str(n)])
        
        
        %Get LF power ratio 3 7
        f = find(Fs*frq >= 3 & Fs*frq <= 8);
        Delta(n) = mean(squeeze(mean(mean(TFP(f,tf,n),3),2)))./mean(squeeze(mean(mean(TFP(:,tf,n),3),2)));
        f = find(Fs*frq >= 8 & Fs*frq <= 20);
        HF(n) = mean(squeeze(mean(mean(TFP(f,tf,n),3),2)));
        
        tx(n,:) = sprintf('%0.2d',n)
        
    end
    
    
    
    %Somw comparaison power plots
    figure,text(Power(:,1),Power(:,2),tx)
    xlim([min(Power(:,1)) max(Power(:,1))])
    ylim([min(Power(:,2)) max(Power(:,2))])
    figure,text(HF,Delta,tx)
    xlim([min(HF) max(HF)])
    ylim([min(Delta) max(Delta)])
    x = linspace(min(HF),max(HF),20);
    y = x.*2;
    hold on,plot(x,y)
    Ratio = Power(:,1)./Power(:,2);
    DeepAna = Delta >2; %1.65
end


% %Z-zcore the context
% figure
% for sz = 1:2
%     subplot(1,2,sz)
%     buf = cross_iso_pen(:,:,sz);
%     bufv = reshape(buf,size(buf,1)*size(buf,2),1);
%     bufz = (bufv-mean(bufv))./std(bufv);
%     bufv(abs(bufz)>3) = NaN;
%     buf = reshape(bufv,size(buf,1),size(buf,2));
%     bar(chanselect,mean(buf,2))
%     hold on,errorbar(chanselect,mean(buf,2),std(buf,[],2)./sqrt(n))
% end
%
% % DeepAna = Ratio> 2.05;
%
% %3,4, and 15 probably aren;t V1 (based on RF shape...)
% % DeepAna([3,4,15]) = 1;  %This pens excluded
% DeepAna = zeros(1,N);
%
% %oR USE A LINEAR CLASSIFIER
% % DeepAna = find(Power(:,1)>3e-3 & Power(:,2) < 2e-3);
% details(:,5) = DeepAna(details(:,1));

%Now sort into the different cvonditions
%New NEw NEw style!
%1 - Baseline
%2 - ORI 1 SZ 1 Centre Only (grey)
%3 - ORI 2 SZ 1 Centre Only (black)
%4 - ORI 1 SZ 2 Centre Only (cyan)
%5 - ORI 2 SZ 2 Centre Only (blue)

%6 -  ORI 1 SZ 1 centre/surround (iso)   (red)
%7 -  ORI 1 SZ 1 centre/surround (cross) (orange)
%8 -  ORI 2 SZ 1 centre/surround (iso)   (red)
%9 -  ORI 2 SZ 1 centre/surround (cross) (orange)
%10 - ORI 1 SZ 1 (Surround only)
%11 - ORI 2 SZ 1 (Surround only)

%12 -  ORI 1 SZ 2 centre/surround (iso)
%13 -  ORI 1 SZ 2 centre/surround (cross)
%14 -  ORI 2 SZ 2 centre/surround (iso)
%15 -  ORI 2 SZ 2 centre/surround (cross)
%16 -  ORI 1 SZ 2 (Surround only)
%17 -  ORI 2 SZ 2 (Surround only)

%Details = pen, channel, layer,cond,deep
%LINE-UP THE PENS according to the CSD%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CSD ANALYSIS
%Make the CSD then put it back into alarge MATRIX indexed by details
clear CSD
sep = 2; %This changes the differentiation grid
full = 1:16;
start = full(1)+sep;
fin = full(end)-sep;
mgCSD = NaN(size(mgLFP,1),size(mgLFP,2));
for a = 1:length(allwords)
    for p = 1:N
        clear buf,clear pull
        for ch= 1:16
            pull(ch) = find(details(:,2) == ch & details(:,4) == a & details(:,1) == p);
            buf(ch,:) = mgLFP(pull(ch),:);
        end
        for ch = start:fin
            mgCSD(pull(ch),:) = -0.4.*(buf(ch-sep,:)-(2.*buf(ch,:))+buf(ch+sep,:))./(((100.*10.^-6).*sep).^2);
        end
    end
end

%NOW look at individual penetrations (centonly)
%Pull out channels around reversal (i.e. use incchans)
clear label
for i = 1:length(incchans)
    label{i} = incchans(length(incchans)-i+1);
end
csdjet = flipud(jet(64));

sampt = find(px > 0.08 & px < 0.14);
figure
clear X, clear Y
for p = 1:N
    subplot(3,4,p)
    clear csd
    for ch= 1:length(incchans)
        f = find(details(:,3) == incchans(ch) & (details(:,4)> 1 & details(:,4) < 5) & details(:,1) == p);
        csd(ch,:) = nanmean(mgCSD(f,sampt));
    end
    dx = incchans;
    dy = px(sampt);
    dxf = incchans(1):0.1:incchans(end);
    [X,Y] = meshgrid(dy,dx);
    [XI,YI] = meshgrid(dy,dxf);
    ZI = interp2(X,Y,csd,XI,YI);
    colormap(csdjet);
    imagesc(dy,dxf,flipud(ZI))
    
    set(gca,'YTick',incchans)
    set(gca,'YTickLabels',label)
    
    title(info(p).name)
end


%Can we match the penetartions using an auto-adjust?
%Take the CSD from 70ms to 140ms
%Penetartion #4 has the nicest lookign data
sampt = find(px > 0.08 & px < 0.14);
clear csd
for ch= 1:length(incchans)
    f = find(details(:,3) == incchans(ch) & details(:,4) == 6 & details(:,1) == 7);
    csd(ch,:) = mgCSD(f,sampt);
end

%Now go through all other csds to get the shiftvalue.
%then change detials(:,5) appropriately
details(:,5) = details(:,3);
clear penshift
for p = 1:N
    shift = [-2:1:2];
    clear diff
    for s = 1:length(shift)
        clear buf
        for ch= 1:length(incchans)
            f = find(details(:,3) == incchans(ch)+shift(s) & details(:,4) == 6 & details(:,1) == p);
            if ~isempty(f)
                buf(ch,:) = mgCSD(f,sampt);
            else
                buf(ch,:) = NaN(1,length(sampt));
            end
        end
        
        %Find didffrence between csds
        diff(s) = nansum(nansum((buf-csd).^2));
    end
    [i,j] = min(diff);
    penshift(p) = shift(j);
    %And change details(:,3) score accordingly
    f = find(details(:,1) == p);
    details(f,5) = details(f,5)-penshift(p);
end
%USe details(:,5) ionstead of (:,3)!

%Afetr shifting to check
myfig = figure;
mgNCSD = mgCSD;
for p = 1:N
    subplot(4,5,p)
    clear csd
    for ch= 1:length(incchans)
        f = find(details(:,5) == incchans(ch) & details(:,4) == 6 & details(:,1) == p);
        csd(ch,:) = mgCSD(f,gt);
    end
    
    %Could we normalize the csd to diff betwen peak and trough?
    diff = max(max(csd))-min(min(csd));
    f = find(details(:,1) == p);
    mgNCSD(f,:) = mgCSD(f,:)./diff;
    
    
    dx = incchans;
    dy = px(gt);
    dxf = incchans(1):0.1:incchans(end);
    [X,Y] = meshgrid(dy,dx);
    [XI,YI] = meshgrid(dy,dxf);
    ZI = interp2(X,Y,csd,XI,YI);
    colormap(csdjet);
    imagesc(dy,dxf,flipud(ZI))
    set(gca,'YTick',incchans)
    set(gca,'YTickLabel',label)
    title(info(p).name)
    %     colorbar
end


%SNR PLOTS
%We can make a plot of SNR against adjusted channel
minchan = min(details(:,3));
maxchan = max(details(:,3));
allchans = minchan:maxchan;
for n = 1:length(allchans)
    f = find(details(:,3) == allchans(n));
    snr(n) = nanmean(mgSNR(f));
end
figure,bar(allchans,snr)



%NMUA
%Centtre only response
%TAke only good SNR
legtext = ['Ori 1, Sz 1';'Ori 2, Sz 1';'Ori 1, Sz 2';'Ori 2, Sz 2'];
cutoff = 0;
figure
z = 0;
for a = [2 3 4 5]
    z = z+1;
    %size, snrcutoff, inccchans
    f = find(details(:,4) == a & mgSNR > cutoff & (details(:,3) >= 2 & details(:,3) <= 4));
    buf = mean(mgNMUA(f,:));
    h = plot(px,smooth(buf,10));
    set(h,'Color',szcol(a,:))
    hold on
    CO(z) = nanmean(buf);
end
xlim([-0.2 1])
legend(legtext);

%Make an index describing orientation-tuning strength
clear CO
for N = 1:length(info)
    for a = 1:17
        %size, snrcutoff, inccchans
        f = find(details(:,1) == N & details(:,4) == a & mgSNR > cutoff & (details(:,3) >= -5 & details(:,3) <= -1));
        buf = mean(mgNMUA(f,:));
        CO(N,a) = nanmean(buf);
    end
end
OI = ((CO(:,2)+CO(:,4))-(CO(:,3)-CO(:,5)))./(CO(:,2)+CO(:,3)+CO(:,4)+CO(:,5));
CI = ((CO(:,7)+CO(:,9))-(CO(:,6)-CO(:,8)))./(CO(:,6)+CO(:,7)+CO(:,8)+CO(:,9));
CI2 = ((CO(:,13)+CO(:,15))-(CO(:,12)+CO(:,14)))./(CO(:,12)+CO(:,13)+CO(:,14)+CO(:,15));
figure,subplot(1,2,1),scatter(OI,CI)
subplot(1,2,2),scatter(OI,CI2)


%Make an index describing orientation-tuning strength
clear CO
z = 0;
for N = 1:length(info)
    for chn = 1:length(incchans)
        z = z+1;
        for a = 1:17
            
            
            %size, snrcutoff, inccchans
            f = find(details(:,1) == N & details(:,4) == a & details(:,3) == incchans(chn));
            if ~isempty(f)
                CO(z,a) = nanmean(mgNMUA(f,:));
            else
                CO(z,a) = NaN;
            end
        end
    end
end
%OI is orientation tuning based on centr eonly responses
OI = ((CO(:,2)+CO(:,4))-(CO(:,3)+CO(:,5)))./(CO(:,2)+CO(:,3)+CO(:,4)+CO(:,5));
%SS is surround suppression index, based on iso-stimuli
SS = ((CO(:,2)+CO(:,3))-(CO(:,6)+CO(:,8)))./(CO(:,2)+CO(:,3)+CO(:,6)+CO(:,8));
%CI = cross-iso index
CI = ((CO(:,7)+CO(:,9))-(CO(:,6)+CO(:,8)))./(CO(:,6)+CO(:,7)+CO(:,8)+CO(:,9));
%Same for large size
CI2 =((CO(:,13)+CO(:,15))-(CO(:,12)+CO(:,14)))./(CO(:,12)+CO(:,13)+CO(:,14)+CO(:,15));
%Surround activation index, difference between centre and surround
SURR1 = ((CO(:,2)+CO(:,3))-(CO(:,10)+CO(:,11)))./(CO(:,2)+CO(:,3)+CO(:,10)+CO(:,11));
SURR2 = ((CO(:,4)+CO(:,5))-(CO(:,16)+CO(:,17)))./(CO(:,4)+CO(:,5)+CO(:,16)+CO(:,17));
%regress
[B1,BINT,R,RINT,STATS(1,:)] = regress(CI,[OI,ones(length(OI),1)]);
[B2,BINT,R,RINT,STATS(2,:)] = regress(CI2,[OI,ones(length(OI),1)]);
[B3,BINT,R,RINT,STATS(3,:)] = regress(CI,[SS,ones(length(OI),1)]);
[B4,BINT,R,RINT,STATS(4,:)] = regress(CI2,[SS,ones(length(OI),1)]);
[B5,BINT,R,RINT,STATS(5,:)] = regress(CI,[SURR1,ones(length(OI),1)]);
[B6,BINT,R,RINT,STATS(6,:)] = regress(CI2(SURR2<1.5),[SURR2(SURR2<1.5),ones(length(OI(SURR2<1.5)),1)]);

%Only two signbificant regressions:
%1 - Small sz CI with OI
%3 - Small size CI with SS
x = [-1:0.1:1];
y1 = B1(2)+x.*B1(1);
y2 = B2(2)+x.*B2(1);
y3 = B3(2)+x.*B3(1);
y4 = B4(2)+x.*B4(1);
y5 = B5(2)+x.*B5(1);
y6 = B6(2)+x.*B6(1);
figure
subplot(3,2,1),scatter(OI,CI),hold on,plot(x,y1),xlim([-0.5 1])
subplot(3,2,2),scatter(OI,CI2),hold on,plot(x,y2),xlim([-0.5 1])
subplot(3,2,3),scatter(SS,CI),hold on,plot(x,y3),xlim([-0.5 0.7])
subplot(3,2,4),scatter(SS,CI2),hold on,plot(x,y4),xlim([-0.5 0.7])
subplot(3,2,5),scatter(SURR1,CI),hold on,plot(x,y5),xlim([-0.5 1])
subplot(3,2,6),scatter(SURR2,CI2),hold on,plot(x,y6),xlim([-0.5 1])



%Also don;t average across ORI
legtext = ['Cent ';'Iso  ';'Cross';'Surr '];
cutoff = 0;
centconds = [2 3;4 5];
isoconds = [6 8;12 14];
crossconds = [7 9;13 15];
surronly = [10 11;16 17];
allconds(:,:,1) = centconds;
allconds(:,:,2) = isoconds;
allconds(:,:,3) = crossconds;
allconds(:,:,4) = surronly;
for sz = 1:2
    for o = 1:2
        figure
        for a = 1:4 %cent,iso,cross
            %size, snrcutoff, inccchans
            cn = allconds(sz,o,a);
            f = find(details(:,4) == cn  & mgSNR > cutoff & (details(:,3) >= 0 & details(:,3) <= 4));
            buf = mean(mgNMUA(f,:));
            h = plot(px,smooth(buf,10));
            set(h,'Color',surrcol(a+1,:))
            hold on
        end
        legend(legtext);
        xlim([0 1])
    end
end


%NMUA
%Surround conditions, split by size, average across ori
%TAke only good SNR
legtext = ['Cent ';'Iso  ';'Cross';'Surr '];
cutoff = 0;
allconds(:,:,1) = centconds;
allconds(:,:,2) = isoconds;
allconds(:,:,3) = crossconds;
allconds(:,:,4) = surronly;
for sz = 1:2
    figure
    for a = 1:4 %cent,iso,cross
        %size, snrcutoff, inccchans
        cn1 = allconds(sz,1,a);
        cn2 = allconds(sz,2,a);
        f = find((details(:,4) == cn1 | details(:,4) == cn2 ) & mgSNR > cutoff & (details(:,3) >= 0 & details(:,3) <= 4));
        buf = mean(mgNMUA(f,:));
        h = plot(px,smooth(buf,5));
        set(h,'Color',surrcol(a+1,:))
        hold on
    end
    legend(legtext);
    xlim([0 0.2])
end

%Per layer
%Surround conditions, split by size, average across ori
%TAke only good SNR
cutoff = 0;
for sz = 1:2
    figure
    for chn = 1:length(incchans)
        subplot(4,3,chn)
        for a = 1:4 %cent,iso,cross
            %size, snrcutoff, inccchans
            cn1 = allconds(sz,1,a);
            cn2 = allconds(sz,2,a);
            f = find((details(:,4) == cn1 | details(:,4) == cn2 ) & details(:,3) == incchans(chn) & mgSNR > cutoff);
            buf = mean(mgNMUA(f,:));
            h = plot(px,smooth(buf,10));
            set(h,'Color',surrcol(a+1,:))
            hold on
            xlim([0 1])
            outbuf(a,:) = smooth(buf,10);
        end
        centonly(chn,:) = outbuf(1,:);
        isoonly(chn,:) = outbuf(2,:);
        crossonly(chn,:) = outbuf(3,:);
        isosupp(chn,:,sz) = outbuf(1,:)-outbuf(2,:);
        isocross(chn,:,sz) = outbuf(3,:)-outbuf(2,:);
        %     legend(legtext);
    end
    
    mn = -0.05;
    mx = 0.7;
    label = [0:0.2:0.6];
    labelpos = 64.*((label-mn)./(mx-mn));
    
    figure,subplot(1,3,1);
    dx = incchans;
    dy = px(gt);
    dxf = incchans(1):0.1:incchans(end);
    [X,Y] = meshgrid(dy,dx);
    [XI,YI] = meshgrid(dy,dxf);
    ZI = interp2(X,Y,centonly(:,gt),XI,YI);
    buf = 64.*((ZI-mn)./(mx-mn));
    image(px(gt),incchans,buf)
    axis xy
    title('Cent only')
    h = colorbar,set(h,'YTick',labelpos),set(h,'YTickLabel',label)
    
    subplot(1,3,2);
    ZI = interp2(X,Y,isoonly(:,gt),XI,YI);
    buf = 64.*((ZI-mn)./(mx-mn));
    image(px(gt),incchans,buf)
    axis xy
    title('Iso only')
    h = colorbar,set(h,'YTick',labelpos),set(h,'YTickLabel',label)
    
    subplot(1,3,3);
    ZI = interp2(X,Y,crossonly(:,gt),XI,YI);
    buf = 64.*((ZI-mn)./(mx-mn));
    image(px(gt),incchans,buf)
    axis xy
    title('Cross only')
    h = colorbar,set(h,'YTick',labelpos),set(h,'YTickLabel',label)
    
    %Plot out isosupp and cross-iso effect
    figure,subplot(1,2,1);
    dx = incchans;
    dy = px(gt);
    dxf = incchans(1):0.1:incchans(end);
    [X,Y] = meshgrid(dy,dx);
    [XI,YI] = meshgrid(dy,dxf);
    ZI = interp2(X,Y,isosupp(:,gt,sz),XI,YI);
    imagesc(px(gt),incchans,ZI)
    axis xy
    title('Cent only vs. Iso')
    colorbar
    subplot(1,2,2)
    ZI = interp2(X,Y,isocross(:,gt,sz),XI,YI);
    imagesc(px(gt),incchans,ZI)
    axis xy
    title('Cross vs. Iso')
    colorbar
end

figure,
%Difference between iso and cross for the two sizes (sz1 = r)
plot(px(gt),smooth(nanmean(isocross(6:10,gt,1)),10),'r')
hold on
plot(px(gt),smooth(nanmean(isocross(6:10,gt,2)),10),'b')
xlim([0 0.5])
ylim([-0.05 0.18])
% end


%%%HOW ABOUT SOME
%%%CSDs%%%here?%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Average for conditions
for sz = 1:2
    figure
    for a = 1:4
        clear csd
        subplot(1,4,a)
        for ch= 1:length(incchans)
            %channel, size, pen>5
            cn1 = allconds(sz,1,a);
            cn2 = allconds(sz,2,a);
            f = find((details(:,4) == cn1 | details(:,4) == cn2 ) & details(:,5) == incchans(ch));
            csd(ch,:) = nanmean(mgCSD(f,gt));
            
            csdresp(ch,:,a,sz) = nanmean(mgCSD(f,gt));
            muaresp(ch,:,a,sz)  = nanmean(mgNMUA(f,gt));
        end
        dx = incchans;
        dy = px(gt);
        dxf = incchans(1):0.1:incchans(end);
        [X,Y] = meshgrid(dy,dx);
        [XI,YI] = meshgrid(dy,dxf);
        ZI(:,:,a,sz) = interp2(X,Y,csd,XI,YI);
        colormap(csdjet);
        mn = -3000;
        mx = 2000;
        buf = 64.*((ZI(:,:,a,sz)-mn)./(mx-mn));
        image(dy,dxf,flipud(buf))
        xlim([0 0.3])
        set(gca,'YTick',incchans)
        set(gca,'YTickLabels',label)
        colorbar
    end
end


%Centre vs Iso
figure
for sz = 1:2
    subplot(1,2,sz)
    diff = ZI(:,:,1,sz)-ZI(:,:,2,sz);
    imagesc(dy,dxf,flipud(diff))
    set(gca,'YTick',incchans)
    set(gca,'YTickLabels',label)
    colormap(csdjet);
end


%Cross vs Iso
figure
for sz = 1:2
    subplot(1,2,sz)
    diff = ZI(:,:,3,sz)-ZI(:,:,2,sz);
    imagesc(dy,dxf,flipud(diff))
    set(gca,'YTick',incchans)
    set(gca,'YTickLabels',label)
    colormap(csdjet);
end

%Surround only
figure
for sz = 1:2
    subplot(1,2,sz)
    diff = ZI(:,:,1,sz)-ZI(:,:,4,sz);
    imagesc(dy,dxf,flipud(diff))
    set(gca,'YTick',incchans)
    set(gca,'YTickLabels',label)
    colormap(csdjet);
end



%Pull out CSDs from upper layers
lay = 10;
figure
col = ['k','r','m'];
for c = 1:3
    subplot(2,1,1)
    csd = csdresp(lay,:,c,1);
    plot(px(gt),csd,col(c))
    hold on,xlim([0 0.3])
    subplot(2,1,2)
    mua = smooth(muaresp(lay,:,c,1),10);
    plot(px(gt),mua,col(c))
    hold on,xlim([0 0.3])
end


return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Can now do the same for the PSTH data, but would have to generate a PSTH
%SNR value
%Now make laminar plot with SNR cutoff
figure
for n = 1:nchans
    subplot(1,nchans,n)
    for a = 1:length(allwords)
        f = find(details(:,3) == incchans(n) & details(:,4) == a);
        presp(n,:,a) = smooth(nanmean(mgNPSTH(f,:)),4);
        h = plot(TB,presp(n,:,a));
        set(h,'Color',szcol(a,:))
        xlim([0 0.6])
        hold on
    end
end

figure
tbgt = find(TB >= 0 & TB < 0.6);
for a = 1:9
    subplot(3,3,a)
    
    %Interpolate the response
    dx = incchans;
    dy = TB(tbgt);
    dxf = incchans(1):0.1:incchans(end);
    [X,Y] = meshgrid(dy,dx);
    [XI,YI] = meshgrid(dy,dxf);
    PZI(:,:,a) = interp2(X,Y,presp(:,tbgt,a),XI,YI);
    
    imagesc(TB(tbgt),incchans,PZI(:,:,a))
    axis xy
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Get relevant part
beg = -0.1;
fin = 0.8;
spacer = 0.1;
tf = find(px >= beg & px <= fin);
td = px(tf);
ptf = find(TB >= beg & TB <= fin);
ptd = TB(ptf);

%Now for each channel average for each type
figure
% incchans = [2:11];
szcol = jet(length(allwords));
for chn = chnorder
    %size
    subplot(4,4,chn)
    for a = 1:length(allwords)
        h = plot(td,smooth(CHAN(chn).MUA(a,tf),20))
        set(h,'Color',szcol(a,:))
        hold on
    end
    xlim([-0.1 0.7])
end
title('MUA')

%linear
figure
z = 0;
for chn = incchans
    z = z+1;
    %orienttion
    
    for a = 1:length(allwords)
        subplot(2,1,1)
        h = plot(td+((fin-beg)*(z-1))+(spacer*(z-1)),smooth(CHAN(chn).MUA(a,tf),20))
        set(h,'Color',szcol(a,:))
        hold on
        xlim([-0.2 (fin-beg)*(length(incchans)-1)+(spacer*(length(incchans)-1))+(fin-beg)])
        subplot(2,1,2)
        h = plot(td+((fin-beg)*(z-1))+(spacer*(z-1)),smooth(CHAN(chn).NMUA(a,tf),20))
        set(h,'Color',szcol(a,:))
        hold on
        xlim([-0.2 (fin-beg)*(length(incchans)-1)+(spacer*(length(incchans)-1))+(fin-beg)])
    end
    
    if chn == incchans(end)
        legend(num2str(allwords(1)),num2str(allwords(2)),num2str(allwords(3)),num2str(allwords(4)),...
            num2str(allwords(5)),num2str(allwords(6)),num2str(allwords(7)),num2str(allwords(8)),num2str(allwords(9)))
    end
end
title('MUA')

%linear
figure
z = 0;
for chn = incchans
    z = z+1;
    %orienttion
    
    for a = 1:length(allwords)
        subplot(2,1,1)
        h = plot(ptd+((fin-beg)*(z-1))+(spacer*(z-1)),smooth(CHAN(chn).PSTH(a,ptf),20))
        set(h,'Color',szcol(a,:))
        hold on
        xlim([-0.2 (fin-beg)*(length(incchans)-1)+(spacer*(length(incchans)-1))+(fin-beg)])
        subplot(2,1,2)
        h = plot(ptd+((fin-beg)*(z-1))+(spacer*(z-1)),smooth(CHAN(chn).NPSTH(a,ptf),20))
        set(h,'Color',szcol(a,:))
        hold on
        xlim([-0.2 (fin-beg)*(length(incchans)-1)+(spacer*(length(incchans)-1))+(fin-beg)])
    end
    
    if chn == incchans(end)
        legend(num2str(allwords(1)),num2str(allwords(2)),num2str(allwords(3)),num2str(allwords(4)),...
            num2str(allwords(5)),num2str(allwords(6)),num2str(allwords(7)),num2str(allwords(8)),num2str(allwords(9)))
    end
end
title('SUA')


%TAKE time-window averages
%Stimulu comes on at 0 and stays on for 1 sec
pk = find(px>0.05 & px < 0.15);
sus = find(px>0.15 & px < 0.5);
col = jet(length(incchans));
figure
for chn = 1:length(incchans)
    M{chn} = num2str(incchans(chn));
end
z = 0;
for chn = incchans
    
    z = z+1;
    %size
    subplot(1,3,1)
    buf = nanmean(CHAN(chn).NMUA(:,tf),2);
    h = plot(allwords,buf);
    set(h,'Color',col(z,:))
    hold on
    xlim([0 max(allwords)])
    
    subplot(1,3,2)
    buf = nanmean(CHAN(chn).NMUA(:,pk),2);
    h = plot(allwords,buf);
    set(h,'Color',col(z,:))
    hold on
    xlim([0 max(allwords)])
    
    subplot(1,3,3)
    buf = nanmean(CHAN(chn).NMUA(:,sus),2);
    h = plot(allwords,buf);
    set(h,'Color',col(z,:))
    hold on
    xlim([0 max(allwords)])
    if chn == incchans(end)
        legend(M)
    end
    
end
title('MUA')

%Single-unti summed
%Stimulu comes on at 0 and stays on for 1 sec
sutb = find(TB>=0);
pk = find(TB>0.05 & TB < 0.15);
sus = find(TB>0.15 & TB < 0.5);
figure
z = 0;
for chn = incchans
    
    %orienttion
    %orienttion
    z = z+1;
    subplot(1,3,1)
    buf = nanmean(CHAN(chn).NPSTH(:,sutb),2);
    h = plot(allwords,buf);
    set(h,'Color',col(z,:))
    hold on
    xlim([0 max(allwords)])
    
    subplot(1,3,2)
    buf = nanmean(CHAN(chn).NPSTH(:,pk),2);
    h = plot(allwords,buf);
    set(h,'Color',col(z,:))
    hold on
    xlim([0 max(allwords)])
    
    subplot(1,3,3)
    buf = nanmean(CHAN(chn).NPSTH(:,sus),2);
    h = plot(allwords,buf);
    set(h,'Color',col(z,:))
    hold on
    xlim([0 max(allwords)])
    if chn == incchans(end)
        legend(M)
    end
    
end
title('SUA')







return




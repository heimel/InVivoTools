function whatever

dbstop if error


%Analyse Flash to get CSD response
chnorder = [1:16];
spikeon =1;
makedata =0;

%Data details
%library for extracting tdt data files
addpath('D:\MouseLaminar\Analysis\TDT2ML')
datadir = 'D:\MouseLaminar\Data\';
logdir = 'D:\MouseLaminar\StimuliandLogs\';
suadir = 'D:\MouseLaminar\SUA\';
addpath(genpath('D:\MouseLaminar\Wavelet'))

info = log_surround2sz_STATIC;

%17 conditions, which can be grouped into 4 conds for each size
%we don't do surround here
%so we are left with 13 conds 
spontconds = [1 1;1 1];
centconds = [2 3;4 5];
isoconds = [6 8;10 12];
crossconds = [7 9;11 13];
allconds(:,:,1) = centconds;
allconds(:,:,2) = isoconds;
allconds(:,:,3) = crossconds;
allconds(:,:,4) = spontconds;
nallconds = 26;


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
    makefilt = 1;
    notch = 1;
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
        nblocks = length(info(N).static);
        prevt = 0;
        MATBUF = [];
        Word = [];
        stimon = [];
        clear EVENT,clear Env,clear Spikes
        
        %Average over blocks
        for B = 1:nblocks
            
            Blockno = num2str(info(N).static(B));
            blocknames = ['Block-',Blockno];
            [pathstr,name,ext,versn] = fileparts(Tankname);
            
            %Load up the logfile for this session
            %Mh will make this into an automatic detection
            try
                logfile = [Stem,'_B0',Blockno];
                logfile = [logdir,logfile];
                load(logfile)
            catch
                logfile = [Stem,'_B',Blockno];
                logfile = [logdir,logfile];
                load(logfile)
            end
            
            MATBUF = [MATBUF;MAT];
            
            clear EVENT
            EVENT.Mytank = [datadir,Tankname];
            EVENT.Myblock = blocknames;
            %This will obtain the headers for the stream data (Env and LFP)
            %The word and stimulus bits (strons)
            %The trials structure (Trials)
            %And snips header
            EVENT = Exinf4_matt(EVENT);
            
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
            
            %Thesecare the times of the stimulus bits
            stimon = [stimon;EVENT.Trials.stim_onset];
            
            %Read in the word bit
            Word = [Word;EVENT.Trials.word];
        end
        
        %reassign MAT
        MAT = MATBUF;
        
        wn = find(isnan(Word));
        Word(wn) = [];
        
        if strcmp(Tankname,'Mouse_20121211') & strcmp(Blockno,'18')
            Word(end) = [];
        end
        if strcmp(Tankname,'Mouse_20130411') & strcmp(Blockno,'12')
            Word(end) = [];
        end
        if strcmp(Tankname,'Mouse_20130222') & strcmp(Blockno,'11')
            Word(410:end,:) = [];
        end
        if strcmp(Tankname,'Mouse_20130226') & strcmp(Blockno,'12')
            Word(512:end,:) = [];
        end
        if strcmp(Tankname,'Mouse_20130307') & strcmp(Blockno,'23')
            MAT(1,:) = [];
        end
        if strcmp(Tankname,'Mouse_20130411') & strcmp(Blockno,'12')
            MAT(781:end,:) = [];
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
        allwords = 1:32;
        allwords([10 11 16 17 10+17 11+17]) = [];
        if info(N).nstims == 2
            wordorder = [1:26];
        elseif info(N).nstims == 5
            %Here the no stim condition is condition 2
            wordorder = [14:26,1:13];
        end
        
        aws(N) = length(unique(Word))
        
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
            
            meanMUA = [];
            meanLFP = [];
            SNR = [];
            statmua = [];
            statdets = [];
            
            
            for a = 1:length(allwords)
                
                %Find all the rows of the MAT matrix of a particular size
                f = find(Word == allwords(wordorder(a)));
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
                                Rast(z).T = T-stimon(f(x));
                                Alltimes = [Alltimes,T-stimon(f(x))];
                            end
                        end
                    end
                    
                    %Asign MUA data
                    MUA(z,:) = ENV(:,f(x))';
                    
                    %DO LFP dat
                    LP = FPT(:,f(x));
                    %Filtering
%                     if notch > 0
                        filtbuf = filter(Hd1,LP');
                        filtbuf = filter(Hd2,filtbuf);
                        filtbuf = filter(Hd3,filtbuf);
%                     end
                    LFP(z,:) = filtbuf;
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
                meanLFP(a,:) = nanmean(LFP);
                
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
            %Conds 1-13
            nonopt = [1:13];
            base = nanmean(nanmean(meanMUA(nonopt,preT),2));
            
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
                TBbase = nanmean(nanmean(meanPSTH(nonopt,preTB),2));
                
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
            mgLFP = [mgLFP;meanLFP];
            mgSNR = [mgSNR;SNR'];
            
            %PEN no, channel number, adjusted channel number, cond
            details = [details;[repmat([N,chn,chn-R],nallconds,1),[1:nallconds]']];
            
            %STATS
            %Individual condition light on/off tests
            clear stat
            for a = nonopt
                f = find(statdets == a);
                on = nanmean(statmua(f,anaT),2);
                f = find(statdets == a+13);
                off = nanmean(statmua(f,anaT),2);
                
                %2 sample non-para test
                stat(a,1) = ranksum(on(~isnan(on)),off(~isnan(off)));
            end
            isp(chn,:,N) = stat';
            mgISP = [mgISP;[stat;NaN(13,1)]];
            
            %Grouped conditions
            q = 0;
            for a = 1:3
                for sz = 1:2
                    q = q+1;
                    f = find(statdets == allconds(sz,1,a) | statdets == allconds(sz,2,a));
                    on = nanmean(statmua(f,anaT),2);
                    f = find(statdets == allconds(sz,1,a)+13 | statdets == allconds(sz,2,a)+13);
                    off = nanmean(statmua(f,anaT),2);
                    
                    %2 sample non-para test
                    isp2(chn,q,N) = ranksum(on(~isnan(on)),off(~isnan(off)));
                    mgISP2 = [mgISP2;isp2(chn,q,N)];
                    mgISP2_det = [mgISP2_det;[N,chn,chn-R,q]];
                end
            end
            
            %Does light affect baseline?
            f = find(statdets <= 13);
            off = nanmean(statmua(f,preT),2);
            f = find(statdets > 13);
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
    
    save SurroundDataStatic_2
else
    
    load SurroundDataStatic_2
end

% if makedata
%     return
% end
gt = find(px >= 0 & px <= 0.5);
sust = find(px >= 0.2 & px <= 0.5);
susspk =  find(TB>=0.2 & TB<=0.5);
cutoff = 0;
%Color
szcol = [0 0 0;0.5 0.5 0.5;0 0 0;0 1 1;0 0 1;1 0 0;1 0.6 0.2;1 0 0;1 0.6 0.2;0 1 0;0.2 0.8 0.2;1 0 0;1 0.6 0.2;1 0 0;1 0.6 0.2;0 1 0;0.2 0.8 0.2];
surrcol = [0 0 0;0.5 0.5 0.5;1 0 0;1 0.6 0.2;0 1 0];
incchans = [-5:1:4];
nchans = length(incchans);
px = px(1:end-1)
jetcsd = flipud(jet);

%Fior interpolation
dx = incchans;
dy = px;
dxf = incchans(1):0.5:incchans(end);
[X,Y] = meshgrid(dy,dx);
[XI,YI] = meshgrid(dy,dxf);
dy = TB;
[XS,YS] = meshgrid(dy,dx);
[XSI,YSI] = meshgrid(dy,dxf);


%CSD ANALYSIS
%Make the CSD then put it back into alarge MATRIX indexed by condtab
sep = 2; %This changes the differentiation grid
full = 1:16;
start = full(1)+sep;
fin = full(end)-sep;
mgCSD = NaN(size(mgLFP,1),size(mgLFP,2));
mgNCSD = NaN(size(mgLFP,1),size(mgLFP,2));
for p = 1:N
    for a = 1:13
        for s = 1:2
            clear buf,clear pull
            for ch= 1:16
                pull(ch) = find(details(:,1) == p & details(:,2) == ch & details(:,4) == a+(13*(s-1)));
                buf(ch,:) = mgLFP(pull(ch),:);
            end
            for ch = start:fin
                mgCSD(pull(ch),:) = smooth(-0.4.*(buf(ch-sep,:)-(2.*buf(ch,:))+buf(ch+sep,:))./(((100.*10.^-6).*sep).^2),10);
            end
        end
    end
end


%normlaioze the CSD
for p = 1:N
    f = find(details(:,1) == p & details(:,3) == 0 & (details(:,4) > 1 & details(:,4) < 14));
    buf = nanmean(mgCSD(f,:));
    normfact = max(abs(buf(peakT)));
    
    f = find(details(:,1) == p);
    mgNCSD(f,:) = mgCSD(f,:)./normfact;
end
        


csd = reshape(mgNCSD,size(mgNCSD,1).*size(mgNCSD,2),1);
csdz = (csd-nanmean(csd))./nanstd(csd);
csd(abs(csdz)>5) = NaN;
csdz = (csd-nanmean(csd))./nanstd(csd);
csd(abs(csdz)>5) = NaN;
mgNCSD = reshape(csd,size(mgNCSD,1),size(mgNCSD,2));


%MAKE The 5D data matrices
Raw = zeros(length(incchans),length(px),3,2,2,N);
RawSpk = zeros(length(incchans),length(TB),3,2,2,N);
RawCSD = zeros(length(incchans),length(px),3,2,2,N);
z = 0;
for n = 1:N
    for sz = 1:2
        for s = 1:2
            for a = 1:4
                z = z+1;
                for chn = 1:length(incchans)
                    cond1 = allconds(sz,1,a)+(13*(s-1));
                    cond2 = allconds(sz,2,a)+(13*(s-1));
                    f1 = find(details(:,1) == n & details(:,3) == incchans(chn) & details(:,4) == cond1);
                    f2 = find(details(:,1) == n & details(:,3) == incchans(chn) & details(:,4) == cond2);
                    Raw(chn,:,a,s,sz,n) = smooth(nanmean(mgNMUA([f1 f2],:)),20);
                    RawSpk(chn,:,a,s,sz,n) = smooth(nanmean(mgNPSTH([f1 f2],:)),20);
                    RawCSD(chn,:,a,s,sz,n) = nanmean(mgNCSD([f1 f2],:));
                end
            end
        end
    end
    
    if 1
        figure
%         for a = 1:4
%         subplot(1,5,a),imagesc(px,dxf,RawCSD(:,:,a,1,1,n))
%         colorbar,colormap(jetcsd),axis xy
%         xlim([-0.2 0.8])
%         end
%         subplot(1,5,5),
        imagesc(px,dxf,RawCSD(:,:,3,1,1,n)-RawCSD(:,:,2,1,1,n))
        colorbar,colormap(jetcsd),axis xy
        xlim([0 0.5])
       
    end
        
    if 0
        figure
        z = 0;
        for s = 1:2
            for a = 1:3
                z = z+1;
                subplot(2,5,z) %2,5
                ZI(:,:,a) = interp2(X,Y,Raw(:,:,a,s,sz,n),XI,YI);
                imagesc(px,incchans,ZI(:,:,a))
                axis xy
                xlim([-0.1 0.8])
                colorbar
            end
            z = z+1;
            subplot(2,5,z)
            imagesc(px,incchans,ZI(:,:,1)-ZI(:,:,2))
            axis xy
            xlim([-0.1 0.8])
            colorbar
            z = z+1;
            subplot(2,5,z)
            imagesc(px,incchans,ZI(:,:,3)-ZI(:,:,2))
            axis xy
            xlim([-0.1 0.8])
            title(num2str(n))
            colorbar
        end
    end
    
end




%%%TAKE MEANS ACROSS PENS
incpens = [1:11,13];
M = nanmean(Raw(:,:,:,:,:,incpens),6);
MSPK = nanmean(RawSpk(:,:,:,:,:,incpens),6);
MCSD = nanmean(RawCSD(:,:,:,:,:,incpens),6);

%INTERACTION EFFECT
%Surround suppression
%     SS = squeeze((Raw(:,sust,1,1,incpens)-Raw(:,sust,2,1,incpens))-(Raw(:,sust,1,2,incpens)-Raw(:,sust,2,2,incpens)));
%     SS_m =  mean(mean(SS,3),2);
%     SS_s =  std(mean(SS,2),[],3)./sqrt(length(incpens));
%     figure,errorbar(incchans,SS_m,SS_s)

%     SSp = squeeze(mean(SS,2));
%     figure
%     colp = jet(max(incpens));
%     for p = incpens
%         hold on,plot(incchans,SSp(:,p),'Color',colp(p,:))
%     end
%     legend(num2str(incpens'))

%Plot out each condition
mn = -0.2;
mx = 0.8;
for sz = 1:2
    figure
    z = 0;
    for s = 1:2
        for a = 1:4
            z = z+1;
            subplot(2,4,z)
            MI(:,:,a,s,sz) = interp2(X,Y,M(:,:,a,s,sz),XI,YI);
            buf = MI(:,:,a,s)-mn;
            buf = 64.*(buf./(mx-mn));
            if a < 4
                image(px,incchans,buf)
            else
                buf = MI(:,:,a,s,sz)-mn;
                buf = 64.*(buf./(0.3-mn));
                image(px,incchans,buf)
            end
            axis xy
            xlim([-0.25 0.75])
        end
    end
end

%Actually using the entire time-period
sust = find(px >= 0 & px <= 0.5);
latet = find(px >= 0.2 & px <= 0.5);

%Summed up over time
%Just nion-opto
for sz = 1:2
    SM = squeeze(mean(M(:,sust,:,op,sz),2));
    smr = squeeze(mean(Raw(:,sust,:,op,sz,:),2));
    SMS = std(smr,[],3)./sqrt(length(incchans));
    figure
    for C = 1:3
        errorbar(incchans,SM(:,C),SMS(:,C),'Color',surrcol(C+1,:))
        hold on
        xlim([-6 5])
    end
end

%STATS for nonopto
for sz = 1:2
    smr = squeeze(mean(Raw(:,sust,:,1,sz,:),2));
    smrinc2 = squeeze((smr(:,3,:)+smr(:,2,:))>0.1);
    iso = squeeze(smr(:,2,:));
    crs = squeeze(smr(:,3,:));
    iso(~smrinc2) = NaN;
    crs(~smrinc2) = NaN;
    OSSI = (crs-iso)./(crs+iso);
    pkw(sz) = kruskalwallis(OSSI')
    for n = 1:10
        psr(n,sz) = signrank(OSSI(n,:))
    end
end



%SS and CI, non opto
figure
szcol = [0 0 0;0.5 0.5 0.5];
for sz = 1:2
    smr = squeeze(mean(Raw(:,sust,:,1,sz,:),2));
    %     smrinc = squeeze((smr(:,1,:)+smr(:,2,:))>0.1);
    smrinc2 = squeeze((smr(:,3,:)+smr(:,2,:))>0.1);
    %     cent = squeeze(smr(:,1,:));
    iso = squeeze(smr(:,2,:));
    crs = squeeze(smr(:,3,:));
    %     cent(~smrinc) = NaN;
    iso(~smrinc2) = NaN;
    crs(~smrinc2) = NaN;
    %     vals = sum(smrinc,2);
    vals2 = sum(smrinc2,2);
    %     SS = squeeze((cent-iso)./(cent+iso));
    CI = squeeze((crs-iso)./(crs+iso));
    %     figure,errorscatter(incchans,nanmean(SS,2),nanstd(SS,[],2)./sqrt(vals),[1 0 0])
    %     hold on
    errorscatter(incchans,nanmean(CI,2),nanstd(CI,[],2)./sqrt(vals2),szcol(sz,:))
    xlim([-6 5])
    hold on
end

%SPIKE BASED
mn = -0.2;
mx = 0.8;
figure
z = 0;
for s = 1:2
    for a = 1:4
        z = z+1;
        subplot(2,4,z)
        MISPK(:,:,a,s) = interp2(XS,YS,MSPK(:,:,a,s),XSI,YSI);
        buf = MISPK(:,:,a,s)-mn;
        buf = 64.*(buf./(mx-mn));
        if a < 4
            image(TB,incchans,buf)
        else
            buf = MISPK(:,:,a,s)-mn;
            buf = 64.*(buf./(0.3-mn));
            image(TB,incchans,buf)
        end
        axis xy
        xlim([-0.25 0.75])
    end
end


%modulatory FX
for sz = 1:2
    figure
    for s = 1:2
        %Cross - Iso
        subplot(2,2,s)
        buf = (MI(:,:,3,s,sz)-MI(:,:,2,s,sz));
        Mx = 0.2;,Mn = -0.2;
        buf = 64.*((buf-Mn)./(Mx-Mn));
        image(px,incchans,buf)
        axis xy
        xlim([-0.25 0.75])
        title('Cross-Iso')
        
        %Cent - Iso
        subplot(2,2,s+2)
        buf = (MI(:,:,1,s,sz)-MI(:,:,2,s,sz));
        Mx = 0.3;,Mn = -0.3;
        buf = 64.*((buf-Mn)./(Mx-Mn));
        image(px,incchans,buf)
        axis xy
        xlim([-0.25 0.75])
        title('Cent-Iso')
    end
end

%Spont act
suot = mean(M(:,sust,4,1,1),2);
figure,plot(incchans,suot,'k')
suot = mean(M(:,sust,4,2,1),2);
hold on,plot(incchans,suot,'b')
title('Anticipatory changes in sustaianed activity')


%Errorbar plots showing the change in modulation produced by teh light
%Cross Iso
figure,
for sz = 1:2
     off = squeeze(Raw(:,:,3,1,sz,:)-Raw(:,:,2,1,sz,:));
     on = squeeze(Raw(:,:,3,2,sz,:)-Raw(:,:,2,2,sz,:));
     Moff = squeeze(nanmean(nanmean(off(:,latet,incpens),2),5));
     Mon = squeeze(nanmean(nanmean(on(:,latet,incpens),2),5));
     
     Int = nanmean(Moff-Mon,2);
     Ints = std(Moff-Mon,[],2)./sqrt(length(incpens))
     
     subplot(1,2,sz)
     errorbar(incchans,Int,Ints)
end
%Errorbar plots showing the change in modulation produced by teh light
%Cent Iso
figure,
for sz = 1:2
     off = squeeze(Raw(:,:,1,1,sz,:)-Raw(:,:,2,1,sz,:));
     on = squeeze(Raw(:,:,1,2,sz,:)-Raw(:,:,2,2,sz,:));
     Moff = squeeze(nanmean(nanmean(off(:,latet,incpens),2),5));
     Mon = squeeze(nanmean(nanmean(on(:,latet,incpens),2),5));
     
     Int = nanmean(Moff-Mon,2);
     Ints = std(Moff-Mon,[],2)./sqrt(length(incpens))
     
     subplot(1,2,sz)
     errorbar(incchans,Int,Ints)
end



%interaction
for sz = 1:2
figure
subplot(2,2,1)
buf = (MI(:,:,3,1,sz)-MI(:,:,2,1,sz))-(MI(:,:,3,2,sz)-MI(:,:,2,2,sz));
imagesc(px,incchans,buf)
axis xy
xlim([-0.25 0.75]),colorbar
title('Cross-Iso')
%Cent / Iso
subplot(2,2,2)
buf = (MI(:,:,1,1,sz)-MI(:,:,2,1,sz))-(MI(:,:,1,2,sz)-MI(:,:,2,2,sz));
imagesc(px,incchans,buf)
axis xy
xlim([-0.25 0.75]),colorbar
title('SurrSupp')
%Cent
subplot(2,2,3)
buf = (MI(:,:,1,1,sz)-MI(:,:,4,1,sz))-(MI(:,:,1,2,sz)-MI(:,:,4,2,sz));
imagesc(px,incchans,buf)
axis xy
xlim([-0.25 0.75]),colorbar
title('VR')

%Summed up over time
subplot(2,2,4)
suot = mean((M(:,sust,3,1,sz)-M(:,sust,2,1,sz))-(M(:,sust,3,2,sz)-M(:,sust,2,2,sz)),2);
plot(incchans,suot,'r')
suot = mean((M(:,sust,1,1,sz)-M(:,sust,2,1,sz))-(M(:,sust,1,2,sz)-M(:,sust,2,2,sz)),2);
hold on,plot(incchans,suot,'b'),xlim([-5 4])
%      suot = mean((M(:,sust,1,1)-M(:,sust,4,1))-(M(:,sust,1,1)-M(:,sust,4,2)),2);
%     hold on,plot(incchans,suot,'k'),xlim([-5 4])
title('Light off - Light on, interaction with effect')
end


%%%CSD
clear MI
mn = -1.5;
mx = 1.5;
for sz = 1:2
    figure
    z = 0;
    for s = 1:2
        for a = 1:4
            z = z+1;
            subplot(2,4,z)
            MI(:,:,a,s,sz) = interp2(X,Y,MCSD(:,:,a,s,sz),XI,YI);
            buf = MI(:,:,a,s,sz)-mn;
            buf = 64.*(buf./(mx-mn));
            image(px,incchans,buf),colorbar
            axis xy,colormap(jetcsd)
            xlim([0 0.5])
        end
    end
end

%Differences
for sz = 1:2
    figure
    z = 0;
    s = 1;
        SS = MI(:,:,1,s,sz)-MI(:,:,2,s,sz);
        CI = MI(:,:,3,s,sz)-MI(:,:,2,s,sz);
        subplot(1,2,1)
        imagesc(px,incchans,SS),colormap(jetcsd),colorbar
        axis xy
        xlim([0 0.5])
        subplot(1,2,2)
        imagesc(px,incchans,CI),colormap(jetcsd),colorbar
        axis xy
        xlim([0 0.5])
end




%LATENCY ANALYSIS
latana = 1;
makelats = 0;
if latana
    if makelats
        PL = 33;
        %Curve-fitting
        %approach%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        latcols = ['r','b','c','k','g'];
        %cross-iso, %Cent-iso %Cent-crs %Cent-only %Surr only
        lt = find(px>0 & px<0.3);
        clear coeff,clear iplat,clear iplats,clear islope,clear islopes
        lut_lat = [];
        for sz = 1:2
            for chn = 1:length(incchans)
                %MAke the data
                clear meanR
                clear diff
                clear alla
              
                diff(1,:) = nanmean(Raw(chn,lt,3,1,sz,:)-Raw(chn,lt,2,1,sz,:),6);
                diff(2,:) =  nanmean(Raw(chn,lt,1,1,sz,:)-Raw(chn,lt,2,1,sz,:),6);
                diff(3,:) = nanmean(Raw(chn,lt,1,1,sz,:)-Raw(chn,lt,3,1,sz,:),6);
                diff(4,:) =nanmean(Raw(chn,lt,1,1,sz,:),6);%Cent only
               
                for r = 1:4
                    for t = 1:length(incpens)
                        switch r
                            case 1
                                buf = Raw(chn,lt,3,1,sz,incpens(t))-Raw(chn,lt,2,1,sz,incpens(t));
                            case 2
                                buf =  Raw(chn,lt,1,1,sz,incpens(t))-Raw(chn,lt,2,1,sz,incpens(t));
                            case 3
                                buf = Raw(chn,lt,1,1,sz,incpens(t))-Raw(chn,lt,3,1,sz,incpens(t));
                            case 4
                                buf = Raw(chn,lt,1,1,sz,incpens(t));
                        end
                        
                        %HERE are where the latencies are made at the
                        %individual channel level
                        if r < 4
                            [plat(t),pcf(t,:),prs(t),pcon(t),model(t)] = latencyfitmouse1gauss(buf,px(lt),0,0,PL);
                        else
                            [plat(t),pcf(t,:),prs(t),pcon(t),model(t)] = latencyfitmouse1gauss(buf,px(lt),1,0,PL);
                        end
                        
                        %Store in a look-up table to allow statistics
                        lut_lat = [lut_lat;[sz,chn,r,t,plat(t),prs(t),pcon(t),pcf(t,:)]];
                    end
                    %these are the mean latencies across pens that will be used later
                    %in teh main graph
                    iplat(chn,sz,r) = mean(plat(prs>0.3 & pcon));
                    iplats(chn,sz,r) = std(plat(prs>0.3 & pcon))./sqrt(sum(prs>0.3 & pcon));
                    %also try median
                    iplatm(chn,sz,r) = median(plat(prs>0.3 & pcon));
                    iplatms(chn,sz,r) = bootse(plat(prs>0.3 & pcon),1000);
                    %slope
                    %Slope is based on the standard deviation of teh first
                    %slope
                    col = (1-(pcf(:,2)<pcf(:,5) | isnan(pcf(:,5)))).*3+3;
                    yu = find(prs>0.3 & pcon);
                    if ~isempty(yu)
                        islope(chn,sz,r) = mean(pcf(sub2ind(size(pcf),yu',col(yu))));
                        islopes(chn,sz,r) = std(pcf(sub2ind(size(pcf),yu',col(yu))))./sqrt(sum(prs>0.3 & pcon));
                    else
                        islope(chn,sz,r) = NaN;
                        islopes(chn,sz,r) = NaN;
                    end
                    
                end
                
                %Tehse are the latencies fit to the average across penetartions, used
                %later at the demo fit graph
                for r = 1:4
                    if r < 4
                        [lat(chn,sz,r),coeff(chn,:,sz,r),rs(chn,sz,r),converge(chn,sz,r),Model(chn,sz,r)] = latencyfitmouse1gauss(diff(r,:),px(lt),0,1,PL);
                    else
                        [lat(chn,sz,r),coeff(chn,:,sz,r),rs(chn,sz,r),converge(chn,sz,r),Model(chn,sz,r)] = latencyfitmouse1gauss(diff(r,:),px(lt),1,1,PL);
                    end
                end
            end
        end
        save(['LatStat',num2str(PL),'_data'],'plat','pcf','prs','pcon','model','lat','coeff','rs','converge','Model','iplatm','iplatms','islope','islopes','iplat','iplats','lut_lat','latcols')
    else
        %LAtency with P set to 10.
        %Lat33_data is normal
        %Lat5 also for paper
        load('LatStat33_data')
        %          load('Lat5_data')
    end
    
    
%     %33 -5% graphs
%     load('Lat33_data')
%     ipb = iplat;
%     load('Lat5_data')
%     diff = ipb-iplat
    
%     %difference plots
%     iplats(isnan(iplats)) = 0;
%     figure
%     for sz = 1:2
%         subplot(2,1,sz)
%         for r = [1 2 4]
%             buf = diff(:,sz,r);
%             bufs = iplats(:,sz,r);
%             buf(~bufs) = NaN;
%             %         buf(rs(:,sz,r)<0.3) = NaN;
%             errorbar(incchans,buf,bufs,latcols(r))
%             hold on
%         end
%     end
    
    
    %these are the latency plots across layers
    iplats(isnan(iplats)) = 0;
    figure
    for sz = 1:2
        subplot(2,1,sz)
        for r = [1 2 4]
            buf = iplat(:,sz,r);
            bufs = iplats(:,sz,r);
            buf(~bufs) = NaN;
            %         buf(rs(:,sz,r)<0.3) = NaN;
            errorbar(incchans,buf,bufs,latcols(r))
            hold on
        end
    end
    
    %Slope plots?
      islopes(isnan(islopes)) = 0;
    figure
    for sz = 1:2
        subplot(2,1,sz)
        for r = [1 2 4]
            buf = islope(:,sz,r);
            bufs = islopes(:,sz,r);
            buf(~bufs) = NaN;
            %         buf(rs(:,sz,r)<0.3) = NaN;
            errorbar(incchans,buf,bufs,latcols(r))
            hold on
        end
    end
    
    iplatms(isnan(iplatms)) = 0;
    figure
    for sz = 1:2
        subplot(2,1,sz)
        for r = [1 2 4]
            buf = iplatm(:,sz,r);
            bufs = iplatms(:,sz,r);
            buf(~bufs) = NaN;
            %         buf(rs(:,sz,r)<0.3) = NaN;
            errorbar(incchans,buf,bufs,latcols(r))
            hold on
        end
    end
    
    
    %STAts
    %Does SS latency vary across layers?
    %One-way repeated measures ANOVA
    %[sz,chn,r,t,plat(t),prs(t),pcon(t)]
    pdt = NaN(10,2);
    pdtr = NaN(10,2);
    pdt2 = NaN(10,2);
    pdtr2 = NaN(10,2);
    clear pdtcsr
    for sz = 1:2
        M = [];
        H = [];
        V = [];
        vdets = [];
        dets = [];
        hdets = [];
        
        %Layer based stats for overlay on graph.
        %Are SS and OTSS different?
        %Compartment based stats, not used at the moment.
        for lay = 1:10
            
            %Surround suppression latency
            ss = find(lut_lat(:,2) == lay & lut_lat(:,1) == sz & lut_lat(:,3) == 2);
            %VR
            vr = find(lut_lat(:,2) == lay & lut_lat(:,1) == sz & lut_lat(:,3) == 4);
            %CI
            ci = find(lut_lat(:,2) == lay & lut_lat(:,1) == sz & lut_lat(:,3) == 1);
            
            
            %CI vs. SS
            %Need to get chans where bioth the crossiso (#1) and centiso (#2) have
            %a good rs.
            %Get rid of any with bad Rs
            goodrs = lut_lat(ss,6)>0.3 & lut_lat(ci,6)>0.3 & lut_lat(ss,7) & lut_lat(ci,7);
            diff = lut_lat(ss(goodrs),5)-lut_lat(ci(goodrs),5);
            if ~isempty(diff)
                %t-test
                [h,pdt(lay,sz)] = ttest(diff);
                pdtr(lay,sz) = signrank(diff);
                nch(lay,sz)= length(diff);
            end
            
            %VR vs. SS
            %Need to get chans where bioth the crossiso (#1) and centiso (#2) have
            %a good rs.
            %Get rid of any with bad Rs
            goodrs = lut_lat(ss,6)>0.3 & lut_lat(vr,6)>0.3 & lut_lat(ss,7) & lut_lat(vr,7);
            diff = lut_lat(ss(goodrs),5)-lut_lat(vr(goodrs),5);
            if ~isempty(diff)
                %t-test
                [h,pdt2(lay,sz)] = ttest(diff);
                pdtr2(lay,sz) = signrank(diff);
                nch2(lay,sz)= length(diff);
            end
        end
        
        M = [];
        H = [];
        V = [];
        vdets = [];
        dets = [];
        hdets = [];
        
        for c = 1:3
            %Surround suppression latency
            f = find((lut_lat(:,2) >= comp(c,1) & lut_lat(:,2) <= comp(c,2)) & lut_lat(:,1) == sz & lut_lat(:,3) == 2 & lut_lat(:,6) >0.3 & lut_lat(:,7));
            M = [M;lut_lat(f,5)];
            dets = [dets;ones(length(f),1).*c];
            ssmeds(c,sz) = median(lut_lat(f,5));
            
            %VR
            g = find((lut_lat(:,2) >= comp(c,1) & lut_lat(:,2) <= comp(c,2)) & lut_lat(:,1) == sz & lut_lat(:,3) == 4 & lut_lat(:,6) >0.3 & lut_lat(:,7));
            vrmeds(c,sz) = median(lut_lat(g,5));
            vrmeans(c,sz) = mean(lut_lat(g,5));
            
            %CI
            f = find((lut_lat(:,2) >= comp(c,1) & lut_lat(:,2) <= comp(c,2)) & lut_lat(:,1) == sz & lut_lat(:,3) == 1 & lut_lat(:,6) >0.3 & lut_lat(:,7));
            V = [V;lut_lat(f,5)];
            vdets = [vdets;ones(length(f),1).*c];
            
            %CIdiff with CentISo
            %Need to get chans where bioth the crossiso (#1) and centiso (#2) have
            %a good rs.
            i = find((lut_lat(:,2) >= comp(c,1) & lut_lat(:,2) <= comp(c,2)) & lut_lat(:,1) == sz & lut_lat(:,3) == 1);
            j = find((lut_lat(:,2) >= comp(c,1) & lut_lat(:,2) <= comp(c,2)) & lut_lat(:,1) == sz & lut_lat(:,3) == 2);
            %Get rid of any with bad Rs
            goodrs = lut_lat(i,6)>0.3 & lut_lat(j,6)>0.3 & lut_lat(i,7) & lut_lat(j,7)
            diff = lut_lat(i(goodrs),5)-lut_lat(j(goodrs),5);
            %get intersection fo channels/t'
            diffmeds(c,sz) = median(diff);
            H = [H;diff];
            hdets = [hdets;ones(length(diff),1).*c];
            %t-test
            [h,pdtc(c,sz)] = ttest(diff);%Should be signrank
            pdtcsr(c,sz) = signrank(diff);%Should be signrank
        end
        [h,pdth(sz)] = ttest(H);
        %Do latencies vary across comps?
        p(sz) = anovan(M,dets); %SS latency
        kp_ss(sz) = kruskalwallis(M,dets);
        pd(sz) = anovan(H,hdets); %Diff betwen crossiso and centiso
        kp_ssci(sz) = kruskalwallis(H,hdets);
        pv(sz) = anovan(V,vdets); %CrossIso
        kp_ci(sz) = kruskalwallis(V,vdets)
        
    end
    
    
    clear diff
    %Plot otu mod differences for each layer AND ADD LATENCY
    %These are the demo fits from teh paper.
    %E.g. Figure 5G
    latcolv = [1 0 0;0 0 1;0 1 1;0 0 0;0 1 0];
    for sz = 1:2
        figure
        for chn = 1:length(incchans)
            for a = 1:4 %cent,iso,cross
                meanR(a,:) = nanmean(Raw(chn,lt,a,1,sz,:),6);
            end
            diff(1,:) = meanR(3,:)-meanR(2,:);%Cross-iso (red)
            diff(2,:) = meanR(1,:)-meanR(2,:);%Cent-iso
            diff(4,:) = meanR(1,:);%Cent
            subplot(2,5,chn)
            for r = [1 2 4]
                
                plot(px(lt),diff(r,:),latcols(r))
                hold on
                
           
                %Vertical line at iplat (i.e. the mean latency across pens)
                h =line([iplatm(chn,sz,r) iplatm(chn,sz,r)],[0.3 0.4]),set(h,'Color',latcolv(r,:))
                %Hprozonta; line has 95% conf interval (1.96*se)
                h =line([iplatm(chn,sz,r)-1.96*iplatms(chn,sz,r) iplatm(chn,sz,r)+1.96*iplatms(chn,sz,r)],[0.35 0.35]),set(h,'Color',latcolv(r,:))

                %Regenerate curve-fits
                cf = coeff(chn,:,sz,r);
                Mod = Model(chn,sz,r);
                
                a = cf(1);
                b = cf(2);
                c = cf(3);
                if Mod==1
                    d = cf(4);
                    e = cf(5);
                    f = cf(6);
                end
                t = px(lt);
                if Mod == 1
                    yf = a.*normpdf(t,b,c)+d.*normcdf(t,e,f);
                elseif Mod == 2
                    yf = a.*normpdf(t,b,c);
                elseif Mod == 3
                    yf = a.*normcdf(t,b,c);
                end
                plot(t,yf,latcols(r))
                xlim([0 0.3])
            end
        end
    end
    
    
    
    figure
    buf1 = iplat(:,1,5);
    buf1s = iplats(:,1,5);
    buf1(~buf1s) = NaN;
    buf2 = iplat(:,2,5);
    buf2s = iplats(:,2,5);
    buf2(~buf2s) = NaN;
    plot(incchans,buf1),hold on,plot(incchans,buf2,'r')
    
    
end


return


































%Raw light indiced changes in response
figure
for n = 1:N
    clear Mn
    %Get mean responses to all conds
    tm = find(px>0 & px<1);
    for o = 1:2
        for chn = 1:length(incchans)
            for a = [6 8 12 14]
                %PEN no, channel number, adjusted channel number, cond
                cond = a+((o-1)*17);
                f = find(details(:,3) == incchans(chn) & details(:,4) == cond & details(:,1) == n);
                %Take mean actitivity across pens
                Mn(chn,a,o) = nanmean(nanmean(mgNMUA(f,tm)));
                Mns(chn,a,o) = std(nanmean(mgNMUA(f,tm)))./sqrt(length(f));
            end
        end
    end
    %Changes ion raw data
    change = Mn(:,:,2)-Mn(:,:,1);
    subplot(2,5,n),bar(incchans,change);
    title('Light induced changes in raw data')
    %     legend({'Spont','Sz 1, Ori 1','Sz 1, Ori 2','Sz 2, Ori 1','Sz 2, Ori 2'})
    
end

%SAme for PSTH, (also include SNR in the equation-not done yet)
if 0
    figure
    for n = 1:N
        clear Mn
        %Get mean responses to all conds
        tbm = find(TB>0 & TB<1);
        for o = 1:2
            for chn = 1:length(incchans)
                for a = 1:21
                    %PEN no, channel number, adjusted channel number, cond
                    cond = a+((o-1)*21);
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
end

%Exclude any PENS?
%MAe another col of detauils (col 5) which contains an inclusion flag
% exclude = [3 5 7];
details(:,5) = ones(size(details,1),1);
% for e = 1:length(exclude)
%     f = find(details(:,1) == exclude(e));
%     details(f,5) = 0;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get the mean response to allconditons
%Then plot out comparisons
incchans = [-5:4];
clear Mn
tm = find(px>0 & px<0.5);
for o = 1:2
    for chn = 1:length(incchans)
        for a = 1:21
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
% small = squeeze(mean(Mn(:,2:3,:),2));
% large = squeeze(mean(Mn(:,4:5,:),2));
% iso = squeeze(mean(Mn(:,[6 8 12 14],:),2));
% small_s = squeeze(mean(Mns(:,2:3,:),2));
% large_s = squeeze(mean(Mns(:,4:5,:),2));
% iso_s = squeeze(mean(Mns(:,[6 8 12 14],:),2));
% figure
% title('Size tuning effects')
% errorscatter(incchans',[small,large,iso],[small_s,large_s,iso_s])

%Let's make a more sophisticado version
clear Mn
tm = find(px>0 & px<1);
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
figure,bar(SS)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get the mean response to the grouped conditions
%Then plot out comparisons
tm = find(px>0 & px<1);
for o = 1:2
    for sz = 1:2
        for chn = 1:length(incchans)
            for a = 1:3
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
            conds = allconds(sz,:,a)+((o-1).*21);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            cross = (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            cst = mean(cross,2);
            
            a = 2;
            conds = allconds(sz,:,a)+((o-1).*21);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            iso = (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            ist = mean(iso,2);
            
            a = 1;
            conds = allconds(sz,:,a)+((o-1).*21);
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
tm = find(px>0 & px<1);
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
            conds = allconds(sz,:,a)+((o-1).*21);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            cross = (mgNMUA(f1,tm)+mgNMUA(f2,tm))./2;
            cst = mean(cross,2);
            
            a = 3;
            conds = allconds(sz,:,a)+((o-1).*21);
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


%%%CENT vs ISO
%This calculates (Cross-Iso] at the level of individual pens then takes the
%mean and std of teh difference.
%Also plot the timecourse of teh modulation
tm = find(px>0 & px<1);
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
            conds = allconds(sz,:,a)+((o-1).*21);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            cent = (mgNMUA(f1,:)+mgNMUA(f2,:))./2;
            cst = mean(cent,2);
            
            a = 2;
            conds = allconds(sz,:,a)+((o-1).*21);
            f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(1));
            f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == conds(2));
            iso = (mgNMUA(f1,:)+mgNMUA(f2,:))./2;
            ist = mean(iso,2);
            
            %statistics, the mean paired diff per chan, per pen
            ci_stat = [ci_stat;cst-ist];
            ci_det = [ci_det;repmat([o,chn,sz],length(cst),1)];
            
            %Take mean actitivity across pens
            CIdf(chn,sz,o) = nanmean(nanmean(cent-iso));
            CIdfs(chn,sz,o) = std(nanmean(cent-iso,2))./sqrt(size(iso,1));
            
            %Subtract and plot timecourse%%%%%%%%%%%%%%%
            subplot(2,5,chn)
            sub = nanmean(cent-iso);
            %Optional SE fill
            subse = nanstd(cent-iso)./sqrt(size(cent,1));
            fillx = [px,fliplr(px)];
            filly = [mattsmooth(sub+subse,20),fliplr(mattsmooth(sub-subse,20))];
            %             fill(fillx,filly,fillcol(o,:))
            hold on
            h = plot(px,mattsmooth(sub,100));
            set(h,'Color',optocol(o,:))
            
            title(['Size ',num2str(sz),' - Centre-Iso'])
            xlim([-1 1.5])
            
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
                cond = a+((s-1)*21);
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
        cond1 = 6+(21*(s-1));
        cond2 = 8+(21*(s-1));
        cond3 = 12+(21*(s-1));
        cond4 = 14+(21*(s-1));
        f = find(details(:,5) & details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = mean(mgNMUA(f,:));
        h = plot(px,mattsmooth(buf,10));
        set(h,'Color',col(6,:))
        hold on
        
        %Plot iso (size irrelevant here) (blue)
        s = 2;
        cond1 = 6+(21*(s-1));
        cond2 = 8+(21*(s-1));
        cond3 = 12+(21*(s-1));
        cond4 = 14+(21*(s-1));
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
        cond1 = 6+(21*(s-1));
        cond2 = 8+(21*(s-1));
        cond3 = 12+(21*(s-1));
        cond4 = 14+(21*(s-1));
        f = find(details(:,5) & details(:,3) == incchans(chn) & (details(:,4) == cond1 | details(:,4) == cond2 | details(:,4) == cond3 | details(:,4) == cond4));
        buf = nanmean(mgNPSTH(f,:));
        h = plot(TB,mattsmooth(buf,4));
        set(h,'Color',col(6,:))
        hold on
        
        %Plot iso (size irrelevant here) (blue)
        s = 2;
        cond1 = 6+(21*(s-1));
        cond2 = 8+(21*(s-1));
        cond3 = 12+(21*(s-1));
        cond4 = 14+(21*(s-1));
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
                spont = 1+(21*(o-1));
                cond1 = 13+(21*(o-1));
                cond2 = 15+(21*(o-1));
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
                spont = 1+(21*(o-1));
                cond1 = 13+(21*(o-1));
                cond2 = 15+(21*(o-1));
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
        cond1 = 7+(21*(o-1));
        cond2 = 9+(21*(o-1));
        %We should pre-average both conditions
        f1 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond1);
        f2 = find(details(:,5) & details(:,3) == incchans(chn) & details(:,4) == cond2);
        cross =  (mgNPSTH(f1,tm)+mgNPSTH(f2,tm))./2;
        cst = mean(cross,2);
        
        %get iso
        cond1 = 6+(21*(o-1));
        cond2 = 8+(21*(o-1));
        cond3 = 12+(21*(o-1));
        cond4 = 14+(21*(o-1));
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
    for a = 1:21
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
        for a = 1:21
            
            
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




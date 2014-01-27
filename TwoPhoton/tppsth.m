function record = tppsth(record, channel, stimcodes, pixels, plotit, names,windowsize,stepsize,basemeth,blst)
% TPPSTH - Gives a peristimulus time histogram for one stimcode
%
%[mydata, myt, myavg, bins, responsive]=tppsth(record, channel, stimcodes, pixels, plotit, names,windowsize,stepsize,basemeth,blst)
%
%
%  [DATA, T, AVG, WINDOWTIMES] = TPPSTH(RECORD, CHANNEL,
%       STIMCODES, PIXELS_OR_DATA, PLOTIT, NAMES, WINDOWSIZE,STEPSIZE,
%       BASELINEMETHOD,BLANKID)
%
%  Gives a peristimulus time histogram for stimcodes listed in
%  array STIMCODES.  If STIMCODES is empty, then all stimcodes are
%  used.
%
%  RECORD is contains a struct describing the data.
%  CHANNEL is the channel number to read.
%  PIXELS_OR_DATA can be a cell list of pixel indices that specifies
%  areas of the image to be analyzed, or a struct with previously
%  extracted data.  If it is a struct, it should contain fields
%  'data' and 't' that are returned from TPREADDATA.
%
%  PLOTIT indicates whether or not the data should be plotted.  If
%  PLOTIT is 0, then data is not plotted.  If PLOTIT is 1, then the
%  individual entries are plotted.  If PLOTIT is 2, then the average
%  results are plotted (see AVG below).
%  NAMES should be a cell list of strings that should have as many entries
%  as PIXELS.  WINDOWSIZE is the size of a sliding window for computing average
%  responses and the standard deviation and standard error (in seconds).
%  STEPSIZE is the window step size (in seconds).
%
%  BASEELINEMETHOD specifies the baseline used to identify F in dF/F.
%  0 means spontaneous interval preceding each stimulus.
%  3 means filter the data and use the blank stimulus (if there is one)
%    for baseline.
%
%  BLANKID is the stimulus number of the blank stimulus, or [] for
%  automatic detection.
%
%  DATA is a cell list of the individual responses, T are the time points for
%  these responses.  The individual responses are themselves cell lists,
%  divided into two rows corresponding to stimulus time and interstimulus
%  time.  For example, data{1}{5,1} are the fifth response values to the
%  first stimulus during stimulus on time, and t{1}{5,1} is the time of
%  this response.  data{1}{5,2} is the fifth response during the
%  interstimulus interval.  Note that the stimulus responses will not
%  necessarily occur at even intervals because the frame sampling is not
%  necessarily in phase with the stimulus computer.
%
%  AVG is the average response in each time window.  AVG is a cell
%  matrix; AVG{i}{j} is the average response for cell i for stimulus j.
%
%  Steve VanHooser


if isempty(pixels), error(['No pixel regions specified.']); end;

stims = getstimsfile( record );
if isempty(stims)
    % create stims file
%     stiminterview(record);
%     stims = getstimsfile( record );
      errormsg(['No stimulus file present for ' recordfilter(record) ', Skipping analysis.']);
  return

end;

s.stimscript = stims.saveScript;
s.mti = stims.MTI2;


[s.mti,starttime]=tpcorrectmti(s.mti,record);

do = getDisplayOrder(s.stimscript);

%commented out by Alexander 2010-06-07. Why was it in here?
%do = do(1:max(1,fix(length(do)/2)));


if isempty(stimcodes), stimcodes = 1:numStims(s.stimscript); end;

if nargin<9, baselinemethod = 0; else baselinemethod = basemeth; end;
if nargin<10, blankstimid = []; else blankstimid = blst; end;

if ~isempty(blankstimid), theblankid = blankstimid; else theblankid = -1; end;

if theblankid==-1,
    for i=1:numStims(s.stimscript),
        if isfield(getparameters(get(s.stimscript,i)),'isblank'),
            theblankid = i;
            break;
        end;
    end;
end;

params = tpprocessparams( '', record ); % for analysis params

mydata = {}; myt = {};
masterint = []; masterspint = []; masterintind = []; masterspintind = [];
hwait = waitbar(0,'Calculating PSTH');
for j=1:length(stimcodes)
    stimcodelocs = find(do==stimcodes(j));
    interval = [];
    spinterval = [];
    
    for i=1:length(stimcodelocs),
        dp = struct(getdisplayprefs(get(s.stimscript,do(stimcodelocs(i)))));
        BGpretime = dp.BGpretime;
        if isnan(BGpretime) 
            BGpretime = 0;
        end
        BGposttime = dp.BGposttime;
        if isnan(BGposttime) 
            BGposttime = 0;
        end
%        interval(i,:) = ...
%             [ s.mti{stimcodelocs(i)}.frameTimes(1) (s.mti{stimcodelocs(i)}.startStopTimes(3) + ...
%             0.5*(s.mti{stimcodelocs(i)}.startStopTimes(3)-s.mti{stimcodelocs(i)}.startStopTimes(1)) + BGpretime +BGposttime) ];
%        disp('TPPSTH: TEMP SHORTENED INTEVRAL');
        interval(i,:) = ...
            [ s.mti{stimcodelocs(i)}.frameTimes(1) (s.mti{stimcodelocs(i)}.startStopTimes(3)+ BGpretime +BGposttime) ];

        if BGposttime > 0
            %spinterval(i,:)=[s.mti{stimcodelocs(i)}.startStopTimes(3) s.mti{stimcodelocs(i)}.startStopTimes(4)];
            spinterval(i,:) = [s.mti{stimcodelocs(i)}.startStopTimes(1)-BGposttime+1 s.mti{stimcodelocs(i)}.startStopTimes(1)];
        elseif BGpretime > 0
            if BGpretime > params.separation_from_prev_stim_off
                separation_from_prev_stim_off =  params.separation_from_prev_stim_off; %s
            else
                separation_from_prev_stim_off = 0;
            end
            spinterval(i,:)=[s.mti{stimcodelocs(i)}.startStopTimes(1)+ separation_from_prev_stim_off  s.mti{stimcodelocs(i)}.frameTimes(1)];
        end
    end % stimcodeloc i
    masterint = [masterint ; interval];
    masterintind = [masterintind ; repmat(j,size(interval,1),1)];
    masterspint = [ masterspint ; spinterval];
    masterspintind = [masterspintind ; repmat(j,size(interval,1),1)];
end % stimcode j

meanforbaselines = [];

if iscell(pixels),
    [data,t] = tpreaddata(record, [masterint ; masterspint]-starttime, pixels, 1,channel);
else
    if baselinemethod==3,
        for p=1:size(pixels.data,2),
            [pixels.data{p},meanforbaselines(p)] = tpfilter(pixels.data{p},pixels.t{p});
        end;
    end;
    [data,t] = data2intervals(pixels.data,pixels.t,[masterint; masterspint]-starttime);
end;

window_start = min(0,min(masterspint(:,1)-masterint(:,1)))-windowsize/2;
window_end = max(max(masterint(:,2)-masterint(:,1)),max(masterspint(:,2)-masterint(:,1)))+windowsize/2;

n_selected_rois = size(data,2); 
for j=1:length(stimcodes), % different uniq stimuli
    theindssp = find(masterspintind==j); % all intervals with spont. data for stimulus j
    theinds = find(masterintind==j); % all intervals with data for stimulus j
    for k=1:n_selected_rois
        totalspont = [];
        for i=1:length(theindssp),
            totalspont = cat(1,totalspont,data{length(masterintind)+theindssp(i),k});
        end
        if baselinemethod==3
            if theblankid>0,
                li = find(masterintind==theblankid);
                baseline = [];
                for jj=1:length(li),
                    baseline(end+1) = nanmean(data{li(jj),k});
                end;
                baseline = nanmean(baseline);
            else
                baseline = meanforbaselines(k);
            end
        end
        
        newdata = {}; newt = {};
        newdatacat = []; newtcat = [];
        for i=1:length(theinds),
            if baselinemethod==0, % mean of spontaneous data for each interval
                baseline = nanmean(data{length(masterintind)+theindssp(i),k});
            end
            if isnan(baseline)
                disp('TPPSTH: Baseline is NaN (perhaps no spontaneous data). Taking mean baseline');
                baseline = nanmean(data{theinds(i),k});
            end
            newdata{i,1}= (data{theinds(i),k}-baseline)/baseline; % i.e. Delta F/F
            newt{i,1} = t{theinds(i),k} - (masterint(theinds(i),1)-starttime);
            mynewtinds = find(~isnan(newt{i,1}));
            newdatacat = cat(1,newdatacat,newdata{i,1}(mynewtinds));
            newtcat = cat(1,newtcat,newt{i,1}(mynewtinds));
        end
        for i=1:length(theindssp), % add spontaneous data
            if baselinemethod==0
                baseline = nanmean(data{length(masterintind)+theindssp(i),k});
            end;
            if isnan(baseline)
                disp('baseline is NaN (perhaps no spontaneous data). Taking mean baseline');
                baseline = nanmean(data{theinds(i),k});
                whos baseline
            end
            newdata{i,2}= (data{length(masterintind)+theindssp(i),k}-baseline)/baseline;
            newt{i,2} = t{length(masterintind)+theindssp(i),k} - (masterint(theinds(i),1)-starttime);
            mynewtinds = find(~isnan(newt{i,2}));
            newdatacat = cat(1,newdatacat,newdata{i,2}(mynewtinds));
            newtcat = cat(1,newtcat,newt{i,2}(mynewtinds));
            % above assumes correspondence between theinds and theindssp
        end;
        mydata{j,k} = newdata;  
        myt{j,k} = newt;
        warns = warning('off');
        [Yn,Xn] = slidingwindowfunc(newtcat,newdatacat,window_start,stepsize,window_end,windowsize,'mean',0);
        bins{j,k} = Xn';
        myavg{j,k} = Yn';
        warning(warns);
    end
    waitbar(j/length(stimcodes));
end;
close(hwait); 

% responsive calculation now done in tptuningcurve
if 0
for c=1:n_selected_rois
    dat = [];
    for stim=1:length(stimcodes)
        for rep=1:size(mydata{stim,c},1) % rep
            dat = [dat; mydata{stim,c}{rep,1}];
        end
    end % stim
    [record.measures(c).responsive,record.measures(c).responsive_p] = ttest(dat);
    disp(['TPPSTH: Cell ' num2str(c) ' Responsive p = ' num2str(record.measures(c).responsive_p)]);
end % cell c
end

for i=1:n_selected_rois
     record.measures(i).psth_tbins{1} = cat(1,bins{:,i});
     record.measures(i).psth_response{1} = cat(1,myavg{:,i});
end


if 0 && n_selected_rois>0 % plot 
    clr = 'bgrcmykwbgrcmykwbgrcmykwbgrcmykwbgrcmykwbgrcmykw';
    figure('Numbertitle','off','Name','PSTH');
    maxavg = max(flatten(myavg));
    minavg = min(flatten(myavg));
    rangavg = maxavg-minavg;
    ymax = maxavg + 0.2*rangavg;
    ymin = minavg - 0.2*rangavg;
    for c=1:n_selected_rois
        for stim=1:length(stimcodes)
            subplot(size(myt,2),length(stimcodes),(c-1)*length(stimcodes)+stim);
            hold on
            for rep=1:size(mydata{stim,c},1) % rep
                plot(myt{stim,c}{rep,1},mydata{stim,c}{rep,1},'k' );% stim clr(stim));
                plot(myt{stim,c}{rep,2},mydata{stim,c}{rep,2},'k');% spont ,clr(stim));
            end
            plot(bins{stim,c},myavg{stim,c},clr(stim) ,'linewidth',2 ); %clr(stim)
            ylim([ymin ymax]);
            plot([0 0],[ymin ymax],'color',[1 1 0]);
            if c<n_selected_rois
                set(gca,'xtick',[]);
            else
                xlabel('Time (s)');
            end
            if stim>1
                set(gca,'ytick',[]);
            else
                %ylabel(tpresponselabel(channel));
                ylabel(names{c});
            end
            
        end % stim
    end % cell c
end


if plotit % old routine
    colors = [ 1 0 0 ; 0 1 0; 0 0 1; 1 1 0 ; 0 1 1; 1 0.5 1; 0.5 0 0 ; 0 0.5 0; 0 0 0.5; 0.5 0.5 0; 0.5 0.5 0.5];
    stimcodecell = {};
    for k=1:size(data,2),
        figure;
        hold on;
        legs = {};
        hl = [];
        for j=1:length(stimcodes)
            stimcodecell{j} = int2str(stimcodes(j));
            ind = mod(j,length(colors)); if ind==0, ind = length(colors); end;
            for i=1:size(colors,1), plot(0,0,'color',colors(i,:),'visible','off'); end;
            if plotit==1,
                for i=1:size(mydata{j,k},1),
                    if j==theblankid 
                        lw=20; 
                    else
                        lw = 6; 
                    end
                    h = plot(myt{j,k}{i,1},mydata{j,k}{i,1},'.-','color',colors(ind,:),'markersize',lw);
                    plot(myt{j,k}{i,2},mydata{j,k}{i,2},'.-','color',colors(ind,:),'markersize',lw);
                end;
                if ~isempty(h)
                    hl(end+1) = h(1);
                    legs{end+1} = stimcodecell{j};
                end
            elseif plotit==2,
                if j==theblankid
                    lw=2; 
                else
                    lw = 1; 
                end
                hl(end+1) = plot(bins{j,k},myavg{j,k},'-','color',colors(ind,:),'linewidth',lw);
                legs{end+1} = stimcodecell{j};
            end;
        end;
        legend( hl,legs );
        title(names{k});
        xlabel('Time (s)');
        ylabel(tpresponselabel(channel));
    end;
end;



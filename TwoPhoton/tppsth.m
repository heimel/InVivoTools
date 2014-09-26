function record = tppsth(record, pixels)
% TPPSTH - Gives a peristimulus time histogram
%
%  RECORD = TPPSTH(RECORD, PIXELS_OR_DATA)
%
%  RECORD is contains a struct describing the data.
%  PIXELS_OR_DATA can be a cell list of pixel indices that specifies
%  areas of the image to be analyzed, or a struct with previously
%  extracted data.  If it is a struct, it should contain fields
%  'data' and 't' that are returned from TPREADDATA.
%
% Output:
%   RECORD.measures(i).psth_tbins{1}     % time bin centers 
%   RECORD.measures(i).psth_response{1}  % response for ROI i
%
%  200X-200X Steve VanHooser
%  200X-2014 Alexander Heimel


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

params = tpprocessparams(record ); 

if isempty(pixels)
    errormsg('No pixel regions specified or data given.');
end

s = getstimsfile( record );
if isempty(s)
    errormsg(['No stimulus file present for ' recordfilter(record) ', Skipping analysis.']);
    return
end

[s.MTI2,starttime] = tpcorrectmti(s.MTI2,record);

do = getDisplayOrder(s.saveScript);
stimcodes = 1:numStims(s.saveScript);

if ~isempty(params.blankstimid)
    theblankid = params.blankstimid; 
else
    theblankid = -1;
end

if theblankid==-1 % get blank id stim
    for i=1:numStims(s.saveScript),
        if isfield(getparameters(get(s.saveScript,i)),'isblank'),
            theblankid = i;
            break
        end
    end
end


mydata = {}; myt = {};
masterint = []; masterspint = []; masterintind = []; masterspintind = [];
hwait = waitbar(0,'Calculating PSTH');
for j=1:length(stimcodes)
    stimcodelocs = find(do==stimcodes(j));
    interval = [];
    spinterval = [];
    
    for i=1:length(stimcodelocs),
        dp = struct(getdisplayprefs(get(s.saveScript,do(stimcodelocs(i)))));
        BGpretime = dp.BGpretime;
        if isnan(BGpretime) 
            BGpretime = 0;
        end
        BGposttime = dp.BGposttime;
        if isnan(BGposttime) 
            BGposttime = 0;
        end
        interval(i,:) = ...
            [ s.MTI2{stimcodelocs(i)}.frameTimes(1) (s.MTI2{stimcodelocs(i)}.startStopTimes(3) + params.psth_posttime ) ];
        if BGposttime > 0
            spinterval(i,:) = [s.MTI2{stimcodelocs(i)}.startStopTimes(1)-BGposttime+1 s.MTI2{stimcodelocs(i)}.startStopTimes(1)];
        elseif BGpretime > 0
            if BGpretime > params.separation_from_prev_stim_off
                separation_from_prev_stim_off =  params.separation_from_prev_stim_off; %s
            else
                separation_from_prev_stim_off = 0;
            end
            spinterval(i,:)=[s.MTI2{stimcodelocs(i)}.startStopTimes(1)+ separation_from_prev_stim_off  s.MTI2{stimcodelocs(i)}.frameTimes(1)];
        end
    end % stimcodeloc i
    masterint = [masterint ; interval];
    masterintind = [masterintind ; repmat(j,size(interval,1),1)];
    masterspint = [ masterspint ; spinterval];
    masterspintind = [masterspintind ; repmat(j,size(interval,1),1)];
end % stimcode j

meanforbaselines = [];

if iscell(pixels)
    [data,t] = tpreaddata(record, [masterint ; masterspint]-starttime, pixels, 1);
else
    if params.psth_baselinemethod==3
        for p=1:size(pixels.data,2)
            [pixels.data{p},meanforbaselines(p)] = tpfilter(pixels.data{p},pixels.t{p});
        end
    end
    [data,t] = data2intervals(pixels.data,pixels.t,[masterint; masterspint]-starttime);
end

window_start = min(0,min(masterspint(:,1)-masterint(:,1)))-params.psth_windowsize/2;
window_end = max(max(masterint(:,2)-masterint(:,1)),max(masterspint(:,2)-masterint(:,1)))+params.psth_windowsize/2;

n_selected_rois = size(data,2); 
for j=1:length(stimcodes), % different uniq stimuli
    theindssp = find(masterspintind==j); % all intervals with spont. data for stimulus j
    theinds = find(masterintind==j); % all intervals with data for stimulus j
    for k=1:n_selected_rois
        totalspont = [];
        for i=1:length(theindssp),
            totalspont = cat(1,totalspont,data{length(masterintind)+theindssp(i),k});
        end
        if params.psth_baselinemethod==3
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
        
        newdata = {}; 
        newt = {};
        newdatacat = []; 
        newtcat = [];
        for i=1:length(theinds)
            switch params.psth_baselinemethod
                case 0 % mean of spontaneous data for each interval
                    baseline = nanmean(data{length(masterintind)+theindssp(i),k});
            end
            if isnan(baseline)
                logmsg('Baseline is NaN (perhaps no spontaneous data). Taking mean baseline');
                baseline = nanmean(data{theinds(i),k});
            end
            newdata{i,1} = (data{theinds(i),k}-baseline)/baseline; % i.e. Delta F/F
            newt{i,1} = t{theinds(i),k} - (masterint(theinds(i),1)-starttime);
            mynewtinds = find(~isnan(newt{i,1}));
            newdatacat = cat(1,newdatacat,newdata{i,1}(mynewtinds));
            newtcat = cat(1,newtcat,newt{i,1}(mynewtinds));
        end
        for i=1:length(theindssp) % add spontaneous data
            switch params.psth_baselinemethod
                case 0 % mean of spontaneous data for each interval
                    baseline = nanmean(data{length(masterintind)+theindssp(i),k});
            end
            if isnan(baseline)
                logmsg('baseline is NaN (perhaps no spontaneous data). Taking mean baseline');
                baseline = nanmean(data{theinds(i),k});
            end
            newdata{i,2}= (data{length(masterintind)+theindssp(i),k}-baseline)/baseline;
            newt{i,2} = t{length(masterintind)+theindssp(i),k} - (masterint(theinds(i),1)-starttime);
            mynewtinds = find(~isnan(newt{i,2}));
            newdatacat = cat(1,newdatacat,newdata{i,2}(mynewtinds));
            newtcat = cat(1,newtcat,newt{i,2}(mynewtinds));
            % above assumes correspondence between theinds and theindssp
        end
        mydata{j,k} = newdata;  
        myt{j,k} = newt;
        warns = warning('off');
        [Yn,Xn] = slidingwindowfunc(newtcat,newdatacat,window_start,params.psth_stepsize,window_end,params.psth_windowsize,'mean',0);
        bins{j,k} = Xn';
        myavg{j,k} = Yn';
        
        ind0 = find(bins{j,k}<0,1,'last');
        myavg{j,k} = myavg{j,k} - myavg{j,k}(ind0);  
        
        warning(warns);
    end % roi k
    waitbar(j/length(stimcodes));
end % stim j
close(hwait); 

for i=1:n_selected_rois
     record.measures(i).psth_tbins{1} = cat(1,bins{:,i});
     record.measures(i).psth_response{1} = cat(1,myavg{:,i});
end


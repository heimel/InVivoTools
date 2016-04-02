function [record,resp] = tptuningcurve(record, pixels)
%  TPTUNINGCURVE - Tuning curve for two-photon data
%
%  RESPS = TPTUNINGCURVE(RECORD, CHANNEL, PARAMETER, PIXELS_OR_DATA, PLOTIT, NAMES,
%            [TRIALS], [T0 T1],[SP0 SP1],BLANKSTIMID)
%
%    Computes mean responses, standard deviations, standard error, and
%  individual responses for a directory of two-photon data that
%  also has NewStim stimulus data associated with it.
%
%  RECORD is the struct describing the data resides.  CHANNEL is the
%  channel number of data to read.
%
%  PARAMETER is the name of the parameter to be examined (e.g., 'angle' for
%  the angle of a periodicstim).  Alternatively, the user can specify [] and
%  output values will be numbered from 1 .. number of stimuli.
%  The data are averaged over the entire course of the stimulus presentation.
%
%  PIXELS_OR_DATA can either be a cell list that specifies areas of the image
%  to be analyzed, or a struct with previously extracted data.
%  If it is a cell list of pixels, then each entry should be indices
%  corresponding to the pixels in each region.  If it is a struct, it should
%  contain fields 'data' and 't' that are returned from TPREADDATA.
%
%  Any interstimulus time is used to compute spontaneous activity.
%
% RESPS is a structure of length (PIXELS) with the following entries:
%     2013-06-23 USE OF RESPS IS DEPRECATED, USE RECORD ONLY
%
%    'curve' is a matrix with four rows; the first row contains the
%      data point labels, the second row contains the mean response
%      value divided by the mean spontaneous value, the third row
%      is the standard deviation, and the fourth row is standard error
%
%    'ind' is a cell list that contains all individual responses for
%      each stimulus.  This is dF/F.
%
%    'spont' is a vector with the mean, standard deviation, and
%       standard error measured over the interstimulus time
%
%    'indspont' is a vector containing the individual responses during the
%    spontaneous periods.
%
%    'indf' is a vector containing the individual responses for each
%      stimulus.  This is F.
%
%    'blankresp' is a vector containing mean, standard deviation, and standard
%       error of responses during a blank trial, if it exists
%    'blankind' is a list of individual responses to the blank condition
%
%
%  200X Steve Vanhooser, 200X-2014 Alexander Heimel

params = tpprocessparams( record );
channel = params.response_channel;
thetrials = [];
timeint= [];
sponttimeint= [];


if ~isempty(params.blankstimid)
    theblankid = params.blankstimid;
else
    theblankid = -1;
end


s = getstimsfile( record );
if isempty(s)
    errormsg(['No stimulus file present for ' recordfilter(record) ', Skipping analysis.']);
    return
end

% get paramname
paramname = varied_parameters(s.saveScript);
if isempty(paramname)
    logmsg('No parameter varied');
    paramname = {''};
end
ind = strmatch(record.stim_type,paramname);
if isempty(ind)
    paramname = paramname{1};
else
    paramname = paramname{ind};
end

if (isempty(paramname) || strcmp(paramname,'location')) && ...
        (~isempty(strfind(lower(record.stim_type),'til')) ||...
        ~isempty(strfind(lower(record.stim_type),'position')))
    variable = 'position';
    stimparams = cellfun(@getparameters,get(s.saveScript));
    rects = cat(1,stimparams(:).rect);
    left = uniq(sort(rects(:,1)));
    right = uniq(sort(rects(:,3)));
    top = uniq(sort(rects(:,2)));
    bottom = uniq(sort(rects(:,4)));
    center_x = (left+right)/2;
    center_y = (top+bottom)/2;
    n_x = length(center_x);
    n_y = length(center_y);
    stimrect = [min(left) min(top) max(right) max(bottom)];
else
    variable = paramname;
end

[s.MTI2,starttime] = tpcorrectmti(s.MTI2,record);
do = getDisplayOrder(s.saveScript);

tottrials = length(do)/numStims(s.saveScript);

if isempty(thetrials)
    do_analyze_i = 1:length(do);
else
    do_analyze_i = [];
    for i=1:length(thetrials),
        do_analyze_i = cat(2,do_analyze_i,...
            fix(1+(thetrials(i)-1)*length(do)/tottrials):fix(thetrials(i)*length(do)/tottrials));
    end;
end;

interval = zeros(length(do_analyze_i),2);
spinterval = zeros(length(do_analyze_i),2);
for i=1:length(do_analyze_i),
    stimind = do_analyze_i(i);
    if ~isempty(timeint),
        interval(i,:) = s.MTI2{stimind}.frameTimes(1) + timeint;
    else
        stimtime = s.MTI2{stimind}.startStopTimes(3)-s.MTI2{stimind}.startStopTimes(2);
        response_window =[params.response_window(1) min(stimtime,params.response_window(2))];
        interval(i,:) = s.MTI2{stimind}.startStopTimes(2) + response_window;
    end;
    
    dp = struct(getdisplayprefs(get(s.saveScript,do(i))));
    if ~isempty(sponttimeint),
        spinterval(i,:) = s.MTI2{stimind}.frameTimes(1) + sponttimeint;
    else
        BGpretime = dp.BGpretime;
        if isnan(BGpretime)
            BGpretime = 0;
        end
        BGposttime = dp.BGposttime;
        if isnan(BGposttime)
            BGposttime = 0;
        end
        
        if BGposttime > 0,  % always analyze before time
            spinterval(i,:)=[s.MTI2{stimind}.startStopTimes(1)-BGposttime+1 s.MTI2{stimind}.startStopTimes(1)];
            spinterval(i,:)=[s.MTI2{stimind}.startStopTimes(1)-BGposttime+1 s.MTI2{stimind}.startStopTimes(1)];
        elseif BGpretime > 0,
            if BGpretime > params.separation_from_prev_stim_off
                separation_from_prev_stim_off =  params.separation_from_prev_stim_off; %s
            else
                separation_from_prev_stim_off = 0;
            end
            spinterval(i,:)=[s.MTI2{stimind}.startStopTimes(1)+separation_from_prev_stim_off s.MTI2{stimind}.frameTimes(1)];
        end
    end
end

meanforbaselines = [];

if iscell(pixels),
    [data,t] = tpreaddata(record, [interval; spinterval]-starttime, pixels,0, channel);
else
    if params.response_baselinemethod==3,
        meanforbaselines = zeros(1,size(pixels.data,2));
        for p=1:size(pixels.data,2)
            [pixels.data{p},meanforbaselines(p)] = tpfilter(pixels.data{p},pixels.t{p});
        end
    end
    [data,t] = data2intervals(pixels.data,pixels.t,[interval; spinterval]-starttime);
end

for p=1:size(data,2) % roi p
    curve = []; indspont = []; ind = {}; indf = {}; 
    indspontt = []; indspontm = []; indsponttm = [];
    blankd = []; blankt = []; blankdm = []; blanktm = [];
    
    for i=(size(interval,1)+1):(size(interval,1)+size(spinterval,1)),
        indspont = cat(1,indspont,data{i,p});
        indspontt = cat(1,indspontt,t{i,p});
        indspontm = cat(1,indspontm,nanmean(data{i,p}));
        indsponttm = cat(1,indsponttm,nanmean(t{i,p}));
    end;
    spont = [ nanmean(indspont) nanstd(indspont) nanstderr(indspont) ];
    
    if theblankid==-1,
        for i=1:numStims(s.saveScript),
            if isfield(getparameters(get(s.saveScript,i)),'isblank')
                theblankid = i;
                break
            end
        end
    end
    if theblankid>0,
        li = find(do(do_analyze_i)==theblankid);
        for j=1:length(li),
            mn = data{li(j),p};
            blankd = cat(1,blankd,mn);
            blankt = cat(1,blankt,t{li(j),p});
            blankdm = cat(1,blankdm,nanmean(mn));
            blanktm = cat(1,blanktm,nanmean(t{li(j),p}));
        end
    end
    
    if params.response_baselinemethod==3,
        if theblankid>0,
            baseline = repmat(nanmean(blankdm),1,(size(interval,1)+size(spinterval,1)));
        else
            baseline = repmat(meanforbaselines(p),1,(size(interval,1)+size(spinterval,1)));
        end
    else
        baseline = compute_baseline(interval(:,1)-starttime,params.response_baselinemethod,indspont,indspontt,indspontm,indsponttm,blankd,blankt,blankdm,blanktm);
    end
    
    myind = 1;
    for i=1:numStims(s.saveScript)
        if theblankid~=i,
            li = find(do(do_analyze_i)==i);
            if ~isempty(li) % make sure the stim was actually shown
                ind{myind} = [];  %#ok<AGROW>
                indf{myind} = []; %#ok<AGROW>
                for j=1:length(li)
                    mn = nanmean(data{li(j),p}');
                    ind{myind} = cat(1,ind{myind},(mn-baseline(li(j)))/baseline(li(j))); %#ok<AGROW>
                    indf{myind} = cat(1,indf{myind},mn);
                end
                if isempty(paramname)
                    curve(1,myind) = myind; %#ok<AGROW>
                else
                    curve(1,myind) = getfield( getparameters(get(s.saveScript,i)),paramname); %#ok<GFLD>
                end;
                curve(2,myind) = nanmean(ind{myind}); %#ok<AGROW>
                curve(3,myind) = nanstd(ind{myind}); %#ok<AGROW>
                curve(4,myind) = nanstderr(ind{myind}); %#ok<AGROW>
                myind = myind + 1;
            end
        else
            li = find(do(do_analyze_i)==i);
            blankind = [];
            for j=1:length(li),
                mn = nanmean(data{li(j),p}');
                blankind = cat(1,blankind,(mn-baseline(li(j)))/baseline(li(j)));
            end
            blankresp = [nanmean(blankind) nanstd(blankind) nanstderr(blankind)];
        end
    end % stimulusnumber i
    
    switch params.response_projection_method
        case 'none'
            % do nothing
        case 'mean'
            uniqstims = uniq(sort(curve(1,:)));
            proj_curve = zeros(4,length(uniqstims));
            for j = 1:length(uniqstims)
                stim = uniqstims(j);
                indstim = find( curve(1,:) == stim );
                proj_curve(1,j) = stim;
                proj_curve(2,j) = mean(curve(2,indstim));
                proj_curve(3,j) = norm(curve(3,indstim),2) + std(curve(2,indstim));
                n = sum((curve(3,indstim)./curve(4,indstim)).^2);
                if isnan(n)
                    n=inf;
                end
                proj_curve(4,j) = norm(curve(3,indstim),2)/sqrt(n) + sem(curve(2,indstim));
            end
            curve = proj_curve;
        case 'max'
            uniqstims = uniq(sort(curve(1,:)));
            proj_curve = zeros(4,length(uniqstims));
            for j = 1:length(uniqstims)
                stim = uniqstims(j);
                indstim = find( curve(1,:) == stim );
                proj_curve(1,j) = stim;
                [proj_curve(2,j),indmax] = max(curve(2,indstim));
                proj_curve(3,j) = curve(3,indstim(indmax));
                proj_curve(4,j) = curve(4,indstim(indmax));
            end
            curve = proj_curve;
    end
    
    record.measures(p).triggers = 0;
    record.measures(p).variable = variable;
    record.measures(p).range = {curve(1,:)};
    record.measures(p).response = {curve(2,:)};
    [m,ind] = max(record.measures(p).response{1});
    record.measures(p).preferred_stimulus = {record.measures(p).range{1}(ind)};
    record.measures(p).relative_range = { (1:length(curve(1,:)))-ind}; 
    record.measures(p).response_normalized ={curve(2,:) / m};
    record.measures(p).curve = curve;
    record.measures(p).ind = {ind};
    record.measures(p).spont = spont;
    record.measures(p).channel = channel;
    if exist('blankresp','var')==1,
        record.measures(p).blankresp = blankresp;
        record.measures(p).blankind = blankind;
    end;
    record.measures(p).response_max = {max(curve(2,:))};
    
    for trigger = 1:length(record.measures(p).response_max) % selectivity index
        record.measures(p).selectivity_index{trigger} = ...
            (max(record.measures(p).response{trigger})-(min(record.measures(p).response{trigger}))) / ...
            max(record.measures(p).response{trigger});
    end % trigger
    
    switch lower(record.measures(p).variable)
        case 'angle'
            newmeasures = compute_angle_measures(record.measures(p));
            if ~isempty(newmeasures)
                record.measures = structconvert(record.measures,newmeasures);
            end
            record.measures(p) = newmeasures;
        case 'contrast'
            newmeasures = compute_contrast_measures(record.measures(p));
             if ~isempty(newmeasures)
                record.measures = structconvert(record.measures,newmeasures);
            end
            record.measures(p) = newmeasures;
        case 'sfrequency'
            newmeasures = compute_sfrequency_measures(record.measures(p));
             if ~isempty(newmeasures)
                record.measures = structconvert(record.measures,newmeasures);
            end
            record.measures(p) = newmeasures;
        case 'size'
            record.measures(p).suppression_index = compute_suppression_index( curve(1,:), curve(2,:) );
        case 'position'
            record.measures(p).rect = stimrect;
            resp_by_pos = reshape(curve(2,:),n_x,n_y)';
            resp_by_pos = thresholdlinear(resp_by_pos);
            record.measures(p).rf{1} = resp_by_pos;
            center_of_mass_x = center_x(:)'*  sum(resp_by_pos,1)'/sum(resp_by_pos(:));
            center_of_mass_y = center_y(:)'*sum(resp_by_pos,2)/sum(resp_by_pos(:));
            record.measures(p).rf_center{1} = round([center_of_mass_x center_of_mass_y]);            
    end
    
    record.measures(p).responsive = any(curve(2,:)-2*curve(4,:)>0);
    
%    resp(p) = record.measures(p); %#ok<AGROW>
end % roi p
resp = record.measures;

try
    responsedata = cellfun(@mean,data(1:end/2,:)); % mean F over interval
    spontdata = cellfun(@mean,data(end/2+1:end,:)); % mean F over interval
    last_spont = cellfun(@(x) x(end),data(end/2+1:end,:)); % last F (for spontaneous data)
    first_response = cellfun(@(x) x(end),data(1:end/2,:)); % first F (for response data)
    betweenF = (last_spont + first_response)/2;
    [responsive,p]=ttest(responsedata-betweenF,spontdata-betweenF,params.responsive_alpha,'right');
catch me
    logmsg(me.message);
    responsive = nan(size(data,2),1);
    p = nan(size(data,2),1);
end

if length(responsive)==size(data,2)
    for c=1:size(data,2)
        if ~isnan(responsive(c))
            record.measures(c).responsive = responsive(c);
        end
        record.measures(c).responsive_p = p(c);
    end
end



function [record,resp] = tptuningcurve(record, channel, paramname, pixels, plotit, names, trials, tint,sptint, blst, basemeth, projection_method)

%  TPTUNINGCURVE - Tuning curve for two-photon data
%
%  RESPS = TPTUNINGCURVE(RECORD, CHANNEL, PARAMETER, PIXELS_OR_DATA, PLOTIT, NAMES,
%            [TRIALS], [T0 T1],[SP0 SP1],BLANKSTIMID,BASELINE_METHOD,PROJECTION_METHOD)
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
%  If PLOTIT is 1 then data are plotted with titles given in cell list NAMES.
%  There should be one entry in NAMES for each set of pixel indices.
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
% TRIALS is an array list of trial numbers to include.  The stimuli are assumed
%   to have been run in repeating blocks.  If this argument is not present or is
%   empty then all trials are included.
%
% [T0 T1] is the time interval to analyze relative to stimulus onset.  If this
%   argument is not present or empty then the stimulus duration is analyzed.
%
% [SP0 SP1] is the time interval to analyze for computing the resting state
%   relative to stimulus onset. Default if not specified or if empty is specified
%   is to analyze the interval 2 seconds after the last stimulus until stimulus
%   onset.
%
%  BLANKSTIMID is the ID of a stim to consider the blank stimulus.  If EMPTY then
%    stimulus parameters are examined for the presence of an 'isblank' field.
%    If none is found, then no stimulus is considered blank.
%
%  BASELINEMETHOD determines how the baseline is calculated:
%     0  - Use the data collected during the previous ISI
%     1  - Use the closest blank stimulus
%     2  - Use a 20s window of ISI and blank values.
%     3  - Filter data with 240s highpass and use mean
%
%  PROJECTION_METHOD determines how to handle when there is more than one
%       stimulus parameter
%       'none' - do no project
%       'mean' - use response mean over other stimulus parameters
%       'max' - use response maximum over other stimulus parameters
%
%  200X Steve Vanhooser, 200X-2013 Alexander Heimel

if nargin<7, thetrials = []; else thetrials = trials; end;
if nargin<8, timeint= []; else timeint = tint; end;
if nargin<9, sponttimeint= []; else sponttimeint= sptint; end;
if nargin<10, blankstimid = []; else blankstimid = blst; end;
if nargin<11, baselinemethod = 0; else baselinemethod = basemeth; end;
if nargin<12, projection_method = 'none'; end

if ~isempty(blankstimid)
    theblankid = blankstimid; 
else
    theblankid = -1; 
end


 params = tpprocessparams( '', record ); % for analysis params
 

interval = [];
spinterval = [];

stims = getstimsfile( record );
if isempty(stims)
    % create stims file
    stiminterview(record);
    stims = getstimsfile( record );
end;


% get paramname
if isempty(paramname)
    paramname = varied_parameters(stims.saveScript);
    if isempty(paramname)
        disp('TPTUNINGCURVE: No parameter varied');
        paramname = {''};% {'stim_number'};
    end
    ind = strmatch(record.stim_type,paramname);  % notice: changed from record.stim_parameters 2013-03-29!
    if isempty(ind)
        paramname = paramname{1};
    else
        paramname = paramname{ind};
    end
end


if isempty(paramname) && ...
        (~isempty(findstr(lower(record.stim_type),'tile')) ||...
        ~isempty(findstr(lower(record.stim_type),'position')))
    variable = 'position';
    
    
    stimparams = cellfun(@getparameters,get(stims.saveScript));
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



s.stimscript = stims.saveScript;
s.mti = stims.MTI2;
[s.mti,starttime] = tpcorrectmti(s.mti,record);
do = getDisplayOrder(s.stimscript);

tottrials = length(do)/numStims(s.stimscript);

if isempty(thetrials)
    do_analyze_i = 1:length(do);
else
    do_analyze_i = [];
    for i=1:length(thetrials),
        do_analyze_i = cat(2,do_analyze_i,...
            fix(1+(thetrials(i)-1)*length(do)/tottrials):fix(thetrials(i)*length(do)/tottrials));
    end;
end;

for i=1:length(do_analyze_i),
    stimind = do_analyze_i(i);
    if ~isempty(timeint),
        interval(i,:) = s.mti{stimind}.frameTimes(1) + timeint;
    else
        stimtime = s.mti{stimind}.startStopTimes(3)-s.mti{stimind}.startStopTimes(2);
        response_window =[params.response_window(1) min(stimtime,params.response_window(2))];
       % timeint = [0 response_window];
     %  interval(i,:) = [ s.mti{stimind}.frameTimes(1) s.mti{stimind}.startStopTimes(3)];
       interval(i,:) = s.mti{stimind}.startStopTimes(2) + response_window;
    end;
    
    dp = struct(getdisplayprefs(get(s.stimscript,do(i))));
    if ~isempty(sponttimeint),
        spinterval(i,:) = s.mti{stimind}.frameTimes(1) + sponttimeint;
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
            spinterval(i,:)=[s.mti{stimind}.startStopTimes(1)-BGposttime+1 s.mti{stimind}.startStopTimes(1)];
            spinterval(i,:)=[s.mti{stimind}.startStopTimes(1)-BGposttime+1 s.mti{stimind}.startStopTimes(1)];
        elseif BGpretime > 0,
            if BGpretime > params.separation_from_prev_stim_off
                separation_from_prev_stim_off =  params.separation_from_prev_stim_off; %s
            else
                separation_from_prev_stim_off = 0;
            end
            spinterval(i,:)=[s.mti{stimind}.startStopTimes(1)+separation_from_prev_stim_off s.mti{stimind}.frameTimes(1)];
        end;
    end;
end;

meanforbaselines = [];

if iscell(pixels),
    [data,t] = tpreaddata(record, [interval; spinterval]-starttime, pixels,0, channel);
else
    if baselinemethod==3,
        for p=1:size(pixels.data,2),
            [pixels.data{p},meanforbaselines(p)] = tpfilter(pixels.data{p},pixels.t{p});
        end;
    end;
    [data,t] = data2intervals(pixels.data,pixels.t,[interval; spinterval]-starttime);

end;

for p=1:size(data,2) % roi p
    curve = []; spcurve = []; indspont = []; ind = {}; indf = {}; indspontt = []; indspontm = []; indsponttm = [];
    blankd = []; blankt = []; blankdm = []; blanktm = [];
    
    for i=(size(interval,1)+1):(size(interval,1)+size(spinterval,1)),
        indspont = cat(1,indspont,data{i,p});
        indspontt = cat(1,indspontt,t{i,p});
        indspontm = cat(1,indspontm,nanmean(data{i,p}));
        indsponttm = cat(1,indsponttm,nanmean(t{i,p}));
    end;
    spont = [ nanmean(indspont) nanstd(indspont) nanstderr(indspont) ];
    
    if theblankid==-1,
        for i=1:numStims(s.stimscript),
            if isfield(getparameters(get(s.stimscript,i)),'isblank'),
                theblankid = i;
                break;
            end;
        end;
    end;
    if theblankid>0,
        li = find(do(do_analyze_i)==theblankid);
        for j=1:length(li),
            mn = data{li(j),p};
            blankd = cat(1,blankd,mn);
            blankt = cat(1,blankt,t{li(j),p});
            blankdm = cat(1,blankdm,nanmean(mn));
            blanktm = cat(1,blanktm,nanmean(t{li(j),p}));
        end;
    end;
    
    if baselinemethod==3,
        if theblankid>0,
            baseline = repmat(nanmean(blankdm),1,(size(interval,1)+size(spinterval,1)));
        else
            baseline = repmat(meanforbaselines(p),1,(size(interval,1)+size(spinterval,1)));
        end;
    else
        baseline = compute_baseline(interval(:,1)-starttime,baselinemethod,indspont,indspontt,indspontm,indsponttm,blankd,blankt,blankdm,blanktm);
    end;
    
    myind = 1;

 %   figure
 %           hold on;
%clr='kbrgyc';
            
    for i=1:numStims(s.stimscript)
        if theblankid~=i,
            li = find(do(do_analyze_i)==i);
            
            
            if ~isempty(li), % make sure the stim was actually shown
                ind{myind} = []; indf{myind} = [];
                for j=1:length(li),

%                    plot(data{li(j),3},clr(i));
                    
                    mn = nanmean(data{li(j),p}');
                    %ind{myind} = cat(1,ind{myind},(mn-indspont(li(j)))/indspont(li(j)));
                    ind{myind} = cat(1,ind{myind},(mn-baseline(li(j)))/baseline(li(j)));
                    indf{myind} = cat(1,indf{myind},mn);
                end;
                if isempty(paramname),
                    curve(1,myind) = myind;
                else
                    curve(1,myind) = getfield(getparameters(get(s.stimscript,i)),paramname);
                end;
                curve(2,myind) = nanmean(ind{myind});
                curve(3,myind) = nanstd(ind{myind});
                curve(4,myind) = nanstderr(ind{myind});
                myind = myind + 1;
            end
        else
            li = find(do(do_analyze_i)==i);
            blankind = [];
            for j=1:length(li),
                mn = nanmean(data{li(j),p}');
                %blankind = cat(1,blankind,(mn-indspont(li(j)))/indspont(li(j)));
                blankind = cat(1,blankind,(mn-baseline(li(j)))/baseline(li(j)));
            end;
            blankresp = [nanmean(blankind) nanstd(blankind) nanstderr(blankind)];
        end;
    end; % stimulusnumber i
    
    switch projection_method
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
    record.measures(p).response_normalized ={curve(2,:) / m};
    record.measures(p).curve = curve;
    record.measures(p).ind = {ind};
    record.measures(p).spont = spont;
    record.measures(p).indspont = indspont;
    record.measures(p).indf = {indf};
    record.measures(p).channel = channel;
    if exist('blankresp','var')==1,
        record.measures(p).blankresp = blankresp;
        record.measures(p).blankind = blankind;
    end;
    record.measures(p).response_max = max(curve(2,:));
    switch record.measures(p).variable
        case 'angle'
            newmeasures = compute_angle_measures(record.measures(p));
            if ~isempty(newmeasures)
                record.measures = structconvert(record.measures,newmeasures);
            end
            record.measures(p) = newmeasures;
        case 'size'
            record.measures(p).suppression_index = (max(curve(2,:))-curve(2,end))/max(curve(2,:));
            
        case 'position'
            record.measures(p).rect = stimrect;                              
            resp_by_pos = reshape(curve(2,:),n_x,n_y)';
            
            %resp_by_pos = resp_by_pos-min(resp_by_pos(:));
            resp_by_pos = thresholdlinear(resp_by_pos);
            record.measures(p).rf{1} = resp_by_pos;
            center_of_mass_x = center_x(:)'*  sum(resp_by_pos,1)'/sum(resp_by_pos(:));
            center_of_mass_y = center_y(:)'*sum(resp_by_pos,2)/sum(resp_by_pos(:));
            record.measures(p).rf_center{1} = round([center_of_mass_x center_of_mass_y]);
            %disp(['RESULTS_ECTESTRECORD: ' 'Cell ' num2str(measure.index) ' Center of response [x,y] = [ ' num2str(fix(center_x)) ', ' num2str(fix(center_y)) ']']);
                    
    end
    
    record.measures(p).responsive = any(curve(2,:)-2*curve(4,:)>0);
        
    if plotit
        figure;
        hold on;
        if isempty(paramname)
            paramname = '';
        end
        
        switch paramname
            case 'angle'
                curve(1,end+1) = curve(1,1)+360;
                curve(2:4,end) = curve(2:4,1);
                
                plot(curve(1,:),curve(2,:),'ko','linewidth',2);
                [otcurve,pref,hwhh]=fit_otcurve(curve);
                plot(otcurve(1,:),otcurve(2,:),'k');
                
                disp(['Cell ' num2str(p) ': OSI = ' num2str(record.measures(p).osi)]);
            otherwise
                plot(curve(1,:),curve(2,:),'k-','linewidth',2);
                try
                    disp(['Cell ' num2str(p) ': Suppression index = ' num2str(record.measures(p).suppression_index)]);
                end
        end
        
        
        h=myerrorbar(curve(1,:),curve(2,:),curve(4,:),curve(4,:));
        delete(h(2)); set(h(1),'linewidth',2,'color',0*[1 1 1]);
        if exist('blankresp','var')==1, % plot blank response if it exists
            a = axis;
            plot([-1000 1000],blankresp(1)*[1 1],'k-','linewidth',1);
            plot([-1000 1000],[1 1]*(blankresp(1)-blankresp(3)),'k--','linewidth',0.5);
            plot([-1000 1000],[1 1]*(blankresp(1)+blankresp(3)),'k--','linewidth',0.5);
            axis(a); % make sure the axis doesn't get changed on us
        end;
        xlabel(capitalize(paramname));
        ylabel('\Delta F/F');
        title(names{p});
        switch paramname
            case 'eyes'
                set(gca,'Xtick',[0 1 2]);
                set(gca,'Xticklabel',{'Left','Right','Both'});
            case 'angle'
                xlim([-5 365]);
                set(gca,'XTick',(0:45:360));
            otherwise
                % nothing special
        end
        smaller_font(-8);
        bigger_linewidth(2);
    end % plotit
   resp(p) = record.measures(p);
end % roi p

% responses = [];
% for i=1:numStims(s.stimscript),
%     li = find(do(do_analyze_i)==i);
%     responses(end+1:end+length(li),1) =  cellfun(@mean,data(li,p));
%     responses(end-length(li)+1:end,2 ) = i;
% end


responsedata = cellfun(@mean,data(1:end/2,:)); % mean F over interval
spontdata = cellfun(@mean,data(end/2+1:end,:)); % mean F over interval

last_spont = cellfun(@(x) x(end),data(end/2+1:end,:)); % last F (for spontaneous data)
first_response = cellfun(@(x) x(end),data(1:end/2,:)); % first F (for response data)
betweenF = (last_spont + first_response)/2;

[responsive,p]=ttest(responsedata-betweenF,spontdata-betweenF,params.responsive_alpha,'right');
% [responsive,p]=kruskal_wallis_test(responsedata-betweenF,spontdata-betweenF);
%mdata = mdata(1:end/2,:) - edata(end/2+1:end,:); %subtract spontaneous
%[responsive,p] = ttest(mdata(1:end/2,:))
%[responsive,p] = ttest(mdata(1:end/2,:) - mdata(end/2+1:end,:)  )


%responsive = and(responsive,mean(responsedata-spontdata)>0 );
for c=1:size(data,2)
    record.measures(c).responsive = responsive(c);
    record.measures(c).responsive_p = p(c);
    disp(['TPTUNINGCURVE: Cell ' num2str(c) ...
        ' Responsive = ' num2str(record.measures(c).responsive) ...
        ', p = ' num2str(record.measures(c).responsive_p)]);
end
    

% for c=1:size(data,2)
%     % take maximally responsive stimulus
%     [dummy,ind] = max(record.measures(c).response{1}); %#ok<ASGLU>
%     responsedata = cellfun(@mean,data(1:end/2,:)); % mean F over interval
%     spontdata = cellfun(@mean,data(end/2+1:end,:)); % mean F over interval
%     last_spont = cellfun(@(x) x(end),data(end/2+1:end,:)); % last F (for spontaneous data)
%     first_response = cellfun(@(x) x(end),data(1:end/2,:)); % first F (for response data)
%     betweenF = (last_spont + first_response)/2;
%     responsedata = responsedata(do==ind,:);
%     spontdata = spontdata(do==ind,:);
%     betweenF = betweenF(do==ind,:);
%     [responsive,p]=ttest(responsedata-betweenF,spontdata-betweenF);
%     
%     % multiple test correction
%     % p = min(1,p*size(curve,2));
%     
%     record.measures(c).responsive = responsive(c);
%     record.measures(c).responsive_p = p(c);
%     disp(['TPTUNINGCURVE: Cell ' num2str(c) ...
%         ' Responsive = ' num2str(record.measures(c).responsive) ...
%         ', p = ' num2str(record.measures(c).responsive_p)]);
% end



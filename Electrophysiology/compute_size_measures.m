function measures = compute_size_measures( measures, st )
%COMPUTE_SIZE_MEASURES compute some specific size tuning measures
%
%  MEASURES = COMPUTE_SIZE_MEASURES( MEASURES, STIMSFILE )
%
%
% 2014-2016 Alexander Heimel
%

if ~strcmp(measures.variable,'size') 
    return
end

if isfield(st,'saveScript')
    stimscriptfield = 'saveScript';
else
    stimscriptfield = 'stimscript';
end
sscript = st.(stimscriptfield);

if ~iscell(measures.curve)
    measures.curve = {measures.curve};
end

for t=1:length(measures.triggers)
    measures.suppression_index{t} = ...
        compute_suppression_index( measures.range{t}, measures.response{t} );

    response = measures.curve{t}(2,:);
    
    ind_blank = find(measures.range{t}==0);
    if isempty(ind_blank)
        if isfield(measures,'rate_spont')
            baseline = measures.rate_spont{t};
        elseif min(response)<0
            baseline = min(response);
        else
            baseline = 0;
        end
    else
        baseline = mean(measures.curve{t}(2,ind_blank));
    end
    
    response = response - baseline;
        
    par = dog_fit(measures.range{t} ,response );
    par(1) = par(1) + baseline;
    if any(isnan(par))
        logmsg('Could not fit DOG to curve');
        return;
    end
    
    fitx = min(measures.range{t}):0.5:max(measures.range{t}); % only get optimal within tested range
    fity = dog(par,fitx);
    [m,indm] = max(fity); %#ok<ASGLU>
    
    measures.size_fit_optimal{t} = fitx(indm);
    measures.size_fit_suppression_index{t} = ...
        compute_suppression_index( fitx, fity );
    
    % recompute stimulus sizes
    monitor.size_cm = [51 29];
    monitor.size_pxl = [1920 1080];
    monitor.slant_deg = 0;
    monitor.center_rel2nose_cm = [0 0 st.NewStimViewingDistance];
    monitor.tilt_deg = 0;
    % first get monitor info
    switch st.NewStimPixelsPerCm
        case 1920/51 % wall-e
            monitor.size_cm = [51 29];
            monitor.size_pxl = [1920 1080];
            monitor.slant_deg = 45; % left towards mouse
        case 800/70.5 % robbie
            monitor.size_cm = [70.5 70.5/800*600];
            monitor.size_pxl = [800 600];
            monitor.slant_deg = 0;
        otherwise
            logmsg('Cannot recognize monitor settings. Defaulting');
    end

    
    
    do = cellfun(@(x) x.stimid,st.MTI2);
    stims = get(sscript);
    stimind = NaN(length(measures.range{t}),1);
    for i=1:length(measures.range{t})
        for j=1:(length(stims)+1)  % if this goes wrong, something else is wrong
            p = getparameters(stims{j});
            if p.size == measures.range{t}(i)
                stimind(i) = find(do==j,1);
                break;
            end
        end
        
        % lines below are specific for stimuli with equal axes
        rect = st.MTI2{stimind(i)}.MovieParams.Movie_destrects(:,1,1)';
        rect = halfrect(rect); %  destrect is double requested stim, see periodicstim/spatial_phase and makeclippingrgn
        
        [~,angle_mean(i)] = rect2visualangle( rect, monitor);
    end
    measures.range_corrected{t} = angle_mean/pi*180;
    
    
end

function hrect = halfrect(rect)
% halves rect in size
cx = (rect(1)+rect(3))/2;
cy = (rect(2)+rect(4))/2;
w = rect(3)-rect(1);
h = rect(4)-rect(2);
w = w / 2;
h = h / 2;
hrect =round( [ cx-w/2 cy-h/2 cx+w/2 cy+h/2]); 



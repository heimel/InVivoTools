function measures = compute_tfrequency_measures( measures )
%COMPUTE_TFREQUENCY_MEASURES compute some specific spatial frequency measures
%
%  MEASURES = COMPUTE_TFREQUENCY_MEASURES( MEASURES )
%   fits Difference of Gaussians (DOG) to tuning curve and computes
%     tf_fit_optimal
%     tf_fit_halfheight_high
%     tf_fit_halfheight_low 
%     tf_fit_bandwidth = tf_fit_halfheight_high / tf_fit_halfheight_high
%
%   bandwidth and tf_fit_halfheight_low are NaN if the response does not
%   drop below half max
%
% 2016, Alexander Heimel
%
measures.usable=1;

if ~iscell(measures.curve)
    measures.curve = {measures.curve};
end
n_triggers = length(measures.curve);
for t = 1:n_triggers
    ind = find(measures.range{t}==measures.preferred_stimulus{t});
    best = max(measures.response{t}(ind));
    worst = min(measures.response{t}(ind));
    measures.selectivity{t} = (best-worst)/(best+worst);
    
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
    
    measures.tf_fit_optimal{t} = NaN;
    measures.tf_fit_halfheight_high{t} = NaN;
    measures.tf_fit_halfheight_low{t} = NaN;
    measures.tf_fit_bandwidth{t} = NaN;
    measures.tf_fit_lowpass{t} = NaN;

    response = response - baseline;

    par = dog_fit(measures.range{t} ,response );
    par(1) = par(1) + baseline;
    if any(isnan(par))
        logmsg('Could not fit DOG to tf curve');
        return;
    end

    
    
    fitx = min(measures.range{t}):0.001:max(measures.range{t}); % only get optimum in tested range
    fity = dog(par,fitx);
    [m,indm] = max(fity);
    fit_optimal = fitx(indm);
    fitx = 1:0.1:40;
    fity = dog(par,fitx);
    indm = find(fitx>fit_optimal,1);
    indh = find(fity>m/2,1,'last');
    if ~isempty(indh) && indh>indm && fitx(indh)<max(measures.range{t})
        fit_halfheight_high = fitx(indh);
    else 
        fit_halfheight_high = NaN;
    end
    indl = find(fity>m/2,1,'first');
    if ~isempty(indl) && indl<indm && fitx(indl)>min(measures.range{t}) 
        fit_halfheight_low = fitx(indl); 
    else
        fit_halfheight_low = NaN;
    end
    fit_bandwidth = fit_halfheight_high / fit_halfheight_low;
    if ~isnan(fit_halfheight_high) && ~isnan(fit_halfheight_low)
        fit_lowpass = false;
    elseif ~isnan(fit_halfheight_high)
        fit_lowpass = true;
    else
        fit_lowpass = NaN;
    end
    
    
    measures.tf_fit_halfheight_low{t} = fit_halfheight_low;
    measures.tf_fit_halfheight_high{t} = fit_halfheight_high;
    measures.tf_fit_optimal{t} = fit_optimal;
    measures.tf_fit_bandwidth{t} = fit_bandwidth;
    measures.tf_fit_lowpass{t} = fit_lowpass;
end




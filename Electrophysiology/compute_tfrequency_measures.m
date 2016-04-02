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

    response = response - baseline;

    fitx = 0.005:0.001:0.5;
    par = dog_fit(measures.range{t} ,response );
    par(1) = par(1) + baseline;
    
    if any(isnan(par))
        logmsg('Could not fit DOG to tf curve');
        return;
    end
    

    fity = dog(par,fitx);
    [m,indm] = max(fity);
    measures.tf_fit_optimal{t} = fitx(indm);
    
    indh = find(fity>m/2,1,'last');
    if ~isempty(indh) && indh>indm && fitx(indh)<max(measures.range{t})
        measures.tf_fit_halfheight_high{t} = fitx(indh);
    else
        logmsg('Could not fit DOG to tf curve');
        return;
    end
    indl = find(fity>m/2,1,'first');
    if ~isempty(indl) && indl<indm && fitx(indl)>min(measures.range{t}) 
        measures.tf_fit_halfheight_low{t} = fitx(indl); 
    end
    if ~isnan(measures.tf_fit_halfheight_high{t}) && ~isnan(measures.tf_fit_halfheight_low{t})
        measures.tf_fit_bandwidth{t} = measures.tf_fit_halfheight_high{t} / measures.tf_fit_halfheight_high{t};
        measures.tf_fit_lowpass{t} = false;
    elseif ~isnan(measures.tf_fit_halfheight_high{t})
        measures.tf_fit_lowpass{t} = true;
    end
end


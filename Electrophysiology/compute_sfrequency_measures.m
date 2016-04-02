function measures = compute_sfrequency_measures( measures )
%COMPUTE_SFREQUENCY_MEASURES compute some specific spatial frequency measures
%
%  MEASURES = COMPUTE_CONTRAST_MEASURES( MEASURES )
%   fits Difference of Gaussians (DOG) to tuning curve and computes
%     sf_fit_optimal
%     sf_fit_halfheight_high
%     sf_fit_halfheight_low 
%     sf_fit_bandwidth = sf_fit_halfheight_high / sf_fit_halfheight_high
%
%   bandwidth and sf_fit_halfheight_low are NaN if the response does not
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
    
    measures.sf_fit_optimal{t} = NaN;
    measures.sf_fit_halfheight_high{t} = NaN;
    measures.sf_fit_halfheight_low{t} = NaN;
    measures.sf_fit_bandwidth{t} = NaN;
    measures.sf_fit_lowpass{t} = NaN;
    
    fitx = 0.005:0.001:0.5;
    response = response - baseline;
        
    par = dog_fit(measures.range{t} ,response );
    par(1) = par(1) + baseline;
    if any(isnan(par))
        logmsg('Could not fit DOG to sf curve');
        return;
    end
    
    fity = dog(par,fitx);
    
    [m,indm] = max(fity);
    measures.sf_fit_optimal{t} = fitx(indm);
    
    indh = find(fity>m/2,1,'last');
    if ~isempty(indh) && indh>indm && fitx(indh)<max(measures.range{t})
        measures.sf_fit_halfheight_high{t} = fitx(indh);
    else
        logmsg('Could not fit DOG to sf curve');
        return;
    end
    indl = find(fity>m/2,1,'first');
    if ~isempty(indl) && indl<indm && fitx(indl)>min(measures.range{t}) 
        measures.sf_fit_halfheight_low{t} = fitx(indl); 
    end
    if ~isnan(measures.sf_fit_halfheight_high{t}) && ~isnan(measures.sf_fit_halfheight_low{t})
        measures.sf_fit_bandwidth{t} = measures.sf_fit_halfheight_high{t} / measures.sf_fit_halfheight_high{t};
        measures.sf_fit_lowpass{t} = false;
    elseif ~isnan(measures.sf_fit_halfheight_high{t})
        measures.sf_fit_lowpass{t} = true;
    end
end


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
% 2016-2019, Alexander Heimel
%

measures.usable=1;
fittozerobaseline = true;

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
    measures.tf_fit_dogpar{t} = NaN;
    measures.fit_explained_variance{t} = NaN;

    response = response - baseline;

    if all(measures.response{t}==0)
        logmsg('Completely no response. Not fitting');
        return
    end
    
    if fittozerobaseline
        par = dog_fit(measures.range{t} ,response,'zerobaseline' );
    else
        par = dog_fit(measures.range{t} ,response ); %#ok<UNRCH>
    end
    par(1) = par(1) + baseline;
    measures.tf_fit_dogpar{t} = par;

    if any(isnan(par))
        logmsg('Could not fit DOG to tf curve');
        measures.tf_fit_dogpar{t} = NaN;
        return
    end
    
    if par(2)<1E-4 && par(4)<1E-4
        logmsg('DOG fit gives flat line');
        measures.tf_fit_dogpar{t} = NaN;
        return
    end
    

    if par(2)<1E-4 
        logmsg('DOG does not fit well');
        measures.tf_fit_dogpar{t} = NaN;
        return
    end

    
    par(1) = 0; % set baseline to zero
    fitx = logspace(log10(min(measures.range{t})),log10(max(measures.range{t})),1000);
    fity = dog(par,fitx);
    [m,indm] = max(fity);
    fit_optimal = fitx(indm);
    
    if fit_optimal == max(measures.range{t})
        logmsg('DOG does not fit well. Measured on too small a range');
        measures.tf_fit_dogpar{t} = NaN;
        return
    end
        
    
    %fitx = 0.5:0.1:40;
    fitx = logspace(log10(0.1),log10(40),1000);
    fity = dog(par,fitx);
    indm = find(fitx>fit_optimal,1);
    indh = find(fity>m/2,1,'last');
    if ~isempty(indh) && indh>indm %&& fitx(indh)<max(measures.range{t})
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
    
    fit = dog(par,measures.range{t});    
    % Explained variance explained: https://en.wikipedia.org/wiki/Coefficient_of_determination
    if par(1)==0
        % measures.fit_explained_variance{t} = 1 - std([fit 0]-[response 0])^2/std([response 0])^2;
        measures.fit_explained_variance{t} = 1 - sum( ([fit 0]-[response 0]).^2)/length([fit 0])/std([response 0])^2;
    else
        % measures.fit_explained_variance{t} = 1 - std(fit-response)^2/std(response)^2;
        measures.fit_explained_variance{t} = 1 - sum( (fit-response).^2 )/length(fit)/std(response)^2;
    end
    
    if measures.fit_explained_variance{t}<0
        logmsg('Negative explained variance?');
    end
end




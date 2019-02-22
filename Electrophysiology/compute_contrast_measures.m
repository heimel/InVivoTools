function measures = compute_contrast_measures( measures )
%COMPUTE_CONTRAST_MEASURES compute some specific contrast measures
%
%  MEASURES = COMPUTE_CONTRAST_MEASURES( MEASURES )
%
%
% 2013-2019 Alexander Heimel
%

measures.usable=1;

% STIMULUS SELECTIVITY
% at preferred contrast, calculate stimulus selectivity as
% best-worst/best+worst  (subtracted rate_spont)
if ~iscell(measures.curve)
    measures.curve = {measures.curve};
end
n_triggers = length(measures.curve);
for t = 1:n_triggers
    ind = find(measures.range{t}==measures.preferred_stimulus{t});
    best = max(measures.response{t}(ind));
    worst = min(measures.response{t}(ind));
    measures.selectivity{t} = (best-worst)/(best+worst);
    
    ind_blank = find(measures.range{t}==0);
    if isempty(ind_blank)
        if isfield(measures,'rate_spont')
            response = measures.curve{t}(2,:)-measures.rate_spont{t};
        else
            response = measures.curve{t}(2,:);
        end
    else
        response = measures.curve{t}(2,:)-mean(measures.curve{t}(2,ind_blank));
    end
    [measures.nk_rm{t},measures.nk_b{t},measures.nk_n{t},measures.fit_explained_variance{t}] = ...
        naka_rushton(measures.range{t},response);
    
    % compute C50 and dynamic range
    measures.c50{t} = NaN;
    measures.dynamic_range{t} = NaN;
    cXX = @(f,b,n) ((f * b^n)/(b^n+1-f))^(1/n); 
    measures.c50{t} = cXX(0.5,measures.nk_b{t},measures.nk_n{t});
    c25 = cXX(0.25,measures.nk_b{t},measures.nk_n{t});
    c75 = cXX(0.75,measures.nk_b{t},measures.nk_n{t});
    measures.dynamic_range{t} = c75-c25;
    
end

if any([measures.c50{:}]<0.1)
    measures.usable = 0;
    logmsg('C50 below 10%');
end

if any([measures.nk_n{:}]<0.9)
    measures.usable = 0;
    logmsg('nk_n below 0.9');
end




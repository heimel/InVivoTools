function measures = compute_size_measures( measures )
%COMPUTE_SIZE_MEASURES compute some specific size tuning measures
%
%  MEASURES = COMPUTE_SIZE_MEASURES( MEASURES )
%
%
% 2014-2016 Alexander Heimel
%

if ~strcmp(measures.variable,'size') 
    return
end

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
end

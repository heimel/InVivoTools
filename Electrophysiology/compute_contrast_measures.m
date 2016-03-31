function measures = compute_contrast_measures( measures )
%COMPUTE_CONTRAST_MEASURES compute some specific contrast measures
%
%  RECORD = COMPUTE_CONTRAST_MEASURES( RECORD )
%
%
% 2013 Alexander Heimel
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
    [measures.nk_rm{t},measures.nk_b{t},measures.nk_n{t}] = naka_rushton(measures.range{t},response);
    
    % get c50 from fit
    cn=(0:0.01:1);
    r=measures.nk_rm{t}* (cn.^measures.nk_n{t})./ ...
        (measures.nk_b{t}^measures.nk_n{t}+cn.^measures.nk_n{t}) ; % without spont
    ind=findclosest(r,0.5*max(r));
    measures.c50{t}=cn(ind);
end

if any([measures.c50{:}]<0.1)
    measures.usable=0;
    logmsg('C50 below 10%');
end

if any([measures.nk_n{:}]<0.9)
    measures.usable=0;
    logmsg('nk_n below 0.9');
end


% % calculate adaptation
% n_spikes_per_stim=zeros(1,length(inp.st.mti));
% for i=1:length(inp.st.mti)
%   n_spikes_per_stim(i)= ...
%     length(get_data(inp.spikes,[inp.st.mti{i}.startStopTimes(2),inp.st.mti{i}.startStopTimes(3)]));
% end
% norm_n_spikes_per_stim=n_spikes_per_stim/mean(n_spikes_per_stim);
%
% pfit=polyfit((1:length(n_spikes_per_stim)),norm_n_spikes_per_stim,1);
% % p(1) is fractional change in rate per presented stimulus;
% measures.rate_change=pfit(1);


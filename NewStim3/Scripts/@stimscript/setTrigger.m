function A = setTrigger( S, trigger)
%SETTRIGGER sets triggers for NewStim stimulus scripts
%
% 2015, Alexander Heimel
%

if nargin<2 || isempty(trigger)
    trigger = 'none';
end

if ischar(trigger)
    switch trigger
        case 'none'
            trigger = 0;
        case 'interleaved'
            % show every stimulus twice
            % alternate for each repetitions whether first
            S.trigger = zeros(length(S.displayOrder),2);
            numrep = ceil(length(S.displayOrder)/numStims(S));
            tmp = repmat(1:numrep,numStims(S),1);
            x = (mod(tmp(1:length(S.displayOrder)),2)==0);
            if size(x,2)==1
                x = x';
            end
            trigger = flatten([x(1:end)' 1-x(1:end)']')';
            S.displayOrder = S.displayOrder(fix(1:0.5:end+0.5));
        case 'all'
            trigger = 1;
        case 'custom'
            answer=inputdlg('Give trigger sequence','Custom trigger',1,{''});
            trigger = str2num(answer{1}); %#ok<ST2NM>
    end
end

S.trigger = repmat(trigger(:)',1,length(S.displayOrder)/length(trigger));

if any(S.trigger)
    logmsg(['Trigger order: ' mat2str(S.trigger)]);
end

A = S;


function  [pks,locs] = findpeaks_fast(data,varargin)
%FINDPEAKS_FAST Find local peaks in data, different from FINDPEAKS!
%
% [pks,locs] = findpeaks_fast(data,varargin)
%
% only has global threshold, and finds the peak for each interval where data
% is above MINPEAKHEIGHT. If two peaks are within MINPEAKDISTANCE, then the
% maximum of the two is returned.
%
% 2010, Alexander Heimel
%

pks = [];
locs = [];

% possible varargins with default values
pos_args={...
    'minpeakheight',0,...
    'minpeakdistance',1,...
    };

assign(pos_args{:});

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
    if rem(nvarargin,2)==1
        warning('FINDPEAKS_FAST:WRONGVARARG','odd number of varguments');
        return
    end
    for i=1:2:nvarargin
        found_arg=0;
        for j=1:2:length(pos_args)
            if strcmp(varargin{i},pos_args{j})==1
                found_arg=1;
                if ~isempty(varargin{i+1})
                    assign(pos_args{j}, varargin{i+1});
                end
            end
        end
        if ~found_arg
            warning('FINDPEAKS_FAST:WRONGVARARG',['could not parse argument ' varargin{i}]);
            return
        end
    end
end


ind = find(data>minpeakheight);
if isempty(ind)
    return;
end
dind = diff(ind);
p = find(dind > 1);

ends = [ind(p);ind(end)];
starts = [ind(1); ind( p+1)];

%figure;
%plot( data);
%hold on;
%plot( ends,data(ends),'or');
%plot( starts,data(starts),'vg');

locs = zeros(length(starts),1);
pks = locs;
for i = 1:length(starts)
    [pks(i),locs(i)] = max(data(starts(i):ends(i)));
    locs(i) = locs(i) + starts(i) -1;
end

% now consider mean peak d
too_close = find(diff(locs) <= minpeakdistance);
while ~isempty(too_close) && length(locs)>1
    locs(too_close+ (pks(too_close)<pks(too_close+1))) = NaN;
    ind = ~isnan(locs);
    locs = locs(ind);
    pks = pks(ind);
    

    too_close = find(diff(locs) <= minpeakdistance);

end

%too_close = find(dlocs <= minpeakdistance,1);
%while ~isempty(too_close) && length(locs)>1
%     if pks(too_close)>pks(too_close+1)
%         pks = [pks(1:too_close) ;pks(too_close+2:end)];
%         locs = [locs(1:too_close) ;locs(too_close+2:end)];
%     else
%         pks = [pks(1:too_close-1); pks(too_close+1:end)];
%         locs = [locs(1:too_close-1); locs(too_close+1:end)];
%     end
%     too_close = find(diff(locs) <= minpeakdistance,1);
% end

 %plot( locs,pks,'k*');


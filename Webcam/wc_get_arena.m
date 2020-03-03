function record = wc_get_arena( record,verbose )
%WC_GET_ARENA automatically fits a rectangular arena from a movie still
%
%  RECORD = WC_GET_ARENA( RECORD )
%
% 2019, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = false;
end

[~,filename] = wc_getmovieinfo( record );

try
    vid = VideoReader(filename);
catch me
   logmsg([me.message ' for ' recordfilter(record)]);
   return
end
stimstart = wc_getstimstart( record, vid.FrameRate );
try
    vid.CurrentTime = stimstart;
catch me
    switch me.identifier
        case 'MATLAB:set:notLessEqual'
            errormsg(['Stimstart is too large for ' recordfilter(record)]);
        otherwise
            errormsg([me.message ' for ' recordfilter(record)]);
    end
    return
end
frame = double(readFrame(vid));

frame = mean(frame,3); % convert to gray
hor = diff(smooth(mean(frame,1),10));
[~,ind] = max(hor);
arena(1) = ind;
[~,ind] = min(hor);
arena(3) = ind - arena(1);

ver = diff(smooth(mean(frame,2),10));
[~,arena(2)] = max(ver);
[~,ind] = min(ver);
arena(4) = ind - arena(2);

record.measures.arena = arena;

if verbose
    figure('Name','Arena','NumberTitle','off');
    imagesc(frame);
    hold on
    rectangle('pos',arena);
end

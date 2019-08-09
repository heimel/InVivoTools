function record = wc_get_arena( record )
%WC_GET_ARENA automatically fits a rectangular arena from a movie still
%
%  RECORD = WC_GET_ARENA( RECORD )
%
% 2019, Alexander Heimel

[~,filename] = wc_getmovieinfo( record );

vid = VideoReader(filename);
stimstart = wc_getstimstart( record, vid.FrameRate );
vid.CurrentTime = stimstart;
frame = double(readFrame(vid));

frame = mean(frame,3); % convert to gray
hor = diff(mean(frame,1));
[~,ind] = max(hor);
arena(1) = ind;
[~,ind] = min(hor);
arena(3) = ind - arena(1);

ver = diff(mean(frame,2));
[~,arena(2)] = max(ver);
[~,ind] = min(ver);
arena(4) = ind - arena(2);

record.measures.arena = arena;

% figure
% imagesc(frame);
% hold on
% rectangle('pos',arena);


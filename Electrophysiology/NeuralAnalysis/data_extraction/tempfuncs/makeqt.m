function makeQT(mti,filename)

%  takes a single MTI, makes QT

 % read from the mti

ds = mti.ds;
dp = mti.dp;
imgs = [];
for i=mti.dp.frames,
  imgs = cat(3,imgs,Screen(ds.offscreen(i),'GetImage'));
end;

  % save as a movie

window=qt(1,'OpenWindow',[],[],8);
Screen('SetClut',window,ds.clut);

rows=size(imgs,1); cols = size(imgs,2);
trackTimescale = 75;
frameDuration = round(trackTimescale/FrameRate(1));
preload = 1;
movie=qt('MovieCreate',filename,window);
qt('VideoTrackCreate',movie,rows,cols,trackTimescale,preload);
qt('VideoMediaCreate',movie);
bits=8;

qt('VideoMediaSamplesAdd',movie,imgs,bits,frameDuration);
qt('VideoMediaSave',movie);
qt('VideoTrackSamplesSet');
qt('VideoTrackSave',movie);
qt('MovieSave',movie);
qt('CloseWindow',window);


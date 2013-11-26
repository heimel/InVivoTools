function clipmultitif(fname,n_frames_per_clip)
%CLIPMULTITIFF clips multitiff into clips with fixed number of frames
%
%  CLIPMULTITIF( FNAME, N_FRAMES_PER_CLIP = 100)
%
% 2009, Alexander Heimel
%

if nargin<2
  n_frames_per_clip=[];
end
if isempty(n_frames_per_clip)
  n_frames_per_clip=100;
end


if ~exist(fname,'file')
  error(['CLIPMULTITIF: cannot find file ' fname]);
end

iminf=tiffinfo(fname);
n_clips=ceil(iminf.NumberOfFrames/n_frames_per_clip);

if n_clips==1
  disp([ fname ' is already smaller than ' num2str(n_frames_per_clip) '. Doing nothing.']);
  return
end
[pathstr,name,ext]=fileparts(fname);

disp(['cutting ' fname ' into ' num2str(n_clips) ' clips.']);

fr=1;
for c=1:n_clips
  clipfname=fullfile( pathstr,[name '_' num2str(c,'%04d') '.tif']);
  disp(['writing clip ' clipfname ])
  c_fr=1;
  if exist(clipfname,'file');
    delete(clipfname);
  end
  while c_fr<=n_frames_per_clip && fr<=iminf.NumberOfFrames 
    frame=imread(fname,fr);
    fr=fr+1;
    c_fr=c_fr+1;
    imwrite(frame,clipfname,'tif','WriteMOde','append','Description',iminf.ImageDescription);
  end
end




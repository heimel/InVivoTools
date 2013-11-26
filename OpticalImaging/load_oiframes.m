function ffrr=load_oiframes(filenames,cond,framesuse,compression)

% LOAD_OIFRAMES loads and saves oi images
%
%  ffrr=LOAD_OIFRAMES(FILENAMES,CONDITIONS,FRAMES,OUTPUTMETH,...
%		normmethMETHOD,normmethFLAG)
%
% 2013, Alexander Heimel, Mehran Ahmadlou

if nargin<4
    compression=1;
end

info = imagefile_info(filenames{1}); % assume all files same structure
if ~isempty(cond),conditions=cond; else conditions=1:info.n_conditions; end;
if ~isempty(framesuse), frames=framesuse; else frames=1:info.n_images;end;

ffrr={};  % NEED TO BE PRECALCULATED FOR SPEED AND MEMORY 
for i=1:length(filenames),
    disp(['LOAD_OIFRAMES: Working on '  filenames{i} '.']);
    fr={};
    for j=1:length(conditions),
        for k=1:length(frames),
            block_offset=(conditions(j)-1)*info.n_images+frames(k);
            img=read_oi_compressed(filenames{i},block_offset,1,1,compression,0);
            fr = [fr,img];
        end;
    end;
    ffrr = [ffrr,fr];
end;
fprintf('\n');
pth = fileparts(filenames{1});
save(fullfile(pth,'spontaneous_frames.mat'),'ffrr')

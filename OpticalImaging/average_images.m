function [avg,stddev]=average_images(filenames,cond,framesuse,outmeth,normmeth,normflag,compression,ror)

% AVERAGE_IMAGES Compute average, standard deviation of intrinsic images
%
%  [AVG,STDDEV]=AVERAGE_IMAGES(FILENAMES,CONDITIONS,FRAMES,OUTPUTMETH,...
%		normmethMETHOD,normmethFLAG)
%
%  Computes image average and standard deviation for each condition in
%  the array CONDITIONS (empty means use all) and each frame in the array
%  FRAMES (empty means use all).  FILENAMES is a cell list of filenames
%  to include in the averaging.
%
%  OUTPUTMETHOD is the output method:
%     'avgframes' means average all frames in the list; in this case,
%          AVG and STDDEV have dimensions XxYxCONDITION
%     'indframes' means return the average for each frame; in this case,
%          AVG and STDDEV have dimensions XxYxFRAMExCONDITION
%  normmethMETHOD is the normalization method, and normmethFLAG is a flag:
%     'none'  no normalization
%     'subtract' subtract the condition number given in normmethFLAG
%     'division' divide by the condition number given in normmethFLAG
%     'subtractframe' subtract the frame number given in normmethFLAG
%
%  Conditions and frames are numbered starting from 1.
%
%  At present, this program is very memory-heavy.  Use with caution.
%
%  Example:
%
%  [AVG,STDDEV]=AVERAGE_IMAGES({'squ45.a','squ45.b','squ45.c'},[],[],...
%              'avgframes','none',[]);
%
%  2004 Steve Van Hooser
%  2005-01-31 JFH: changed read_oi_frames to read_oi_compressed and
%                  added compression to argumentlist
%  2013, Alexander Heimel

if nargin<7
    compression=1;
end

if strcmp(normmeth,'ror')
    rort=normflag';
end
if strcmp(normmeth,'subtractframe_ror')
    rort=ror'/sum(ror(:));
end


info = imagefile_info(filenames{1}); % assume all files same structure
if ~isempty(cond),conditions=cond; else conditions=1:info.n_conditions; end;
if ~isempty(framesuse), frames=framesuse; else frames=1:info.n_images;end;

if strcmp(outmeth,'avgframes'),
    avg = zeros(floor(info.xsize/compression),...
        floor(info.ysize/compression),...
        length(conditions));
    stddev=avg;
elseif strcmp(outmeth,'indframes'),
    avg = zeros(floor(info.xsize/compression),...
        floor(info.ysize/compression),...
        length(frames),length(conditions));
    stddev=avg;
end;

ffrr={};
for i=1:length(filenames),
    disp(['AVERAGE_IMAGES: Working on '  filenames{i} '.']);
    if strcmp(normmeth,'subtract')||strcmp(normmeth,'divide'),
        %    nrm=read_oi_frames(filenames{i},1+(normflag-1)*info.n_images,...
        %		       info.n_images,compression,0);
        nrm=read_oi_compressed(filenames{i},1+(normflag-1)*info.n_images,...
            info.n_images,1,compression,0);
        nrm=mean(nrm,3);
    end;
   fr={};
    for j=1:length(conditions),
        if strcmp(normmeth,'subtractframe')||strcmp(normmeth,'subtractframe_ror')
            block_offset=(conditions(j)-1)*info.n_images+normflag;
            [nrm,fileinfo] = read_oi_compressed(filenames{i},block_offset,1,1,compression,0);
        end;
        
        for k=1:length(frames),
            block_offset=(conditions(j)-1)*info.n_images+frames(k);
            img=read_oi_compressed(filenames{i},block_offset,1,1,compression,0,fileinfo);
           fr=[fr,img];
            switch normmeth
                case 'subtract'
                    img=img-nrm;
                case 'subtractframe'
                    img=img-nrm;
                case 'divide'
                    img=img./nrm;
                case 'subtractframe_ror'
                    %         img=img-nrm;
                    %         img=img/ (rort(:)' * img(:));
                    img=img./nrm;
                    img=img/(rort(:)' * img(:)) -1 ;
                case 'ror'
                    img=img/ (rort(:)' * img(:));
            end;
            if strcmp(outmeth,'avgframes'),
                avg(:,:,j)=avg(:,:,j)+img;
                stddev(:,:,j)=stddev(:,:,j)+img.*img;
            elseif strcmp(outmeth,'indframes'),
                avg(:,:,k,j)=avg(:,:,k,j)+img;
                stddev(:,:,k,j)=stddev(:,:,k,j)+img.*img;
            end;
        end;
    end;
   ffrr=[ffrr,fr];
end;
%fprintf('\n');
%pth = fileparts(filenames{1});
% save(fullfile(pth,'spontaneous_frames.mat'),'ffrr')
% save(fullfile('D:\Data\2013\05\28\','spontaneous_frames.mat'),'ffrr')
% save(fullfile('D:\Data\2013\05\28\','spontaneous_frames.mat'),'ffrr')

if strcmp(outmeth,'avgframes'),
    N = length(frames)*length(filenames);
    avg=avg/N;
    stddev=sqrt((stddev-N*avg.*avg)/(N-1));
elseif strcmp(outmeth,'indframes'),
    N = length(filenames);
    stddev=sqrt((stddev-N*avg.*avg)/(N-1));
    avg=avg/N;
end;

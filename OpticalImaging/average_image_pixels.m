function [ind,avg,stddev]=average_image_pixels(filenames,cond,framesuse,pixelinds,outmeth,normmeth,normflag)

% AVERAGE_IMAGE_PIXELS Read pixels from images, returns average, std dev
%
%  [IND,AVG,STDDEV]=AVERAGE_IMAGE_PIXELS(FILENAMES,CONDITIONS,FRAMES,...
%       PIXELINDS,OUTPUTMETH,normmethMETHOD,normmethFLAG)
%
%  Computes image average and standard deviation for each condition in
%  the array CONDITIONS (empty means use all) and each frame in the array
%  FRAMES (empty means use all).  FILENAMES is a cell list of filenames
%  to include in the averaging.  Only the pixel indicies corresponding to
%  PIXELINDS are saved.
%
%  OUTPUTMETHOD is the output method:
%     'avgframes' means average all frames in the list; in this case,
%          AVG and STDDEV have dimensions XxYxCONDITION
%     'indframes' means return the average for each frame; in this case,
%          AVG and STDDEV have dimensions XxYxFRAMExCONDITION
%  normmethMETHOD is the normalization method, and normmethFLAG is a flag:
%     'none'  no normalization
%     'subtract' subtract the condition number given in normmethFLAG;
%     'division' divide by the condition number given in normmethFLAG
%     'subtractframe' subtract the frame number given in normmethFLAG
%
%  Conditions and frames are numbered starting from 1.  
%  
%
%  At present, this program is very memory-heavy.  Use with caution.
%
%  See also: AVERAGE_IMAGES

[info,header]=imagefile_info(filenames{1}); % assume all files same structure
if ~isempty(cond),conditions=cond; else, conditions=1:info.n_conditions; end;
if ~isempty(framesuse), frames=framesuse; else, frames=1:info.n_images;end;

ind = zeros(length(pixelinds),length(frames),length(conditions),length(filenames));
if strcmp(outmeth,'avgframes'),
	avg = zeros(length(pixelinds),length(conditions));
	stddev=zeros(length(pixelinds),length(conditions));
elseif strcmp(outmeth,'indframes'),
	avg = zeros(length(pixelinds),length(frames),length(conditions));
	stddev=zeros(length(pixelinds),length(frames),length(conditions));
end;

if isempty(pixelinds), return; end;

for i=1:length(filenames),
	disp(['Working on ' filenames{i} '.']);
	if strcmp(normmeth,'subtract')|strcmp(normmeth,'divide'),
		nrm=read_oi_frames(filenames{i},1+(normflag-1)*info.n_images,...
			info.n_images,1,0);
		nrm=mean(nrm,3);
	end;
	for j=1:length(conditions),
		if strcmp(normmeth,'subtractframe'),
			block_offset=(conditions(j)-1)*info.n_images+normflag;
			nrm=read_oi_frames(filenames{i},block_offset,1,1,0);
		end;
		for k=1:length(frames),
			block_offset=(conditions(j)-1)*info.n_images+frames(k);
			img=read_oi_frames(filenames{i},block_offset,1,1,0);
			if strcmp(normmeth,'subtract'),
				img=img-nrm;
			elseif strcmp(normmeth,'subtractframe'),
				img=img-nrm;
			elseif strcmp(normmeth,'divide'),
				img=img./nrm;
			end;
			ind(:,k,j,i)=img(pixelinds);
			if strcmp(outmeth,'avgframes'),
				avg(:,j)=avg(:,j)+img(pixelinds);
				stddev(:,j)=stddev(:,j)+img(pixelinds).*img(pixelinds);
			elseif strcmp(outmeth,'indframes'),
				avg(:,k,j)=avg(:,k,j)+img(pixelinds);
				stddev(:,k,j)=stddev(:,k,j)+img(pixelinds).*img(pixelinds);
			end;
		end;
	end;
end;

if strcmp(outmeth,'avgframes'),
	N = length(frames)*length(filenames);
	avg=avg/N;
	stddev=sqrt((stddev-N*avg.*avg)/(N-1));
elseif strcmp(outmeth,'indframes'),
	N = length(filenames);
	stddev=sqrt((stddev-N*avg.*avg)/(N-1));
	avg=avg/N;
end;

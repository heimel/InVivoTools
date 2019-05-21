function data = oi_read_all_data( record,conditions,frames, verbose) 
%OI_READ_ALL_DATA
%
%  DATA = OI_READ_ALL_DATA( RECORD, CONDITIONS, FRAMES,VERBOSE)
%     DATA  = [X,Y,FRAMES,BLOCK,CONDITIONS]
%
%     RECORD is a struct with at least the following fields
%         blocks = a vector of block file numbers to read. If empty, then 
%                all blocks are read.
%         test = start of block file names, e.g. 'mouse_E1'
%         setup = one of {'andrew','daneel','jander'}
%         date = imaging data, e.g. '2015-01-22'
%
%     CONDITIONS is a vector with the requested condition (stimulus)
%         numbers
%     FRAMES is a vector with requested frame numbers
%
% 2014-2019, Alexander Heimel

if nargin<4 || isempty(verbose)
    verbose = false;
end
if nargin<2
    conditions = [];
end
if nargin<3
    frames = [];
end
if isfield(record,'blocks') 
    blocks = record.blocks;
else
    blocks = [];
end

filenames = fullfilelist(experimentpath(record),convert_cst2cell(record.test));

experimentlist={};
extension='';
for i=1:length(filenames)
    base=filenames{i};
    filter=[ base 'B*.BLK'];
    files=dir(filter);
    if isempty(files)
        logmsg(['Could not find any files matching ' filter ]);
    end
    if isempty(blocks)
        blocks=(0:length(files)-1);
    end
    for blk=blocks
        experimentlist{end+1}=[ base 'B' num2str(blk) '.BLK' extension ]; %#ok<AGROW>
        if exist(experimentlist{end},'file')==0
            experimentlist = experimentlist(1:end-1);
            break
        end
    end
end

if isempty(experimentlist)
    logmsg(['No experiment files found for ' recordfilter(record)]);
    data = [];
    return
end

fileinfo = imagefile_info(experimentlist{1}); % assume all files same structure
if isempty(conditions)
    conditions = 1:fileinfo.n_conditions; 
end
if isempty(frames)
    frames = 1:fileinfo.n_images;
end

img = read_oi_compressed(experimentlist{1},1,1,1,1,0,fileinfo);
data = zeros(size(img,1),size(img,2),length(frames),length(experimentlist),length(conditions));
for i=1:length(experimentlist)
   logmsg(['Reading '  experimentlist{i} '.']);
   for c=1:length(conditions)
       for f=1:length(frames)
           block_offset = (conditions(c)-1)*fileinfo.n_images+frames(f);
           data(:,:,f,i,c) = read_oi_compressed(experimentlist{i},block_offset,1,1,1,0,fileinfo);
       end
   end
end

if verbose
    figure 
    maxdata = max(data(:));
    mindata = min(data(:));
    logmsg(['Min = ' num2str(mindata) ', Max = ' num2str(maxdata)]);
    for c=1:size(data,5)
        for t=1:size(data,4)
            subplot(size(data,4),size(data,5),size(data,4)*(t-1)+c);
            image( ((data(:,:,end,t,c)- mindata)/(maxdata-mindata) )*64);
            axis image off
        end
    end
end

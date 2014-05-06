function data = oi_read_all_data( record,conditions,frames) 
%OI_READ_ALL_DATA
%
%  DATA = OI_READ_ALL_DATA( RECORD, CONDITIONS, FRAMES)
%     DATA  = [X,Y,FRAMES,BLOCK,CONDITIONS]
%
% 2014, Alexander Heimel

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

filenames = fullfilelist(oidatapath(record),convert_cst2cell(record.test));

% if ~iscell(filenames)
%     d = dir(filenames);
%     if isempty(d)
%         logmsg(['No files ' filenames]);
%         data = [];
%         return
%     end
%     filenames = {d.name};
% end

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
            experimentlist={experimentlist{1:end-1}};
            break
        end
    end
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

if 0
    figure %#ok<UNRCH>
    for c=1:size(data,5)
        for t=1:size(data,4)
            subplot(size(data,5),size(data,4),size(data,4)*(c-1)+t);
            imagesc(data(:,:,end,t,c));
        end
    end
end

function [response,response_sem,response_all,tc_roi,tc_ror,ratio,tc_roi_sem,tc_ror_sem,ratio_sem]=average_timecourse(fname,n_images,...
						  blocks,roi,ror,...
		       compression,record,show)
%AVERAGE_TIMECOURSE calculates the timecourse over a subset of pixels
%
% [RESPONSE,RESPONSE_SEM,RESPONSE_ALL,TC_ROI,TC_ROR,RATIO]=...
%                   AVERAGE_TIMECOURSE(FNAME,N_IMAGES,...
%				      BLOCKS,ROI,ROR,...
%				      COMPRESSION,RECORD,SHOW)
%       
%  
%   2005, Alexander Heimel
%
% 2006-06-13 corrected normalization of ratio 
%

response=record.response;
response_sem=record.response_sem;
response_all=record.response_all;
tc_roi=record.timecourse_roi;
tc_ror=record.timecourse_ror;
ratio=record.timecourse_ratio;
tc_roi_sem=[];
tc_ror_sem=[];
ratio_sem=[];


if nargin<8
  show=[];
end
if nargin<7
  stim_onset=3; % seconds
  stim_offset=9; % seconds
  stim_type='';
  record=[];
else
  stim_onset=record.stim_onset;
  stim_offset=record.stim_offset;
  stim_type=record.stim_type;
end
if nargin<6
  compression=1;
end
if nargin<5
  ror=[];
end
if nargin<4
  roi=[];
end
if nargin<3
  blocks=[];
end
if nargin<2
  n_images=[];
end


if isempty(n_images)
  n_images=inf;
end

if isempty(show)
  show=1;
end




if ~iscell(fname)
  fname={fname};
end




experimentlist={};
cancel=0;
orgfname=fname{1};
while ~cancel & isempty(experimentlist)
  extension='';
  blocks_file={};
  n_file=[];
  for i=1:length(fname)
    base=fname{i}
    files=dir([base 'B*.BLK']);
    n_file(i)=length(files);

    if isempty(blocks)
      blocks_file{i}=(0:n_file(i)-1);
    else
      blocks_file{i}=blocks(find(blocks<n_file(i)));
    end
    blocks=blocks-n_file(i);
    blocks=blocks(find(blocks>=0));

    disp([  fname{i} ': calculating timecourse over blocks:' ]);
    disp(  num2str(blocks_file{i}) );


    for blk=blocks_file{i}
      experimentlist{end+1}=[ base 'B' num2str(blk) '.BLK' extension ];
    end
  end
    
  if isempty(experimentlist)
    button=questdlg(...
      'Cannot find BLK files. Do you want to locate them yourself?',...
      'Missing BLK files','Yes','No','Yes');
    switch button
      case 'No'
        cancel=1;
        return
      case 'Yes'
        
        [pathname,filename]=fileparts(fname{1});
        filt=[filename 'B*.BLK'];
        [filename,newpath]=uigetfile(filt,['Locate BLK files of ' orgfname] )
        if isequal(filename,0) | isequal(newpath,0)
          return
        end
          
        
        for i=1:length(fname)
          [pathname,filename]=fileparts(fname{i});
          fname{i}=fullfile(newpath,filename);
        end
	
	
    end
  end
end

if isempty(experimentlist)
  error('could not open any BLK-files');
end



% check if last file is ready
fileinfo=imagefile_info(experimentlist{end})
if fileinfo.n_total_images==0
  % not ready yet
  experimentlist={experimentlist{1:end-1}};
end
if isempty(experimentlist)
  disp('No blockfiles ready yet.')
  return
end


% get file info
fileinfo=imagefile_info(experimentlist{1})
if isempty(fileinfo.name)
  return
end


frame_duration=fileinfo.frameduration;


if fileinfo.n_images<n_images
  n_images=fileinfo.n_images;
end
  

conditions=(1:fileinfo.n_conditions);

if isempty(ror) & ~isempty(roi)
  % make ROR complement of ROI
  ror=ones( size(roi))-roi;
end
if isempty(roi) 
  % make ROI whole image
  roi=ones( floor(fileinfo.xsize/compression), ...
	    floor(fileinfo.ysize/compression) );
end
if isempty(ror) 
  % make ROR also whole image
  ror=ones( floor(fileinfo.xsize/compression), ...
	    floor(fileinfo.ysize/compression) );
end


  if 0 % commented out because it takes too much memory
    % compute principal component
    
    % reading blankframes
    blank_stim=0;
    blankframes=zeros( floor(fileinfo.xsize/compression),...
		       floor(fileinfo.ysize/compression),...
		       length(experimentlist)*fileinfo.n_images);
    for blk=1:length(experimentlist)
      blankframes(:,:,(blk-1)*fileinfo.n_images+1:blk*fileinfo.n_images)=...
	  read_oi_compressed(...
	      experimentlist{blk},...
	      blank_stim*fileinfo.n_images,...
	      fileinfo.n_images,...
	      1,...  %only first part
	      compression,0);
    end
    
    plot_frame(blankframes(:,:,1),roi,ror);
    [pc_rom,pc_ror]=oi_pca(blankframes,roi',ror');
    
    plot_frame(pc_ror,roi,ror);
    plot_frame(pc_rom,roi,ror);
    %%%
  end

%tc_roi=zeros(n_images,length(conditions));
%tc_ror=tc_roi;
%ratio=tc_roi;

ttc_roi=zeros(n_images,length(conditions),length(experimentlist));
ttc_ror=ttc_roi;
tratio=ttc_roi;




for i=1:length(experimentlist)
  disp(['# ' experimentlist{i}]);
  
  [ttc_roi(:,:,i),ttc_ror(:,:,i),tratio(:,:,i)]=...
      get_timecourse(experimentlist{i},n_images,(1:length(conditions)),...
				   roi,ror,compression,0);
      
%  tc_roi=tc_roi+ttc_roi;
%  tc_ror=tc_ror+ttc_ror;
%  ratio=ratio+tratio;
end
%tc_roi=tc_roi/length(experimentlist);
%tc_ror=tc_ror/length(experimentlist);
%ratio=ratio/length(experimentlist);


tc_roi=mean(ttc_roi,3);
tc_roi_sem=sem(ttc_roi,3);
tc_ror=mean(ttc_ror,3);
tc_ror_sem=sem(ttc_ror,3);
ratio=mean(tratio,3);
ratio_sem=sem(tratio,3);

firstframes=[];
if ~isempty(stim_onset)
  if isempty(frame_duration)
    firstframes=(1:stim_onset);
  else 
    firstframes=(1: ceil(stim_onset/frame_duration) +1 );
    % added one, because in first 600 ms after stimulus not much effect
  end
end
if isempty(firstframes)
  firstframes=1;
end


% add two seconds after stim offset
if ~isempty(stim_offset)
  dataframes=setdiff( (1:ceil( (stim_offset+2) /frame_duration)),firstframes);
else
  dataframes=setdiff( (1:size(ratio,1)),firstframes);
end

dataframes = dataframes(dataframes<=fileinfo.n_images);

logmsg(['First frames: ' mat2str(firstframes) ...
    ', data frames: ' mat2str(dataframes)]);


normratio=ratio(firstframes(end),:);  % align ratio's at last frame
                                      % before onset
ratio=ratio./repmat(normratio,size(ratio,1),1);
ratio=(ratio-1)*100; % to get percentage change
ratio_sem=100*ratio_sem./repmat(normratio,size(ratio,1),1);

tresponse=squeeze(mean( tratio(dataframes,:,:),1)) ./ ...
	  squeeze( tratio(firstframes(end),:,:))-1;
tresponse=-tresponse*100; % make perc and positive


if size(tresponse,1)>1
  response=mean(tresponse');
  
  
  % OUTLIER REMOVAL
  % USING INTER QUARTILE RANGE (IQR=Q3-Q1)
  % ALL POINTS < Q1-1.5IQR and > Q3+1.5IQR ARE REMOVED
  q1=prctile(tresponse',25);
  q3=prctile(tresponse',75);
  iq=q3-q1;
  outliers=[];
  
  if size(tresponse,2)==1 % when we have ONLY ONE condition, by Mehran
      tresponse = tresponse';
  end;
  all=(1:size(tresponse,2));
  
  for cond=1:size(tresponse,1)
    outliers{cond}=find( tresponse(cond,:)<q1(cond)-1.5*iq(cond) );
    outliers{cond}=[outliers{cond} ...
		    find( tresponse(cond,:)>q3(cond)+1.5*iq(cond) )];
    
    good=setdiff( all,[outliers{cond}]);
    response(cond)=mean( tresponse(cond,good));
  
  
    tc_roi=mean(ttc_roi(:,:,good),3);
    tc_roi_sem=sem(ttc_roi(:,:,good),3);
    tc_ror=mean(ttc_ror(:,:,good),3);
    tc_ror_sem=sem(ttc_ror(:,:,good),3);
    ratio=mean(tratio(:,:,good),3);
    ratio_sem=sem(tratio(:,:,good),3);
    normratio=ratio(firstframes(end),:);  
    % align ratio's at last frame before onset
    ratio=ratio./repmat(normratio,size(ratio,1),1);
    ratio=(ratio-1)*100; % to get percentage change
    ratio_sem=100*ratio_sem./repmat(normratio,size(ratio,1),1);
    
    if ~isempty(outliers{cond})
      disp(['Removed outliers (based on IQR) for condition ' ...
	    num2str(cond) ' : ' num2str([outliers{cond}]-1) ]);
    end
    
  end
else
  response=tresponse;
end
response_sem=nan*response;

if size(tresponse,1)>1
  response_sem=std(tresponse')/sqrt(size(tresponse,2));
end
response_all=tresponse';

switch record.datatype
 case 'fp',
  disp('flavoprotein: flipping response!')
  response_all=-response_all;
  response=-response;
end

if strcmp(record.stim_type,'ledtest')==1
  response=mean(mean(ttc_roi(dataframes,:,:),1),3);
  response_sem=sem( squeeze(mean(ttc_roi(dataframes,:,:),1))');
  response_all=squeeze(mean(ttc_roi(dataframes,:,:),1))';
end

if show==1
 h=plot_testresults(fname,response,response_sem,response_all,...
		    tc_roi,tc_ror,ratio,roi,ror,record);
end

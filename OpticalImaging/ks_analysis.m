function [img,data]=ks_analysis( fname,freq,skip,n_images,compression,roi,ror,stim_onset,stim_offset)
% KS_ANALYSIS performs Kalatsky-Stryker analysis for periodic imaging stimulus
%
%  [IMG,DATA]=KS_ANALYSIS( FNAME, FREQ )
%  [IMG,DATA]=KS_ANALYSIS( FNAME,FREQ,SKIP,N_IMAGES,COMPRESSION,...
%                              ROI,ROR,STIM_ONSET,STIM_OFFSET)
%
%    FNAME is name of the file to be processed at 
%    frequency FREQ (Hz), which usually is the stimulus frequency
%    or a higher harmonic of that.
%
%    COMPRESSION is the number of pixels to skip on each horizontal line
%    and will be decreased until a number is found that divides the size
%    of a line. The final COMPRESSION factor is returned. The whole file
%    consists of as many blocks as COMPRESSION, with block 1 starting at
%    the first pixel of each line. This construction is used but in case
%    memory is limited and to get a quick first impression of the data.
%
%    SKIP is how many pixels to skip, 0 is to show all
%    N_IMAGES is maximum number of frames to process
%
%    IMG is phase image
%    DATA is the complex valued image, containing both phase and
%    amplitude. Use IMAGESC_COMPLEX(DATA) to plot or PLOT_ABSOLUTE_MAP
%    to plot the processed DATA from two opposite stimuli.
%
%    use PLOT_ABSOLUTE_MAP to combine a stimulus map and its reverse
%
%  April 2003, Alexander Heimel (heimel@brandeis.edu)
%
%  2005-02-08 JFH: Routed camera_framerate to function in calibration\
%  2005-02-24 JFH: Added stim_onset and stim_offset as arguments
  
  
%close all
  
global file_in_frames;
global orgframes;


if nargin<9
  stim_offset=[];
end
if nargin<8
  stim_onset=[];
end
if nargin<7
  ror=[];
end
if nargin<6
  roi=[];
end
if nargin<5
  compression=[];
end
if nargin<4
  n_images=[];
end
if nargin<3
  skip=[];
end
if nargin<2
  disp('Stimulus frequency is required.');
  return
end    

if isempty(n_images)
  n_images=10000;
end






global frames; % for debugging
% to force reload: global file_in_frames; file_in_frames='';

global prev_skip;
if isempty(prev_skip)
  prev_skip=-1;
end




debug=0; % if 1, then don't reload if already in memory

  
  
%fname=complete_oi_path(fname);


% get fileinfo
fileinfo=imagefile_info(fname);

% calculate compression
memory_max=64*1024*1024; % maximum fileblock to read in one go
compression=ceil(fileinfo.filesize/memory_max);
if isempty(skip)
  skip=compression;
end

disp(['Image compression : ' num2str(compression)]);
disp(['Skipping frames   : ' num2str(skip)]);



% get framerate
%camera_framerate=1/0.04032972;% (Hz) camera dependent
%at BU 30Hz
framerate=fileinfo.framerate;
disp(['Framerate: ' num2str(framerate,3) ' frames per second']);




img=[];

% get file and compression information
%[emptyframes,compression,fileinfo]=...
%    read_oi_compressed( fname,1,n_images,0, compression,0); 

if fileinfo.n_images==-1
  return
end
 


% get timecourse of ROI and mask (inverse of roi)
timecourse_mask=[];
timecourse_roi=[];
timecourse_mask_smooth=[];
ratio=[];
if 0
  if ~isempty(roi)
    % if ROI is defined, use timecourse of surrounding region
    timecourse_roi=get_timecourse(fname,n_images,1,roi);
    timecourse_mask=get_timecourse(fname,n_images,1,1-roi);
  else
    timecourse_roi=get_timecourse(fname,n_images,1,[]);
    timecourse_mask=timecourse_roi;
  end

  % smoothing timecourse outside roi
  filterfreq=0.1*freq;
  [b,a]=cheby1(1,0.4,[filterfreq/(framerate/2)],'low');
  timecourse_mask_smooth=filtfilt(b,a,timecourse_mask);
  % define ratio for subtracting smooth mask signal from ROI
  ratio=mean(timecourse_roi)/mean(timecourse_mask_smooth);
end







% read and process them all
n_frame=1;
n_parts=ceil(compression/(skip+1))^2;
for row=1:skip+1:compression
  for col=1:skip+1:compression
    disp(['Processing fileblock ' num2str(n_frame) ' of ' ...
	  num2str(n_parts) ...
	  ' (starting at pixel ' num2str(row) ',' num2str(col) ')'])   
    try 
      oldname=file_in_frames.name;
    catch
      oldname='';
    end
    
    % reread (when debugging only  when new filename)    
    orgframes=...
	read_oi_compressed( fname,1,n_images,(row-1)*compression+col,...
			    compression,0); 
    
    
    
    if isempty(orgframes) % no file read
      file_in_frames.name='';
      return;
    end
    prev_skip=skip;
    
    % some preprocessing (only detrending helps and is important)
    if(1), orgframes=detrend_data(orgframes); end
    if(0), orgframes=subtract_dc_component(orgframes); end
    if(0), 
      orgframes=subtract_slow_components(orgframes,...
					 round(2*framerate/freq/2));
    end
    if(0), orgframes=subtract_global_timecourse(orgframes);  end
    
    file_in_frames=fileinfo; % so we know which file is in memory
    reloaded=1;

    
    
    if ~isempty(stim_onset)
      firstframe=round(stim_onset*framerate)+1;
      disp(['First frame: '  num2str(firstframe)]);
    else
      firstframe=1;
    end
    if ~isempty(stim_offset)
      lastframe=round(stim_offset*framerate)+1;
      disp(['Last frame: '  num2str(lastframe)]);
    else
      lastframe=size(orgframes,3);
    end
    
    
    frames=orgframes(:,:,firstframe:lastframe);
    
    
    n_images=size(frames,3);
    
    if(0)
      % subtract smooth timecourse outside ROI
      % smoothened timecourse is rescaled to mean of each pixels 
      n=size(frames);
      frames2=reshape(frames,n(1)*n(2),n(3));
      if ~isempty(timecourse_mask_smooth)
	norm_tc_smooth=timecourse_mask_smooth/mean(timecourse_mask_smooth);
	
	frames2=frames2-...
		mean(frames2,2)*norm_tc_smooth(1:n(3))';
	%frames2=frames2-norm_tc_smooth(1:n(3),ones(1,n(1)*n(2)))';
	frames=reshape(frames2,n(1),n(2),n(3));  
      end
    end
    if(0), frames=detrend_data(frames); end
    
    firstframes{n_frame}=frames(:,:,1);
    lastframes{n_frame}=frames(:,:,end);
    
    
    fourframelist{n_frame}=ft_image(frames,freq,framerate,0);
    n_frame=n_frame+1;
  end
end
flframes(:,:,1)=combine_compressed_frames(firstframes);
flframes(:,:,2)=combine_compressed_frames(lastframes);


plot_oi_frames(flframes);

data=combine_compressed_frames(fourframelist);







% some control plots
figure;

subplot(3,2,1) % time course

timecourse=squeeze(sum(sum(frames)))/...
    (size(frames,1)*size(frames,2));  % total picture
  
if ~isempty(timecourse_mask)
  timecourse_org=squeeze(sum(sum(orgframes)))/...
      (size(orgframes,1)*size(orgframes,2));  % total picture

  hold on
  
  
%  plot(linspace(1/framerate,n_images/framerate,n_images),...
%       (timecourse_mask(1)+timecourse)/...
%       (timecourse_mask(1)+timecourse(1))*100,'b');
%  plot(linspace(1/framerate,n_images/framerate,n_images),...
%       timecourse_org(1:n_images)/timecourse_org(1)*100,'k');
  plot(linspace(1/framerate,n_images/framerate,n_images),...
       timecourse_roi(1:n_images)/mean(timecourse_roi),'r');
  plot(linspace(1/framerate,n_images/framerate,n_images),...
       timecourse_mask_smooth(1:n_images)/mean(timecourse_mask_smooth),'k');
  hold off;
%  legend('corr','org','mask',2);
  
  ylabel('Rel. Intensity (%)');
  legend('ROI','mask',0);

else
  plot(linspace(1/framerate,n_images/framerate,n_images),...
       timecourse);
end
title('Time course');
xlabel('Time (s)');



if ~isempty(timecourse_roi)
  subplot(3,2,2) % spectrum
  nfft=min(2048, length(timecourse));
  spectrum(timecourse_roi,nfft,0,hanning(nfft),framerate);
  set(gca,'XScale','log');
  hold on;
  ax=axis;
  plot([freq freq],[ax(3) ax(4)],'k:');
  ax([1 2])=[0.01 10];
  axis(ax);
  title('Spectrum ROI');
end



subplot(3,2,3) % time course ROI
pixel=size(frames);
pixel=ceil(pixel([1 2])/2);
timecourse=squeeze(frames(pixel(1),pixel(2),:));  % one pixel
%plot(linspace(1/framerate,n_images/framerate,n_images),timecourse);
hold on;
% plot orginal
plot(linspace(1/framerate,n_images/framerate,n_images),...
     squeeze(frames(pixel(1),pixel(2),:)),'b');
title('Time course of center pixel (corrected)');
xlabel('Time (s)');
ylabel('Summed activitity');



if ~isempty(timecourse_roi)
  subplot(3,2,4) % spectrum
  nfft=min(2048, length(timecourse));
  spectrum(timecourse_roi-ratio*timecourse_mask_smooth,...
	   nfft,0,hanning(nfft),framerate);
  set(gca,'XScale','log');
  hold on;
  ax=axis;
  plot([freq freq],[ax(3) ax(4)],'k:');
  ax([1 2])=[0.01 10];
  axis(ax);
  title('Spectrum ROI (corrected)');
end

subplot(3,2,5) % histogram of absolute values
absvals=abs(data);
hist(absvals(:));
title('Histogram of absolute values')
disp(['Maximum absolute value: ' num2str(max(absvals(:))) ]);

subplot(3,2,6) % histogram of phases
hist(angle(data(:)));
title('Histogram of phases')

img=plot_ks_data( data, [fname ' at ' num2str(freq) ' Hz']);

return




function frames=detrend_data(frames);
  disp('Detrending data');
  dtframes=reshape(frames,size(frames,1)*size(frames,2),...
		   size(frames, 3));
  dtframes=detrend(dtframes')';
  frames=reshape(dtframes,size(frames,1),size(frames,2),size(frames,3));
  
function frames=subtract_global_timecourse(frames)
  disp('Subtracting global timecourse');
  n=size(frames);
  timecourse=squeeze(sum(sum(frames)))/n(1)/n(2);  % total picture
  frames2=reshape(frames,n(1)*n(2),n(3));
  frames2=frames2-timecourse(:, ones(1,n(1)*n(2)))';
  frames=reshape(frames2,n(1),n(2),n(3));

function frames=subtract_dc_components(frames)
  disp('Subtracting dc component');
  dccomponent=shiftdim(mean(shiftdim(frames,2)),1);
  for t=1:size(frames,3)  % ugly 
    frames(:,:,t)=frames(:,:,t)-dccomponent;
  end
  
function frames=subtract_slow_components(frames,half_av_pd)
% doesn't make much difference
  disp('Subtracting slow components');
  tic
  n=size(frames); 
  flatframes=reshape(frames,n(1)*n(2),n(3));
  
  % get number of components for averaging
  nslowcomp(1)=min(half_av_pd,n(3));
  for t=2:min(half_av_pd,max(1,n(3)-half_av_pd))
    nslowcomp(t)=nslowcomp(t-1)+1;
  end
  for t=min(half_av_pd,max(1,n(3)-half_av_pd))+1:max(1,n(3)-half_av_pd)
    nslowcomp(t)=nslowcomp(t-1);
  end
  for t=max(1,n(3)-half_av_pd)+1:n(3)
    nslowcomp(t)=nslowcomp(t-1)-1;
  end
  
  slowcomp=ones(size(flatframes));
  for z=1:n(1)*n(2)  % ugly to do in for-loop, but perhaps quickest
    if(mod(z,100)==0)
      fprintf(['  ' num2str( z/n(1)/n(2)*100, 2) ' %%  \r' ])
    end
    slowcomp(z,1)=sum( flatframes(z,1:min(half_av_pd,n(3) )));
    for t=2:min(half_av_pd,max(1,n(3)-half_av_pd))
      slowcomp(z,t)=slowcomp(z,t-1)+flatframes(z,t+half_av_pd);
    end
    for t=min(half_av_pd,max(1,n(3)-half_av_pd))+1:max(1,n(3)-half_av_pd)
      slowcomp(z,t)=slowcomp(z,t-1)-flatframes(z,t-half_av_pd)+...
	  flatframes(z,t+half_av_pd);
    end
    for t=max(1,n(3)-half_av_pd)+1:n(3)
      slowcomp(z,t)=slowcomp(z,t-1)-flatframes(z,t-half_av_pd);
    end
    slowcomp(z,:)=slowcomp(z,:)./nslowcomp;
  end
  
  toc
  
  flatframes=flatframes-slowcomp;
  slowcomp=reshape(slowcomp,n(1),n(2),n(3));
  frames=reshape(flatframes,n(1),n(2),n(3));
  

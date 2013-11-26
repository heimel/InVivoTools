function [info,header,header32]=imagefile_info( fname )
%IMAGEFILE_INFO returns info struct with properties of image 3001 file
%
% [INFO,HEADER,HEADER32]=IMAGEFILE_INFO( FNAME )
%      returns
%         info.name
%         info.filesize  (bytes)
%         info.headersize  (bytes)
%         info.n_bytes_per_pixel 
%         info.datatype
%         info.xsize 
%         info.ysize
%         info.xbin % spatial binning in x-dimension
%         info.ybin % spatial binning in y-dimension
%         info.xoffset
%         info.yoffset
%         info.n_images (number of frames for multiple condition files)
%         info.n_total_images
%         info.nconditions (number of conditions)
%         info.date
%         info.cameraframes_per_frame
%         info.camera_framerate  
%         info.framerate = camera_framerate/cameraframes_per_frame (Hz) 
%         info.frameduration = 1 / framerate  (s)
%         info.headeronly = 0:if BLK file used, 1:if HDR used
%
%
%      if file could not be opened, info.n_images=1
%
%  2003, Steve Van Hooser, Alexander Heimel
%
%  2005-01-25 JFH: added n_total_images and n_conditions
%  2005-05-10 JFH: added xoffset and yoffset
%  2006-03-31 JFH: added framerate, camera_framerate and imager, frameduration
%  2007-02-16 JFH: added headeronly

  info=struct('name','','n_images',-1);

  [fid,message] = fopen(fname,'r');
  if fid==-1
    disp(['IMAGEFILE_INFO: Could not open ' fname '.']);
    % see if copy exists
    ind=findstr(fname,'BLK');
    if ~isempty(ind)
      fname(ind:ind+2)='HDR';
      [fid,message] = fopen(fname,'r');
      info.headeronly=1;
    else
      info.headeronly=0;
    end
    if fid==-1
      return
    else
      disp(['IMAGEFILE_INFO: Reading header file ' fname ' instead.']);
    end
  else
    ind=findstr(fname,'BLK');
    if ~isempty(ind)
      info.headeronly=0;
    else
      info.headeronly=[];
    end
  end
  
  
  [header, count] = fread(fid,429,'int32');

  
  
  
  info.name=fname;
  info.filesize=header(1);
  info.headersize=header(4);
  info.n_bytes_per_pixel=header(9);
  info.xsize=header(10);
  info.ysize=header(11);
  info.n_images=header(12);
  info.n_conditions=header(13);
  info.xbin=header(14); % probable, could also be 15,16,17
  info.ybin=header(15); % probable, could also be 15,16,17
  info.xoffset=header(30);
  info.yoffset=header(31);
  
  if info.filesize==0
    % no images yet recorded
    % disp('Error: filesize is zero. no images (yet?) recorded.')
    info.n_total_images=0;
    return
  end
  
				      
  info.cameraframes_per_frame=header(233);
  info.n_total_images=(info.filesize-info.headersize)/...
      (info.xsize*info.ysize*info.n_bytes_per_pixel);
  
  
  
  if info.n_total_images~=info.n_images*info.n_conditions
    disp('IMAGEFILE_INFO: Unsure about total number of images');
    info.n_total_images=0;
    return
    % if interpretation of headerfile is wrong
  end  
  
  %header(235); % is also something 

  
  header32=header;
  
  switch info.n_bytes_per_pixel
   case 2,
    info.datatype='short';
   case 4,
    info.datatype='long';
   otherwise
    disp('IMAGEFILE_INFO: Do not know this datatype');
  end 

  %disp(['Not assigned: ' num2str(header( [ (2:3) (5:8) ] )')])

  
  frewind(fid);
  [header, count] = fread(fid,1716,'uchar');
    
  info.date=char(header(101:109))'; % date as 03/29/106 for 29-03-06

  info.date(end-2:end+1)=num2str(eval(info.date(end-2:end))+1900)';
  info.n_conditions=header(49); % guess


  
  % specifics for levelt lab:
  ind_imager=[929 954 973 974 975 976 977 978];
  
  old_imager  = [15   0 162 81 33  66 180 6 ];  % telix camera on daneel
  
  % .. camera on andrew
  new_imager  = [30 106   0  0 160 65  0  0]; % andrew
  new_imager2 = [30 107   0  0 160 65  0  0]; % andrew after reinstall
  new_imager3 = [15 107   0  0  32 66  0  0]; % andrew 2013? 

  
  
  if header(973) == 162
    info.imager='daneel';
  elseif header(954)==106 || header(954)==107
    info.imager='andrew';
  else
    info.imager='unknown';
  end  		      
  info.camera_framerate=camera_framerate(info.imager, header);
  info.framerate=info.camera_framerate / info.cameraframes_per_frame;
  info.frameduration= 1/ info.framerate;   
  
  
  fclose(fid);
  
  % make copy
  ind=findstr(fname,'BLK');
  if ~isempty(ind)
    fname(ind:ind+2)='HDR';
    fid=fopen(fname,'w');
    if fid~=-1 % dont bother if I cant open it
      fwrite(fid,header32,'uint32');
      fclose(fid);
    end
    
  end
  
  

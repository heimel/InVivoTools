function params_ = readprairieviewxml(filename)
% params_ = readprairieviewxml(filename)
%  A fast tool for reading the prairieview xml file and extracting
%  relevant params.
%
%
%  This function does not read the old format (.pcf files).
%  Use READPRAIRIECONFIG to open either format.
% 

% MM 2/07

fid = fopen(filename);
if(fid==-1)
  error('Failed to open XML file')
end

cycind = zeros(0,0);
q = 0;
while q~=-1
  q = fgetl(fid);
  if(any(strfind(q,'<Datasets>')))
    cycind(length(cycind)+1,1) = ftell(fid);
  end
end
ncycles = length(cycind);
params_.Main.Total_cycles = ncycles;

pos = cycind(1);
params_.Main.Dwell_time__us_ = getxmlval(fid,'Dwell_Time',pos);
params_.Main.Scanline_period__us_ = 1e3*getxmlval(fid,'Scanline_Period',pos);
params_.Main.Lines_per_frame = getxmlval(fid,'Lines_Per_Frame',pos);
params_.Main.Pixels_per_line = getxmlval(fid,'Pixels_Per_Line',pos);
params_.Main.X_microns_per_pixel = getxmlval(fid,'X_Microns_Per_Pixel',pos);
params_.Main.Y_microns_per_pixel = getxmlval(fid,'Y_Microns_Per_Pixel',pos);
framerate = getxmlval(fid,'Framerate',pos);
params_.Main.Frame_period__us_ = (1/framerate) * 1e6;

params_.Image_TimeStamp__us_ = [];

numImages = cell(1,ncycles);
for i_cyc = 1:ncycles
  ni = getxmlval(fid,'Frames',cycind(i_cyc));
  numImages(i_cyc) = {ni};
  eval(['params_.Cycle_' int2str(i_cyc) '.Number_of_images=ni;']);
end

frameind = cell(size(numImages));
timestamp = [];
for i_cyc = 1:ncycles
  str2find = sprintf('<Dataset_x0020_%d>',i_cyc);
  nf = numImages{i_cyc};
  
  if(i_cyc==1)
    % Note that you might think I'd want to frewind the file, but you'd be
    % wrong -- the file position indicator will already be above, but near,
    % where I need it to be after the above code is run.
    
    badstr = sprintf('<Dataset_x0020_%d>',i_cyc+1);
    % 'badstr' means that if a string with these contents is found, we've
    % gone past where we might find the relevant info.
    
  elseif(i_cyc>1 & i_cyc<ncycles)
    fseek(fid,frind(end),-1);
    % Move the file pos to the end of the last frame of the previous
    % cycle
	 badstr = sprintf('<Dataset_x0020_%d>',i_cyc+1);
  else
    fseek(fid,frind(end),-1);
    % Move the file pos to the end of the last frame of the previous
    % cycle
    badstr = 'ozDef';
  end
  
  frind = zeros(nf,1);
  ts = zeros(nf,1);
  ind = 0;
  q = 0;
  badfind = 0;
  while q~=-1 & badfind==0
	 q = fgetl(fid);
	 if(any(strfind(q,str2find)))
		ind = ind + 1;
		fp = ftell(fid);
		frind(ind,1) = fp;
		ts(ind,1) = getxmlval(fid,'Time',fp);
	 elseif(any(strfind(q,badstr)))
		badfind = 1;
	 end
  end
  frameind(i_cyc) = {frind};

  timestamp = [timestamp;ts];

  % eval(['params_.Cycle_' int2str(i_cyc) '.Image_TimeStamp__us_ = 1e3*(ts);']);

end

params_.Image_TimeStamp__us_ = 1e3*timestamp';
% disp(size(1e3*timestamp))

pos = frameind{end};
[c1 c1p] = getxmlval(fid,'Includes_Channel_1',0);
params_.Main.Channel_1_Active = c1;
c2 = getxmlval(fid,'Includes_Channel_2',c1p);
params_.Main.Channel_2_Active = c2;
if(c1==1)
  params_.Main.Channel_1_PMT_Gain = getxmlval(fid,'Channel_1_PMT_Gain',pos);
else
  params_.Main.Channel_1_PMT_Gain = [];
end

if(c2==1)
  params_.Main.Channel_2_PMT_Gain = getxmlval(fid,'Channel_2_PMT_Gain',pos);
else
  params_.Main.Channel_2_PMT_Gain = [];
end

params_.Main.Laser_Power = getxmlval(fid,'Laser_Line_1_Power',pos);
params_.Main.Laser_Wavelength = getxmlval(fid,'Laser_Line_1_Wavelength',pos);


fclose(fid);



function [val,fp] = getxmlval(fid,str2find,pos,makenum)
% 
% makenum -- if set to 1, converts the string to a number.  Default: 1.

if(~exist('makenum','var'))
  makenum = 1;
end

if(~exist('pos','var'))
  pos = 0;
end

fseek(fid,pos,-1);
val = [];
q = 0;
while isempty(val) & q~=-1
  q = fgetl(fid);
  if(any(strfind(q,str2find)))
	 br1 = min(strfind(q,'>'));
	 qq = strfind(q,'<');
	 br2 = min(qq(qq>br1));

	 if(makenum==1)
		val = str2num(q(br1+1:br2-1));
	 else
		val = q(br1+1:br2-1);
	 end
  end
end

if(nargout==2)
  fp = ftell(fid);
end

% Move file position indicator back to original pos
fseek(fid,pos,-1);

function [stdnr,t,nr] = analyze_lamptest(test,day,last)
%ANALYZE_LAMPTEST analyzes calibration intrinsic signal setup measurements
%
%  [STDNR, P2PNR] = ANALYZE_LAMPTEST(TEST,DAY)
%
% 2009, Alexander Heimel
%

figure

if nargin<1
    test = [];
else
    test = num2str(test,'%02d');
end
if nargin<2
    day = '';
end
if isempty(day)
    day = datestr(now,29); % eg. '2010-10-01'
end
if nargin<3
    last = 100;
end

switch isunix
    case 1
        datapath = fullfile('/home/data/Test',day);
    case 0
        if strcmp(host,'jander')
           datapath = fullfile('C:\Data\InVivo\Imaging\Jander\Test',day);
        else
           datapath = fullfile('D:\Data\Test',day);
        end
% datapath modified to include Jander, where data is 
% saved in C:\Data
% Rajeev 2013-08-07

end
if ~exist(datapath,'dir')
    disp(['Path ' datapath ' does not exist. Quitting.']);
    return;
end

cd( datapath );


if isempty(test)
    dd=dir('lamp*BLK');
    if isempty(dd)
        disp(['No lamp test blk files in ' pwd '. Quitting.']);
        return
    end
    [ds,ind]=sort( {dd(:).date});
    filename=dd(ind(end)).name;
    posb=find(filename=='B');
    filename=filename(1:posb(1)-1);
else
    filename=['lamp_E' test];
end

ist=3;        % interstimulus time in seconds
frametime=0.6; % frame time in seconds

experimentlist=dir([filename 'B*BLK']);
experimentlist=sort({experimentlist(:).name});


  
% check if last file is ready
fileinfo=imagefile_info(experimentlist{end});
if fileinfo.n_total_images==0
  % not ready yet
  experimentlist={experimentlist{1:end-1}};
end
fileinfo=imagefile_info(experimentlist{1});



clear('frames');
t=[];

if ~isempty(last)
    start = max(1,(length(experimentlist)-last));
else
    start = 1;
end
disp(['BLKs available: ' num2str(length(experimentlist))]);
disp(['Reading last ' num2str(length(experimentlist)-start) ' BLK files of test ' filename '.']);
if isempty(experimentlist)
  disp('No blockfiles ready yet.')
  return
end


for blk=start:length(experimentlist)
  frames(:,:,(blk-start)*fileinfo.n_images+(1:fileinfo.n_images))=...
      read_oi_compressed(...
	  experimentlist{blk},...
	  1,...
	  fileinfo.n_images,...
	  1,...  %only first part
	  1,0);
  
  t((blk-start)*fileinfo.n_images+(1:fileinfo.n_images))=...
      (ist+fileinfo.n_images*frametime)*(blk-1)+...
      (0:fileinfo.n_images-1)*frametime;
end


response=[];
for i=1:size(frames,3)
  response(i)=sum(sum(frames(:,:,i)));
end
nr=100*response/mean(response);


plot(t,nr,'k.-');


xlabel('Time (s)');
ylabel('Normalized total reflection (%)');

stdnr = std(nr);
p2pnr = max(nr)-min(nr);



tit=filename;
tit(find(tit=='_'))='-';
tit=[tit ' std= ' num2str(std(nr),3)];
tit=[tit ' peak2peak= ' num2str(p2pnr,3)];
title(tit);

disp(['Std = ' num2str(stdnr,3)]);


hold on

% fit exponential
if 0
asymp = 0.001*sign(nr(end)-nr(1)) + nr(end);
[tau,r]=fit_exponential(t,nr-asymp);
plot(t,r*exp(t/tau)+asymp,'r')
disp(['Decay time > ' num2str(-tau,3) ' s.']);
end

% smoothing
nrs = smooth(nr,40);
ts = smooth(t,40);
stdnrs = std(nr-nrs');
plot(ts,nrs,'b');

disp(['After smoothing Std = ' num2str(stdnrs,3)]);

hold off


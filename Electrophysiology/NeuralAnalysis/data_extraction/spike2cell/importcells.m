function cells=importcells(path,trial,suffix)
%IMPORTCELLS stores spike2cell-sorted spikes into Nelsonlab experiment file
%
%   CELLS=IMPORTCELLS(PATH,TRIAL,SUFFIX)
%
%       PATH, root directory of experiment data, e.g. /home/data/2002-08-01
%       TRIAL, full trial name, e.g. t00019
%       SUFFIX, empty or `matched' or `merged'
% 
% note: uses loadcells and transfercells functions
% August 2002, Alexander Heimel, heimel@brandeis.edu


try 
  cksds=cksdirstruct(path);
catch
  disp(['importcells: Could not create/open cksdirstruct ' path])
  return
end
try 
  cells=loadcells(trial,cksds,suffix);
catch
  disp(['importcells: Could not load cells of trial ' num2str(trial) ])
  return
end
try 
  transfercells(cells,cksds);
catch
  disp(['importcells: Could not transfer cells to cksdirstruct'])
  return
end


return


function cells=loadcells(trial,cksds,suffix)
% LOADCELLS reads spike2cell-spiketable file into spikedata object
%
%   CELLS=LOADCELLS(TRIAL,CKSDS,SUFFIX)
%  
%   SUFFIX can be empty or `merged' or `matched'
%
% note that for deleteexpvar to work
%   name should be changed to namepattern or something els
%   and MClust should not be in the path because of streq 
% 
% June 2002, Alexander Heimel, heimel@brandeis.edu


[px,expf] = getexperimentfile(cksds,1);



% load acquisitionfile for sampling frequency samp_dt
  ff=fullfile(getpathname(cksds),trial,'acqParams_out');
f=fopen(ff,'r');
     fclose(f);  % just to get proper error
acqinfo=loadStructArray(ff);


n_tetrodes=0;
for i=1:size(acqinfo,2)
  if strcmp(acqinfo(i).type,'tetrode')
    n_tetrodes=n_tetrodes+1;
  end
end

disp([num2str(n_tetrodes) ' tetrodes found.']);

if(length(suffix)>0)
     suffix=['.' suffix '.'];
else
  suffix='.'; 
end


for tetrode=1:n_tetrodes
  % load spiketable file
  filename=sprintf('%s%s/tet%d%sspiketable',...
		   getscratchdirectory(cksds),trial,tetrode,suffix);


  spiketable=load(filename,'-ascii');
  spiketable(:,1)=spiketable(:,1)*acqinfo(1).samp_dt;

  % load stimulus starttime
  stimsfilename=fullfile(getpathname(cksds),trial,'stims.mat');
  stimsfile=load(stimsfilename);
  intervals=[stimsfile.start ...
		    stimsfile.start+acqinfo(1).reps*acqinfo(1).samp_dt];

  spiketable(:,1)=spiketable(:,1)+stimsfile.start;

  desc_long=filename;
  desc_brief=filename;
  detector_params=[];
  n_classes=max(spiketable(:,2))+1;



  %load spikes
  filename=sprintf('%s%s/tet%d%sspikes',...
		   getscratchdirectory(cksds),trial,tetrode,suffix);
  [spikes,before,after]=loadspikes(filename);
  spikewindow=before+after;

  %load shapes
  filename=sprintf('%s%s/tet%d%sshapes.asc',...
		   getscratchdirectory(cksds),trial,tetrode,suffix);
  shapes=load(filename,'-ascii');
  shapes=reshape(shapes,spikewindow,size(shapes,1)/spikewindow,size(shapes,2));   

cellnamedel=sprintf('cell_%s_%.4d_*',acqinfo(tetrode).name,acqinfo(tetrode).ref);
 deleteexpvar(cksds,cellnamedel); % delete all old representations

  cellnumber=1; % no direct link with classnumber
  for cl=0:n_classes-1
    data=spiketable(find(spiketable(:,2)==cl),1);


    if(length(data)>10) % do not store cells with less then 10 spikes
      cells(tetrode,cellnumber).spikes=  ...
                 spikes(:,:,find(spiketable(:,2)==cl));

      cells(tetrode,cellnumber).shape=shapes(:,:,cl+1);
         % cellname needs to start with 'cell' to be recognized
      % by cksds
      cells(tetrode,cellnumber).name=sprintf('cell_%s_%.4d_%.3d',...
	     acqinfo(tetrode).name,acqinfo(tetrode).ref,cellnumber);
      cells(tetrode,cellnumber).intervals=intervals;
      cells(tetrode,cellnumber).desc_long=desc_long;
      cells(tetrode,cellnumber).desc_brief=desc_brief;
      cells(tetrode,cellnumber).data=data;
      cells(tetrode,cellnumber).detector_params=detector_params;


      cells(tetrode,cellnumber).trial=trial;
      %not really important but nice for plotting

      cellnumber=cellnumber+1;
   end
  end
end

return

function transfercells(cells,cksds)
%TRANSFERCELLS Transfers cells from loadcells to the cksdirstruct
%
%    TRANSFERCELLS(CELLS,CKSDS)
%
% June 2002, Alexander Heimel, heimel@brandeis.edu


n_tetrodes=size(cells,1);
n_cells_per_tetrode=size(cells,2);


for tet=1:n_tetrodes
  for cl=1:n_cells_per_tetrode
    if ~isempty(cells(tet,cl).shape)
      acell=cells(tet,cl);
      thecell=cksmultipleunit(acell.intervals,acell.desc_long,...
		acell.desc_brief,acell.data,acell.detector_params);
      saveexpvar(cksds,thecell,acell.name,1);

     end
  end
end

return







function [spikes, before, after]=loadspikes(filename,first,last)
% LOADSPIKES Load spikes from spike2cell file
%
%   [SPIKES, BEFORE, AFTER]=LOADSPIKES(FILENAME,FIRST,LAST)
%
%  (first record is 1) inclusive last
%
% June 2002, Alexander Heimel (heimel@brandeis.edu)


fspikes=fopen(filename,'r');
spikecount=fread(fspikes,1,'int');    
n_channels=fread(fspikes,1,'int');    
before=fread(fspikes,1,'int');
after=fread(fspikes,1,'int');

if nargin==1
  spikes=fread(fspikes,'float');
  spikes=reshape(spikes,before+after,n_channels,spikecount);
  return
end

if nargin==2
  last=spikecount;
end

n_records=last-first+1;
spikewindow=before+after;
recordsize=spikewindow*n_channels;
fseek(fspikes,recordsize*(first-1)*4,'cof');
spikes=fread(fspikes,n_records*recordsize,'float');
spikes=reshape(spikes,spikewindow,n_channels,n_records);

return

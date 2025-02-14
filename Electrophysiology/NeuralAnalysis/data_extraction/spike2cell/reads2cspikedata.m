function cells=reads2cspikedata(trial,cksds)
%READS2CSPIKEDATA reads spike2cell-spiketable file into spikedata object
%
%   CELLS=READS2CSPIKEDATA(TRIAL,CKSDS)
%  
% June 2002, Alexander Heimel, heimel@brandeis.edu

[px,expf] = getexperimentfile(cksds,1);

thedir=sprintf('t%05d',trial);


% load acquisitionfile for sampling frequency samp_dt
acqinfo=loadStructArray( fullfile(getpathname(cksds),thedir,...
				  'acqParams_out'));




n_tetrodes=size(acqinfo,2)


for tetrode=0:n_tetrodes-1
  % load spiketable file
  filename=sprintf('%st%05dtet%d.spiketable',...
		   getscratchdirectory(cksds),trial,tetrode);
  spiketable=load(filename,'-ascii');
  spiketable(:,1)=spiketable(:,1)*acqinfo(1).samp_dt;

  % load stimulus starttime
  stimsfilename=fullfile(getpathname(cksds),thedir,'stims.mat');
  stimsfile=load(stimsfilename);
  intervals=[stimsfile.start ...
		    stimsfile.start+acqinfo(1).reps*acqinfo(1).samp_dt];

  spiketable(:,1)=spiketable(:,1)+stimsfile.start;

  desc_long=filename;
  desc_brief=filename;
  detector_params=[];
  n_classes=max(spiketable(:,2))+1;



  %load spikes
  filename=sprintf('%st%05dtet%d.spikes',...
		   getscratchdirectory(cksds),trial,tetrode);
  [spikes,before,after]=loadspikes(filename);
  spikewindow=before+after;

  %load shapes
  filename=sprintf('%st%05dtet%d.shapes.asc',...
		   getscratchdirectory(cksds),trial,tetrode);
  shapes=load(filename,'-ascii');
  shapes=reshape(shapes,spikewindow,size(shapes,1)/spikewindow,size(shapes,2));   

  cellnamedel=sprintf('cell_%s_%.4d_*',acqinfo(tetrode+1).name,acqinfo(tetrode+1).ref)
 deleteexpvar(cksds,cellnamedel); % delete all old representations

  cellnumber=1; % no direct link with classnumber
  for cl=0:n_classes-1
    data=spiketable(find(spiketable(:,2)==cl),1);


    if(length(data)>10) % do not store cells with less then 10 spikes

      cellname=sprintf('cell_%s_%.4d_%.3d',acqinfo(tetrode+1).name,acqinfo(tetrode+1).ref,cellnumber)
         % cellname needs to start with 'cell' to be recognized

      cells(tetrode+1,cellnumber).spikes=  ...
                 spikes(:,:,find(spiketable(:,2)==cl));

      cells(tetrode+1,cellnumber).shape=shapes(:,:,cl+1);
      cells(tetrode+1,cellnumber).name=cellname


      thecell=cksmultipleunit(intervals,desc_long,desc_brief,data,detector_params);
      saveexpvar(cksds,thecell,cellname,1);
      cksmu(cellnumber)=thecell;
      cellnumber=cellnumber+1;
   end
  end
end







function cells=spike2cell(arguments,suffix,testname,path)
%SPIKE2CELL calls spike2cell multi-electrode spike sorter
%
%  CELLS=SPIKE2CELL(ARGUMENTS,SUFFIX)
%    Needs RunExperiment to be open to find cksds, uploads
%    extracted spikes.
%
%    ARGUMENTS are passed to spike2cell as commandline arguments   
%    SUFFIX can be
%      '':   taking classes after clustering, before merging
%      'merged': taking classes after merging (default)
%      'matched': taking matched classes
%
%  CELLS=SPIKE2CELL(ARGUMENTS,SUFFIX,TESTNAME)
%    TESTNAME = directory name of experiment data, e.g. t00213
%  CELLS=SPIKE2CELL(ARGUMENTS,SUFFIX,TESTNAME,PATH)
%    PATH = root directory of experiment data,
%           e.g. /home/data/2003-02-06
%    in this case no open RunExperiment is necessary
%
%  Only works for the neliano lab as many spike2cell option are
%  set specifically for the neliano lab
%
%  To not re-sort, but use already sorted spikes, set
%      ARGUMENTS = '--old --text'
%  Or use IMPORTCELLS (see help importcells)
%
%
%  Type '!spike2cell -h|more' for help regarding commandline arguments
%  of spike2cell
%
%  See also IMPORTCELLS, COMBINECELLS, CLUSTERGRAPH, COLORPLOTSHAPES
%    
%
%  2003, Alexander Heimel (heimel@brandeis.edu)
%

if nargin<4
  cksds=getcksds;
  if isempty(cksds), 
    errordlg(['No existing data---make sure you hit '...
	      'return after directory in RunExperiment window']);
    return;
  end
  path=getpathname(cksds);
end

if nargin<3
  try
    testname = get(findobj(geteditor('RunExperiment'),'Tag','SaveDirEdit'),...
		   'String');
  catch
    errordlg(['Could not find testname. Make sure RunExperiment is' ...
	      ' open.']);
  end
end

if nargin<2
  suffix='merged';
end

if nargin<1
  arguments='';
end


  

% load acquisitionfile for sampling frequency samp_dt
ff=fullfile(getpathname(cksds),testname,'acqParams_out');
f=fopen(ff,'r');
try
  fclose(f);  % just to get proper error message
catch
  errordlg(['Could not open ' ff '. Check path.']);
  return
end
acqinfo=loadStructArray(ff);
n_tetrodes=size(acqinfo,2);


commandbase='xterm -e spike2cell';
command=commandbase;
command=[command ' -p ' path];
command=[command ' -t ' testname];
command=[command ' --n_tetrodes=' num2str(n_tetrodes)];
command=[command ' --n_channels_per_tetrode=4'];

command=[command ' ' arguments];
command=[command ' &'];
%  {OPT_N_CHANNELS_PER_TETRODE,1,0,0},
 

disp(command);

try
  [s,w]=unix(command);
catch
  s=1;
end
if s
  errordlg('Unable to run spike2cell. Try command from terminal'); 
  return
end

disp('Hit any key when ready with spikesorting')
pause

disp(['Importing ' suffix ' data from ' path testname]);
cells=importcells(path,testname,suffix);

 


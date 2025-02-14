function [stimuli,param] = import_population( stimuli, path, ...
					      testname, cellname )
%IMPORT_POPULATION imports population of genetic stimuli from experiment
%  
%      [STIMULI,PARAM] = IMPORT_POPULATION( STIMULI,  PATH, TESTNAME,
%        CELLNAME )
%          e.g. PATH = '/home/data/2003-02-17', TEST = 't00012'  
%  
%      [STIMULI,PARAM] = IMPORT_POPULATION( STIMULI, PATH, TESTNAME )
%          prompts for cellname if more than one cell found
%
%      [STIMULI,PARAM] = IMPORT_POPULATION( STIMULI, CELLNAME )
%          gets path and testname from RunExperiment panel
%
%      [STIMULI,PARAM] = IMPORT_POPULATION( STIMULI )
%          prompts for cellname if more than one cell found
%   
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%

if nargin<3  %no path and testname given
  cksds = getcksds;
  if isempty(cksds), 
    errordlg(['No existing data---make sure you hit '...
	      'return after directory in RunExperiment window']);
    return;
  end; 
  testname = get(findobj(geteditor('RunExperiment'),'Tag','SaveDirEdit'),...
		 'String');
else
  cksds=cksdirstruct(path);
end

if nargin==1 | nargin==3
  cellname=getcellname(cksds)
end

if isempty(stimuli)
  generation=1
  clear('stimuli');
  stimuli(1)=struct('chromosome',[],'response',[],'fitness',[],'generation',0);
  stimuli(1)=[];
else
  generation=max( [stimuli(:).generation] )
end

[savescript,mti]=getstimscript(cksds,testname);

sms=get(savescript);

% get parameters
p=getparameters(sms{1});
%param=genetic_defaults;
param.background=p.BG';
param.window=(p.rect(3)-p.rect(1))/p.scale;
param.window=(p.rect(4)-p.rect(2))/p.scale;
param.scale=p.scale;
param.time_per_frame=1000/p.fps;
param.duration=p.N;
param.isi=p.isi;

 param.bins=linspace( 0.000, (param.duration*param.time_per_frame+100)/1000,...
		     10);  % not quite good

s = getstimscripttimestruct(cksds,testname);
param.repeats=length(s.mti);


% get chromosomes
m=getshapemovies(sms{1});
chromosomes=getshapemovies(sms{1});



pause off
responses=calculate_responses(cksds,testname,cellname,param.bins, ...
			      param.repeats);
pause on
fitnesses = compute_fitness( responses );

if max(responses(:))==0
  disp('WARNING: No spikes found');
end



stimuli = insert_in_population( stimuli, chromosomes, responses, ...
				fitnesses, generation);

disp(['Best stimulus fitness:' num2str(stimuli(1).fitness) ])


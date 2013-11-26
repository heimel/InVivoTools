function b = stiminterview(argument)
%  STIMINTERVIEW - Create a stimulus timing structure from user responses
%
%  B = STIMINTERVIEW(RECORD)
%  B = STIMINTERVIEW(DIRNAME)
%
%  Interviews the user for a description of a stimulus lacking a
%  log in a 'stims.mat' file.  The resulting stims.mat file is
%  stored in the directory pointed to by RECORD.
%
if isstruct(argument)
    record = argument;
    dirname = tpdatapath( record );
else
    dirname = argument;
end

disp(['Beginning user interview to describe stimuli in ' dirname '.']);

stimlist = [];
stimtimesfilename=fullfile( fixpath(dirname),'stimtimes.txt');
if ~exist(stimtimesfilename,'file')
  % create stimtimes files from tif file (written by Alexander, without
  % proper knowledge about the file structure)
  params=tpreadconfig(record );
  fid = fopen(stimtimesfilename,'w');
  % assuming line structure: 
  %    stimnumber, startpreback startstim stopstim stoppostback
  fprintf(fid,'%d %f %f %f %f\n',1,...
    params.frame_timestamp(1),params.frame_timestamp(1),...
    params.frame_timestamp(end),params.frame_timestamp(end));
  fclose(fid);
end

fid = fopen(stimtimesfilename,'r');
if fid<0,
  error('Sorry, could not find the stimtimes.txt file, so no analysis is possible.');
end
while ~feof(fid),
  stimline = fgets(fid);
  stimdata = sscanf(stimline,'%f');
  if length(stimdata)>2
    stimlist(end+1) = stimdata(1);
  end;
end;

stimlist = unique(stimlist);

isi = input('What was the interstimulus interval? (default 1)');
if isempty(isi)
  isi=1;
end
isis = input('Did the interstimulus interval occur before the stimulus (0/1, default 0)?');
if isempty(isis)
  isis=0;
end
if isis==1
    isi = -1 * isi; 
end

paramname = input('Enter the name of the varied parameter (must be valid variable name. Default = angle): ','s');
if isempty(paramname)
    paramname = 'angle';
end
paramval = [];

argstr = '';
for i=1:length(stimlist),
  r = input(['Please enter parameter value for stimulus ' int2str(stimlist(i)) ': ']);
  if isempty(r)
    disp('  assigning zero to parameter value');
    r=0;
  end
    paramval(end+1) = r;
    argstr = [argstr ',stimlist(' int2str(i) '),paramval(' int2str(i) ')'];
end;

thestr=['createmti([fixpath(dirname ) ''stimtimes.txt''],isi,paramname' argstr ');'];

eval(thestr);

b = 1;

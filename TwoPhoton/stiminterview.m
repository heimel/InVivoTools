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
    dirname = experimentpath(record);
else
    record = [];
    dirname = argument;
end

logmsg(['Beginning user interview to describe stimuli in ' dirname '.']);

stimlist = [];

dur = input('What was the stimulus duration? (default 1 s)');
if isempty(dur)
  dur=1;
end
isi = input('What was the interstimulus interval? (default 1 s)');
if isempty(isi)
  isi=1;
end
isis = input('Did the interstimulus interval occur before the stimulus (0/1, default 1)?');
if isempty(isis)
  isis=1;
end

if isis == 1
    bgpretime = isi;
    bgposttime = 0;
else
    bgpretime = isi;
    bgposttime = 0;
end

if isis==1
    isi = -1 * isi; 
end


stimtimesfilename=fullfile( fixpath(dirname),'stimtimes.txt');
if ~exist(stimtimesfilename,'file')
    logmsg('Creating stimtimes.txt file');
    n_stimuli =  input('What was the number of different stimuli? (default 1)');
    if isempty(n_stimuli) || n_stimuli<1
        n_stimuli=1;
    end
    n_repeats =  input('What was the number of repeats? (default 1)');
    if isempty(n_repeats) || n_repeats<1
        n_repeats=1;
    end
    
    
    starttime =  input('Shift in starttime? (default 0)');
    if isempty(starttime)
        if isfield(record,'datatype') && strcmp(record.datatype,'tp')
            params = tpreadconfig(record );
            starttime = params.frame_timestamp(1);
            endtime = params.frame_timestamp(end);
        else
            starttime = 0;
        end
    end
    
    % create stimtimes files from tif file (written by Alexander, without
    % proper knowledge about the file structure)
    % assuming line structure:
    %    stimnumber, startpreback startstim stopstim stoppostback
    fid = fopen(stimtimesfilename,'w');
    
    t = starttime;
    for r = 1:n_repeats
        for s = 1:n_stimuli
            timeline = [t  t+bgpretime t+bgpretime+dur t+bgpretime+dur+bgposttime];
            fprintf(fid,'%d %f %f %f %f\n',1,timeline(1),timeline(2),timeline(3),timeline(4));
            t = t+bgpretime+dur+bgposttime;
        end
    end
    fclose(fid);
    logmsg(['Created ' stimtimesfilename]);
end


fid = fopen(stimtimesfilename,'r');
if fid<0,
    error('Sorry, could not find the stimtimes.txt file, so no analysis is possible.');
end
while ~feof(fid)
    stimline = fgets(fid);
    stimdata = sscanf(stimline,'%f');
    if length(stimdata)>2
        stimlist(end+1) = stimdata(1);
    end
end
fclose(fid);

stimlist = unique(stimlist);


paramname = input('Enter the name of the varied parameter (must be valid variable name. Default = angle): ','s');
if isempty(paramname)
    paramname = 'angle';
end
paramval = [];

argstr = '';
for i=1:length(stimlist),
  r = input(['Please enter parameter value for stimulus ' int2str(stimlist(i)) ' (default = 0) : ']);
  if isempty(r)
    r=0;
  end
  paramval(end+1) = r;
end

createmti( fullfile(dirname, 'stimtimes.txt'),isi,paramname,stimlist,paramval );

b = 1;

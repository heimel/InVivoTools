function write_gerbilrun(pathname, scriptName, saveWaves, outfile);

% WRITE_GERBILRUN Send commands to run a stimscript remotely
%
% 
%
% Note: the name of this function has no real significance.
%

if strcmp(computer,'LNX86'), pathname = linpath2mac(pathname); end;
pathname = localpath2remote(pathname);

fid = fopen(outfile,'wt');

fprintf(fid,'ReceptiveFieldGlobals; if isempty(RFparams)|RFparams.state==0|exist(%s)==1,',scriptName);
fprintf(fid,'ShowStimScreen\n');
fprintf(fid,'MTI = DisplayTiming(%s);\n',scriptName);

if saveWaves,
	fprintf(fid, ...
	  'adjust_duration(''acqParams_in'',%s,[''%s'' filesep ''acqParams_in'']);\n', ...
		scriptName,pathname);
	if strcmp(getenv('HOST'),'gerbil.bio.brandeis.edu')~=1,
		fprintf(fid,'applescript(''startDormouse'')\n');
	end;
	fprintf(fid,'pause(4)\n');
end;

fprintf(fid,'[MTI2,start]=DisplayStimScript(%s,MTI,0);\n',scriptName);

if saveWaves,
  fprintf(fid,'gggg = pwd; cd(''%s'');\n',pathname);
  %fprintf(fid, ...
  %    'str=datestr(now);str(find((str=='' '')|(str=='':'')))==[''---''];\n');
  %fprintf(fid,'eval([''save '' str '' MTI2 start %s'']);\n',scriptName);
  fprintf(fid,'eval([''saveScript = strip(%s)'']);\n',scriptName);
  fprintf(fid,'MTI2 = stripMTI(MTI2);\n');
  fprintf(fid,'StimWindowGlobals;\n');
  fprintf(fid,'zzz=clock;');
  fprintf(fid,'save stims MTI2 start saveScript StimWindowRefresh;\n');
  fprintf(fid,'cd(gggg);\n');
  fprintf(fid,'pause(max([0 10-etime(clock,zzz)]));StimEndSound;\n'); % so we don't start a new stim before acquisition is done
end;

%fprintf(fid,'CloseStimScreen\n');
fprintf(fid,'end;');
fclose(fid);

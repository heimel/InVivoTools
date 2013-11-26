function im = prairieviewlatestblock(dirname,cyclenum,channum);

tpdirname = [dirname '-001'];

pcfile = dir([tpdirname filesep '*_Main.pcf']);
if isempty(pcfile), pcfile = dir([tpdirname filesep '*.xml']); end;
pcfile = pcfile(end).name;
params = readprairieconfig([tpdirname filesep pcfile]);

latestfile = dir([tpdirname filesep 'Cycle' int2str(cyclenum) '_Image_Block_Ch' int2str(channum) '_Frames*']);

strs = {};
for i=1:length(latestfile), strs{i} = latestfile(i).name; end;

sorted = sort(strs);

pause(1.5); % wait for file to be written

disp(['File is ' sorted{end} '.']);
fid=fopen([tpdirname filesep sorted{end}]);
im = fread(fid,Inf,'uint32',0,'l');
fclose(fid);
im = (reshape(fix(im/12),params.Main.Pixels_per_line,params.Main.Lines_per_frame)');

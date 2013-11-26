function [outstim] = loadstim(ws)

ws = unloadstim(ws);
WSp = getparameters(ws);

if exist(WSp.filename),
	[Y,FS] = wavread(WSp.filename);
else,
	error(['Cannot open wav file ' WSp.filename '.']);
end;

displayType = 'Sound'; 
displayProc = 'standard';
dS = {'displayType',displayType,'displayProc',displayProc,...
	'offscreen',0,'frames',0,'depth',8,...
	'clut_usage',ones(1,256),'clut',{},...
	'clut_bg',repmat(WSp.background,256,1),'userfield',struct('sound',Y','rate',FS)};
outstim = ws;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);

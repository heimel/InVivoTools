function [outstim] = loadstim(qts)

StimWindowGlobals;

qts = unloadstim(qts);
QTSp = getparameters(qts);

if exist(QTSp.filename,'file')
    [movie,props,props1,props2,props3] = Screen('OpenMovie',StimWindow,QTSp.filename,0);
    qts.movieparams.duration = props; 
    qts.movieparams.fps = props1;
    qts.movieparams.width = props2;
    qts.movieparams.height = props3;    
    WaitSecs(1);
else
	error(['Cannot open quicktime movie file ' QTSp.filename '.']);
end;

displayType = 'QUICKTIME'; 
displayProc = 'standard';

dS = {'displayType',displayType,'displayProc',displayProc,...
	'offscreen',0,'frames',0,'depth',8,...
	'clut_usage',ones(1,256),'clut',{},...
	'clut_bg',repmat(QTSp.background,256,1),'userfield',struct('movie',[movie],'movieparams',qts.movieparams)};

if (QTSp.rect(3)-QTSp.rect(1))*(QTSp.rect(4)-QTSp.rect(2))>=4,
    % nothing needs to be done
    rect = QTSp.rect;
else,
    ctr = [ mean(QTSp.rect([3 1])) mean(QTSp.rect([2 4])) mean(QTSp.rect([3 1])) mean(QTSp.rect([4 2]))];
    rect = [1 1 qts.movieparams.width qts.movieparams.height] + [ctr];
end;

dps = struct(getdisplayprefs(qts));
newdp = {'rect', rect,QTSp.dispprefs{:}};

outstim = setdisplayprefs(qts,displayprefs(newdp));

outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);

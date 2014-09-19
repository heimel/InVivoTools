function P = getparameters(S)

 % for docs, see help getparameters

P = struct('BG',S.BG,'value',S.value,'random',S.random,'repeat',S.repeat,...
		'bgpause',S.bgpause,'fps',S.fps,'rect',S.rect,'pixSize',...
		S.pixSize,'randState',S.randState);
P.dispprefs = S.dispprefs;

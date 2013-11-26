function [newcell,outstr,assoc,ra_rf]=lgncentsizeanalysis(cksds,cell,...
		cellname,display,rf)

%  MLMOTIONANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,TC]=MLMOTIONANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY,RF)
%
%  DISPLAY is 0/1 depending upon whether or not output should be displayed
%  graphically.
%
%  Analyzing this test does not depend on any other tests.
%  

newcell = cell;

motiontestcurve = [];

 % first, disassociate any 'Motion test' measures associated with this cell
assoclist = mlassociatelist('Motion test');

 % remove all existing associates in assoclist to replace with recomputed vals
for I=1:length(assoclist),
  [as,i] = findassociate(newcell,assoclist{I},'protocol_ML',[]);
  if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

motiontest = findassociate(newcell,'Motion test','protocol_ML',[]);

if isempty(motiontest),
	disp(['mlmotiontestanalysis: No test data']);
	% we're done, nothing to do
	return;
end;
s = getstimscripttimestruct(cksds,motiontest.data);

numpos =0;
% we used isi as a dummy indexing variable since isi is effectively zero
% isi = loc number / 1000
for i=1:numStims(s.stimscript),
	p = getparameters(get(s.stimscript,i));
	if p.isi*1000>numpos, numpos = p.isi*1000; end;
end;

trigs = {}; condnames = {}; df = []; begstims = zeros(1,numpos);
do = getDisplayOrder(s.stimscript);
for i=1:numpos, % not very efficient but I feel lazy
	for j=1:numStims(s.stimscript),
		p=getparameters(get(s.stimscript,j));
		if p.isi*1000==i,
			if begstims(i)==0, begstims(i) = j; end;
			si = find(do==j);
			for k=1:length(si),
				trigs{i}(k)=s.mti{si(k)}.frameTimes(1);
				df(end+1) = s.mti{si(k)}.frameTimes(end)-trigs{i}(k);
			end;
		end;
	end;
	condnames{i} = ['Position ' int2str(i)];
end;

inp.spikes = newcell; inp.triggers = trigs; inp.condnames = condnames;
RAparams.res = 0.010; RAparams.interval=[-0.2 mean(df)];
RAparams.cinterval=[0 mean(df)];
RAparams.axessameheight = 1;
RAparams.showcbars=1; RAparams.fracpsth=0.5;RAparams.normpsth=1;
RAparams.showvar=0;RAparams.psthmode=0;RAparams.showfrac=1;

if display,
	where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
    orient(where.figure,'landscape');
else, where = []; end;

ra_rf = raster(inp,'default',where);

locs = 1:numpos;

cr = getoutput(ra_rf);
for I=1:length(cr.bins),
	activ(I) = sum(cr.counts{I}(1:end))*diff(cr.bins{I}(1:2));
end;
[m,i] = max(activ);
maxloc = locs(i);
motiontestcurve= [locs; activ];
% now we have best RF loc

% begin motion analysis

if nargin<5|isempty(rf),rf=maxloc;
else, rf = str2num(rf); end; % analyze best location if none specified

trigs_dir = {}; condnames = {};
numdirs = numStims(s.stimscript)/numpos;
thedirs = 0:360/numdirs:(360-360/numdirs);
for i=1:numdirs, 
	j=begstims(rf)+i-1;
	si = find(do==j);
	for k=1:length(si),
		trigs_dir{i}(k)=s.mti{si(k)}.frameTimes(1);
	end;
	condnamesd{i} = ['Direction ' num2str(thedirs(i))];
end;

inpd.spikes = newcell; inpd.triggers = trigs_dir; inpd.condnames=condnamesd;
RAdparams.res = 0.010; RAdparams.interval=[-0.2 mean(df)];
RAdparams.cinterval=[0 mean(df)];
RAdparams.axessameheight = 1;
RAdparams.showcbars=1; RAdparams.fracpsth=0.5;RAdparams.normpsth=1;
RAdparams.showvar=0;RAdparams.psthmode=0;RAdparams.showfrac=1;

if display,
	where2.figure=figure;where2.rect=[0 0 1 1]; where2.units='normalized';
    orient(where2.figure,'landscape');
else, where2 = []; end;

ra_dir = raster(inpd,'default',where2);

crd = getoutput(ra_dir);
clear activ;
for I=1:length(crd.bins),
	activ(I) = sum(crd.counts{I}(1:end))*diff(crd.bins{I}(1:2));
end;
[m,i] = max(activ);
maxlocdir = thedirs(i);
motiondircurve= [thedirs; activ];

outstr.bestrf = maxloc; % best rf location
outstr.motiontestcurve = motiontestcurve;
outstr.motiondircurve = motiondircurve;

assoc= [];

assoc=struct('type','Max RF','owner','protocol_ML','data',...
	outstr.bestrf,'desc','Center size');

assoc(end+1)=struct('type','Motion RF Response Curve','owner','protocol_ML',...
	'data',outstr.motiontestcurve,'desc','Motion stimulus RF curve');

assoc(end+1)=struct('type','Motion Dir Response Curve','owner','protocol_ML',...
	'data',outstr.motiondircurve,'desc','Motion stimulus direction curve');

for i=1:length(assoc),newcell=associate(newcell,assoc(i)); end;

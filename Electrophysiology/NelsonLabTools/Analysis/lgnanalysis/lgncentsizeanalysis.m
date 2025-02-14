function [newcell,outstr,assoc,tc]=lgncentsizeanalysis(cksds,cell,...
		cellname,display)

%  LGNCENTSIZEANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,TC]=LGNCENTERSIZEANAL(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  DISPLAY is 0/1 depending upon whether or not output should be displayed
%  graphically.
%
%  Analyzing this test does not depend on any other tests.
%  
%  Measures gathered from the Cent Size test (associate name in quotes):
%  'Center Size'            |   The center size in degrees
%  'Has surround'           |   Whether or not cell is center surround - by user
%  'Center latency test'    |   Center size latency measure
%  'Center transience test' |   Center size transience measure
%  'Sustained/Transient response' | Whether cell is sustained or transient
%  'Center Initial Response' | Initial response to center stimulus (50ms)
%  'Center Maintained Response' | Response 300-350 ms later

newcell = cell;

ONOFF = [];
centsizecurve = [];

% adding measures: PTIle, PTIme, PTIlm, l=late, m=middle, e=early
eb = 0.010; ee = 0.110;
mb = 0.200; me = 0.300;
lb = 0.400; le = 0.500;

 % first, disassociate any 'cent size' measures associated with this cell
assoclist = setxor(lgnassociatelist('CentSize'),...
	{'Has surround' 'Cent Size Params'});


% 'Has surround' => chosen by user
% 'Cent Size Params' => specified by user, may be adjusted by analysis

for I=1:length(assoclist),
  [as,i] = findassociate(newcell,assoclist{I},'protocol_LGN',[]);
  if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

 % pull any user specified parameters, defaulting if they don't make sense

csparams = findassociate(newcell,'Cent Size Params','protocol_LGN',[]);
try,centsizewindow=eval(csparams.data.evalint);catch,centsizewindow=[0 0.1];end;
try, earlywind = eval(csparams.data.evalint); catch, earlywind = []; end;
try, latewind=eval(csparams.data.lateint);catch,latewind=[]; end;

cstest = findassociate(newcell,'Cent Size test','protocol_LGN',[]);

if isempty(cstest),
	disp(['lgncentsizeanalysis: No test data']);
	% we're done, nothing to do
	return;
end;

s = getstimscripttimestruct(cksds,cstest.data);

inp.st = s; inp.spikes = newcell; inp.paramname = 'radius';

astimparam = getparameters(get(inp.st.stimscript,1));
yloc = astimparam.center(2);
if eqlen(astimparam.FGc,[0 0 0]), ONOFF = 0; else, ONOFF = 1; end;

inp.title=cellname;
if display,
	where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
    orient(where.figure,'landscape');
else, where = []; end;

tc = tuning_curve(inp,'default',where);

c = getoutput(tc);
[m,i] = max(c.curve(1,:));
cr = getoutput(c.rast);
if ~isempty(centsizewindow),  % if not empty, use this window
   for I=1:length(cr.bins),
      i1 = findclosest(cr.bins{I},centsizewindow(1));
      i2 = findclosest(cr.bins{I},centsizewindow(2));
      activ(I) = sum(cr.counts{I}(i1:i2))*diff(cr.bins{I}(1:2));
   end;
   [m,i] = max(activ);
   maxloc = c.curve(1,i);
   centsizecurve = [c.curve(1,:); activ];
   xi=c.curve(1,1):1:c.curve(1,end);yi=interp1(c.curve(1,:),activ,xi,'spline');
   [m2,i2]=max(yi); maxloc_cont = xi(i2);
   %figure(2); plot(xi,yi); hold on; plot(xi(i2),yi(i2),'rx');
end;  % now we have best center size

bt = diff(cr.bins{i}(1:2)); % time of 1 bin
l = size(cr.values{1},2);  % number of trials

int1 = [0 0.1]; int2 = [0 0.5];
for I=1:length(cr.bins),
	iii1 = findclosest(cr.bins{I},int1(1));
	iii2 = findclosest(cr.bins{I},int1(2));
	iii3 = findclosest(cr.bins{I},int2(1));
	iii4 = findclosest(cr.bins{I},int2(2));
	act1(I) = sum(cr.counts{I}(iii1:iii2))/(bt*l*(iii2-iii1+1));
	act2(I) = sum(cr.counts{I}(iii3:iii4))/(bt*l*(iii4-iii3+1));
end;

centsizecurve1 = [c.curve(1,:); act1];
centsizecurve2 = [c.curve(1,:); act2];

centsizecurve1_a = c.curve;

[mm,ii] = max(cr.counts{i});
tlat = cr.bins{i}(ii);  % now we have latency

if isempty(earlywind)|isempty(latewind),
   ear = tlat + [0 0.050]; lat = tlat + 0.3 + [0 0.050];
else, ear = earlywind; lat = latewind;
end;

if max(lat)>0.5, lat = 0.45+[0 0.050]; latewind = lat; end;

e1 = findclosest(cr.bins{i},ear(1));
e2 = findclosest(cr.bins{i},ear(2));
l1 = findclosest(cr.bins{i},lat(1));
l2 = findclosest(cr.bins{i},lat(2));
v = find(c.curve(1,:)==0);
if isempty(v),
   spont = c.spont(1)*bt;
else,
   spont = cr.ncounts(v);
end;
x=sum(cr.counts{i}(e1:e2))/(bt*l*(e2-e1+1))-spont;
y=sum(cr.counts{i}(l1:l2))/(bt*l*(e2-e1+1))-spont;
trans = (x-y)/x;

replyear = []; replylat = [];
for I=1:l,
	replyear(end+1) = sum(cr.values{i}(e1:e2,I))/(bt*(e2-e1+1));
	replylat(end+1) = sum(cr.values{i}(l1:l2,I))/(bt*(l2-l1+1));
end;

if ~isempty(v),  % can do sig tests
	replyspont = [];
	for I=1:l,
		replyspont(end+1) = sum(cr.values{v}(e1:e2,I))/(bt*(e2-e1+1));
		replyspont(end+1) = sum(cr.values{v}(l1:l2,I))/(bt*(l2-l1+1));
	end;
    [hsustained,sigsustained]=ttest2(replylat,replyspont,0.05,1);
end;

RFlocadj = [];
%gg=findassociate(cell,'RF location','protocol_LGN',[]);
%if ~isempty(gg),
%	odlasc=findassociate(cell,'optic disk location','protocol_LGN',[]);
%	domeye=findassociate(cell,'Dominant eye','protocol_LGN',[]);
%	lgnlay=findassociate(cell,'LGN Layer','protocol_LGN',[]);
%	if ~isempty(odlasc)&~isempty(domeye)&~isempty(lgnlay),
%		switch lgnlay,
%		case '2','3b', % use right eye for both arbitrarily
%			switch domeye,
%			case 'contra',
%			RFlocadj=gg.data-...
%				[odlasc.data.RightHort-69.672 odlasc.data.RightVert+18.068];
%		case '1','3a/3c','3a','3c',
%			RFlocadj=gg.data-...
%				[odlasc.data.LeftHort+69.6907 odlasc.data.LeftVert+19.186];
%		end;
%	end;
%end;

NewStimGlobals;  % for NewStimPixelsPerCm
warning('LGNCENTSIZEANALYSIS: uses NewStimPixelsPerCm. maybe incorrect.');

outstr.trans = trans;   % transience measure
outstr.tlat = tlat + (0.2e-3)+(6.79e-3)*yloc/480;     % latency
outstr.maxloc = maxloc; % best center size
outstr.centsize = 2*maxloc/NewStimPixelsPerCm;
outstr.centsize_cont = 2*maxloc_cont/NewStimPixelsPerCm;
outstr.initresp = [mean(replyear) std(replyear) std(replyear)/sqrt(l)];
outstr.maintresp= [mean(replylat) std(replylat) std(replylat)/sqrt(l)];
outstr.spontresp= [mean(replyspont) std(replyspont) std(replyspont)/sqrt(l)];
outstr.sustained = hsustained; % whether response is significant in 2nd window
outstr.earlyint = ear;
outstr.lateint  = lat;
outstr.evalint = centsizewindow;
outstr.RFlocadj = RFlocadj;

assoc= [];

assoc=struct('type','Center size','owner','protocol_LGN','data',...
	outstr.centsize,'desc','Center size');

assoc(end+1)=struct('type','Center size cont','owner','protocol_LGN',...
	'data',outstr.centsize_cont,'desc','Center size, continuous measurement');

% hassurround not adjusted

assoc(end+1)=struct('type','Center latency test','owner','protocol_LGN',...
	'data',tlat, ...
	'desc','Latency as determined by response to centersurround stim');

assoc(end+1)= struct('type',...
	'Sustained/Transient response',...
	'owner','protocol_LGN','data',outstr.sustained,'desc',...
	'Does cell respond in a sustained or transient way?');

assoc(end+1)= struct('type','Center transience test','owner','protocol_LGN',...
	'data',trans, 'desc',...
	'Transcience as determined by response to centersurround stim');

assoc(end+1)=struct('type',...
	'Center Initial Response','owner','protocol_LGN',...
	'data',outstr.initresp,'desc',...
	'Initial response to center stimulus.');

assoc(end+1)=struct('type',...
	'Center Maintained Response','owner','protocol_LGN',...
	'data',outstr.maintresp,'desc',...
	'Maintained response to center stimulus');

assoc(end+1)=struct('type','Cent Size spontaneous','owner','protocol_LGN',...
	'data',outstr.spontresp,'desc','Spontaneous response during cent size');

assoc(end+1)=struct('type','Cent Size Params',...
	'owner','protocol_LGN','data',struct('evalint',mat2str(centsizewindow),...
	'earlyint',mat2str(outstr.earlyint),'lateint',mat2str(outstr.lateint)),...
	'desc','Parameters specifying center size test analysis');

assoc(end+1)=struct('type','Center Size Curve','owner','protocol_LGN',...
	'data',centsizecurve,'desc','Activity curve, center-surround');
assoc(end+1)=struct('type','Center Size Curve 1','owner','protocol_LGN',...
	'data',centsizecurve1,'desc','Activity curve, center-surround [0 0.1]');
assoc(end+1)=struct('type','Center Size Curve 2','owner','protocol_LGN',...
	'data',centsizecurve2,'desc','Activity curve, center-surround [0 0.5]');
assoc(end+1)=struct('type','Center Size Curve All','owner','protocol_LGN',...
	'data',centsizecurve1_a,'desc','Activity curve all');

if ~isempty(ONOFF),
	assoc(end+1)=struct('type','LGN ON or OFF','owner','protocol_LGN',...
	'data',ONOFF,'desc','0/1 if cell is OFF-center or ON-center');
end;

if ~isempty(RFlocadj),
	assoc(end+1)=struct('type','RF location adj','owner','protocol_LGN',...
		'data',RFlocadj,'desc','RF location (adjusted for optic disks)');
end;

for i=1:length(assoc),newcell=associate(newcell,assoc(i)); end;

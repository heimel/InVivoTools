function [newcell,outstr,assoc,tc]=ctxcentsizeanalysis(cksds,cell,...
		cellname,display)

%  CTXCENTSIZEANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,TC]=CTXCENTERSIZEANAL(CKSDS,CELL,CELLNAME,DISPLAY)
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

 % first, disassociate any 'cent size' measures associated with this cell
assoclist = setxor(ctxassociatelist('CentSize'),...
	{'Has surround' 'Cent Size Params'});


% 'Has surround' => chosen by user
% 'Cent Size Params' => specified by user, may be adjusted by analysis

for I=1:length(assoclist),
  [as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
  if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

 % pull any user specified parameters, defaulting if they don't make sense

csparams = findassociate(newcell,'Cent Size Params','protocol_CTX',[]);
try,centsizewindow=eval(csparams.data.evalint);catch,centsizewindow=[0 0.1];end;
try, earlywind = eval(csparams.data.evalint); catch, earlywind = []; end;
try, latewind=eval(csparams.data.lateint);catch,latewind=[]; end;

cstest = findassociate(newcell,'Cent Size test','protocol_CTX',[]);

if isempty(cstest),
	disp(['No test data']);
	% we're done, nothing to do
	return;
end;

s = getstimscripttimestruct(cksds,cstest.data);

inp.st = s; inp.spikes = newcell; inp.paramname = 'radius';

astimparam = getparameters(get(inp.st.stimscript,1));
yloc = astimparam.center(2);

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
end;  % now we have best center size

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
bt = diff(cr.bins{i}(1:2)); % time of 1 bin
v = find(c.curve(1,:)==0);
if isempty(v),
   spont = c.spont(1)*bt;
else,
   spont = cr.ncounts(v);
end;
l = size(cr.values{1},2);  % number of trials
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

NewStimGlobals;  % for NewStimPixelsPerCm
warning('CTXCENTSIZEANALYSIS: uses NewStimPixelsPerCm. maybe incorrect.');

outstr.trans = trans;   % transience measure
outstr.tlat = tlat + (0.2e-3)+(6.79e-3)*yloc/480;     % latency
outstr.maxloc = maxloc; % best center size
outstr.centsize = 2*maxloc/NewStimPixelsPerCm;
outstr.initresp = [mean(replyear) std(replyear) std(replyear)/sqrt(l)];
outstr.maintresp= [mean(replylat) std(replylat) std(replylat)/sqrt(l)];
outstr.spontresp= [mean(replyspont) std(replyspont) std(replyspont)/sqrt(l)];
outstr.sustained = hsustained; % whether response is significant in 2nd window
outstr.earlyint = ear;
outstr.lateint  = lat;
outstr.evalint = centsizewindow;

assoc= [];

assoc=struct('type','Center size','owner','protocol_CTX','data',...
	outstr.centsize,'desc','Center size');

% hassurround not adjusted

assoc(end+1)=ctxnewassociate('Cent Size test',...
			     cstest(end).data,...
			     'Cent Size test');


assoc(end+1)=struct('type','Center latency test','owner','protocol_CTX',...
	'data',tlat, ...
	'desc','Latency as determined by response to centersurround stim');

assoc(end+1)= struct('type',...
	'Sustained/Transient response',...
	'owner','protocol_CTX','data',outstr.sustained,'desc',...
	'Does cell respond in a sustained or transient way?');

assoc(end+1)= struct('type','Center transience test','owner','protocol_CTX',...
	'data',trans, 'desc',...
	'Transcience as determined by response to centersurround stim');

assoc(end+1)=struct('type',...
	'Center Initial Response','owner','protocol_CTX',...
	'data',outstr.initresp,'desc',...
	'Initial response to center stimulus.');

assoc(end+1)=struct('type',...
	'Center Maintained Response','owner','protocol_CTX',...
	'data',outstr.maintresp,'desc',...
	'Maintained response to center stimulus');

assoc(end+1)=struct('type','Cent Size spontaneous','owner','protocol_CTX',...
	'data',outstr.spontresp,'desc','Spontaneous response during cent size');

assoc(end+1)=struct('type','Cent Size Params',...
	'owner','protocol_CTX','data',struct('evalint',mat2str(centsizewindow),...
	'earlyint',mat2str(outstr.earlyint),'lateint',mat2str(outstr.lateint)),...
	'desc','Parameters specifying center size test analysis');

for i=1:length(assoc),newcell=associate(newcell,assoc(i)); end;

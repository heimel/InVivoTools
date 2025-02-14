function outstr = lgncentsizeanal(tc,centsizewindow,earlywind,latewind)

%  LGNCENTSIZEANAL
%
%  ANALINFO = LGNCENTSIZEANAL(TUNING_CURVE, CENTSIZEWINDOW, EARLYWIND, LATEWIND)
%
%  Finds the center size giving a tuning curve object TUNING_CURVE.  CENTERSIZE
%  is the time interval over which to perform analysis (e.g., [0 0.100] is 
%  0 to 100 milliseconds), or can be empty ([]) to use the whole response.
%  EARLYWIND and LATEWIND describe time intervals over which to analyze the
%  early and late response, or can be blank for the interval 50ms after the
%  maximum response and a 50 ms interval starting 300ms after the maximum
%  response.
%
%  Analyzes the results of presenting centersurround stimuli to an LGN cell.
%
%  Returns the following:
%    best center size *
%    the latency of the response  *
%    an index of transience  *
%    the initial, maintained, and spontaneous responses, with error  *
%    whether the maintained response is significant (sustained) *
%    the early and late windows used *

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
tlat = cr.bins{i}(ii),  % now we have latency

if isempty(earlywind)|isempty(latewind),
   ear = tlat + [0 0.050]; lat = tlat + 0.3 + [0 0.050];
else, ear = earlywind; lat = latewind;
end;

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
	replyear(end+1) = sum(cr.values{i}(e1:e2,I))/(bt*l*(e2-e1+1));
	replylat(end+1) = sum(cr.values{i}(l1:l2,I))/(bt*l*(l2-l1+1));
end;

if ~isempty(v),  % can do sig tests
	replyspont = [];
	for I=1:l,
		replyspont(end+1) = sum(cr.values{v}(e1:e2,I))/(bt*l*(e2-e1+1));
		replyspont(end+1) = sum(cr.values{v}(l1:l2,I))/(bt*l*(l2-l1+1));
	end;
    [hsustained,sigsustained]=ttest2(replylat,replyspont,0.05,1);
end;


outstr.trans = trans;   % transience measure
outstr.tlat = tlat;     % latency
outstr.maxloc = maxloc; % best center size
outstr.initresp = [mean(replyear) std(replyear) std(replyear)/sqrt(l)];
outstr.maintresp= [mean(replylat) std(replylat) std(replylat)/sqrt(l)];
outstr.spontresp= [mean(replyspont) std(replyspont) std(replyspont)/sqrt(l)];
outstr.sustained = hsustained; % whether response is significant in 2nd window
outstr.earlyint = ear;
outstr.lateint  = lat;

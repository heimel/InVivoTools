function [newcell,outstr,assoc]=ctxvepanalysis(cksds,cell,cellname,display,nameref)

%  CTXVEPANALYSIS shell around CTXLFPANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC]=CTXVEOANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the VEP tests for latency. CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the VEP Test (associate name in quotes):
%  'VEP Latency'                  | latency of response



newcell = cell;

assoclist = ctxassociatelist('VEP Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);


veptest = findassociate(newcell,'VEP Test','protocol_CTX',[]);
if ~isempty(veptest),
  s=getstimscripttimestruct(cksds,veptest(end).data);

  latency=ctxlfpanalysis(cksds,veptest(end).data,nameref.name,...
			 nameref.ref,1);
   
  assoc(end+1)=ctxnewassociate('VEP Test',...
			       veptest(end).data,...
			       'VEP Test');
  assoc(end+1)=ctxnewassociate('VEP Latency',...
			       latency,'VEP Latency');
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.latency = latency; % no longer used

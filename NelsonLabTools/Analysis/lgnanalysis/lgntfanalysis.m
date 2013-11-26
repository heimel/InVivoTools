function [newcell,outstr,assoc,pc]=lgntfanalysis(cksds,cell,cellname,display)

%  LGNTFANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=LGNTFANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the temporal frequency test.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the TF test (associate name in quotes):
%  'TF Response Curve F1'         |   F1 response
%  'TF Pref'                      |   TF w/ max firing
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF, angle)

newcell = cell;

assoclist = lgnassociatelist('TF Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_LGN',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

if display,
	where.figure=figure;
	where.rect=[0 0 1 1];
	where.units='normalized';
	orient(where.figure,'landscape');
else, where = []; end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f1curve = []; maxgrating = []; tfpref = []; pc = [];

tftest = findassociate(newcell,'TF test','protocol_LGN',[]);
if ~isempty(tftest),
	s=getstimscripttimestruct(cksds,tftest(end).data);
	if ~isempty(s),
			inp.paramnames = {'tFrequency'};
			inp.title=['Temporal frequency ' cellname];
			inp.spikes = newcell;
			inp.st = s;
			pc = periodic_curve(inp,'default',where);
			p = getparameters(pc);
			p.graphParams(4).whattoplot = 6;
			pc = setparameters(pc,p);
			co = getoutput(pc);
			[m,i]=max(co.f1curve{1}(2,:)); tfpref = co.f1curve{1}(1,i);
			f1curve = co.f1curve{1}(1:2,:);
			maxgrating = m;
			sig = [];
			gg = abs(co.f1vals{1});
			for jj=1:length(co.f1curve{1}(1,:)),
				sig(jj) = ttest(gg(:,jj),co.spont(1),0.02,1);
			end;
			assoc(end+1)=struct('type','TF Response Curve F1',...
				'owner','protocol_LGN','data',f1curve,'desc',...
				'TF Response Curve (F1)');
			assoc(end+1)=struct('type','TF Phase','owner','protocol_LGN',...
				'data',angle(mean(co.f1vals{1})),'desc','TF Phase');
			assoc(end+1)=struct('type','Max drifting grating firing',...
				'owner','protocol_LGN','data',maxgrating,'desc',...
				'Max firing to a drifting grating');
			assoc(end+1)=struct('type','TF Pref',...
				'owner','protocol_LGN','data',tfpref,'desc',...
				'Temporal frequency preference');
			assoc(end+1)=struct('type','TF significant firing',...
				'owner','protocol_LGN','data',sig,...
				'desc','TF significant firing');
	end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.f1curve = f1curve;
outstr.maxgrating = maxgrating;
outstr.tfpref = tfpref;

function [newcell,outstr,assoc]=lgnctxdomuir(cksds,intnameref,extcellname,testlist,draw)

% DO_MUIR Do multi-unit extracellular/intracellular analysis
%
% [NEWINTCELL,OUTSTR,ASSOC]=DO_MUIR(CKSDS,INTNAMEREF,EXTCELL,TESTLIST,[DRAW])
%
%  Analyzes correlations among an extracellularly recorded spike data object stored
%  in the experiment file with name EXTCELL and an intracellularly recorded cell
%  INTNAMEREF, a name/reference pair in the CKSDIRSTRUCT object CKSDS, during tests
%  in TESTLIST (a cell list of strings).  If DRAW is 1, the result is drawn in a
%  new figure.
%
%  See also:  SPIKEDATA, CKSDIRSTRUCT, GETEXPERIMENTFILE

 % constants
A.t0 = 0.001; A.t1 = 0.007; % spike removal parameters
T0 = -0.010; T1 = 0.100; % time interval to examine
intcellname = getcells(cksds,intnameref); intcellname = intcellname{1};
sdint=getfield(load(getexperimentfile(cksds),intcellname,'-mat'),intcellname);
A.spiketimes=get_data(sdint,[0 Inf],2);
cksfd=cksfiltereddata(getpathname(cksds),intnameref.name,intnameref.ref,...
	3,A,'','');

cell= load(getexperimentfile(cksds),extcellname,'-mat');
extcell= getfield(cell,extcellname);


trigs = [];
the_ints = get_intervals(cksfd);
for i=1:length(testlist),
	stimtime=getstimscripttimestruct(cksds,testlist{i});
	for b=1:size(the_ints,1),
	   if (stimtime.mti{1}.startStopTimes(1)>=the_ints(b,1))...
		   	&stimtime.mti{1}.startStopTimes(1)<=the_ints(b,2),
		    break;
	   end;
    end;
	trigs = cat(2,trigs,get_data(extcell,[the_ints(b,1)-T0 the_ints(b,2)-T1-0.3]));
	   % the 0.3 above is so we don't just run over the edge
end;

% now we have the triggers

[indwaves,avg,stddev,sampletimes]=raster_continuous(cksfd,trigs,T0,T1,1e-4);
stderr = stddev/sqrt(length(trigs));
if draw,
	h = figure;
	hold off;
	plot(sampletimes,avg,'b');
	hold on;
	plot(sampletimes,avg+stderr,'r'); plot(sampletimes,avg-stderr,'r');
	title(['Correlation: ' extcellname ' x ' intcellname ],'interpreter','none');
	ylabel(['Membrane potential (V)']);
	xlabel(['Time (s)']);
end;

newcell=sdint;
assoc = [];
outstr.avg = avg;
outstr.stddev = stddev;
outstr.stderr = stderr;
outstr.sampletimes = sampletimes;

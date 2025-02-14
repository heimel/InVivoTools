function str = igorcurrentsteps(currsteps,disporder,stimdur,datapath,scriptName,saving,remPath)

if ~saving, error('Cannot use if not saving results.'); end;

%str = {[sprintf('disp([''testing %d %s'']);',myarg,scriptName)]};

str = {'applescript(''igorcurrentsteps.applescript'');'};

numsteps = length(currsteps);

currStepCmds = zeros(length(disporder),4);

 % each row  [ currstep current_duration delay total_stim_duration ]

stimlist = unique(disporder);
numstims = length(stimlist);
numrepeats = round(length(disporder)/numstims); % assume even number
numcurrrepeats = numrepeats / numsteps;

if mod(numrepeats,numsteps)~=0,
  error('# of stimulus repeats must be divisible by # of current injections.');
end;

for i=1:length(stimlist)
	inds = find(disporder==stimlist(i));
	d0 = randperm(numsteps);
	if numsteps>1,p = [0:1/(numsteps-1):1]; else, p = []; end;
	for j=2:numcurrrepeats,
		if numsteps==1, d0=[d0 1];
		else,
			r = rand(1,1);
			f=find(p(1:end-1)<r&p(2:end)>=r);
			n=[1:d0(end)-1 d0(end)+1:numsteps];
			n=n(f);
			d=[1:n-1 n+1:numsteps];
			di = randperm(numsteps-1);
			d0 = [d0 n d(di)];
		end;
	end;
	currStepCmds(inds,1)=currsteps(d0)';
end;

currStepCmds(:,2) = stimdur; 
currStepCmds(:,3) = 0.1;
currStepCmds(:,4) = 0.1+stimdur+0.1;

currdir = pwd;
cd(datapath);
save currStepCmds currStepCmds -ascii
cd(pwd);

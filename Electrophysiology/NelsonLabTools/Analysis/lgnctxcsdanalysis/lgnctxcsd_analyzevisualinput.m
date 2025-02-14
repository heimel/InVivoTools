function [csdind_,samps,poss,fieldsind_]=lgnctxcsd_analyzevisinput(cksds,ref,testlist,gridloc,pos,plot);

numtrigs = [];
for i=1:length(testlist),
	sts = getstimscripttimestruct(cksds,testlist{i});
	blinkstim = get(sts.stimscript,1);
	blinkList = getgridorder(blinkstim);
	trigs = sts.mti{1}.frameTimes(find(blinkList==gridloc(i)));
	numtrigs(end+1) = length(trigs),
	[csdind{i},samptimes{i},fieldsind{i}]=lgnctxcsd_computecsdumich16(cksds,ref(i),trigs,...
		0,0.150,1e-4);
end;

poss = [];
for i=1:length(testlist), poss=[poss pos(i)-(1525:-100:25)]; end;

poss = unique(poss),

samps = 0:1e-4:0.150;

%csdind_ = csdind{1};
%fieldsind_ = fieldsind;
csdind_ = single(zeros(length(samps),length(poss)));
fieldsind_ = single(zeros(length(samps),length(poss)));
for i=1:length(poss),
	poss(i),
	csdnorm = 0; fieldnorm = 0;
	for j=1:length(testlist),
		chan = find( (pos(j)-(1525:-100:25))==poss(i)),
		if ~isempty(chan),
			if chan>1&chan<16, % csd only defined for some channels
				csdind_(:,i)=csdind_(:,i)+...
						mean(csdind{j}(:,chan,:),3)*numtrigs(j);
				csdnorm = csdnorm + numtrigs(j);
			end;
			fieldsind_(:,i)=fieldsind_(:,i)+...
				mean(fieldsind{j}(:,chan,:),3)*numtrigs(j);
			fieldnorm = fieldnorm + numtrigs(j);
		end;
	end;
	fieldsind_(:,i) = fieldsind_(:,i)/fieldnorm;
	if csdnorm~=0, csdind_(:,i)=csdind_(:,i)/csdnorm; end;
end;

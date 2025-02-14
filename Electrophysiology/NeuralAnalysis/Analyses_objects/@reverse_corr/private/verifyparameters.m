function [good,errormsg] = verifyparameters(p,inputs)
  % guarenteed inputs will be good
proceed = 1;
errormsg = ''; good = 1;
return;
if proceed,
   % check that all arguments are present and appropriately sized
   fieldNames = {'interval','timeres','feature','showrast','show1drev','normalize',...
		'chanview','colorbar','clickbehav','pseudoscreen',...
		'datatoview','showdata','show1drevprs','bgcolor','gain',...
                'immean','feamean','crcpixel','crctimeres','crcproj',...
                 'crctimeint'};
   fieldSizes={[1 2],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 4],...
              [1 3],[1 1],[1 5],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[2 3],...
                 [1 2]};
   [proceed,errormsg] = hasAllFields(p, fieldNames, fieldSizes);
end;

if proceed,
	if (p.interval(1)>=p.interval(2)),
		proceed=0;errormsg='interval(1) must be < interval(2).'; end;
        if p.timeres<0|(p.timeres>diff(p.interval)),
                proceed=0;errormsg='timeres must be >0 & < diff(interval).'; end;
        if (~isint(p.feature))|(p.feature<=0|p.feature>6),
                proceed=0;errormsg='feature must be >=0 & <= 6'; end;
        fieldNames = {'showrast','colorbar','show1drev','showdata',...
                   'show1drevprs(1)','show1drevprs(5)'};
	for i=1:length(fieldNames),
		eval(['if ~isboolean(p.' fieldNames{i} '),proceed=0;' ...
		   'errormsg=''' fieldNames{i} ' must be 0 or 1.''; end;']);
	end;
	if (p.clickbehav~=0)&(p.clickbehav~=1)&(p.clickbehav~=2),
		proceed=0;errormsg='clickbehav must be 0,1, or 2.';
	end;
	if (p.chanview~=0)&(p.chanview~=1)&(p.chanview~=2)&(p.chanview~=3),
			proceed=0;errormsg='chanview must be 0,1,2, or 3.';
	end;
        if p.datatoview(1)<=0|p.datatoview(1)>length(inputs.spikes),proceed=0;
	   errormsg='datatoview(1) must be in 1..length(input.spikes).'; end;
        offsets = p.interval(1):p.timeres:p.interval(2);
        if length(offsets)==1, offsets = [p.interval(1) p.interval(2)]; end;
        if p.datatoview(2)<0|p.datatoview(2)>(length(offsets)-1),proceed=0;
	   errormsg='datatoview(2) must be in 1..num intervals.'; end;
        ps = getparameters(inputs.stimtime(1).stim);
        if isa(inputs.stimtime(1).stim,'stochasticgridstim'),
          if p.bgcolor<0|p.bgcolor>size(ps.values,1),
             proceed=0;errormsg='bgcolor must be 1..num of colors in stim.';
          end;
        elseif isa(inputs.stimtime(1).stim,'blinkingstim'),
          % doesn't matter, parameter bgcolor is irrelevant for blinkingstim
        else, proceed=0; errormsg='stims must be stochasticgridstim or blinkingstim.';
        end;
	if p.show1drevprs(2)<0,proceed=0;errormsg='show1drevprs(2) must be >0.';
        end;
        if p.show1drevprs(4)<p.show1drevprs(3),
          proceed=0;errormsg='show1drevprs(3) must be > show1drevprs(4).';
        end;
end;

good = proceed;

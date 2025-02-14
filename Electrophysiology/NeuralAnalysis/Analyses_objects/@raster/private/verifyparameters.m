function [good,errormsg] = verifyparameters(p,I)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'res','interval','fracpsth','normpsth',...
		'showvar','psthmode','showfrac','cinterval','showcbars',...
                'axessameheight'};
        fieldSizes = {[1 1],[-1 2],[1 1],[1 1],[1 1],[1 1],[1 1],[-1 2],...
                  [1 1],[-1 -1],[1 1]};
        [proceed,errormsg] = hasAllFields(p, fieldNames, fieldSizes);
end;

if proceed,
        if size(p.interval,1)~=length(I.triggers)&size(p.interval,1)~=1,
          proceed=0; errormsg='size(interval,1) must be length(triggers) or 1.'; end;
        if size(p.cinterval,1)~=length(I.triggers)&size(p.cinterval,1)~=1,
          proceed=0; errormsg='size(cinterval,1) must be length(triggers) or 1.'; end;
        for i=1:size(p.cinterval,1),
   	  cmi=min(p.cinterval(i,:));cmx=max(p.cinterval(i,:));
          if size(p.interval,1)~=1,
             mi = min(p.interval(i,:)); mx = max(p.interval(i,:));
          else, mi = min(p.interval(1,:)); mx = max(p.interval(1,:)); end;
	  if cmi<mi|cmx>mx,
		proceed=0;errormsg='all cintervals must be in interval.';
	  end;
        end;
	if p.res<=0,proceed=0;errormsg='res must be >0.'; end;
        fieldNames={'normpsth','showvar','psthmode','showcbars',...
                    'axessameheight'};
	for i=1:length(fieldNames),
		eval(['if ~isboolean(p.' fieldNames{i} '),proceed=0;' ...
		   'errormsg=''' fieldNames{i} ' must be 0 or 1.''; end;']);
	end;
	if p.fracpsth>1|p.fracpsth<0,proceed=0;errormsg='fracpsth not in 0..1.';
        end;
	if p.showfrac>1|p.showfrac<0,proceed=0;errormsg='showfrac not in 0..1.';
        end;
end;

good = proceed;

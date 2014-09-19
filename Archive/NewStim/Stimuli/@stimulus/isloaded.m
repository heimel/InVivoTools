function [loaded] = isloaded(stimulus)

% check to make sure dataStruct.offscreen points to something real

loaded = 0;

ds = getdisplaystruct(stimulus);

if ~isempty(ds)&stimulus.loaded,
	dss = struct(ds);
	if dss.offscreen(1)~=0,
		try,
			rect = Screen(dss.offscreen(1),'Rect');
		catch,
			rect = [];
		end;
		if ~isempty(rect),
			loaded = 1;
		else,
			loaded = 0;
		end;
	end;
end;

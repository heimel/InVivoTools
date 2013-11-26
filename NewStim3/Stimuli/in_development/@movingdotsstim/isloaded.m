function [loaded] = isloaded(stimulus);

% ISLOADED - Is stimulus loaded?

loaded = 0;

ds = getdisplaystruct(stimulus);

if ~isempty(ds),
	dss = struct(ds);
	if ~isempty(dss.userfield),
		loaded = 1;
	end;
end;

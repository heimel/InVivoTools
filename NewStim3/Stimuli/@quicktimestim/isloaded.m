function [loaded] = isloaded(qts);

% check to make sure dataStruct.offscreen points to something real

loaded = 0;

ds = getdisplaystruct(qts);

if ~isempty(ds),
	dss = struct(ds);
	if isfield(dss,'userfield'),
        if isfield(dss.userfield,'movie')
    		loaded = (dss.userfield.movie>=0);
        end;
	end;
end;

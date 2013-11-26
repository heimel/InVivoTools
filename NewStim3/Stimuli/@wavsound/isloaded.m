function [loaded] = isloaded(wv);

% check to make sure dataStruct.offscreen points to something real

loaded = 0;

ds = getdisplaystruct(wv);

if ~isempty(ds),
	dss = struct(ds);
	if strcmp(class(dss.userfield),'struct'),
		loaded = (length(dss.userfield.sound)>1);
	end;
end;

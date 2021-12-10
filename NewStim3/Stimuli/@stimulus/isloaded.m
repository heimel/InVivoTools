function [loaded] = isloaded(stimulus)

NewStimGlobals;

% check to make sure dataStruct.offscreen points to something real

loaded = 0;

ds = getdisplaystruct(stimulus);

if ~isempty(ds)&&stimulus.loaded,
    dss = struct(ds);
    if dss.offscreen(1)~=0 
        if NS_PTBv<3,
            try
                rect = Screen(dss.offscreen(1),'Rect');
            catch
                rect = [];
            end
        else
            if ~isnan(dss.offscreen(1))
                rect = Screen(dss.offscreen(1),'WindowKind');
            else % for customdraws without preloaded textures
                rect = [0 0 1 1];
            end
        end;
        if ~isempty(rect),
            loaded = 1;
        else
            loaded = 0;
        end
    end
end

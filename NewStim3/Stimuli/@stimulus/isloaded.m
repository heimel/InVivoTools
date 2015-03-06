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
            rect = Screen(dss.offscreen(1),'WindowKind');
        end;
        if ~isempty(rect),
            loaded = 1;
        else
            loaded = 0;
        end
    end
end

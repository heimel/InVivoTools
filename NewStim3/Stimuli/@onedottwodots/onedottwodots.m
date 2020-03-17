function st = onedottwodots( params, oldstim )
%One dot, 2 dots - stimulus to show bitmaps moving in real world

%Warning: This stimulus works best if you program it via the script editor
%instead of the stim editor! 
%
% 2020 Leonie Cazemier, Alexander Heimel

if nargin<2
    oldstim = [];
end

default.filename = 'large_circle.png';
default.appear = 1;
default.stay = 0;
default.stoppoint = Inf;
default.start_position = 'top';
default.velocity_degps = [0 60]; % vx,vy in deg/s, right and up and away are positive
default.duration = 3; % duration of movement in s
default.extent_deg = [6 6]; % extent in degrees
default.backdrop = [0.5 0.5 0.5];
%dot_distances: if Nnan - no extra dots
% if one or multiple inputs, will combine the dots but also show them separately
default.dot_distances = [15];
default.dispprefs = {'BGpretime',0};
if isempty(oldstim)
    oldstimpar = default;
else
    oldstimpar = getparameters(oldstim);
end

if nargin<1
    params = default;
elseif ischar(params)
    switch lower(params)
        case 'graphical'
            params = structgui( oldstimpar ,capitalize(mfilename));
        case 'default'
            params = default;
        otherwise
            errormsg(['Unknown argument ' params]);
            st = [];
            return
    end
end
if ischar(params.dispprefs) % str to cell
    params.dispprefs = eval(params.dispprefs);
end


NewStimListAdd(mfilename);
s = stimulus(5);
data = struct('params', params);
st = class(data,mfilename,s);
st.stimulus = setdisplayprefs(st.stimulus,displayprefs(params.dispprefs));



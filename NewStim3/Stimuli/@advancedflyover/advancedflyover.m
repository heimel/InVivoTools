function st = advancedflyover( params, oldstim )
%ADVANCED FLYOVER stimulus to show bitmaps moving in real world
%
% 2014, Azadeh Tafreshiha, Alexander Heimel

if nargin<2
    oldstim = [];
end

default.filename = 'large_circle.png';
default.appear = 1;
default.stay = 1;
default.stoppoint = 15;
default.start_position = 'left';
default.velocity_degps = [60 0]; % vx,vy in deg/s, right and up and away are positive
default.duration = 5; % duration of movement in s
default.extent_deg = [6 6]; % extent in degrees
default.backdrop = [0.5 0.5 0.5];
default.dispprefs = '{''BGpretime'',0}';
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



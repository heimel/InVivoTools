 function st = azadehloom( params, oldstim )
%AZADEHLOOM stimulus to show bitmaps moving in real world
%
% 2014, Azadeh Tafreshiha, Alexander Heimel

if nargin < 2
    oldstim = [];
end

default.filename = 'large_circle.png';
default.center_r2n_cm = [0 0 100]; % position of object center in cm relative to nose%
default.velocity_cmps = [0 0 -20]; % vx,vy,vz in cm/s, right and up and away are positive
default.duration = 5; % duration of movement in s
default.extent_cm = [10 10 0]; % extent in real world in cm
default.backdrop = [0.5 0.5 0.5];
default.dispprefs = '{''BGpretime'',3}';

if isempty(oldstim)
    oldstimpar = default;
else
    oldstimpar = getparameters(oldstim);
end

if nargin < 1
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



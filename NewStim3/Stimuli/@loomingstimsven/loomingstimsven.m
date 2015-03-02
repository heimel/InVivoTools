function st = loomingstimsven( params, oldstim )
%SVENSTIM stimulus to show bitmaps moving in real world
%
% 2014, Azadeh Tafreshiha, Alexander Heimel

if nargin<2
    oldstim = [];
end

default.filename = 'large_circle.png';
% default.center_r2n_cm = [0 0]; % position of object center in cm relative to nose%
default.velocity_cmps = [0 0 36]; % vx,vy,vz in cm/s, right and up and away are positive
default.expansiontime = 0.250;
default.statictime = 0.250;
default.extent_degree = [2 2 0]; % extent in real world in degree
default.n_repetitions = 15;
default.expanded_diameter = 20;
default.backdrop = [0.5 0.5 0.5];
default.dispprefs = '{''BGpretime'',3}';
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



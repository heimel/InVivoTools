function st = optostim(params,oldstim)
%OPTOSTIM to give a optogenetics stimulus
%
% 2016, Alexander Heimel


default.duration = 0.001; % pulse duration in s
default.waveform = 'triggerup';
default.waveamplitude = 1; 
default.backdrop = [0.5 0.5 0.5];
default.dispprefs = '{''BGpretime'',3}';

if nargin<2 || isempty(oldstim)
    oldstimpar = default;
else
    oldstimpar = getparameters(oldstim);
end

if nargin < 1 || isempty(params)
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

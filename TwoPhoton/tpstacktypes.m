function stacktypes = tpstacktypes(record)
%TPSTACKTYPES returns the possible ROI types for a tp ROI
%
%  STACKTYPES = TPSTACKTYPES( RECORD ) 
%
% 200X, Steve Van Hooser
% 2010-2018, Alexander Heimel
%

if nargin<1
    record.experiment = '';
end

switch record.experiment
    case {'10.14'}
        stacktypes = {'cell','neuron','glia'};
    case '10.24'
        stacktypes = {'shaft','spine','dendrite','unknown','aggregate','pia'};
    case {'11.12'}
        stacktypes = {'mito','bouton','t_bouton','spine','axon','axon_int','bg','dendrite','aggregate','unknown','axon_int'};
    case {'12.34'}
        stacktypes = {'aggregate','axon','axon_int','bg','bouton','cell','dendrite','shaft','spine','t_bouton','unknown'};
    case {'11.74','11.74_lvs'}
        stacktypes = {'aggregate','cell','dendrite','puncta','shaft','spine','unknown'};
    case {'12.81','12.81 mariangela'}
        stacktypes = {'spine','shaft','dendrite','unknown','line'};
    case {'12.76','13.29'}
        stacktypes = {'cell','neuron','glia'};
    case {'14.24'}
        stacktypes = {'axon','bouton','Npil','Pyr','PV','shaft','spine','SST','unknown'};
    case '17.20.16'
        stacktypes = {'cell'};
    otherwise 
        stacktypes = {'aggregate','axon','bouton','cell','dendrite','glia','mito','neurite','pia','shaft','soma','spine','unknown'};
end
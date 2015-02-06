function stacktypes = tpstacktypes(record)
%TPSTACKTYPES returns the possible ROI types for a tp ROI
%
%  STACKTYPES = TPSTACKTYPES( RECORD ) 
%
% Steve Van Hooser, 2010-2012 Alexander Heimel
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
        stacktypes = {'mito','bouton','t-bouton','spine','axon','dendrite','unknown'};
    case {'12.81','12.81 mariangela'}
        stacktypes = {'spine','shaft','dendrite','unknown','line'};
    case {'12.76','13.29'}
        stacktypes = {'cell','neuron','glia'};
    otherwise 
        stacktypes = {'aggregate','axon','bouton','cell','dendrite','glia','mito','pia','shaft','spine','unknown'};
end
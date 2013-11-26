function[out,h]=SONADCToSingle(in,header)
% Covert an SON ADC channel to single precision floating point
%
%

% Malcolm Lidierth 03/02

if(nargin<2)
    header.scale=1;
    header.offset=0;
end;

if isstruct(header)
    if(isfield(header,'kind'))
        if header.kind~=1
            warning('SONADCToDouble: Not an ADC channel on input');
            return;
        end;
    end;
end;

out=single((double(in)*header.scale/6553.6)+header.offset);

if(nargin==2)
h=header;
end;

if(nargout==2)
h.max=max(out(:));
h.min=min(out(:));
h.kind=10;
end;
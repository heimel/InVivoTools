function[out,hout]=SONRealToADC(in,header)
% Converts floating point array to int16 and returns a scale and offset in SON format.
% The input data are scaled to fill the maximum range of the int16 output array
% 

% Malcolm Lidierth 03/02.

in=double(in);                      % make sure we have doubke precision
a(1)=min(in(:));                    % find minimum ...
a(2)=max(in(:));                    % ....and maximum of input
scale=polyfit([-32768 32767],a,1);  % find slope and intercept for the line
                                    % through {-32768,min} and {32767,max)
in=((in-scale(2)))/scale(1);        % y=ax+b so find x=(y-b)/a
in=round(in);                       % round to nearest integer
if(max(in)>32767) | (min(in)<-32768)  % Debug check that int16 conversion can't lead to overflow
    warning('SONRealToADC: Outside 16bit-integer range');
    return;
end;
out=int16(in);                      % convert to int16
hout=header;                        % copy header info
hout.scale=scale(1)*6553.6;         % adjust slope to conform to SON scale format...
hout.offset=scale(2);               % ... and set offset
hout.kind=1;                           % set kind to ADC channel

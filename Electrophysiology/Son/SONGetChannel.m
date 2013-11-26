function[data,header]=SONGetChannel(fid,chan,timeunits)
% Reads from the SON (*.smr) file with file identifier fid returning data 
% for channel chan. Both frame based (triggered) and continuous data may be read.
%

% Malcolm Lidierth 02/02

SizeOfHeader=20;                                            % Block header is 20 bytes long


Info=SONChannelInfo(fid,chan);
if(Info.kind==0) 
    warning('SONGetChannel: No data on that channel');
    data=-1;
    return;
end;

switch Info.kind
case {1}
    [data,header]=SONGetADCChannel(fid,chan);
case {2,3,4}
    [data,header]=SONGetEventChannel(fid,chan);
case {5}
    [data,header]=SONGetMarkerChannel(fid,chan);
case {6}
    [data,header]=SONGetADCMarkerChannel(fid,chan);
case {7}
    [data,header]=SONGetRealMarkerChannel(fid,chan);
case {8}
    [data,header]=SONGetTextMarkerChannel(fid,chan);
case {9}
    [data,header]=SONGetRealWaveChannel(fid,chan);
otherwise
    warning('SONGetChannel: Channel type not supported');
    return;
end;


switch Info.kind
case {1,6,7,9}
header.transpose=0;
end;



    






    


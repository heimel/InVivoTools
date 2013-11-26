function[ChanList]=SONChanList(fid)
% Returns a structure with list of the channels in a SON file
% 
%

% Malcolm Lidierth 02/02

h=SONFileHeader(fid);
AcChan=0;
for i=1:h.channels
    c=SONChannelInfo(fid,i);
    if(c.kind>0)                                    % Only look at channels that are active
        AcChan=AcChan+1;
        ChanList(AcChan).number=i;
        ChanList(AcChan).kind=c.kind;
        ChanList(AcChan).title=c.title;
        ChanList(AcChan).comment=c.comment;
        ChanList(AcChan).phyChan=c.phyChan;
    end
end

            
            
            

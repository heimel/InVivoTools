function[header]=SONGetBlockHeaders(fid,chan)
% Returns a matrix containing the SON data block headers in file 'fid' for channel 'chan'.
% The returned header im memory contains for each disk block
% a column with rows 1-5 representing:                              Offset to start of block in file
%                                                                   Start time in clock ticks
%                                                                   End time in clock ticks
%                                                                   Chan number
%                                                                   Items
% See CED documentation for details - note this header is a modified form of the disk header

% Malcolm Lidierth 02/02

predBlock=1;
succBlock=2;
startTime=3;
endTime=4;
chanNumber=5;
items=6;

FileH=SONFileHeader(fid);
Info=SONChannelInfo(fid,chan);

if(Info.firstblock==-1)
    warning('SONGetBlockHeaders: No data on this channel');
    header = [];
    return;
end;
    
header=zeros(6,Info.blocks);                                %Pre-allocate memory for header data
fseek(fid,Info.firstblock,'bof');                           % Get first data block    
header(1:4,1)=fread(fid,4,'int32');                         % Last and next block pointers, Start and end times in clock ticks
header(5:6,1)=fread(fid,2,'int16');                         % Channel number and number of items in block

if(header(5,1)~=chan)                                        % Header channel number may be different in some applications
    disp(sprintf('Note: SONBlockHeaders: the block headers list channel %d as channel %d. Will use %d as identifier',chan,header(5,1),chan));
end;

if(header(succBlock,1)==-1)
    header(1,1)=Info.firstblock;                            % If only one block
else
    fseek(fid,header(succBlock,1),'bof');                   % Loop if more blocks
    for i=2:Info.blocks
        header(1:4,i)=fread(fid,4,'int32');                         
        header(5:6,i)=fread(fid,2,'int16'); 
        if (header(5,1)~=chan) warning ('Data header refers to wrong channel in file');
            return;
        end;
        fseek(fid,header(succBlock,i),'bof');
        header(1,i-1)=header(1,i);                          
    end;
    header(1,Info.blocks)=header(2,Info.blocks-1);          % Replace predBlock for previous column
end;
header(2,:)=[];                                           % Delete succBlock data


[r,c]=size(header);
if(c>1)
    for i=2:c                                                   % Check headers all refer to same channel
        if(header(4,i)~=header(4,1))
            warning('SONGetBlockHeaders: The block headers refer to different channel numbers');
            clear('header');
            return;
        end;
    end;
end;

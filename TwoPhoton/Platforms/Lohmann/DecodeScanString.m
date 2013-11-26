function trajectories=DecodeScanString(TifStruct,TimePerPix)
%DECODESCANSTRING
%
% col2:
% 0: Abs 1: Rel 2: Inc 3: IncInc 4: LoopStart 5: LoopEnd
% col3
% 3: galvoX 4: galvoY 7: digital 9: loop 10: Smartmove time 11: ImageX 12: ImageY
%
% 20XX, Max Sperling
%
% See email from Friederiek Siegel on May 10, 2011
% However, I could not get it to work (Alexander Heimel, June 2011)
%


InfoStruct = TifStruct;%.Info(1,1);   
    
pos1 = strfind(InfoStruct.ImageDescription,'scan=');
pos2 = strfind(InfoStruct.ImageDescription(pos1:end),';"');
scanstring = InfoStruct.ImageDescription(pos1+6:pos1+pos2-2);

trajectory = NaN*zeros(1,InfoStruct.Width*InfoStruct.Height*1.05);
trajectories = NaN*zeros(InfoStruct.Width*InfoStruct.Height*1.05,2);

scan=str2num(scanstring);
cycle_duration=TimePerPix;

% from seconds to cycles
scan(:,1)=round(scan(:,1)/cycle_duration); %change time to cycles
scan(:,4)=(scan(:,4)*cycle_duration).*(scan(:,2)==2)...  %change velocity to m/cycles
    +(scan(:,4)*cycle_duration^2).*(scan(:,2)==3)... %change accel to m/cycles^2
    +scan(:,4).*(scan(:,2)~=2 & scan(:,2)~=3);

nCycles = scan(end,1);

% data = zeros(uint16(nCycles+1),1);

for channel = 3:4
    
    scan_ch = scan(scan(:,3) == channel | scan(:,3) == 9,:);
    nCommands = size(scan_ch,1);
    command_line = 1;
    tmpAbs = 0;
    tmpInc = 0;
    tmpIncInc = 0;
    loopTimeOffsets = [];
    loopStartIdx = [];
    loopsToDo = [];
    
    for cycle=0:nCycles
        doLoop = 1;
        while doLoop
            if command_line <= nCommands
                doLoop = (sum(loopTimeOffsets) + scan_ch(command_line,1)) == cycle;
            else
                doLoop=0;
            end
            
            if doLoop
                switch scan_ch(command_line,2)
                    case 0 % Abs
                        tmpAbs = scan_ch(command_line, 4);
                        command_line = command_line + 1;
                    case 1 % Rel
                        tmpAbs = tmpAbs + scan_ch(command_line, 4);
                        command_line = command_line + 1;
                    case 2 % Inc
                        tmpInc = scan_ch(command_line, 4);
                        command_line = command_line + 1;
                    case 3 % IncInc
                        tmpIncInc = scan_ch(command_line, 4);
                        command_line = command_line + 1;
                    case 4 % LoopStart
                        loopTimeOffsets = [loopTimeOffsets 0];
                        loopStartIdx = [loopStartIdx command_line];
                        loopsToDo = [loopsToDo scan_ch(command_line, 4)];
                        command_line = command_line + 1;
                    case 5 % LoopEnd
                        if loopsToDo(end) == 1 %loop finished
                            loopTimeOffsets(end) = []; %remove information for this loop from the loop lifo
                            loopStartIdx(end) = [];
                            loopsToDo(end)  = [];
                            command_line = command_line + 1;
                        else % do an other loop
                            loopsToDo(end) = loopsToDo(end) - 1;
                            loopTimeOffsets(end) = loopTimeOffsets(end) + (scan_ch(command_line, 1) - scan_ch(loopStartIdx(end), 1));
                            command_line =  loopStartIdx(end) + 1;
                        end
                    otherwise % should not happen
                        command_line = command_line + 1;
                        disp('unknown command detected! skipping it!');
                end
                
            end
            
        end
        trajectory(cycle+1) = tmpAbs;
        tmpAbs = tmpAbs + tmpInc;
        tmpInc = tmpInc + tmpIncInc;
        
        
    end
    trajectories(:,channel-2) = trajectory;
    
end

end

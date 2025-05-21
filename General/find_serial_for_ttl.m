function com = find_serial_for_ttl( name )
%find_serial_for_ttl. Returns COM port for sending TTL
%
%  COM = find_serial_for_ttl( NAME='Silicon Labs CP210x USB to UART Bridge')
%
%    NAME is friendly name of USB2UART device,
%       e.g. 'Silicon Labs CP210x USB to UART Bridge'
%
%    COM is matching COM port, e.g. 'COM5'
%
% 2025, Alexander Heimel

if nargin<1 
    name = 'Silicon Labs CP210x USB to UART Bridge';
end

com = [];

%%
Skey = 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM';
% Find connected serial devices and clean up the output
[~, list] = dos(['REG QUERY ' Skey]);
list = strread(list,'%s','delimiter',' ');
coms = 0;
for i = 1:numel(list)
  if strcmp(list{i}(1:3),'COM')
      if ~iscell(coms)
          coms = list(i);
      else
          coms{end+1} = list{i};
      end
  end
end
if ~isempty(coms)
    % fprintf('Found serial ports: ')
    % fprintf(coms{1})
    % for i=2:length(coms)
    %     fprintf([', ' coms{i} ])
    % end
    % fprintf('\n')
else
    disp('Did not find any serial ports.')
    return
end

key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB\';
% Find all installed USB devices entries and clean up the output
[~, vals] = dos(['REG QUERY ' key ' /s /f "FriendlyName" /t "REG_SZ"']);
vals = textscan(vals,'%s','delimiter','\t');
vals = cat(1,vals{:});
out = 0;
% Find all friendly name property entries
for i = 1:numel(vals)
  if strcmp(vals{i}(1:min(12,end)),'FriendlyName')
      if ~iscell(out)
          out = vals(i);
      else
          out{end+1} = vals{i};
      end
  end
end
% Compare friendly name entries with connected ports and generate output
count = 0;
devs = {};
for i = 1:numel(coms)
    ind = find(contains(out,['(' coms{i} ')']));
    if ~isempty(ind) && contains(out{ind},name)
        count = count+1;
        com = str2double(coms{i}(4:end));
        devs{count,1} = out{ind}(27:end);
        devs{count,2} = coms{i};
    end
end
switch count
    case 0
        disp(['Could not find USB2UART device with name ' name]);
        return
    case 1
        com = devs{count,2};
        disp([ com ' is unique USB2UART device with name ' name ])
    otherwise
        disp(['Returning multiple USB2Uart devices with name ' name]);
        com = devs(:,2);
end
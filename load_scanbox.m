scanbox_path = [fileparts(mfilename('fullpath')) filesep 'Scanbox_Yeti'];
if exist(scanbox_path,'dir')
    disp('Added Scanbox path');
    addpath(genpath(scanbox_path));
    return
end


scanbox_path = [fileparts(mfilename('fullpath')) filesep '..' filesep  'Scanbox_Yeti'];
if exist(scanbox_path,'dir')
    disp('Added Scanbox path');
    addpath(genpath(scanbox_path));
end
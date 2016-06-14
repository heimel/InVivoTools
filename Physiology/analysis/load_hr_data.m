function [data,stim_par]=load_hr_data(date,variable_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                Load DATA                 %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


location        = ['session' ' ' date];
directory_name  = fullfile(location);
files           = dir(directory_name);
file_index      = find([files.isdir]);
counter         = 1;
% data            = zeros;
% stim            = zeros;

for i = 3:length(file_index)
% Set paths to look for data variables
file_name            = files(file_index(i)).name;
file_path_name_data  = fullfile(directory_name,file_name, variable_name);
file_path_name_stim  = fullfile(directory_name,file_name, 'stims.mat');

file_info       = exist(file_path_name_data,'file');

% if, and only if file info containts a matlab variables -> run in loop
if file_info == 2 
    
    temp  = load(file_path_name_data);
    
    
    % one time exception to include time at index 1
    if counter == 1
        data(1,:)   = temp.time';
    end
    
    % fill data variable
    data(counter+1,:) = temp.data';
    
    % fill stimulus variable
    stim_par(counter+1,:) = load_stim_ref(file_path_name_stim);

    counter = counter + 1;
    
end

end

disp(' ');logmsg(' *** Loading variables *** ');
str = [' *** ' location ' ***'];
logmsg(str);
str = [' *** Used variable: ' variable_name ' ***'];
logmsg(str);

end
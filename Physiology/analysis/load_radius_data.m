function [data,stim_par]=load_radius_data(date,variable_name,post_time)
%load_radius_data(date,variable_name,post_time)
%-------------------------------------------------------------------------%  
%   
%   
%   
% 
%   Last edited 28-5-2016. SL
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

% when no value for post_time is given, the default is 10.
if nargin<3
    post_time = 10;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                Load DATA                 %%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


location        = ['session' ' ' date];
directory_name  = fullfile(location);
files           = dir(directory_name);
file_index      = find([files.isdir]);

for i = 3:length(file_index)
% Set paths to look for data variables
file_name            = files(file_index(i)).name;
file_path_name_data  = fullfile(directory_name,file_name, variable_name);
file_path_name_stim  = fullfile(directory_name,file_name, 'stims.mat');

file_info       = exist(file_path_name_data,'file');

% if, and only if file info containts a matlab variables -> run in loop
if file_info == 2 
    
    % fill data variable
    data(:,i-2) = importdata(file_path_name_data);
   
    % fill stimulus variable
    stim_par(i-2,:) = load_stim_ref(file_path_name_stim);
            
end

end

% Add post time to stim_par struct
[a,~] = size(stim_par);
for i = 1:a
    stim_par(i).post_time = post_time;
end

disp(' ');logmsg(' *** Loading pupil size radius data *** ');
str = [' *** ' location ' ***'];
logmsg(str);
str = [' *** Used variable: ' variable_name ' ***'];
logmsg(str);

end
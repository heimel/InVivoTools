function stimscript = tile( stimscript )
%TILE
%
% Tiles a script at several locations 
%
% 2012, Alexander Heimel
%

StimWindowGlobals

prompt = {'Number of columns:','Number of rows:','Overlap (%):'};
name = 'Tiling parameters';
numlines = 1;
defaultanswer = {'6','3','20'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
n_x = str2double(answer{1});
n_y = str2double(answer{2});
overlap = str2double(answer{3})/100;

          
% first remake script
parameters = getparameters(stimscript); %#ok<NASGU>
eval(['stimscript=' class(stimscript) '(parameters);']);
rect = parameters.rect;

screenwidth = rect(3)-rect(1);
screenheight = rect(4)-rect(2);
width = round(screenwidth/n_x*(1+overlap));
height = round(screenheight/n_y*(1+overlap));


stims = get(stimscript);


% first remove current stimuli
for i = 1:length(stims)
    stimscript = remove(stimscript,1);
end

for y = 1:n_y
    for x = 1:n_x
        for i=1:length(stims)
            parameters = getparameters(stims{i});
            parameters.rect = round([ ...
                max(0,rect(1)+screenwidth/n_x*(x-0.5)-width/2) ...
                max(0,rect(2)+screenheight/n_y*(y-0.5)-height/2)  ...
                min(rect(3),rect(1)+screenwidth/n_x*(x-0.5)+width/2) ...
                min(rect(4),rect(2)+screenheight/n_y*(y-0.5)+height/2) ]);
            parameters.row = y;
            parameters.col = x;
            parameters.location = (y-1)*n_x + x; % starts from top left, first horizontal
            stimscript = append(stimscript,eval([class(stims{i}) '(parameters)']));
        end
    end
end


% 
% wp = getparameters(warmupps)
%     wp.imageType = 2;
%     wp.dispprefs={'BGpretime',1,'BGposttime',1};
%     warmupps = periodicstim(wp);
%     %
%     
% 	warmup = StimScript(0); warmup=append(warmup,warmupps);warmup=loadStimScript(warmup);

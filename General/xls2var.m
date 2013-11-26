function sessionpars=xls2var(fname, sheet, label_row)
%XLS2VAR read excel table and convert to struct of arrays
% it is very important that xls files are text or number format, I did
% not manage to read multiple sheets yet.
% blanks in numeric data are returned as 'NaN'.
% output: each header (first row strings) of the Excel file is a field
% of structure sessionpars.
%
% 2010, Judith Peters

if nargin<2
    sheet = [];
end
if nargin<3
    label_row = 1;
end

if ~exist(fname,'file')
    error('xls2var:fileNotFound','File %s not found.',fname); %
end



try
    if isempty(sheet)
        [num,txt]=xlsread(fname); %check num and txt matrices to see whether data are correctly read as num vs txt
    else
        [num,txt]=xlsread(fname,sheet); %check num and txt matrices to see whether data are correctly read as num vs txt
    end
catch ME
    error('MATLABxls2varxlsreaderr',...
        'XLSREAD was unable to read this file %s',ME.message); % Platform support is dependent on XLSREAD.
end

% remove rows before label_row
txt = txt(label_row:end,:);
%num = num(label_row:end,:);
num = num(1:end,:);


%delete nan rows of num
todel = [];
for i=1:size(num,2)
    if all(isnan(num(:,i)))
        todel = [todel i];
    end
end
num(:,todel) = [];

[rows,numVars] = size(txt);

numi = 1;
for varInd=1:numVars
    varName = txt{1,varInd}; %first row element = variable name
    if isempty(varName)
        varName = ['field' num2str(varInd)];
    else
        varName = genvarname(varName); %create proper MATLAB var name (remove spaces and stuff)
    end
    stringData=txt(2:end,varInd);
    strInds=~cellfun(@isempty,stringData);
    if size(find(strInds),1)/size(stringData,1) > 0.5 %if more strings than not than create cell array
        varData=num2cell(txt(2:end,varInd));
        varData(strInds)=stringData(strInds);
    else %number array
        if numi<=size(num,2)
            varData=num(1:end,numi);
            numi = numi + 1;
        else
            varData = NaN*zeros(size(num,1),1);
        end    
    end
    
    sessionpars.(varName)=varData;
end



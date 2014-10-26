function iueinfo = get_iue_info( iue_number )
%GET_IUE_INFO read info from In Utero Spreadsheet
%
%  IUEINFO = GET_IUE_INFO( IUE_NUMBER )
%     where IUE_NUMBER is e.g. 09-01
%
% 2009, Alexander Heimel
%


switch computer
    case {'PCWIN','PCWIN64'}
        xlsfile = '\\orange\group folders\MuizenlijstLeveltLab\In Utero Electroporatie 2009.xls';
    case {'GLNX86','GLNXA64'}
        xlsfile = '/mnt/orange/group folders/MuizenlijstLeveltLab/In Utero Electroporatie 2009.xls';
end

[numeric,txt,raw]=xlsread(xlsfile);

x={txt{:,4}};
x=strfind(x,['IUE ' iue_number]);

for i=1:length(x)
  if x{i}==1
    row=i;
    break;
  end
end

line=txt(row,:); % first line is empty

iueinfo.name=line{4};
iueinfo.dec=line{3};
iueinfo.vector=line{11};
iueinfo.raw=raw(row+1,:);
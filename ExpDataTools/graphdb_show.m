function newud=graphdb_show( ud)
%GRAPHDB_SHOW
%
%   NEWUD=GRAPHDB_SHOW( UD)
%
% 2007, Alexander Heimel

record=ud.db(ud.current_record);

path=compose_figurepath(record.path);
filename=record.filename;
filename=fullfile(path,filename);

if exist(filename,'file')~=2
  errordlg(['Unable to find file ' filename '. Check filename and path.'],'Show graph');
  disp(['GRAHDB_SHOW: Unable to find file ' filename '. Check filename and path.']);
elseif 0 && usejava('jvm')
  imageview(filename);
else
  img=imread(filename);
  figure('name',filename,'numbertitle','off');
  image(img);
  axis off image;  
end

newud=ud;

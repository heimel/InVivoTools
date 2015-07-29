function newud=graphdb_show( ud)
%GRAPHDB_SHOW
%
%   NEWUD=GRAPHDB_SHOW( UD)
%
% 2007-2015, Alexander Heimel

global values_x values_y

record=ud.db(ud.current_record);

path=compose_figurepath(record.path);
filename=record.filename;
filename=fullfile(path,filename);

if isfield(record,'values') && ~isempty(record.values) && isfield(record.values,'gx')
    values_x = record.values.gx; %#ok<NASGU>
    values_y = record.values.gy; %#ok<NASGU>
    evalin('base','global values_x values_y');
    logmsg('Values available in workspace as values_x values_y. To show data: dispcell(values_y)');
end

if exist(filename,'file')~=2
  errormsg(['Unable to find file ' filename '. Check filename and path.']);
elseif 0 && usejava('jvm')
  imageview(filename);
else
  img=imread(filename);
  figure('name',filename,'numbertitle','off');
  image(img);
  axis off image;  
end

newud=ud;

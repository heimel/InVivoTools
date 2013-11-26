function db=micefrommdb( mousenumbers, filename)
%MICEFROMMDB get specific mice from Mice.mdb
%
%  DB = MICEFROMMDB( MOUSENUMBERS, FILENAME )
%
%    See also IMPORT_MDB
%
% 2006, Alexander Heimel
%

if nargin<2
  filename=[];
end

db=[];
if isempty(mousenumbers)
  return
end

crit=[ '\(Muisnummer=' num2str(mousenumbers) '\) '];

for i=2:length(mousenumbers)
  crit=[crit ' and \(Muisnummer=' num2str(mousenumbers) '\) '];
end


db=import_mdb(filename,[],crit);

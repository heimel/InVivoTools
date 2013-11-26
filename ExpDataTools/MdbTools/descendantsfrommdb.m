function mice=descendantsfrommdb( mouse, gen)
%DESCENDANTSFROMMDB get all ancestors up to a certain generation
%

if nargin<2
  gen=1;
end


if isnumeric(mouse)
  mouse=micefrommdb(mouse);
end

if gen==0 % done
  mice=[];
  return
end

gender=mouse.MaledFemale;

switch gender
  case 'male',
    parent='Father';
  case 'female',
    parent='Mother';
end

crit=[ parent ' like \''%' mouse.Muisnummer '%\'''];


kids=import_mdb('','',crit);
mice=[];
for i=1:length(kids)
  kids(i).generation=gen;
  mice=[mice kids(i) descendantsfrommdb(kids(i),gen-1)];
end



return




  
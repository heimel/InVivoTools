function mice=ancestryfrommdb( mouse, gen )
%ANCESTRYFROMMDB get all ancestors up to a certain generation
%

if nargin<2
  gen=1
end


father=[];
mother=[];

if isnumeric(mouse)
  mouse=micefrommdb(mouse);
end

if gen==0 % done
  mice=mouse;
  return
end



if isstruct(mouse)
  father=mouse.Father
  father=str2double(father);
  if ~isnan(father)
    father=micefrommdb(father);
    fathersside=ancestryfrommdb(father,gen-1);
  else
    fathersside=mouse.Father;
  end
  
  mother=mouse.Mother;
  mother=str2double(mother);
  if ~isnan(mother)
    mother=micefrommdb(mother);
    mothersside=ancestryfrommdb(mother,gen-1);
  else
    mothersside=mouse.Mother;
  end
  
  
end

mice={ mouse, fathersside,mothersside};





  
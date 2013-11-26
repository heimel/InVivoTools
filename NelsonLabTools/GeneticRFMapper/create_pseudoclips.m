function clips = create_pseudoclips(chromosomes,param,blankclip )
%CREATE_PSEUDOCLIPS creates device independent movieclips of chromosomes
%
% CLIPS = CREATE_PSEUDOCLIPS( CHROMOSOMES, PARAM, BLANKCLIP )
%     clip{duration}(window(1),window(2),3)=background/255
%
% CLIPS = CREATE_PSEUDOCLIPS( CHROMOSOMES )
%   uses genetic_defaults as PARAM
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  param=genetic_defaults;
end
if nargin<3
% start with blank clip
  for f=1:param.duration
    blankclip{f}(1:param.window(1),1:param.window(2),1)=param.background(1)/255;
    blankclip{f}(1:param.window(1),1:param.window(2),2)=param.background(2)/255;
    blankclip{f}(1:param.window(1),1:param.window(2),3)=param.background(3)/255;
  end
end
  

for i=1:length(chromosomes)
  chromosome=chromosomes{i};
  clip=blankclip;
  
  for f=1:param.duration   %just for faster parsing
    aclip(:,:,:,f)=clip{f};    
  end
  
  
  for g=1:length(chromosome)
    gene=chromosome(g);
    switch gene.type
     case 1  %'disk'
      box = pseudodisk( 2*gene.size );
      [boxrect, cliprect]=clipbox( size(box), param.window, ...
				   gene.position);
      clear('b');
      b=box(boxrect(1):boxrect(3), boxrect(2):boxrect(4));
      diski=find(b~=0); % find where disk actually is within
                        % bounding box
      
      on=gene.onset; off=on+gene.duration-1;
      
      clipbox=aclip(cliprect(1):cliprect(3),cliprect(2): ...
		    cliprect(4),:,on:off  );
      
      for f=1:gene.duration
	cb=clipbox(:,:,1,f);
	cb(diski)=gene.color.r/255;
	clipbox(:,:,1,f)=cb;
	cb=clipbox(:,:,2,f);
	cb(diski)=gene.color.g/255;
	clipbox(:,:,2,f)=cb;
	cb=clipbox(:,:,3,f);
	cb(diski)=gene.color.b/255;
	clipbox(:,:,3,f)=cb;
      end

      aclip(cliprect(1):cliprect(3),cliprect(2):cliprect(4),:,on:off ...
	     )= clipbox;
      
     case 3 % oval 
      theta=gene.orientation/360*2*pi;
      ct=cos(theta);
      st=sin(theta);
      e2=gene.eccentricity^2;
      s2=gene.size^2;
      red=gene.color.r/255;
      green=gene.color.g/255;
      blue=gene.color.b/255;
      maxdist=ceil(max(gene.eccentricity,1)*gene.size)+max(abs(gene.speed.x),abs(gene.speed.y))*gene.duration;

      range=(gene.onset:gene.onset+gene.duration-1);
      for xr=-maxdist:maxdist
        for yr=-maxdist:maxdist
	  xp=ct*xr + st*yr;
	  yp=-st*xr + ct*yr;
	  if xp^2 + yp^2/e2 <= s2  % so in oval % one FOP could be gained
	    x=xr+gene.position.x;
	    y=yr+gene.position.y;
            for f=range
	      if x>0 & x<=param.window(1) & y>0 & y<=param.window(2)
	        aclip(x,y,1,f)=red;
	        aclip(x,y,2,f)=green;
	        aclip(x,y,3,f)=blue;
              end
	      x=x+gene.speed.x;
              y=y+gene.speed.y;
            end
	  end
	end
      end
      
     otherwise
      disp(['Type ' num2str(gene.type) ' is not yet implemented.']);
    end
  end
  
  
  % clip rgb levels between 0,1
  aclip(find(aclip(:,:,:,:)>1))=1;
  aclip(find(aclip(:,:,:,:)<0))=0; 
  
  for f=1:param.duration
    clip{f}=aclip(:,:,:,f);
  end
  clips{i}=clip;
end



function [boxrect, cliprect]=clipbox( sizebox, sizeclip, position)
% boxrect = [minx miny maxx maxy] in all within (1:sizebox(1),1:sizebox(2)
% cliprect = [minx miny maxx maxy] in all within (1:sizeclip(1),1:sizeclip(2))
% should be same size after clipping

  cliprect(1) = ceil(position.x - sizebox(1)/2 );
  cliprect(2) = ceil(position.y - sizebox(2)/2 );
  cliprect(3) = cliprect(1)+sizebox(1) -1;
  cliprect(4) = cliprect(2)+sizebox(2) -1;
  if cliprect(1) < 1
    boxrect(1) = 2 - cliprect(1);
    cliprect(1) = 1;
  else
    boxrect(1) = 1;
  end
  if cliprect(2) < 1
    boxrect(2) = 2 - cliprect(2);
    cliprect(2) = 1;
  else
    boxrect(2) = 1;
  end
  if cliprect(3) > sizeclip(1)
    boxrect(3) = sizebox(1) - cliprect(3) + sizeclip(1);
    cliprect(3) = sizeclip(1);
  else
    boxrect(3) = sizebox(1);
  end
  if cliprect(4) > sizeclip(2)
    boxrect(4) = sizebox(2) - cliprect(4) + sizeclip(2);
    cliprect(4) = sizeclip(2);
  else
    boxrect(4) = sizebox(2);
  end

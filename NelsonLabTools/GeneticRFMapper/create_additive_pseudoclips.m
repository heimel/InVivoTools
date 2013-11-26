function clips = create_additive_pseudoclips(chromosomes,param,blankclip )
%CREATE_ADDITIVE_PSEUDOCLIPS creates device independent movieclips of chromosomes by adding stimulus elements 
%
% CLIPS = CREATE_ADDITIVE_PSEUDOCLIPS( CHROMOSOMES, PARAM, BLANKCLIP )
%     clip{duration}(window(1),window(2),3)=background/255
%
% CLIPS = CREATE_ADDITIVE_PSEUDOCLIPS( CHROMOSOMES )
%   uses default_param as PARAM
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  param=default_param;
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
    gene=chromosome{g};
    switch gene.type
     case 'disk'
      box = pseudodisk( gene.size );
      [boxrect, cliprect]=clipbox( size(box), param.window, ...
				   gene.position);
%      color=gene.contrast*(gene.color-param.background)/255;
      color=(gene.color-param.background)/255;
      clear('b');
      for c=1:3
	b(:,:,c) =color(c)* box(boxrect(1):boxrect(3), boxrect(2):boxrect(4));
      end
       on=gene.onset; off=on+gene.duration-1;
       aclip(cliprect(1):cliprect(3),cliprect(2):cliprect(4),:,on:off  )=...
	   aclip(cliprect(1):cliprect(3),cliprect(2):cliprect(4),:,on:off)+...
	   b(:,:,:,ones(1,gene.duration));
     otherwise
      disp(['Type ' gene.type ' is not yet implemented.']);
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

  cliprect(1) = ceil(position(1) - sizebox(1)/2 );
  cliprect(2) = ceil(position(2) - sizebox(2)/2 );
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

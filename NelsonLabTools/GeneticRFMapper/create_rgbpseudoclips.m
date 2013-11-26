function [redclips, blueclips, greenclips] = create_rgbpseudoclips(stimuli,param )
%CREATE_RGBPSEUDOCLIPS creates device independent movieclips of chromosomes
%
% [REDCLIPS, GREENCLIPS, BLUECLIPS] = CREATE_RGBPSEUDOCLIPS( STIMULI, PARAM )
%
% [REDCLIPS, GREENCLIPS, BLUECLIPS] = CREATE_RGBPSEUDOCLIPS( STIMULI )
%   uses genetic_defaults as PARAM
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  param=genetic_defaults;
end

for i=1:length(stimuli)
  chromosome=stimuli(i).chromosome;
  
  % start with blank clip
  for f=1:param.duration
    rclip{f}(1:param.window(1),1:param.window(2))=param.background(1);
    gclip{f}(1:param.window(1),1:param.window(2))=param.background(2);
    bclip{f}(1:param.window(1),1:param.window(2))=param.background(3);
  end
  
  for g=1:length(chromosome)
    gene=chromosome(g);
    switch gene.type
     case 1 % 'disk'
      box = pseudodisk( gene.size*2 );
      [boxrect, cliprect]=clipbox( size(box), param.window, gene.position);
      for f=gene.onset:gene.onset+gene.duration-1
	% red
	r=gene.contrast*(gene.color.r-param.background(1));
	rclip{f}(cliprect(1):cliprect(3),cliprect(2):cliprect(4))=...
	    rclip{f}(cliprect(1):cliprect(3),cliprect(2):cliprect(4))+...
	    r*box( boxrect(1):boxrect(3), boxrect(2):boxrect(4) );
	% green
	g=gene.contrast*(gene.color.g-param.background(2));
	gclip{f}(cliprect(1):cliprect(3),cliprect(2):cliprect(4))=...
	    gclip{f}(cliprect(1):cliprect(3),cliprect(2):cliprect(4))+...
	    g*box( boxrect(1):boxrect(3), boxrect(2):boxrect(4) );
	% blue
	b=gene.contrast*(gene.color.b-param.background(3));
	bclip{f}(cliprect(1):cliprect(3),cliprect(2):cliprect(4))=...
	    bclip{f}(cliprect(1):cliprect(3),cliprect(2):cliprect(4))+...
	    b*box( boxrect(1):boxrect(3), boxrect(2):boxrect(4) );
      end
      
      
     otherwise
      disp(['Type ' num2str(gene.type) ' is not yet implemented.']);
    end
  end
  redclips{i}=rclip;
  greenclips{i}=gclip;
  blueclips{i}=bclip;
end


function [boxrect, cliprect]=clipbox( sizebox, sizeclip, position)
% boxrect = [minx miny maxx maxy] in all within (1:sizebox(1),1:sizebox(2)
% cliprect = [minx miny maxx maxy] in all within (1:sizeclip(1),1:sizeclip(2))
% should be same size after clipping

  cliprect(1) = position.x - floor( sizebox(1)/2 );
  if cliprect(1) < 1
    boxrect(1) = 2 - cliprect(1);
    cliprect(1) = 1;
  else
    boxrect(1) = 1;
  end
  
  cliprect(2) = position.y - floor( sizebox(2)/2 );
  if cliprect(2) < 1
    boxrect(2) = 2 - cliprect(2);
    cliprect(2) = 1;
  else
    boxrect(2) = 1;
  end

  cliprect(3) = position.x + ceil( sizebox(1)/2 ) - 1;
  if cliprect(3) > sizeclip(1)
    boxrect(3) = sizebox(1) - cliprect(3) + sizeclip(1);
    cliprect(3) = sizeclip(1);
  else
    boxrect(3) = sizebox(1);
  end
      
  cliprect(4) = position.y + ceil( sizebox(2)/2 ) - 1;
  if cliprect(4) > sizeclip(2)
    boxrect(4) = sizebox(2) - cliprect(4) + sizeclip(2);
    cliprect(4) = sizeclip(2);
  else
    boxrect(4) = sizebox(2);
  end

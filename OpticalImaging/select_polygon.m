function [roi,vx,vy]=select_polygon
%SELECT_POLYGON allows user to select a region in an image
%
%  [ROI,VX,VY]=SELECT_POLYGON
%      ROI is a matrix of the image dimensions containing 1 whenever
%      a pixel is within the selected region and 0 otherwise
%      VX,VY contain vector of the corner points
%
%  2005, Alexander Heimel
%
  
  ax=axis;
  diaglength=sqrt( (ax(2)-ax(1))^2 +(ax(4)-ax(3))^2);
  
  mindist=0.02*diaglength;
  
  x=[];y=[];h=[];
  [x(end+1),y(end+1),button]=ginput(1);
  
  complete=0;
  while ~complete
    [x(end+1),y(end+1),button]=ginput(1);
    
    if button==3
      if ~isempty(x)
	x=x(1:end-2);y=y(1:end-2);
	if ~isempty(h)
	  delete(h(end));
	  h=h(1:end-1);
	end
      end
    else

      dist=sqrt((x(end)-x(1))^2 + (y(end)-y(1))^2);
      if dist<mindist & length(x)>2
	x=x(1:end-1);y=y(1:end-1);
	complete=1;
      end
      if ~complete
	if length(x)>1
	  h(end+1)=line( [x(end-1) x(end)], [y(end-1) y(end)]);
	  set(h,'Color',[1 0 0]);
	end
      else
	h(end+1)=line( [x(1) x(end)], [y(1) y(end)]);
	set(h,'Color',[1 0 0]);
      end
    end
  end
  hold on
  fill( x, y,[ 1 0 0]);
  pause(0.1);
  
  c=get(gca,'children');
  img=[];
  while ~isempty(c)  & isempty(img)
    dat=get(c(end));
    if isfield(dat,'CData')
      img=get(c(end),'CData');
    end
    c=c(1:end-1);
  end
    
  
  if isempty(img)
    ax=axis
    ysize=floor(ax(4)+ax(3))-1;
    xsize= floor( ax(2)+ax(1))-2;
  else
    xsize=size(img,2);
    ysize=size(img,1);
  end

  
  [ax,ay]=meshgrid( (1:xsize),(1:ysize) );
 
  roi=inpolygon(ax(:),ay(:),x,y);
  
  roi=reshape(roi,ysize,xsize);
  
  vx=x;
  vy=y;

function h=plot_frame(frame,roi,ror)
%PLOT_FRAME plots a single image, optionally with ROI and ROR highlighted
%
%  H=PLOT_FRAME(FRAME,ROI,ROR)
%
%  2005, Alexander Heimel
%
  
  h=figure;

  colormap(gray);
  colmap=colormap;
  frame=frame-min(frame(:));
  frame=1+floor(size(colmap,1)*frame/max(frame(:)));
  huemap=ind2rgb(frame',colmap);
  if nargin>1
    huemap(:,:,2)=huemap(:,:,2).*(1+roi);
    huemap=min(huemap,1);
  end  
  if nargin>2
    huemap(:,:,1)=huemap(:,:,1).*(1+ror);
    huemap=min(huemap,1);
  end  
  image(huemap);

  colormap gray;
  axis equal off;
  axis off;
  

  if nargin>1
    ps=ceil(size(huemap,1)*0.03);
    x=0.5*ps;
    y=size(huemap,1)+1;
    patch(x+ps*[0 0 1 1 ],y+ps*[0 1 1 0],[0.7 1 0.7])
    h=text(x+1.5*ps,y+0.5*ps,'ROI');
    if nargin>2
      ext=get(h,'Extent');
      x=x+ext(3)+2*ps;
      patch(x+ps*[0 0 1 1 ],y+ps*[0 1 1 0],[1 0.7 0.7])
      text(x+1.5*ps,y+0.5*ps,'ROR');
    end
  end

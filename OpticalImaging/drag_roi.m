function [mask,rect,data]=drag_roi
%DRAG_ROI returns coordinates of a dragged box on any axes
%
%    [ROI,RECT,DATA]=DRAG_ROI
%         RECT [left bottom right top] in image array coordinates
%         DATA is data in that region
%         ROI is ROI mask, array of imagesize with 1 inside ROI
%
%         Note: ROI is aligned with image. For many Optical_imaging 
%           analysis routines which transpose the data before displaying,
%           this means the ROI should be transposed before use.
%  
%  2004, Alexander Heimel
%
  
   set(gcf,'units','pixels');
  

   rect=[];
   while isempty(rect)
     waitforbuttonpress;
     rect=rbbox;
     
     set(gca,'units','pixels');
     
     pos_axis=get(gca,'Position');
     
     xlim=get(gca,'XLim');
     ylim=get(gca,'YLim');
     
     %move to axis relative coordinates
     rect([1 2])=rect([1 2])-pos_axis([1 2]);
     
     rect([1 3])=rect([1 3])/pos_axis(3);
     rect([2 4])=rect([2 4])/pos_axis(4);
     
     %change from [left bottom width height] to
     %     [left bottom right top]
     
     
     %x is 1,3
     %y is 2,4
     
     
     
     rect(3)=rect(1)+rect(3);
     rect(4)=rect(2)+rect(4);
     

     
     
     
   end
   
   % turn y coordinates around 
   rect([2 4])=1-rect([4 2]);
   
   % get info on data
   c=get(gca,'children');
   while ~isempty(c)
     try
       x=get(c(1),'XData');
       y=get(c(1),'YData');
       alldata=get(c(1),'CData');
     end
     c=c(2:end);
     
     
     % transform to array coordinates
     rect(1)=floor(xlim(1)+rect(1)*(xlim(2)-xlim(1)));
     rect(1)=max(x(1),rect(1));
     
     rect(3)=ceil(xlim(1)+rect(3)*(xlim(2)-xlim(1)));
     rect(3)=min(x(2),rect(3));
     
     rect(2)=floor(ylim(1)+rect(2)*(ylim(2)-ylim(1)));
     rect(2)=max(y(1),rect(2));
     
     rect(4)=ceil(ylim(1)+rect(4)*(ylim(2)-ylim(1)));
     rect(4)=min(y(2),rect(4));
     
     
     if rect(1)<x(1) | rect(3)>x(2) | rect(2)<y(1) | rect(2)>y(2)
       disp('Failed to get ROI. Try again');
       rect=[];
     end
     
   end


   pause(0.1); % necessary, otherwise X crashes 
               % probably something to do with removing the frame
   
   % mask
   mask=rect2mask(rect,[x(2) y(2)]);
   
   % swap x and y to get array coordinates
   rect=rect([2 1 4 3]);

   %[indc,indr] = meshgrid( (rect(2):rect(4)), (rect(1):rect(3)) );
   %indr=(indr-1)*y(2);
   %ind=indc+indr
   
   
   %data=alldata(ind);
   
   
   data=alldata( rect(1):rect(3), rect(2):rect(4));
   

   
   disp(['ROI: ' mat2str(rect) ]);

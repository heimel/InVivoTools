function [xscale,yscale]=compute_optimal_fits(x,y,show_yscaling)
%COMPUTE_TLTPAPER_CONTRAST_SF_FULL_MATRIX
%  used in graph_db for tltrebuttal figures
%
% 2009, Alexander Heimel
%

if nargin<3
    show_yscaling=[];
end
if isempty(show_yscaling)
    show_yscaling=1;
end


if nargout>0
  show=0;
else
  show=1;
end

contrasts=x{1}/100;
sfs=[0.05 0.1 0.2 0.4];

% store current figure handle
curfig=gcf;


%figure;hold on;

respscale=[y{1};y{2};y{3};y{4}];

color=['kbgr'];

cfit=linspace(0.001,1,100);

rr=reshape(respscale,4,4);
for i=1:4
    if show
        % plot(contrasts*100,rr(i,:)','o')
    end
    y{i}=rr(i,:);
    [rm,b,n]=naka_rushton(contrasts,y{i});
    rfit{i} = rm*cfit.^n./(b^n+cfit.^n);
    %       plot(cfit*100,rfit{i},['-' color(i)]);
end


combined_xscale_x=[];
combined_xscale_y=[];
combined_yscale_x=[];
combined_yscale_y=[];
for i=1:4
   % try optimal x scaling
   [xscale(i),min_xscaling_error]=optimal_xscaling(cfit,rfit{1},contrasts,thresholdlinear(y{i}));
   %plot(cfit*100*xscale(i),rfit{1},['-' color(i)]);

   combined_xscale_x=[   combined_xscale_x contrasts/xscale(i)];
   combined_xscale_y=[   combined_xscale_y y{i}];


   % try optimal y scaling
   [yscale(i),min_yscaling_error]=optimal_yscaling(cfit,rfit{1},contrasts,y{i});
%   plot(cfit*100,rfit{1}*yscale(i),[':' color(i)]);

   %combined_yscale_x=[   combined_yscale_x contrasts];
   %combined_yscale_y=[   combined_yscale_y thresholdlinear(y{i})/yscale(i)];

   
   %if min_xscaling_error>min_yscaling_error
   %   disp(['yscaling is better ' num2str(min_xscaling_error/min_yscaling_error)])
   %else
   %   disp(['xscaling is better ' num2str(min_yscaling_error/min_xscaling_error)])
   %end
end

[combined_xscale_x,ind]=sort(combined_xscale_x);
combined_xscale_y=combined_xscale_y(ind);
%plot(combined_xscale_x*100,combined_xscale_y,'ok');
[rm,b,n]=naka_rushton(combined_xscale_x,combined_xscale_y);
combined_xscale_fit = rm*cfit.^n./(b^n+cfit.^n);
disp(['combined xscale naka rushton fit: (rm b n) = ' mat2str([rm b n],2)]);
%plot(cfit*100,combined_xscale_fit,['-k']);



total_yscaling_error=0;
total_xscaling_error=0;

for i=1:4
   % try optimal x scaling
   [xscale(i),min_xscaling_error]=optimal_xscaling(cfit,combined_xscale_fit,contrasts,thresholdlinear(y{i}));

   total_xscaling_error=total_xscaling_error+min_xscaling_error;
   if show
     hp=plot(cfit*100*xscale(i),combined_xscale_fit,['-' ]);
     if i==1
         set(hp,'color',[0 0 0]);
     else
         set(hp,'color',[0.5 0.5 0.5]);
     end
   end
   
   % try optimal y scaling
   [yscale(i),min_yscaling_error]=optimal_yscaling(cfit,rfit{1},contrasts,thresholdlinear(y{i}));
   if show_yscaling
     plot(cfit*100,rfit{1}*yscale(i),[':' color(i)]);
   end
   total_yscaling_error=total_yscaling_error+min_yscaling_error;
   
   if min_xscaling_error>min_yscaling_error
      disp(['yscaling is better ' num2str(min_xscaling_error/min_yscaling_error)])
   else
      disp(['xscaling is better ' num2str(min_yscaling_error/min_xscaling_error)])
   end


end

disp(['xscaling_error = ' num2str(total_xscaling_error,2)])
disp(['yscaling_error = ' num2str(total_yscaling_error,2)])

if nargout==0
  c=get(gca,'children');
  set(gca,'children',[c(5:end); c(1:4)]);
    
elseif nargout==1
  c=get(gca,'children');
  xscale=xscale/xscale(1);
  for i=1:4
    set(c(5-i),'xdata',get(c(5-i),'xdata')/xscale(i))
    set(c(9-i),'xdata',get(c(9-i),'xdata')/xscale(i))
    set(c(13-i),'xdata',get(c(13-i),'xdata')/xscale(i))
  end
 % xlim([0.9 100]);
  hs=plot(cfit*100,combined_xscale_fit,'-');
  set(hs,'color',0.7*[1 1 1]);
  set(gca,'xtick',[1 2 4 10 20 40 90]);
  c=get(gca,'children');
  %set(gca,'children',flipud(c));
  set(gca,'children',[c(2:end); c(1)]);
elseif nargout==2
  c=get(gca,'children');
  yscale=yscale/yscale(1);
  for i=1:4
    set(c(5-i),'ydata',get(c(5-i),'ydata')/yscale(i))
    set(c(9-i),'ydata',get(c(9-i),'ydata')/yscale(i))
    set(c(13-i),'ydata',get(c(13-i),'ydata')/yscale(i))
    set(c(13-i),'udata',get(c(13-i),'udata')/yscale(i))
    set(c(13-i),'ldata',get(c(13-i),'ldata')/yscale(i))
    set(c(5-i),'xdata',get(c(5-i),'xdata')*(1+(i-2.5)/20))
    set(c(9-i),'xdata',get(c(9-i),'xdata')*(1+(i-2.5)/20))
    set(c(13-i),'xdata',get(c(13-i),'xdata')*(1+(i-2.5)/20))
  end
  hs=plot(cfit*100,rfit{1}*yscale(1),'-');
  set(hs,'color',0.7*[1 1 1]);
  c=get(gca,'children');
  set(gca,'children',[c(2:end); c(1)]);
  %set(gca,'children',flipud(c));
end

%return to currrent figure
figure(curfig);


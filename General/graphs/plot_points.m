function hp=plot_points(x,r,spaced)
rnonnan=r(~isnan(r));
if ~isempty(rnonnan)
  switch(spaced)
    case 0
      ax=axis;
      if length(r)>1
        h=0.01*( ax(4)-ax(3));
      else
        h=0;
      end
      hp=plot(x(:)+linspace(0,0,length(r))',r(:)+linspace(-h,h,length(r))','ok');
    case 1 % show spaced
      w=0.3;
      hp=plot(x+linspace(-w,w,length(rnonnan)),rnonnan,'ok');
    case 2 % show spaced keeping relatively position of points in place
      w=0.3;
      hp=plot(x+linspace(-w,w,length(r)),r,'ok');
    otherwise
      disp( ['Option spaced=' num2str(spaced) ' is unknown.']); 
  end
end




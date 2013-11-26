function b = eq(x,y)

b=0;
if isstruct(y),
 sz1 = size(x); sz2=size(y);
 if prod(double(sz1==sz2)),
   b=1;
   if prod(sz1)==1,
       fn1=fieldnames(x); fn2=fieldnames(y);
       if sort(fn1)==sort(fn2),
          for i=1:length(fn1),
            xv=getfield(x,fn1{i}); yv=getfield(y,fn1{i});
	    if ~(eqlen(xv,yv)), b = 0; break; end;
	  end;
       else, b = 0;
       end;
   else,
     for i=1:prod(sz1), if x(i)~=y(i), b = 0; break; end; end;
   end;
 end;
end;

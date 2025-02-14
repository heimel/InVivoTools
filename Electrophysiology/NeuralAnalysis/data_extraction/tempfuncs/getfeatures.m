function F = getfeatures(V,x,y,bg,f);

F = reshape(V,x,y,size(V,2));
if (f==1|f==2),
      %f1 = zeros(x,1,size(V,2)); f2 = zeros(1,y+2,size(V,2));
      %F = cat(1,f2,cat(2,f1,F,f1),f2);
  %if f==2, % later
  %end;
end;
if (f==3|f==4),
   
end;

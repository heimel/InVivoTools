function y=theta(x)
%THETA function y=x for x>0, y=0 for x<0
%  
  
  y=x;
  y(find(y<0))=0;
  

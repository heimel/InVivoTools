function y=subst_filechars(x)
%SUBST_FILECHARS substitutes file control characters by harmless characters
%
% Y=SUBST_FILECHARS(X)
%  Y will have same length as X
%
% 2007, Alexander Heimel
%
% See also GENVARNAME
%

y=x;
y(y=='/')='s';
y(y=='*')='a';
y(y==' ')='_';
y(y==',')='c';
y(y=='\')='_';
y(y=='&')='_';
y(y=='(')='_';
y(y==')')='_';
y(y=='%')='p';
y(y==':')='_';
y(y==';')='_';

doublehyphen=1;
while doublehyphen==1
  p=findstr(y,'__');
  if ~isempty(p)
    y=[y(1:p(1)-1) y(p(1)+1:end)];
    doublehyphen=1;
  else
    doublehyphen=0;
  end
end




function y=subst_specialchars(x)
%SUBST_SPECIALCHARS substitutes any not alphanumeric characters by harmless characters
%
% Y=SUBST_SPECIALCHARS(X)
%  Y will have same length as X
%
% 2007-2012, Alexander Heimel
%
% See also GENVARNAME
%

y=x;
y(y=='/')='s';
y(y=='*')='a';
y(y==' ')='_';
y(y==',')='c';
y(y=='.')='_';
y(y=='\')='_';
y(y=='&')='_';
y(y=='(')='_';
y(y==')')='_';
y(y=='%')='p';
y(y==':')='_';
y(y==';')='_';
y(y=='-')='_';
y(y=='^')='c';
y(y=='#')='h';
y(y=='$')='d';
y(y=='|')='I';

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

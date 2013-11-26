function [n,expiry_date]=dec_numbers(dec,group);
%DEC_NUMBERS returns number of animals allowed on dec protocol per group
%
% [N,EXPIRY_DATE]=DEC_NUMBERS(DEC,GROUP)
%
% 2006, Alexander Heimel
%

if isstr(group)
  group=eval(group);
end
n=NaN;
switch dec
  case '04.05' 
    expiry_date='2005-08-01';
    switch group
      case 1,n=25;
      case 2,n=25;
    end
  case '05.01',
    expiry_date='2007-02-10';
    switch group
      case 1, n=65;
      case 2, n=84;
      case 3, n=6;
    end
  case '05.03',
    expiry_date='2008-05-19';
    switch group,
      case 1, n=200;
      case 2, n=200;
      case 3, n=10;
    end
  case '05.05',
    expiry_date='2007-08-11';
    switch group,
      case 1, n=20;
      case 2, n=24;
      case 3, n=40;
    end
  case '05.06',
    expiry_date='2007-08-11';
    switch group
      case 1, n=48;
      case 2, n=60;
    end
  case '06.08',
    expiry_date='2008-03-27';
    switch group
      case 1, n=8;
      case 2,n=8;
      case 3,n=12;
      case 4,n=10;
      case 5, n=12;
      case 6, n=10;
    end
  otherwise
    disp(['Unknown protocol number: ' dec]);
    expiry_date='???';
end
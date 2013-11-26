function datadir=bxddatadir

switch user
  case 'heimel'
    datadir='/home/heimel/Projects/Mouse/NeuroBsik/data';
  otherwise
    disp('Unknown user. Do not know where bxd-data is');
    datadir='';
end


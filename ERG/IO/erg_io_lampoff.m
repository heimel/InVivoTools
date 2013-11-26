function res = erg_io_lampoff(who)
  global ao;
  
  res = 1;
  switch (who)
      case 'all' %So far the only thing technically possible??
        stop(ao);        %in case it was still running
        putsample(ao,[5 5 5 5]); 
      otherwise
        disp('Unknown command passed to erg_io_lampoff');
        res = -1;
  end
          

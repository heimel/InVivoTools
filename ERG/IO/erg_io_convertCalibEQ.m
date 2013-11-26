%This function is used to test equality of timulus conditions (ege PWM,
%pulse width and LED intensity. It will take the lowest of the high LED  
%intensity range and corresponding values in low intensity LED range (for 2
%timepoints).

function [result_condition, result_voltage, result_time, result_fill, result_levels] = erg_io_convertCalibEQ(color)
  for i = 1:3 [c,v,t,l] = erg_io_convertCalibEQ_1(i, color); result_condition(i) = {c}; result_voltage(i) = v; result_time(i) = t; result_levels(i) = l; end;
  result_fill = 5 - result_time;
  
function [condition, voltage, time, target] = erg_io_convertCalibEQ_1(nr, color)
  global calib;

  cL = calib.([color 'Low']);
  cH = calib.([color 'High']);

  try target = interp1(cH.in,cH.out,max(cH.in)); catch target = NaN; end;
  if (isnan(target)) disp('Error finding lowest value in high LED range in erg_io_convertCalibEQ_1'); voltage = 99;  time = 5; condition = [color 'Low']; end;

  if (nr == 1)
    condition = [color 'High'];
    voltage = max(cH.in);
    time = 0.5;
    return;
  end

  try bi = interp1(cL.out*5    ,cL.in,target); catch bi = NaN; end;
  try ci = interp1(cL.out*10   ,cL.in,target); catch ci = NaN; end;
       
  if     (~isnan(ci) && nr == 2)       voltage = ci; time = 5; condition = [color 'Low'];
  elseif (~isnan(bi) && nr == 3)       voltage = bi; time = 2.5; condition = [color 'Low'];
  else   disp(['Error finding value in low LED range in erg_io_convertCalibEQ_1 (nr = ' num2str(nr) ')']); voltage = 99;  time = 5; condition = [color 'Low']; end

%This function converts values according to calibration values
%Also, this function will hide the range of pulse-times that will be given
%This means it also sends back a 'fill' period according to the max pulse
%width (which is 5msec but it might change in the future).

%targets in photodiode measure (will be milliwats)
function [result_condition, result_voltage, result_time, result_fill] = erg_io_convertCalib(type, targets)
  switch type
    case 'pulse'
      [c,v,t] = erg_io_convertCalib_1('green', targets(1)); result_condition(1) = {c}; result_voltage(1) = v; result_time(1) = t;
      [c,v,t] = erg_io_convertCalib_1('blue', targets(2));  result_condition(2) = {c}; result_voltage(2) = v; result_time(2) = t;
      [c,v,t] = erg_io_convertCalib_1('UV', targets(3));    result_condition(3) = {c}; result_voltage(3) = v; result_time(3) = t;
      %Let's leave the assumption that t=5msec is max confined to this file...
      result_fill = 5 - result_time;
    case 'justoff'
      %This is an attempt to 'hide' the fact that 5v means no-light to the higher layers.
      result_condition = [5]; %Yes it's stored in the less intuitive variable but it makes life a lot easier :)
  end

function [condition, voltage, time] = erg_io_convertCalib_1(color, target)
  global calib;

% if (strcmp(color,'green')) colVal = [0 1 0]; elseif (strcmp(color,'blue')) colVal = [0 0 1]; elseif (strcmp(color,'UV')) colVal = [1 0 1]; end
  cL = calib.([color 'Low']);
  cH = calib.([color 'High']);

% dummy = robustfit(cH.in,cH.out);
% cH.out =  cH.in*dummy(2)+dummy(1);
% dummy = robustfit(cL.in,cL.out);
% cL.out =  cL.in*dummy(2)+dummy(1);

  try ai = interp1(cL.out    ,cL.in,target); catch ai = NaN; end;
  try bi = interp1(cL.out*5  ,cL.in,target); catch bi = NaN; end;
  try ci = interp1(cL.out*10 ,cL.in,target); catch ci = NaN; end;
  try di = interp1(cH.out    ,cH.in,target); catch di = NaN; end;
  try ei = interp1(cH.out*5  ,cH.in,target); catch ei = NaN; end;
  try fi = interp1(cH.out*10 ,cH.in,target); catch fi = NaN; end;
        
  %This is just a trick to try to use the 'low intensity' some more
  try
    xgrens = 3.5;
    if (interp1(cH.out,cH.in,cL.out(1).*10) > xgrens) xgrens = interp1(cH.out,cH.in,cL.out(1).*10); end
  catch
    xgrens = 4;
  end
        
  if     (target==0)                  voltage =  5; time =   5; condition = [color 'Dontcare'];  
  elseif (~isnan(fi))                 voltage = fi; time =   5; condition = [color 'High'];
  elseif (~isnan(ei))                 voltage = ei; time = 2.5; condition = [color 'High'];
  elseif (~isnan(di) && di < xgrens ) voltage = di; time = 0.5; condition = [color 'High'];
  elseif (~isnan(ci))                 voltage = ci; time =   5; condition = [color 'Low'];
  elseif (~isnan(bi))                 voltage = bi; time = 2.5; condition = [color 'Low'];
  elseif (~isnan(ai))                 voltage = ai; time = 0.5; condition = [color 'Low'];
  else   voltage = 99;  time = 5; condition = [color 'Low']; end

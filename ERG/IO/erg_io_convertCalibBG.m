% Converts 3x1 matrix (Candela) to voltage and condition for background
function [result_condition, result_voltage] = erg_io_convertCalibBG(targets)
   [c,v] = erg_io_convertCalib_1('green', targets(1)); result_condition(1) = {c}; result_voltage(1) = v; 
   [c,v] = erg_io_convertCalib_1('blue', targets(2));  result_condition(2) = {c}; result_voltage(2) = v; 
   [c,v] = erg_io_convertCalib_1('UV', targets(3));    result_condition(3) = {c}; result_voltage(3) = v; 

function [condition, voltage] = erg_io_convertCalib_1(color, target)
  global calib ergConfig;

  cL = calib.([color 'Low']);
  cH = calib.([color 'High']);

  target = target/2000/ergConfig.convertToCD; %Important conversion..., 2000 is actually based on: 1/0.5ms = 1/0.0005s = 2000, which traces back to the way calib data is saved: #of arbitrary photodiode units of total amount of light, asuming a pulse would take .5ms
  try ai = interp1(cL.out    ,cL.in,target); catch ai = NaN; end;
  try di = interp1(cH.out    ,cH.in,target); catch di = NaN; end;
        
  if     (target==0)  voltage = 99; condition = [color 'Low'];  
  elseif (~isnan(di)) voltage = di; condition = [color 'High'];
  elseif (~isnan(ai)) voltage = ai; condition = [color 'Low'];
  else                voltage = 99; condition = [color 'Low']; end

  c = 2000*ergConfig.convert2cd.(color);
  if (isnan(di) && isnan(ai) && target > 0)
    disp (['Impossible background level for color ' color ' try ' num2str(min(cL.out)*c) '-' num2str(max(cL.out)*c) ' or ' num2str(min(cH.out)*c) '-' num2str(max(cH.out)*c) ])
  end
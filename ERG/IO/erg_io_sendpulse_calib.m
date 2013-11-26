% T and P are in millisecs!
% This is just for calibration, it sends a pulse in given voltage & time,
% and reads out the USB port (integration device for photodiode)
function res = erg_io_sendpulse_calib(channel,T,P,I)
    global ao;
%    global erg_io_sendpulse_calib_res;
    
    sr = ao.SampleRate;
    T = round(T * ao.SampleRate/1000);
    P = round(P * ao.SampleRate/1000);
    
    preS = round(5 * ao.SampleRate/1000);
    postS = round(25 * ao.SampleRate/1000);
    totS = preS + postS;
    data_o = ones(3,totS)*5;
    data_o(channel,:) = [ones(1,preS)*5 ones(1,T)*I ones(1,postS-T)*5];
    data_o(4,:) = [ones(1,preS)*5 ones(1,P)*0 ones(1,postS-P)*5]; %Pulse for Light Integrator Box (USB)

%   set(ao, 'SamplesOutputFcnCount', totS)
%   set(ao, 'StopFcn', @erg_io_sendpulse_calib_callback)
%   erg_io_sendpulse_calib_res = 0;
    
    putdata(ao,[data_o']);
    start(ao);  
    trigger(ao);    

%   while (erg_io_sendpulse_res == 0) pause(0.000001); end;
    while(issending(ao))
      pause(0.00001);
    end;
    res = 256*128-binvec2dec(ActiveWire(1,'GetPort'));
end

function erg_io_sendpulse_calib_callback(A,B)
%  global erg_io_sendpulse_res;
%  erg_io_sendpulse_calib_res = 256*128-binvec2dec(ActiveWire(1,'GetPort'))
end
  
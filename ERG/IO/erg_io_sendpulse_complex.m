%times in millisecs!

% This function takes in a pre_time and a post_time. In between, a pulse
% will be given corresponding to the pulse_LEDS values (3x1 vector) 
% Values are in 'photodiode' measurements (eg 15-140000 for blue)

function [res_time, res_data] = erg_io_sendpulse_complex (pulse_LEDS, pre_time, post_time, bg_LEDS)
    global ai ao;
    nawee = 600;
    eewan = 600;

    [pulse_condition pulse_voltage pulse_time pulse_fill] = erg_io_convertCalib('pulse', pulse_LEDS);

    pre_samples = round(pre_time * ao.SampleRate/1000);
    post_samples = round(post_time * ao.SampleRate/1000);
    between_samples = round((pulse_time(1)+pulse_fill(1)) * ao.SampleRate/1000);
    tot_samples = pre_samples + post_samples + between_samples;

    nolight = erg_io_convertCalib('justoff');
    data_o = ones(4,tot_samples+nawee)*nolight; %Data in 4th column is irrelevant when we don't readout USB

    
    if (nargin >= 4)
      [bg_condition, bg_voltage] = erg_io_convertCalibBG(bg_LEDS);
    end
    
    
    for channel = 1:3
      if (bg_voltage(channel) < 99)
        %background level
        index = erg_io_switchCondition(bg_condition{channel}); %switch led condition, also returns correct datachannel
        data_o(index,:) = [ones(1,tot_samples+nawee)*bg_voltage(channel)];        
      else
        %this channel is not used as background channel  
        pulse_time_samples = round(pulse_time(channel) * ao.SampleRate / 1000);  
        pulse_fill_samples = round(pulse_fill(channel) * ao.SampleRate / 1000);  
        index = erg_io_switchCondition(pulse_condition{channel}); %switch led condition, also returns correct datachannel
        data_o(index,:) = [ones(1,pre_samples)*nolight ones(1,pulse_time_samples)*pulse_voltage(channel) ones(1,pulse_fill_samples+post_samples+nawee)*nolight];
      end
    end
    
    set(ai,'SamplesAcquiredFcn','');
    set(ai,'SamplesPerTrigger',tot_samples+nawee);

    putdata(ao, data_o');
    start([ai ao]);
    trigger([ai ao]);

    cont = 1;
    while(cont)
      pause(0.00001);
      try
        cont = 0;  
        wait(ao, 10);
        wait(ai, 10);
      catch
        cont = 1;  
      end
    end;

    stop([ai ao]);
    dif = (ao.InitialTriggerTime-ai.InitialTriggerTime); dif = round(ai.SampleRate*dif(6));
    dn = [getdata(ai,tot_samples+nawee)'];
    res_data = dn(:,1+dif:length(dn)-nawee+min(dif, nawee));
%   res_time = (0:length(res_data)-1)./(ai.SampleRate/1000);
    res_time = length(res_data)/(ai.SampleRate/1000);
end


  
%This function sends a pulse, with the given parameters, it does not think
% about calibration, it does however convert millisecs to samples. This function
% is usefull for calibration and equality testing, when the higher level
% functions do want absolute control of the voltages. Ofcourse they could
% use senddata but then they also would have to deal with shaping the
% pulse.
%
%Usage: 
% [res_time, res_data] = erg_io_sendpulse_simple(channel, pre_time, pre_voltage, 
%                             pulse_time, pulse_voltage, post_time, post_voltage)
%
% channel = 1..3 (ie which LED), switchCondition hides the realtion between
% channel and ledcolor!
%
% pre_time & pre_voltage = time before pulse and voltage that should used
% pulse_time & pulse_voltage = duration of pulse and voltage that should used
% post_time & post_voltage = time after pulse and voltage that should be used
%
% Results: res_time is a linear list of timepoints corresponding to each
% datapoint, which simplifies plotting later on. res_data is the resulting
% data.
%
% Note: The result is a multidimensional array: #channels * #samples
%
% example: erg_io_sendpulse_simple(erg_io_switchCondition('blueHigh'),100,5,100,-5,100,5)

function [res_time, res_data] = erg_io_sendpulse_simple(channel, pre_time, pre_voltage, pulse_time, pulse_voltage, post_time, post_voltage)
    global ai ao;
    nawee = 500;
    eewan = 500;
    
    pre_samples = round(pre_time * ao.SampleRate/1000);
    post_samples = round(post_time * ao.SampleRate/1000);
    pulse_samples = round(pulse_time * ao.SampleRate/1000);
    tot_samples = pre_samples + post_samples + pulse_samples;
    
    
    data_o = ones(4,tot_samples+nawee)*5;
    data_o(channel,:) = [ones(1,pre_samples)*pre_voltage ones(1,pulse_samples)*pulse_voltage ones(1,post_samples)*post_voltage ones(1,nawee)*post_voltage];
    set(ai,'SamplesAcquiredFcn','');
    set(ai,'SamplesPerTrigger',tot_samples+nawee);

    putdata(ao, data_o');
    start([ai ao]);
    trigger([ai ao]);

%    cont = 1;
%    while(cont)
%      pause(0.00001);
%      try
%        cont = 0;  
        wait(ao, 10);
        wait(ai, 10);
%      catch
%        cont = 1;  
%      end
%    end;

    stop([ai ao]);
    dif = (ao.InitialTriggerTime-ai.InitialTriggerTime); dif = round(ai.SampleRate*dif(6));
    dn = [getdata(ai,tot_samples+nawee)'];
    res_data = dn(:,1+dif:length(dn)-nawee+min(dif, nawee));
%    res_time = (0:length(res_data)-1)./(ai.SampleRate/1000);
    res_time = (length(res_data)/(ai.SampleRate/1000));
end

  
%Sends raw data to one channel (blueLow, UVhigh, etc)
function res_data = erg_io_senddata(condition, data)
    global ai ao;
    nawee = 500;
    eewan = 500;
    
    tot_samples = length(data);
    
    channel = erg_io_switchCondition(condition);
    data_o = ones(4,tot_samples+nawee)*5;
    data_o(channel,:) = [data ones(1,nawee)*erg_io_convertCalib('justoff')];
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
        wait(ao, 2);
        wait(ai, 2);
      catch
        cont = 1;  
      end
    end;

    stop([ai ao]);
    dif = (ao.InitialTriggerTime-ai.InitialTriggerTime); dif = round(ai.SampleRate*dif(6));
    dn = [getdata(ai,tot_samples+nawee)'];
    res_data = dn(:,1+dif:length(dn)-nawee+min(dif, nawee));
%    res_time = (0:length(res_data)-1)./(ai.SampleRate/1000);
end
  
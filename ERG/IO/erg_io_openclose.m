function res = erg_io_openclose(state, sr)
  global ao ai dio;
  persistent reg_all;
  
  %res: resultcode
  res = 1; %we start with one, which means ok, it can become worse or more in the course of this function :)

  if (~(length(reg_all) == 1)) reg_all = 0; end
  if (~exist('sr') || isempty(sr)) sr = 10000; end %sample rate
      
  switch (state)
    case 'openall'
      %this keeps a list of registered callers, in the end, only when the 
      %last one calls for a close it is actually closed. 
      reg_all = reg_all + 1; 
      if (reg_all == 1)
          
        %Init USB input (photodiode integreting device)
        try 
          ActiveWire(1,'OpenDevice');
        catch
          try
            ActiveWire(1,'CloseDevice'); 
            ActiveWire(1,'OpenDevice');
          catch
            errordlg('Error opening USB device for measuring calibration pulses!','ERG_IO_OPENCLOSE');
            disp('ERG_IO_OPENCLOSE: Error opening USB device for measuring calibration pulses!');
            res = -1; return;
          end
        end
        
        %Init AO = Analog Output    
        daqreset();
        ao = analogoutput('nidaq','Dev1');
        addchannel(ao,[0:3]);

        %The following two statements would interfere with background-LED
        %function so I commented it out
        %ao.OutOfDataMode = 'DefaultValue';
        %ao.Channel.DefaultChannelValue = 5;

        %init AI: Analog Input
        ai = analoginput('nidaq','Dev1');
        addchannel(ai,[0 1]);
               
        set([ai ao],'TriggerType','Manual');  
        ai.ManualTriggerHwOn = 'Trigger'; 
        set(ai,'SampleRate',sr);
        set(ao,'SampleRate',sr);

        %init dio (digital output for photodiode-integrator pulse
        dio = digitalio('nidaq','Dev1');
        addline(dio,0:2,'out');
      end
    case 'closeall'
      reg_all = reg_all - 1; %decrease # of registered callers
      if (~(reg_all > 0)) %no registered callers left? then truly close
        try; ActiveWire(1,'CloseDevice'); catch; end;
        reg_all = 0;
      end
    case 'resetall'
      reg_all = 1;
      erg_io_openclose('closeall');
    case 'status'
      disp(reg_all);     
    otherwise
      disp(['Unknown command passed to erg_io_openclose:' state]);   
      res = -1;
      return;
  end
end

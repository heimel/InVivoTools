% Switches the output current to the led between low/high range
% Returns: ao channel number
%
% Condition can be:
% greenLow, greenHigh, blueLow, blueHigh, UVLow, UVhigh
%
% This should be the only function that 'knows' about what led is 
% connected to what ao_channel and which io port controls its high/low
% state.

function channel = erg_io_switchCondition(condition)
    global dio;
    switch(condition)
        case 'blueDontcare'
            channel = 3;
        case 'blueLow' 
            putvalue(dio, [0 1 1]&getvalue(dio));
            channel = 3;
        case 'blueHigh' 
            putvalue(dio, [1 0 0]|getvalue(dio));
            channel = 3;

        case 'greenDontcare'
            channel = 1;
        case 'greenLow' 
            putvalue(dio, [1 1 0]&getvalue(dio));
            channel = 1;
        case 'greenHigh' 
            putvalue(dio, [0 0 1]|getvalue(dio));
            channel = 1;

        case 'UVDontcare'
            channel = 2;
        case 'UVLow' 
            putvalue(dio, [1 0 1]&getvalue(dio));
            channel = 2;
        case 'UVHigh' 
            putvalue(dio, [0 1 0]|getvalue(dio));
            channel = 2;
        otherwise
            disp(['erg_io_switchCondition can not do much with condition:' condition]);
            channel = -1;
    end

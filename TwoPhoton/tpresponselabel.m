function lab = tpresponselabel( channel)
%TPRESPONSELABEL 
%
% 2011, Alexander Heimel

switch numel(channel)
    case 1
       lab = '\Delta F / F';
       if channel>1 
           lab = [lab ' (channel ' num2str(channel) ')'];
       end
    case 2
        lab = '\Delta R / R';
           lab = [lab ' (Ch. ' num2str(channel(1)) '/ Ch.' num2str(channel(2)) ')'];
    otherwise
        lab = 'Response';
end


        

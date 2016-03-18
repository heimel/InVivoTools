function cells = ec_assign_cell_info( cells, record )
%EC_ASSIGN_CELL_INFO assigns info to spiking cells
%
% 2015, Alexander Heimel
%

logmsg('Sorting and naming cells by mean spike amplitude');

if isfield(record,'test')
    test = record.test;
else
    test = record.epoch;
end

channels_new_index = (0:1000)*10+1; % works for up to 1000 channels, and max 10 cells per channel

channels = unique([cells.channel]);
for ch = channels(:)'
    ind = find([cells.channel]==ch);
    for i = ind(:)'
        cells(i).index = [];
        cells(i).name = '';
        cells(i).desc_long = experimentpath(record);
        cells(i).desc_brief = test;
        cells(i).detector_params = [];
        cells(i).trial = test;
        cells(i).mean_amplitude = mean(cells(i).spike_amplitude);
        cells(i).snr = (max(cells(i).wave)-min(cells(i).wave))/mean(cells(i).std);
        if ~isfield(cells,'type') || isempty(cells(i).type)
            cells(i).type = 'mu'; % just call everything mu by default
        end
    end
    
    % sort by  descending spike amplitude
    [~,sind] = sort([cells(ind).mean_amplitude],2,'descend');
    cells(ind) = cells(ind(sind));
   
    for i = ind(:)'
        cells(i).index = channels_new_index(ch); 
        channels_new_index(ch) = channels_new_index(ch) + 1;
        cells(i).name = sprintf('cell_%s_%.3d',...
            subst_specialchars(test),cells(i).index);
    end
end % ch
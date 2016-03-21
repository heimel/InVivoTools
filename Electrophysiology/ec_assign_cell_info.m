function cells = ec_assign_cell_info( cells, record )
%EC_ASSIGN_CELL_INFO assigns info to spiking cells
%
% 2015, Alexander Heimel
%

logmsg('Sorting and naming cells by mean spike amplitude');

channels_new_index = (0:1000)*10+1; % works for up to 1000 channels, and max 10 cells per channel

channels = unique([cells.channel]);
for ch = channels(:)'
    ind = find([cells.channel]==ch);

    
    
    for i = ind(:)'
        cells(i).index = [];
        cells(i).name = '';
        cells(i).desc_long = experimentpath(record);
        if isfield(record,'test')
            cells(i).desc_brief = record.test;
        elseif isfield(record,'epoch')
            cells(i).desc_brief = record.epoch;
        else
            cells(i).desc_brief = '';
        end
        cells(i).detector_params = [];
        if isfield(record,'test')
            cells(i).trial = record.test;
        elseif isfield(record,'epoch')
            cells(i).trial = record.epoch;
        else
            cells(i).trial = '';
        end
        if isfield(cells,'spike_amplitude')
            cells(i).mean_amplitude = mean(cells(i).spike_amplitude);
        else
            cells(i).mean_amplitude = NaN;
        end
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
            subst_specialchars(cells(i).trial),cells(i).index);
    end
end % ch
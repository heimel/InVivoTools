function cells = import_spikes( record, channels2analyze, verbose, allowchanges )
%IMPORT_SPIKES loads spikes specified in electrophysiology testrecord
%
%  CELLS = IMPORT_SPIKES( RECORD, CHANNELS2ANALYZE, VERBOSE=true, allowchanges=true)
%
% 2015-2017, Alexander Heimel
%

if nargin<3 || isempty(verbose)
    verbose = true;
end
if nargin<4 || isempty(allowchanges)
    allowchanges = true;
end

processparams = ecprocessparams(record);

switch lower(record.setup)
    case 'antigua'
        cells = importtdt( record, channels2analyze, allowchanges);
    case 'intan'
        cells = importintan( record, channels2analyze);
    case 'wall-e'
        channels2analyze = 1;
        cells = importaxon(record,true);
    otherwise % spike2 on daneel
        channels2analyze = 1;
        cells = importspike2(record);
end
n_spikes = 0;
for i=1:length(cells)
    n_spikes = n_spikes + length(cells(i).data);
end

if isempty(cells)
    logmsg('Imported no cells.');
    return
else
    logmsg(['Imported ' num2str(length(cells)) ' cells with ' num2str(n_spikes ) ' spikes.']);
end

if ~strcmpi(processparams.spike_sorting_routine, 'Kilosort') %sorting the snippets
    switch processparams.ec_spike_smoothing
        case 'wavelet'
            for c=1:length(cells)
                n_spikes = size(cells(c).spikes,1);
                n_samples = size(cells(c).spikes,2);
                for i=1:n_spikes
                    A = wavelet_decompose(cells(c).spikes(i,:),3,'db4');
                    cells(c).spikes(i,:) = A(1:n_samples,1);
                end
            end
        case 'sgolay'
            for c=1:length(cells)
                if ~isempty(cells(c).spikes)
                    cells(c).spikes = sgolayfilt(double(cells(c).spikes)',3,11)';
                end
            end
    end
    
    % feature extraction
    cells = get_spike_features(cells, record);
    
    switch processparams.spike_sorting_routine
        case 'klustakwik'
            if allowchanges
                cells = sort_with_klustakwik(cells,record);
            else
                logmsg('Klustakwik sorting cannot be done without changing data on disk. Change ALLOWCHANGES option if necessary.');
            end
        case 'wpca'
            cells = sort_with_wpca(cells,record,verbose);
        case {'kilosort',''}
            % don't sort
        otherwise
            logmsg(['Unknown spike sorting routine ' processparams.spike_sorting_routine]);
    end
    
    if processparams.compare_with_klustakwik
        kkcells = sort_with_klustakwik(cells,record);
        if ~isempty(kkcells)
            cells = compare_spike_sortings( cells, kkcells);
        end
    end
else %just get properties
       
    % feature extraction
    cells = get_spike_features(cells, record); 
    
end

logmsg(['After sorting ' num2str(length(cells)) ' cells.']);

cells = ec_assign_cell_info( cells, record ); % sort cells by descending amplitude

if allowchanges
    transfer2cksdirstruct(cells,experimentpath(record,false));
else
    logmsg('Imported cells not saved to experiment file because of ALLOWCHANGES setting.');
end

spikesfile = fullfile(experimentpath(record), '_spikes.mat');

isi = [];
if exist(spikesfile,'file')
    old = load( spikesfile);
    if isfield(old,'isi')
        isi = old.isi;
    end
    if isfield(old,'cells') && ~isempty(old.cells) && ~isempty(cells) && isfield(old.cells,'channel')
        othercells = old.cells(~ismember([old.cells.channel],channels2analyze));
        if ~isempty(othercells)
            try
                othercells = structconvert( othercells,cells);
            catch
                othercells = [];
            end
            allcells = [cells othercells];
            [~,ind] = sort([allcells.channel]);
            allcells = allcells(ind);
        end
    end
end

if processparams.compute_isi
    isi = get_spike_interval( cells, isi ); %#ok<NASGU>
else
    isi = []; %#ok<NASGU>
end

if allowchanges
    if exist('allcells','var')
        orgcells = cells;
        cells = allcells; %#ok<NASGU>
        save(spikesfile,'cells','isi','-v7');
        cells = orgcells;
    else
        save(spikesfile,'cells','isi','-v7');
    end
end

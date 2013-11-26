function cells = import_klustakwik( record, orgcells )
%IMPORT_KLUSTAKWIK import klustakwik clu file
%
% 2013, Alexander Heimel
%

cells = [];

if nargin<1
    record = [];
end

if isempty(record)
    datapath = pwd;
else
    datapath = ecdatapath(record);
end

filenamec = fullfile(datapath,record.test,[ 'klustakwik.clu.1']);
fidc = fopen(filenamec,'r');
if fidc==-1
    disp(['IMPORT_KLUSTAKWIK: Cannot open ' filenamec ' for reading']);
    return
else
    disp(['IMPORT_KLUSTAKWIK: Writing spike features to ' filenamec]);
end


filenamef = fullfile(datapath,record.test,[ 'klustakwik.fet.1']);
fidf = fopen(filenamef,'r');
if fidf==-1
    disp(['IMPORT_KLUSTAKWIK: Cannot open ' filenamef ' for reading']);
    return
else
    disp(['IMPORT_KLUSTAKWIK: Writing spike features to ' filenamef]);
end

n_fet = str2double(fgetl(fidf)); % number of features

filenamet = fullfile(datapath,record.test,[ 'klustakwik.tim.1']);
fidt = fopen(filenamet,'r');
if fidt==-1
    disp(['IMPORT_KLUSTAKWIK: Cannot open ' filenamet ' for reading']);
    return
end

fgetl(fidc); % extra line????, but necessary


cells = [];%cells(1).data = [];
while(~feof(fidt))
    if feof(fidc)
        disp(['IMPORT_KLUSTAKWIK: Premature end to ' filenamec ]);
        return
    end
    c = str2double( fgets(fidc));
    if c>length(cells)
        cells(c).data = [];
        cells(c).spike_amplitude = [];
        cells(c).spike_trough2peak_time = [];
        cells(c).spike_peak_trough_ratio = [];
        cells(c).spike_prepeak_trough_ratio = [];
        cells(c).spike_lateslope = [];
    end
    cells(c).data(end+1,1) = str2double( fgets(fidt));
%     time(c) = str2double( fgets(fidt));
%     clss(c) = str2double( fgets(fidt));

    cells(c).spike_amplitude(end+1,1) = fscanf(fidf,'%d',1); 
    cells(c).spike_trough2peak_time(end+1,1) = fscanf(fidf,'%f',1); 
    cells(c).spike_peak_trough_ratio(end+1,1) = fscanf(fidf,'%f',1); 
    cells(c).spike_prepeak_trough_ratio(end+1,1) = fscanf(fidf,'%f',1); 
    if n_fet>4
        cells(c).spike_lateslope(end+1,1) = fscanf(fidf,'%d',1);
    end
end
fclose(fidt);
fclose(fidc);
fclose(fidf);

% clu = load('klustakwik.clu.1','-ascii');
% clu=clu(2:end);
% ftc = load('klustakwik.ftc.1','-ascii');
% cls='kbgry';
% figure
% hold on
% for c=1:length(cells)
%     ind = find(clu==c);
%     plot(ftc(ind,1),ftc(ind,5),['.' cls(c)])
% end
% 
% 
% 
% figure
% hold on
% for c=1:length(cells)
%     plot(cells(c).spike_lateslope,cells(c).spike_amplitude,['.' cls(c)])
% end

try
    cksds=cksdirstruct(ecdatapath(record));
catch
    disp(['IMPORTSPIKE2: Could not create/open cksdirstruct ' path])
    return
end

intervals = [];
sample_interval = [];
desc_long = '';
desc_brief = '';
detector_params = [];
trial = '';

if ~isempty( orgcells )
    intervals = orgcells(1).intervals;
    sample_interval = orgcells(1).sample_interval;
    desc_long = orgcells(1).desc_long;
    desc_brief = orgcells(1).desc_brief;
    trial = orgcells(1).trial;
end


% load acquisitionfile for electrode name
% to get samplerate acqParams_out should be used instead of _in
ff=fullfile(getpathname(cksds),trial,'acqParams_in');
f=fopen(ff,'r');
if f==-1
    disp(['Error: could not open ' ff ]);
    return;
end
fclose(f);  % just to get proper error
acqinfo=loadStructArray(ff);


unitchannelname = 'Spikes';

cellnamedel=sprintf('cell_%s_%s_%.4d_*',acqinfo(1).name,unitchannelname,acqinfo(1).ref);
deleteexpvar(cksds,cellnamedel); % delete all old representations




[px,expf] = getexperimentfile(cksds,1);
delete(px);
[px,expf] = getexperimentfile(cksds,1);
for cl=1:length(cells)
    cells(cl).name=sprintf('cell_%s_%s_%.4d_%.3d',...
        acqinfo(1).name,unitchannelname,acqinfo(1).ref,cl);

    cells(cl).index = cl;
   cells(cl).intervals = intervals;
   cells(cl).sample_interval = sample_interval;
   cells(cl).desc_long = desc_long;
   cells(cl).desc_brief = desc_brief;
   cells(cl).detector_params = detector_params;
   cells(cl).trial = trial;
   cells(cl).wave = zeros(1,32);
   cells(cl).std = zeros(1,32);
   cells(cl).snr = NaN;

    acell=cells(cl);
    thecell=cksmultipleunit(acell.intervals,acell.desc_long,...
        acell.desc_brief,acell.data,acell.detector_params);
    saveexpvar(cksds,thecell,acell.name,1);
end





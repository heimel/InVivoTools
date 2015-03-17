%COMPUTING SNR STATISTICS FOR AMENDMENT
% awake-trained: 8 animals
% agatha (seizures and died)
% beatrice
% cornelia (good recordings)
% danique (seizures and died)
% edgar (euthanized because pedestal came off)
% filemon
% gerard (found dead in cage)
% henry
% 
% awake-anesthesized: 6 animals
% ignace
% jules
% kaspar (died before recording)
% louis
% monet
% ovide
% 
% 
% data SNR from Matt
% awake-trained 8 sessions
% awake-anesthesized 6 sessions


h_awtr = openfig('SNR_awaketrained.fig');
c =get(h_awtr,'children');
c = get(c,'children');
y_awtr = get(c,'ydata');
nanmean(y_awtr)
nanstd(y_awtr)


h_awan = openfig('SNR_awakeanesth.fig');
c =get(h_awan,'children');
c = get(c,'children');
y_awan = get(c,'ydata');
nanmean(y_awan)
nanstd(y_awan)


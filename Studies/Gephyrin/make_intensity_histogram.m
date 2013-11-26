reanalyze = true;

csad_file = fullfile(tempdir,'csad_stack.mat');
if reanalyze || ~exist(csad_file,'file')
    analyse_puncta_db('md','spine','all','stack_hash',csad_file);
end
d.csad = load(csad_file);

intensity_present = [];
intensity_absent = [];
n_stacks = length(d.csad.intensity_green)
disp('MAKE_INTENSITY_HISTOGRAM: Shifting puncta intensity to positive');
for s = 1:n_stacks
    for t = 7
        m = min(d.csad.intensity_green{s}(:,t))-0.001;
        intensity_present = [intensity_present; -m+d.csad.intensity_green{s}(logical(d.csad.present{s}(:,t)),t) ];
        intensity_absent = [intensity_absent; -m+d.csad.intensity_green{s}(~logical(d.csad.present{s}(:,t)),t) ];
    end
end
%intensity = intensity(intensity>0);


fig = figure('Name','Intensity histogram');
[n_present,x] = hist( log10(intensity_present),40 )
[n_absent,x] = hist( log10(intensity_absent),x )
%bar(x,[n_present; n_absent]',1,'stacked');
bar(x,[n_present; n_absent]',2);
colormap([0.2 0.2 0.2;0.7 0.7 0.7])
set(gca,'Xtick',-3:2)
set(gca,'Xticklabel',{'<0.001','0.01','0.1','1','10','100'})
xlabel('Normalized puncta intensity');
ylabel('Count');
legend('Present','Absent');
legend boxoff
box off

name = 'intensity_histogram';
figpath = fullfile(getdesktopfolder,'Figures');
save_figure([name '.png'],figpath,fig);
saveas(fig,fullfile(figpath,[name '.ai']),'ai');
warning('off','MATLAB:print:Illustrator:DeprecatedDevice');

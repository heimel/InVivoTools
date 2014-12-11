clear 
%control
x{1} = [0.36372 0.1777 -0.02021 0.24472 0.32469 0.01156 0.32203 0.12924 0.16442 0.29202 0.08873 0.46616 0.09137 0.10049 0.20739 0.10849 0.16215 0.30739 0.1224 0.0851];
y{1} = [0.58197 -0.07322 0.05188 0.10717 0.2688 0.03906 0.24282 0.04464 0.06655 0.26579 -0.0354 0.45212 -0.01694 0.01151 0.26038 0.13396 0.17771 0.32353 0.12842 0.05911];

% with extra original point (first point taken from figure) 2014-10-20
x{1} = [-0.09 0.36372 0.1777 -0.02021 0.24472 0.32469 0.01156 0.32203 0.12924 0.16442 0.29202 0.08873 0.46616 0.09137 0.10049 0.20739 0.10849 0.16215 0.30739 0.1224 0.0851];
y{1} = [0.24 0.58197 -0.07322 0.05188 0.10717 0.2688 0.03906 0.24282 0.04464 0.06655 0.26579 -0.0354 0.45212 -0.01694 0.01151 0.26038 0.13396 0.17771 0.32353 0.12842 0.05911];


% gotten from figure
x{3} = [-0.0213302752293576 0.00963302752293588 0.0860091743119268 0.088073394495413 0.0963302752293579 0.0818807339449542 0.127293577981651 0.174770642201835 0.162385321100918 0.123165137614679 0.106651376146789 0.160321100917431 0.244954128440367 0.205733944954128 0.29243119266055 0.32545871559633 0.319266055045872 0.304816513761468 0.463761467889908 0.35848623853211];
y{3} = [0.0488372093023257 0.0418604651162792 -0.0395348837209301 -0.0186046511627907 0.00930232558139538 0.0627906976744187 0.044186046511628 -0.0744186046511627 0.0674418604651164 0.132558139534884 0.134883720930233 0.17906976744186 0.109302325581395 0.262790697674419 0.267441860465116 0.267441860465116 0.241860465116279 0.323255813953488 0.455813953488372 0.583720930232558];

%MD

x{2} = [0.17094 -0.01119 0.02689 0.07887 0.13756 0.15194 0.03749 0.07351 0.02444 -0.01483 -0.06451 -0.24813 0.09252 -0.25214 -0.04635 0.07025 -0.11523];
y{2} = [0.29712 0.09521 -0.06872 -0.01827 0.13475 0.33887 0.10124 0.04736 0.03072 0.19121 0.27685 0.0252 0.21433 0.26779 0.16783 -0.15543 0.09352];


% gotten from figure
x{4} = [-0.250980392156862 -0.252941176470588 -0.0666666666666666 -0.117647058823529 -0.0470588235294114 -0.0156862745098039 0.0960784313725492 0.150980392156863 0.170588235294118 0.135294117647059 0.0392156862745101 -0.0117647058823525 0.0215686274509807 0.0725490196078433 0.0784313725490198 0.0274509803921572 0.0705882352941177];
y{4} = [0.0260387811634351 0.269806094182826 0.278670360110803 0.08808864265928 0.167867036011081 0.190027700831025 0.216620498614959 0.338504155124654 0.294182825484765 0.136842105263158 0.0969529085872577 0.0925207756232688 0.0304709141274239 0.0481994459833796 -0.0182825484764542 -0.0670360110803321 -0.160110803324099];

disp('WHIT_TAO_DATA: Control');

graph(y{1},x{1},'prefax',[-0.3 0.7 -0.3 0.7],'color',[0 1 0],'xlab','ODI excitation','ylab','ODI inhibition','save_as','whit_odi_ctl.png','extra_options','fit,linear','extra_code','xyline;axis square');
graph((x{1}-y{1})/sqrt(2),[],'style','hist','bins',-0.4:0.05:0.4,'xlab','\DeltaODI','ylab','Number','save_as','whit_odi_ctl_hist.png');


disp('WHIT_TAO_DATA: MD');
graph(y{2},x{2},'prefax',[-0.3 0.7 -0.3 0.7],'color',[0 0.4 0],'xlab','ODI excitation','ylab','ODI inhibition','save_as','whit_odi_md.png','extra_options','fit,linear','extra_code','xyline;axis square');

graph((x{2}-y{2})/sqrt(2),[],'style','hist','bins',-0.4:0.05:0.4,'xlab','\DeltaODI','ylab','Number','save_as','whit_odi_md_hist.png');

% http://www.fon.hum.uva.nl/Service/Statistics/Two_Correlations.html
disp('WHIT_TAO_DATA: Control vs MD correlations are significantly different: p = 0.0249 (from http://www.fon.hum.uva.nl/Service/Statistics/Two_Correlations.html,  Fisher r-to-z transformation) ');

disp('WHIT_TAO_DATA: Absolute ODI differences');
absdiff{1} = abs( y{1}-x{1});


absdiff{2} = abs( y{2}-x{2});
graph(absdiff,[],'xticklabels',{'Ctl','MD'},'showpoints',0,'color',{[0 1 0],[0 0.4 0]},'ylab','Absolute ODI difference','save_as','whit_odi_abs_diff.png','test','ranksum');
disp(['Ctl abs delta ODI = ' num2str(mean(absdiff{1})) ' +- ' num2str(sem(absdiff{1})) ' (Mean +/- SEM)']);
disp(['MD abs delta ODI  = ' num2str(mean(absdiff{2})) ' +- ' num2str(sem(absdiff{2})) ' (Mean +/- SEM)']);

logmsg('Sqrt transform of abs data');
[h,p]=swtest(sqrt(absdiff{1}));
logmsg(['swtest control p = ' num2str(p)]);
[h,p]=swtest(sqrt(absdiff{2}));
logmsg(['swtest control p = ' num2str(p)]);
[h,p]=ttest2(sqrt(absdiff{1}),sqrt(absdiff{2}));
logmsg(['ttest of sqrt transformed data p = ' num2str(p)]);

x = [absdiff{1}';absdiff{2}'];
g = [ones(length(absdiff{1}),1);2*ones(length(absdiff{2}),1)];
p =vartestn(x,g);
disp(['Groups have equal variances: ' num2str(p,2)]);
p = welchanova([x g],[],'off');
logmsg(['Welchanova p = ' num2str(p,2)]);

fun = @sqrt; %id;%@sqrt; %id;% @sqrt; %@log;
logmsg(['Using transform: ' func2str(fun)]);
absdiff = cellfun(fun,absdiff,'UniformOutput',false);
%graph(absdiff,[],'xticklabels',{'Ctl','MD'},'showpoints',0,'color',{[0 1 0],[0 0.4 0]},'ylab','Absolute ODI difference','save_as','whit_odi_abs_diff.png','test','ranksum');
graph(absdiff,[],'xticklabels',{'Ctl','MD'},'showpoints',0,'color',{[0 1 0],[0 0.4 0]},'ylab','Absolute ODI difference','save_as','whit_odi_abs_diff.png');

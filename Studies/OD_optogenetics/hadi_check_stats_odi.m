function data=hadi_check_stats
% 
% tests for statistics, 2014-12-02
% Alexander Heimel

data = getdata;
groups={'pv ctl','pv 1 md','pv sh','pv 7 md'};

x = [];
g = [];
fun =  @id;%@sqrt; %@log;

data = cellfun(fun,data,'UniformOutput',false);

%data = {data{1},data{3},data{4},data{5}}
for i=1:length(data)
    x = [x;data{i}];
    g = [g;i*ones(size(data{i}))];
end
[p,anovatab,stats] = anova1(x,g);
disp(['ANOVA ' num2str(p)]);

[p,h,comp] = myanova(x,g)
disp(['ANOVA ' num2str(p)]);
[p,h,comp] = kruskalwallis(x,g)
disp(['Kruskal-Wallis' num2str(p)]);

for i=1:length(data)

   [h,p]=swtest(data{i});
   pbs=[];
   for j=1:100
       [hbs,pbs(j)]=swtest(bootstrp(100,@mean,data{i}));
   end
   disp(['Group ' groups{i} ': swtest p = ' num2str(p,2)...
       ', n = ' num2str(length(data{i})) ...
       ', bootstrap mean swtest p=' ...
       num2str(mean(pbs),2)]);
end
for i=1:length(data)

   disp(['Group ' groups{i} ':  ' num2str(mean(data{i}),2) ' +/- ' num2str(std(data{i}),2) ' mean +/- std']);
end


p =vartestn(x,g);
disp(['Groups have equal variances: ' num2str(p,2)]);


welchanova([x g])



function x = id(x)


function x = getdata

x{1}=[0.439378
0.537146
0.474506
1
0.695427
0.833041
1
0.821815
0.525486
0.428703
0.507282
0.049839
0.000472
0.038065
-0.08173
0.383083
0.470451
0.438231
0.668235
0.63634
0.730291
0.533963
0.924647
0.665713
0.145452
0.350179
0.942484
0.729973
0.619076
0.595195
0.846293
0.891426
0.119467
0.282952
0.261364
0.366512
0.98619
0.08921
-0.09349
0.93401
0.906973
1
];

x{2}=[0.191873
0.236343
0.275735
0.196789
0.671483
0.615539
0.499856
0.322031
-0.36228
0.746055
0.786496
0.657092
0.223992
0.624671
];

x{3}=[1
0.982222
0.934478
0.94746
0.952246
0.446482
-0.00598
0.065447
0.21214
-0.11071
0.402126
1
0.76705
0.599308
0.888591
0.952531
0.252232
-0.07492
0.23422
0.254193
0.369779
0.142117
0.051931
1
-0.74698
0.18298
-0.78805
-0.06546
-0.44051
-0.83007
-0.79159
-0.67411
-0.64208
0.987678
-1
-0.39706
-0.26637
-0.37621
-0.40376
-0.58897
-1
];

x{4}=[0.336423
0.812076
0.73287
-0.52679
-0.64997
-0.16997
-0.22026
0.194289
0.102915
0.877417
0.725343
0.53143
0.900257
0.802457
1
0.337136
0.609848
0.128855
-0.09322
-0.66045
-0.18783
0.076677
-0.45472
-0.58625
-0.36723
-0.11567
-0.2085
-0.07085
-0.48796
0.676434
0.608453
0.200871
0.122177
0.144281
-0.32953
0.16509
-0.42676
0.356711
0.485675
0.185138
0.349304
0.910419
];

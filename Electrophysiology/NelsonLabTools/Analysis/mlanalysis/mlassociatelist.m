function assoclist=lgnassociatelist(testname)

%  mlassociatelist - list of associates for lgn data analysis
%
%  asclist = mlassociatelist(testname), cell list

switch(testname),
	case 'TF Test',
		assoclist = {'TF Response Curve F1','Max drifting grating firing',...
				'TF Pref','TF Phase'};
	case 'Motion test',
		assoclist = {'Max RF','Motion Dir Response Curve'};
	case 'Rotation test',
		assoclist = {'Max rotation','Rotation Response Curve'};
	case 'Expand test',
		assoclist = {'Max expand','Expand Response Curve'};
	case 'all',
		assoclist = {};
		testlist = {'TF Test','Motion test','Rotation test','Expand test'};
		for i=1:length(testlist),
			assoclist = cat(2,assoclist,lgnassociatelist(testlist{i}));
		end;
end;


function newdb=reanalyse_ectestdb( db )
%REANALYSE_ECTESTDB 
%
% NEWDB = REANALYSE_ECTESTDB( DB )
%
% 2007 Alexander Heimel
%

newdb=db;

tic
for i=1:length(db)
  disp(['Analyzing record ' num2str(i) ' of ' num2str(length(db))]);
  newdb(i)=analyse_ectestrecord( db(i));
  elapsed=toc;
  togo=(length(db)-i)*(elapsed/i); % s
  disp([' estimated time to go: ' num2str(floor(togo/60)) ':' num2str(fix(rem(togo,60)),'%02d') ]);
end


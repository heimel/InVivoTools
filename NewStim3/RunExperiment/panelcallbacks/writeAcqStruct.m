function writeAcqStruct(fname, inDat)
%WRITEACQSTRUCT
%
% 200X, Steve Van Hooser
% 2019, Alexander Heimel

[fid,msg] = fopen(fname,'wt');
if fid==-1,
    logmsg(msg);
    return
end

fn = fieldnames(inDat(1));
s = '';
for i=1:length(fn),
    s = [ s char(9) fn{i}]; %#ok<AGROW>
end;
s = s(2:end);
fprintf(fid,'%s\n',s);

for i=1:length(inDat),
    t = char(9);
    s=[inDat(i).name t inDat(i).type t inDat(i).fname t ...
        num2str(inDat(i).samp_dt,15) t int2str(inDat(i).reps) t ...
        int2str(inDat(i).ref) t int2str(inDat(i).ECGain)];
    fprintf(fid,'%s\n',s);
end
fclose(fid);

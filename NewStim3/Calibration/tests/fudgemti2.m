function mti3 = fudgemti2(MTI2,start,fudgefactor);

%fudgefactor = 0.9933;

for i=1:length(MTI2),
  MTI2{i}.startStopTimes=start+(MTI2{i}.startStopTimes-start)*fudgefactor;
  MTI2{i}.frameTimes=start+(MTI2{i}.frameTimes-start)*fudgefactor;
end;

mti3 = MTI2;

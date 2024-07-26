
l = loadStructArray('acqParams_out');
R = l(1).reps;

for r=1:R,

ns = sprintf('%.3d',r);
eval(['!cp r' ns '_tet1_c01 2r' ns '_tet2_c01']);  % 1   =>  5
eval(['!cp r' ns '_tet1_c02 2r' ns '_tet2_c03']);  % 2   => 7
eval(['!cp r' ns '_tet1_c03 2r' ns '_tet1_c03']);  % 3   => 3
eval(['!cp r' ns '_tet1_c04 2r' ns '_tet3_c03']);  % 4   => 11 
eval(['!cp r' ns '_tet2_c01 2r' ns '_tet3_c01']);  % 5   => 9
eval(['!cp r' ns '_tet2_c02 2r' ns '_tet1_c01']);  % 6   => 1
eval(['!cp r' ns '_tet2_c03 2r' ns '_tet4_c01']);  % 7   => 13
eval(['!cp r' ns '_tet2_c04 2r' ns '_tet4_c03']);  % 8   => 15
eval(['!cp r' ns '_tet3_c01 2r' ns '_tet4_c04']);  % 9   => 16 
eval(['!cp r' ns '_tet3_c02 2r' ns '_tet4_c02']);  % 10  =>  14
eval(['!cp r' ns '_tet3_c03 2r' ns '_tet1_c02']);  % 11  =>  2
eval(['!cp r' ns '_tet3_c04 2r' ns '_tet3_c02']);  % 12  =>  10
eval(['!cp r' ns '_tet4_c01 2r' ns '_tet3_c04']);  % 13  =>  12
eval(['!cp r' ns '_tet4_c02 2r' ns '_tet1_c04']);  % 14  =>  4
eval(['!cp r' ns '_tet4_c03 2r' ns '_tet2_c04']);  % 15  =>  8
eval(['!cp r' ns '_tet4_c04 2r' ns '_tet2_c02']);  % 16  =>  6

if 1,
eval(['!cp 2r' ns '_tet1_c01 r' ns '_tet1_c01']);  % 1
eval(['!cp 2r' ns '_tet1_c02 r' ns '_tet1_c02']);  % 2
eval(['!cp 2r' ns '_tet1_c03 r' ns '_tet1_c03']);  % 3
eval(['!cp 2r' ns '_tet1_c04 r' ns '_tet1_c04']);  % 4
eval(['!cp 2r' ns '_tet2_c01 r' ns '_tet2_c01']);  % 5
eval(['!cp 2r' ns '_tet2_c02 r' ns '_tet2_c02']);  % 6
eval(['!cp 2r' ns '_tet2_c03 r' ns '_tet2_c03']);  % 7 
eval(['!cp 2r' ns '_tet2_c04 r' ns '_tet2_c04']);  % 8 
eval(['!cp 2r' ns '_tet3_c01 r' ns '_tet3_c01']);  % 9
eval(['!cp 2r' ns '_tet3_c02 r' ns '_tet3_c02']);  % 10
eval(['!cp 2r' ns '_tet3_c03 r' ns '_tet3_c03']);  % 11 
eval(['!cp 2r' ns '_tet3_c04 r' ns '_tet3_c04']);  % 12 
eval(['!cp 2r' ns '_tet4_c01 r' ns '_tet4_c01']);  % 13
eval(['!cp 2r' ns '_tet4_c02 r' ns '_tet4_c02']);  % 14
eval(['!cp 2r' ns '_tet4_c03 r' ns '_tet4_c03']);  % 15
eval(['!cp 2r' ns '_tet4_c04 r' ns '_tet4_c04']);  % 16
end;  % if

! rm 2r*;

end; % for

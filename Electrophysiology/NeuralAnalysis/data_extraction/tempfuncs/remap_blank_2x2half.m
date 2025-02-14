
l = loadStructArray('acqParams_out');
R = l(1).reps;

for r=1:R,

ns = sprintf('%.3d',r);
eval(['!cp r' ns '_tet1_c01 2r' ns '_tet3_c01']);  % 1   =>  9
eval(['!cp r' ns '_tet1_c02 2r' ns '_tet4_c01']);  % 2   => 13
eval(['!cp r' ns '_tet1_c03 2r' ns '_tet4_c04']);  % 3   => 16
eval(['!cp r' ns '_tet1_c04 2r' ns '_tet3_c03']);  % 4   => 11 
eval(['!cp r' ns '_tet2_c01 2r' ns '_tet4_c03']);  % 5   => 15
eval(['!cp r' ns '_tet2_c02 2r' ns '_tet3_c04']);  % 6   => 12
eval(['!cp r' ns '_tet2_c03 2r' ns '_tet4_c02']);  % 7   => 14
eval(['!cp r' ns '_tet2_c04 2r' ns '_tet3_c02']);  % 8   => 10

if 1,
eval(['!cp 2r' ns '_tet3_c01 r' ns '_tet1_c01']);  % 9
eval(['!cp 2r' ns '_tet3_c02 r' ns '_tet1_c02']);  % 10
eval(['!cp 2r' ns '_tet3_c03 r' ns '_tet1_c03']);  % 11 
eval(['!cp 2r' ns '_tet3_c04 r' ns '_tet1_c04']);  % 12 
eval(['!cp 2r' ns '_tet4_c01 r' ns '_tet2_c01']);  % 13
eval(['!cp 2r' ns '_tet4_c02 r' ns '_tet2_c02']);  % 14
eval(['!cp 2r' ns '_tet4_c03 r' ns '_tet2_c03']);  % 15
eval(['!cp 2r' ns '_tet4_c04 r' ns '_tet2_c04']);  % 16
end;  % if

! rm 2r*;

end; % for

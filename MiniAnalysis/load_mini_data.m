function [control,transgenic,description]=load_mini_data(dataset)

if nargin<1
    dataset=[];
end

if isempty(dataset)
    disp('unspecified dataset.');
    return
    %dataset='unfiltered_data';
end

hostname = host;

switch hostname
    case 'nin233' % Daan's pc
        basedir = 'C:\EphysData\Slice\Minis';
    case 'olympus-0603301' % FV pc
        basedir = 'P:\Common\InVivo\Electrophys\Slice\Minis';
    case {'giskard','eto'}
        basedir='/home/data/Slice/Minis';
    otherwise
        basedir = '/smb/orange.nin.knaw.nl/MVP/Common/InVivo/Electrophys/Slice/Minis';
end

control={};
transgenic={};

nin = true;
vu = false;
nin12 = true;

bcat_hadi = true;
bcat_paul = true;

switch dataset
    case 'Gephyrin_aged'
        cd(fullfile(basedir,dataset));
        transgenic{end+1}=dlmread('2012_01_10_Cell2_Merge.csv',char(9));
        transgenic{end+1}=dlmread('2012_01_10_Cell41_Merged.csv',char(9));
        transgenic{end+1}=dlmread('2012_01_11_cell21_Merged.csv',char(9));
        transgenic{end+1}=dlmread('2012_01_11_cell31_Merged.csv',char(9));
        transgenic{end+1}=dlmread('2012_01_11_cell41_Merged.csv',char(9));
        transgenic{end+1}=dlmread('2012_01_11_cell51_Merged.csv',char(9));
        transgenic{end+1}=dlmread('2012_01_17_cell1_1_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_10_Cell61_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_12_cell1_1_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_12_cell1_2_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_12_cell3_1_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_12_cell3_2_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_13_cell2_1_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_17_cell2_1_Merged.csv',char(9));
        control{end+1}=dlmread('2012_01_17_cell3_1_Merged.csv',char(9));
    case 'Gephyrin'
        cd(fullfile(basedir,dataset));
        transgenic{end+1}=dlmread('1April2011M1C1.ASC',char(9));
        transgenic{end+1}=dlmread('1April2011M2C1.ASC',char(9));
        transgenic{end+1}=dlmread('1April2011M2C2.ASC',char(9));
        control{end+1}=dlmread('10January2011M1C1.ASC',char(9));
        control{end+1}=dlmread('11March2011M1C3.ASC',char(9));
        control{end+1}=dlmread('11March2011M2C1.ASC',char(9));
        control{end+1}=dlmread('11March2011M2C2.ASC',char(9));
        control{end+1}=dlmread('15March2011M1C1.ASC',char(9));
        control{end+1}=dlmread('15March2011M1C2.ASC',char(9));
        control{end+1}=dlmread('21January2011M1C3.ASC',char(9));
        control{end+1}=dlmread('21June2011M1C1.ASC',char(9));
        control{end+1}=dlmread('21June2011M1C2.ASC',char(9));
        control{end+1}=dlmread('22June2011M1C1.ASC',char(9));
        control{end+1}=dlmread('22June2011M1C2.ASC',char(9));
        transgenic{end+1}=dlmread('22March2011M1C1.ASC',char(9));
        transgenic{end+1}=dlmread('29June2011M1C2.ASC',char(9));
        transgenic{end+1}=dlmread('30June2011M1C2.ASC',char(9));
        transgenic{end+1}=dlmread('31March2011M1C2.ASC',char(9));
        transgenic{end+1}=dlmread('31March2011M1C3.ASC',char(9));
        
    case 'B-Cat/Exc';
        
        if bcat_hadi
            cd(fullfile(basedir,dataset));
            transgenic{end+1}=dlmread('bcat_ex_ko_20070618_19520cell1.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20070618_19520cell2.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20070618_19520cell3.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20070619_19593cell1.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20070619_19593cell2.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20070619_19593cell3.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20071219_21486cell1.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20071227_21789cell2.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20071227_21789cell3.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20080102_21791cell1.csv',';');% genotype checked 23-12-10
            transgenic{end+1}=dlmread('bcat_ex_ko_20080104_21792.csv',';');% genotype checked 23-12-10
            
            control{end+1}=dlmread('bcat_ex_ctl_20070617_19521.csv',';');% genotype checked 23-12-10
            control{end+1}=dlmread('bcat_ex_ctl_20070628_19597.csv',';');% genotype checked 23-12-10
            cd(fullfile(basedir,'TrkB/Exc'));
            control{end+1}=dlmread('ctl_20Mar.csv',';');
            control{end+1}=dlmread('ctl_13Apr18398cel1.csv',';');
            control{end+1}=dlmread('ctl_17Apr18399cel1.csv',';');
            control{end+1}=dlmread('ctl_17Apr18399cel2.csv',';'); % never fired spikes
            control{end+1}=dlmread('ctl_17Apr18399cel3.csv',';');
            control{end+1}=dlmread('ctl_21Apr18282cel1.csv',';');
            control{end+1}=dlmread('ctl_21Apr18282cel2.csv',';');
            control{end+1}=dlmread('ctl_21Apr18282cel3.csv',';');
            control{end+1}=dlmread('ctl_11May18413cel3.csv',';');
        end
        if bcat_paul
            
            
            
            cd(fullfile(basedir,dataset,'Paul'));
            % remove ',' at thousand position, in e.g. 13,202.001
            if 1
                d = dir('*ASC');
                for i = 1:length(d)
                    command = [ 'sed s/,//g "' d(i).name '" > "Correct/' d(i).name '"'];
                    system(command)
                end
                
            end
            cd(fullfile(basedir,dataset,'Paul/Correct'));
            
            transgenic{end+1} = dlmread('24_Jan_12_cell 1.ASC',char(9)); % t
            transgenic{end+1} = dlmread('24_Jan_12_cell 2.ASC',char(9)); % t
            transgenic{end+1} = dlmread('6_Feb_12_cell2.ASC',char(9));   % t
            transgenic{end+1} = dlmread('8_Feb_12_cell1.ASC',char(9));   % t
            transgenic{end+1} = dlmread('9_Feb_12_cell2.ASC',char(9));   % t
            transgenic{end+1} = dlmread('9_Feb_12_cell 4.ASC',char(9));  % t
            transgenic{end+1} = dlmread('17_Feb_12_cell 5.ASC',char(9)); % t
            transgenic{end+1} = dlmread('17_Feb_12_cell 2.ASC',char(9)); % t
            transgenic{end+1} = dlmread('17_Feb_12_cell 3.ASC',char(9)); % t
            transgenic{end+1} = dlmread('17_Feb_12_cell 4.ASC',char(9)); % t
            transgenic{end+1} = dlmread('21Mar12cell 2.ASC',char(9));    % t
            transgenic{end+1} = dlmread('28Mar12_cell 2.ASC',char(9));   % t
            transgenic{end+1} = dlmread('28_Mar12_cell 1.ASC',char(9));  % t
            transgenic{end+1} = dlmread('30_Mar_12_cell 1.ASC',char(9)); % t
            transgenic{end+1} = dlmread('30_Mar_12_cell 2.ASC',char(9)); % t
            transgenic{end+1} = dlmread('3_Apr_12_cell1.ASC',char(9));   % t
            transgenic{end+1} = dlmread('3_Apr_12_cell2.ASC',char(9));   % t

            control{end+1} = dlmread('15_Feb_12_Cell 1.ASC',char(9)); % c
            control{end+1} = dlmread('15_Feb_12_Cell2.ASC',char(9));  % c 
            control{end+1} = dlmread('15_Feb_12_Cell 3.ASC',char(9)); % c
            control{end+1} = dlmread('3_Feb_12_cell 2.ASC',char(9));  % c
            control{end+1} = dlmread('3_Feb_12_cell4.ASC',char(9));   % c

        end
        
        
    case 'TrkB_Mosaic/Inh'
        cd(fullfile(basedir,dataset));
        transgenic{end+1}=dlmread('tlt_20110308_31460_1.csv',';');
        transgenic{end+1}=dlmread('tlt_20110421_32035_1.csv',';');
        transgenic{end+1}=dlmread('tlt_20110427_32037_1.csv',';');
        transgenic{end+1}=dlmread('tlt_20110504_32040.csv',';');
        control{end+1}=dlmread('tlg_20110413_32561_1.csv',';');
        control{end+1}=dlmread('tlg_20110414_33046_3.csv',';');
        control{end+1}=dlmread('tlg_20110428_33047_1.csv',';');
        control{end+1}=dlmread('tlg_20110503_33048_1.csv',';');
        control{end+1}=dlmread('tlg_20110503_33048_2.csv',';');
        control{end+1}=dlmread('tlg_20110505_33049_2s.csv',';');
        control{end+1}=dlmread('tlg_20110506_33050_2.csv',';');
        control{end+1}=dlmread('tlg_20110601_33243_1.csv',';');
        control{end+1}=dlmread('tlg_20110615.csv',';');        

        cd(fullfile(basedir,dataset,'Rogier'));
        transgenic{end+1}=dlmread('d131213_cell1_0002_0003_converted.ASC','\t');
        transgenic{end+1}=dlmread('d131213_cell3_0001_converted.ASC','\t');
        transgenic{end+1}=dlmread('d131213_cell5_0002_converted.ASC','\t');

        
    case 'TrkB/Inh'
        cd(fullfile(basedir,dataset));

        if vu
        % Hadi: 27Aprcel1 noise is 50% more than others, so frequency is overestimate
        control{end+1}=dlmread('ctl_27Apr18796cel1.csv',';');
        control{end+1}=dlmread('ctl_27Apr18796cel3.csv',';');
        % Hadi: 27Aprcel3 is record 6hs after cutting, doubt over quality of slice
        % Alex: indeed all measures are very different from other cells
        % not using
        %control{end+1}=dlmread('ctl_27Apr18796cel4.csv',';');
        
        control{end+1}=dlmread('ctl_3May17895cel1.csv',';');
        
        % Alex: 3Maycel3 removed very unstable first bit of this cell
        control{end+1}=dlmread('ctl_3May17895cel3.csv',';');
        control{end}=control{end}(find(control{end}(:,2)>800000,1):end,:);
        
        control{end+1}=dlmread('ctl_9May18411cel1.csv',';');
        end
        
        if nin
        % new cells done at NIN?
        control{end+1}=dlmread('Control18970 inhib.csv',';');
        
        % new cells done at NIN 2010
      
        % control{end+1}=dlmread('ctl_29917cell6n.csv',';');
        control{end+1}=dlmread('ctl_29918cell4n.csv',';');
        control{end+1}=dlmread('ctl_29920cell3n.csv',';');
        
        % NIN 2011
        control{end+1}=dlmread('Extra/ctl_20110106_31168.csv',';');
        control{end+1}=dlmread('Extra/ctl_20110107_31173.csv',';');
        control{end+1}=dlmread('Extra/ctl_20110406_32700.csv',';');
        
        end
        


        if nin12
            control{end+1}=dlmread('Apr2012/02Dec33324Cell3.csv',',');
            control{end+1}=dlmread('Apr2012/06Jan35022Cell11.csv',',');
            control{end+1}=dlmread('Apr2012/07Dec34417Cell1.csv',',');
            control{end+1}=dlmread('Apr2012/07Dec34417Cell2.csv',',');
            control{end+1}=dlmread('Apr2012/15March35649Cell2.csv',',');
            control{end+1}=dlmread('Apr2012/18Jan35019Cell21-check.csv',',');
            control{end+1}=dlmread('Apr2012/19Jan35070Cell11.csv',',');
            control{end+1}=dlmread('Apr2012/23Dec34591Cell1.csv',',');
            control{end+1}=dlmread('Apr2012/28Dec34593Cell2.csv',',');
            control{end+1}=dlmread('Apr2012/28Dec34593Cell4.csv',',');
            control{end+1}=dlmread('Apr2012/29Dec34594Cell1.csv',',');
            control{end+1}=dlmread('Apr2012/29Dec34594Cell3.csv',',');
        end
        

        
        
        if vu
        % NIN 2011 with VU settings
        control{end+1}=dlmread('Last_TLT_Kazu/01_July_11_33325_ctl.csv',';');
        end
        
        if vu
        % Hadi: 10maycel1 probably pyramidal but not sure
        transgenic{end+1}=dlmread('trg_10May18412cel1.csv',';');
        transgenic{end+1}=dlmread('trg_10May18412cel3.csv',';');
        transgenic{end+1}=dlmread('trg_10May18412cel4.csv',';');
        % Hadi: 10maycel5 probably pyramidal but not sure
        transgenic{end+1}=dlmread('trg_10May18412cel5.csv',';');
        transgenic{end+1}=dlmread('trg_1May18794cel1.csv',';');
        transgenic{end+1}=dlmread('trg_20May18414cel1.csv',';');
        transgenic{end+1}=dlmread('trg_20May18414cel2.csv',';');
        transgenic{end+1}=dlmread('trg_21May18976cel1.csv',';');
        
        % Hadi: mouse seemed to have 'epileptic' fit after inhaling isoflurane
        transgenic{end+1}=dlmread('Transgenic18969 inhib.csv',';');
        
        transgenic{end+1}=dlmread('trg_inh_24Jan2008_22327cella.csv',';');
        end
        
        if nin
        % 2010_nin
        transgenic{end+1}=dlmread('trg_29919cell1n.csv',';');
        
        %Alexander: very short record
        %transgenic{end+1}=dlmread('trg_inh_24Jan2008_22327cellb.csv',';');
 
        % 2011 NIN
        transgenic{end+1}=dlmread('Extra/trg_20110127_32275.csv',';');
        transgenic{end+1}=dlmread('Extra/trg_20110201_32278.csv',';');

        end
        
        if vu
        % NIN 2011 with VU settings
        transgenic{end+1}=dlmread('Last_TLT_Kazu/28_june_11-32522_TLT.csv',';');
        end
        
        if nin12
            transgenic{end+1}=dlmread('Apr2012/03Jan35021Cell3p.csv',',');
            transgenic{end+1}=dlmread('Apr2012/05March35534Cell3p.csv',',');
            transgenic{end+1}=dlmread('Apr2012/07March35535Cell2p.csv',',');
        end
        
        
    case 'TrkB/Exc'

        cd(fullfile(basedir,dataset));
        control{end+1}=dlmread('ctl_20Mar.csv',';');
        control{end+1}=dlmread('ctl_13Apr18398cel1.csv',';');
        control{end+1}=dlmread('ctl_17Apr18399cel1.csv',';');
        control{end+1}=dlmread('ctl_17Apr18399cel2.csv',';'); % never fired spikes
        control{end+1}=dlmread('ctl_17Apr18399cel3.csv',';');
        control{end+1}=dlmread('ctl_21Apr18282cel1.csv',';');
        control{end+1}=dlmread('ctl_21Apr18282cel2.csv',';');
        control{end+1}=dlmread('ctl_21Apr18282cel3.csv',';');
        control{end+1}=dlmread('ctl_11May18413cel3.csv',';');
        
        
        transgenic{end+1}=dlmread('trg_13Mar18194cel1.csv',';');
        % hadi: cell 1 on 31 march firing pattern not tested
        % alex: 31Marcel1 not stable: removed
        %transgenic{end+1}=dlmread('trg_31Mar18394cel1.csv',';');
        transgenic{end+1}=dlmread('trg_31Mar18394cel2.csv',';'); % perhaps not pyramidal
        transgenic{end+1}=dlmread('trg_03Apr18396cel1.csv',';');
        transgenic{end+1}=dlmread('trg_03Apr18396cel2.csv',';');
        transgenic{end+1}=dlmread('trg_11Apr18397cel2.csv',';');
        % hadi: cell 3 on 11 april firing pattern not tested
        transgenic{end+1}=dlmread('trg_11Apr18397cel3.csv',';');% no f-i curve taken
        transgenic{end+1}=dlmread('trg_11Apr18397cel4.csv',';');
        transgenic{end+1}=dlmread('trg_20Apr18281cel1.csv',';');% file noisy
        % alex: 20aprcel2 not stable: removed
        %transgenic{end+1}=dlmread('trg_20Apr18281cel2.csv',';');
        transgenic{end+1}=dlmread('trg_20Apr18281cel3.csv',';');
        
end




description{1}='Event_nr';
description{2}='Time';
description{3}='Amplitude (pA)';
description{4}='Rise time (ms)';
description{5}='Decay time (ms)';
description{6}='Area';
description{7}='Baseline';
description{8}='Noise';
description{9}='Group';
description{10}='Channel';
description{11}='1090rise';
description{12}='Halfwidth';
description{13}='Rise50';
description{14}='Peak_dir';
description{15}='Burst_nr';
description{16}='Burste_nr';
description{17}='1090slope';
description{18}='Rel_time';




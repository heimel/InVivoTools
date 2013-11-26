function cell_nr = get_cellnumber( record, template_nr)
%GET_CELLNUMBER generates cell number hash from ectestrecord
%
% CELL_NR = GET_CELLNUMBER( RECORD, TEMPLATE_NR )
%
%  CELL_NR is the 'crc' hash based on the concatenation of the mouse, date, 
%  test fields of RECORD and the TEMPLATE_NR.
%
% 2012, Alexander Heimel
%

cell_nr = pm_hash('crc',[record.mouse record.date record.test num2str(template_nr)]);

#!/usr/bin/perl -w
# sudo apt-get install libspreadsheet-writeexcel-perl
# http://search.cpan.org/~jmcnamara/Spreadsheet-WriteExcel/lib/Spreadsheet/WriteExcel.pm

use strict;
use Spreadsheet::WriteExcel;

# Create a new Excel workbook called perl.xls
my $workbook = Spreadsheet::WriteExcel->new("\filename");


# Add some worksheets
my $ordersheet = $workbook->add_worksheet("Order");

# set paper size
$ordersheet->set_paper(9); # A4

# make sure to print on 1 page
$ordersheet->fit_to_pages(1, 1);

# add custom colors
my $mint = $workbook->set_custom_color(40, 210, 255, 210);
my $salmon = $workbook->set_custom_color(41, 255, 160, 122);

# Add a Format
my $headerformat = $workbook->add_format();
$headerformat->set_bold();
$headerformat->set_size(18);
$headerformat->set_color('red');
$headerformat->set_bg_color('yellow');
$headerformat->set_align('left');

my $format = $workbook->add_format();
$format->set_size(12);
$format->set_color('black');
$format->set_bg_color($mint);
$format->set_align('left');

#table entry format
my $tformat = $workbook->add_format();
$tformat->set_size(10);
$tformat->set_color('black');
$tformat->set_bg_color($mint);
$tformat->set_align('left');
$tformat->set_border(1);

my $rformat = $workbook->add_format();
$rformat->set_size(12);
$rformat->set_color('black');
$rformat->set_bg_color($mint);
$rformat->set_align('right');

my $aformat = $workbook->add_format();
$aformat->set_bold();
$aformat->set_size(10);
$aformat->set_color('red');
$aformat->set_bg_color($mint);
$aformat->set_align('left');

my $oformat = $workbook->add_format();
$oformat->set_bold();
$oformat->set_size(10);
$oformat->set_color('red');
$oformat->set_bg_color($salmon);
$oformat->set_align('left');
$oformat->set_border(1);


# Set ordersheet as the active worksheet
$ordersheet->activate();

#$ordersheet->set_column(0,6, undef, $format);

# Set the width of the first column in ordersheet
$ordersheet->set_column(0, 0, 5,$format);
$ordersheet->set_column(1, 1, 18,$format);
$ordersheet->set_column(2, 2, 26,$format);
$ordersheet->set_column(3, 3, 13,$format);
$ordersheet->set_column(4, 4, 13,$format);
$ordersheet->set_column(5, 5, 20,$format);
$ordersheet->set_column(6, 6, 13,$format);

# The general syntax is write($row, $col, $token, $format)

# Write some formatted text
$ordersheet->write(0, 0, "", $headerformat);
$ordersheet->write(0, 1, "Ordering form - animals for experiments or transfer", $headerformat);
$ordersheet->write(0, 2, "", $headerformat);
$ordersheet->write(0, 3, "", $headerformat);
$ordersheet->write(0, 4, "", $headerformat);
$ordersheet->write(0, 5, "", $headerformat);
$ordersheet->write(0, 6, "", $headerformat);

$ordersheet->write(2, 1, "Name:", $rformat);
$ordersheet->write(2, 2, "\experimenter", $format);
$ordersheet->write(3, 1, "Group:", $rformat);
$ordersheet->write(3, 2, "Levelt", $format);

$ordersheet->write(7, 1, "Date and time needed:", $rformat);
$ordersheet->write(7, 2, "\collectdate", $format);
$ordersheet->write(8, 1, "DEC protocol:", $rformat);
$ordersheet->write(8, 2, "\decnr", $format);

$ordersheet->write(8, 5, "Experimental group:", $rformat);
$ordersheet->write(8, 6, "\decgroup", $format);
$ordersheet->write(9, 5, "Pilot yes/no:", $rformat);
$ordersheet->write(9, 6, "\decpilot", $format);

$ordersheet->write(11, 1, "ATTENTION:", $aformat);
$ordersheet->write(12, 1, "1. For animals to be housed in the NIH animal unit, permission (signature) from Dries Kalsbeek or Chris Pool", $aformat);
$ordersheet->write(13, 1, "is mandatory!", $aformat);
$ordersheet->write(14, 1, "2. For animals to be housed in the DM2, permission from Dries Kalsbeek (Chris Pool) and Ruben Eggers is mandatory!", $aformat);
$ordersheet->write(15, 1, "3. In case animals are used for an acute experiment (perfusion, decapitation, acute experiment under ", $aformat);
$ordersheet->write(16, 1, "    anesthesia) please indicate the procedure in the column marked Acute Terminal Experiment)", $aformat);

$ordersheet->write(19, 1, "Genotype (Line)", $format);
$ordersheet->write(19, 2, "Animal code", $format);
$ordersheet->write(18, 3, "Number of", $format);
$ordersheet->write(19, 3, "animals", $format);
$ordersheet->write(18, 4, "Housing", $format);
$ordersheet->write(19, 4, "NIH/D2/none", $format);
$ordersheet->write(18, 5, "Acute", $format);
$ordersheet->write(19, 5, "Terminal Experiment", $format);
$ordersheet->write(19, 6, "Code", $format);


$ordersheet->write(42, 2, "Total number:", $rformat);
$ordersheet->write(42, 3, "\n_mice", $format);

#$ordersheet->write(20, 1, "\genotype", $tformat);
#$ordersheet->write(20, 2, "\animal_code", $tformat);
#$ordersheet->write(20, 3, "\number", $tformat);
#$ordersheet->write(20, 4, "\housing", $tformat);
#$ordersheet->write(20, 5, "\acute", $tformat);
#$ordersheet->write(20, 6, "", $oformat);

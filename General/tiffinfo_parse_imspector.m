function tinf = tiffinfo_parse_imspector(tinf)
%TIFFINFO_PARSE_IMSPECTOR used by tiffinfo for ImSpector metadata
%
% TINF = TIFFINFO_PARSE_IMSPECTOR( TINF )
%   adds the following fields to TINF struct:
%       NumberOfChannels
%       NumberOfFrames
%         third_axis_name
%         third_axis_unit
%       if third_axis_name is t
%         frame_period
%
% 2012, Alexander Heimel
%
%

mainNode = tinf.ParsedImageDescription.domnode.getDocumentElement;
entries = mainNode.getChildNodes;
node = entries.getFirstChild;

while ~isempty(node) && strcmp(node.getNodeName,'ca:CustomAttributes')==0
    node = node.getNextSibling;
end
if isempty(node)
    return
end
node = node.getFirstChild;

while ~isempty(node) && strcmp(node.getNodeName,'PropArray')==0
    node = node.getNextSibling;
end
if isempty(node)
    return
end
pa = node; % for if we want more properties
node = pa.getFirstChild;
while ~isempty(node)
    if node.hasAttributes
        val = str2double(node.getAttribute('Value').char);
        if isnan(val)
            val =  node.getAttribute('Value').char;
        end
        tinf.ParsedImageDescription.(subst_specialchars(node.getNodeName.char))...
            = val;
        
    end
    node = node.getNextSibling;
end
tinf.ParsedImageDescription

tinf.NumberOfChannels = tinf.ParsedImageDescription.PMT_Use_Channel_0 + ...
    tinf.ParsedImageDescription.PMT_Use_Channel_1 + ...
    tinf.ParsedImageDescription.PMT_Use_Channel_2 + ...
    tinf.ParsedImageDescription.PMT_Use_Channel_3 + ...
    tinf.ParsedImageDescription.PMT_Use_Channel_4 + ...
    tinf.ParsedImageDescription.PMT_Use_Channel_5 + ...
    tinf.ParsedImageDescription.PMT_Use_Channel_6 + ...
    tinf.ParsedImageDescription.PMT_Use_Channel_7 ;

tinf.NumberOfFrames =  tinf.ParsedImageDescription.Time_Number_of_Steps;

disp('TIFFINFO_PARSE_IMSPECTOR: Only rudimentary implementation');
tinf.third_axis_name = 'T';
tinf.third_axis_unit = 's';
tinf.frame_period = tinf.ParsedImageDescription.Time_Length/(tinf.NumberOfFrames-1);


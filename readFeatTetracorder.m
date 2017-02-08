function [ feat ] = readFeatTetracorder( line )
% [ feat ] = readFeatTetracorder( line )
%   read a feature in Tetracorder like
%    Dw 1.540   1.570   2.400  2.430 rct/lct> 0.7 0.8 lct/rct> 0.7 0.9

C = strread(line,'%s');
feat = [];
expr='^[ ]*[0-9-.]+?[ ]*$';
for i=1:length(C)
    if ~isempty(regexp(C{i},'\\#.*'))
        break;
    end
    if isempty(regexp(C{i},expr))
        field = C{i};
        field = strrep(field,'*','T');
        field = strrep(field,'>','G');
        field = strrep(field,'<','L');
        field = strrep(field,'/','D');
    else
        val = str2num(C{i});
        if isfield(feat,field)
            feat.(field) = [feat.(field) val];
        else
            feat.(field) = val;
        end
    end
end



end


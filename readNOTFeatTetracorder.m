function [ notFeat ] = readNOTFeatTetracorder( line )
% [ notfeat ] = readNOTFeatTetracorder( line )
%   read a feature in Tetracorder like
%     NOT [NOTMUSCOVITE1] 2  0.22r1 .6   \# NOT muscovite, feat 2

linespl = strread(line,'%s');
notFeat = [];
dest = regexp(linespl{2},'\[(.*)\]','tokens');
notFeat.dest = dest{1}{1};
notFeat.feat_id = str2num(linespl{3});
notFeat.fit_th = str2num(linespl{5});
if strfind(linespl{4},'r')
    notFeat.rel=true; notFeat.abs=false;
    tmp = regexp(linespl{4},'r','split');
    notFeat.bd_th = str2num(tmp{1});
    notFeat.relTo = str2num(tmp{2});
    
elseif strfind(linespl{4},'a')
    notFeat.abs=true; notFeat.rel=false;
    tmp = regexp(linespl{4},'a','split');
    notFeat.bd_th = str2num(tmp{1});
end
end


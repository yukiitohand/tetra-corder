function [ clustList ] = readCluster( clusterFile )
% this function is designed for reading a cluster results of the
% Tetracorder, such as 
%     tmp.cluster.txt
%
% Inputs
%    cluterFile : file name
% Outputs
%    clustList : struct of the cluter result
%    active field name
%      - case
%      - group
%      - g_id
%      - no: number of the detected pixels
%      - decision: {'WOW','Great','good','maybe','none','zero'}
%      - outputbase
%      

fid = fopen(clusterFile,'r');
flg=1; i=0; clustList=[];
while flg
    tline = fgetl(fid);
    if ischar(tline)
        i=i+1;
        no = regexp(tline,'^(\d+):".*"$','tokens');
        tmp = regexp(tline,'^\d+\:"(.*)"$','tokens');
        tmp1 = regexp(tmp{1}{1},'\s*','split');
        props = regexp(tmp1{1},'/','split');
        g_id = regexp(props{2},'^(group|case).(.+)$','tokens');
        outputbase = regexp(props{3},'^(.+).fd$','tokens');
        if strcmp(g_id{1}{1},'case')
            clustList(i).case = g_id{1}{2};
        elseif strcmp(g_id{1}{1},'group')
            clustList(i).group = g_id{1}{2};
            if strcmp(g_id{1}{2},'1um')
                clustList(i).g_id = 1;
            elseif strcmp(g_id{1}{2},'2um')
                clustList(i).g_id = 2;
            end
        end
        decision = tmp1{8};
        clustList(i).no = str2num(no{1}{1});
        clustList(i).decision = decision;
        clustList(i).outputbase = outputbase{1}{1};
    else
        flg=0;
    end
end

fclose(fid);

end


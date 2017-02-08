function [ smpls ] = readlibsetup( flibname,group )
% this function is designed for reading a library setup file for 
% Tetracorder, such as 
%     cmd.lib.setup.t4.4a5s6
%
% Inputs
%    flibname : file name
%    group : group to be detected
%       at this point, group 1 is electronic transition region (1um)
%                      group 2 is vibrational region (2um)
% Outputs
%   smpls : list of the description of each reference

fid = fopen(flibname,'r');
smpls = [];
flg1 = true;
i=1;
while flg1
    fprintf('%d\n',i);
    ln=fgetl(fid);
    if strcmp(ln,[sprintf('group %d',group)])
        smpl = sprintf('%s\n',ln);
        flg2 = true;
        while (flg2)
            ln = fgetl(fid);
            smpl = sprintf('%s%s\n',smpl,ln);
            if strcmp(ln,['endaction'])
                flg2=false;
            end
        end
        smpls = [smpls,{smpl}];
    end
    if strcmp(ln,['\##################### ' sprintf('end group %d',group) ' #####################################'])
        flg1=false;
    end
    i=i+1;
end
fclose(fid);

end


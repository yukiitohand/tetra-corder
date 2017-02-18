function [ refList,summary ] = readResMap( refList,res_dir )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(refList)
    base = refList(i).outputbase;
    fpath = [res_dir '/' base];
    im_file = [fpath '.fd'];
    hdr_file = [im_file '.hdr'];
    [hdr_info] = envihdrreadx(hdr_file);
    [im] = envidataread(im_file,hdr_info);
    refList(i).map = im;
    refList(i).map_info = hdr_info;
end

% read summary that is not included in the original references
fList = dir([res_dir '/*.fd']);
N = length(fList);
summary = [];
counter=1;
for n=1:N
    [pathstr,base,ext] = fileparts(fList(n).name);
    flg = searchby('outputbase',base,refList,'COMP_FUNC','strcmp');
    if isempty(flg)
        fprintf('%d %s\n',counter,base);
        summary(counter).outputbase = base;
        counter=counter+1;
    end
end

if ~isempty(summary)
    for i=1:length(summary)
        base = summary(i).outputbase;
        fpath = [res_dir '/' base];
        im_file = [fpath '.fd'];
        hdr_info = envihdrreadx(hdr_file);
        [im] = envidataread(im_file,hdr_info);
        summary(i).map = im;
    end

end

end
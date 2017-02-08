function [ refList,vals,gnotFeats,vegRatios,rawTexts ] = readlibsetupall( flibname )
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
flg = true;

exprCommentOut = '^\\#.*$';
exprValLine = '^==.+$';
exprValName = '\[(.*)\]';
exprNotFeat = '^==[NOT.+$';
exprVegRatio = '^==[RATIO.+$';

rawTexts = [];
vals = [];
gnotFeats = [];
vegRatios = [];
refList = [];

lnum=0;
while flg
    ln = fgetl(fid);
    if ~isempty(regexp(ln,exprCommentOut))
        lnum=lnum+1;
        continue;
    end
    lnum = lnum+1;
    rawTexts{lnum} = ln;
    % read variables
    if ~isempty(regexp(ln,exprValLine)) 
        if ~isempty(regexp(ln,exprNotFeat))
            % read not feature variables
            % ==[NOTDRYVEG]     [splib06]  7128 \# Dry_Long_Grass AV87-2       W1R1Ba
            % ==[NOTGREENVEG]   [splib06]  7170 \# Fir_Tree IH91-2             W1R1Ba
            % ==[NOTMONTSWY]    [splib06]  3270 \# Montmorillonite SWy-1       W1R1Bb
            % ==[NOTMONTAZ]     [splib06]  3228 \# Montmorillonite SAz-1       W1R1Bb
            % ==[NOTMUSCOVITE1] [splib06]  3348 \# Muscovite GDS113 Ruby       W1R1Bb
            % ==[NOTMUSCOVITE2] [splib06]  5832 \# Muscovite CU91-250A med Al  W2R4Nb
            % ==[NOTNAALUNITE1] [splib06]   288 \# Alunite GDS95 Na Syn (150C) W2R4Na
            % ==[NOTKALUNITE1]  [splib06]   300 \# Alunite GDS97 K  Syn (150C) W2R4Na
            % ==[NOTKALUNITE2]  [splib06]   294 \# Alunite GDS96 K  Syn (250C) W2R4Na
            % ==[NOTbroadFe2]   [splib06]  5634 \# Chlorite+Muscovite CU93-65A W1R1Ba
            % ==[NOTepidote]    [splib06]  1668 \# Epidote GDS26.a 75-200um    W1R1Bb
            % ==[NOTgypsum]     [splib06]  1986 \# Gypsum HS333.3B (Selenite)  W1R1Ba
            % ==[NOTjarosite]   [splib06]  2568 \# Jarosite GDS99 K 200C Syn   W1R1Ba
            % ==[NOTCH1]        [splib06]  6840 \# Plastic_PVC GDS338 White    W1R1Fa
            % ==[NOTDOLOMITE]   [splib06]  1572 \# Dolomite HS102.3B           W1R1Bb
            notFeat=[];
            valName = ln(3:17);
            libName = ln(19:27);
            recNum = str2num(ln(28:33));
            libName = regexp(libName,exprValName,'tokens');
            libName = libName{1}{1};
            titl = ln(38:71);
            valName = regexp(valName,exprValName,'tokens');
            valName = valName{1}{1};
            notFeat.dest = valName;
            notFeat.ititl = titl;
            notFeat.lib = libName;
            notFeat.irecno = recNum;
            gnotFeats.(notFeat.dest) = notFeat;
        elseif ~isempty(regexp(ln,exprVegRatio))
            % read like
            % ==[RATIOGREENVEG] [splib06] 7260 \# Lawn_Grass GDS91 (Green)     W1R1Ba
            % ==[RATIOGVEG1]    [splib06] 7644 \# Lawn_Grass GDS91 +const 1.0  W1R1Ba
            vegRatio=[];
            valName = ln(3:17);
            libName = ln(19:27);
            recNum = str2num(ln(28:33));
            libName = regexp(libName,exprValName,'tokens');
            libName = libName{1}{1};
            titl = ln(38:71);
            valName = regexp(valName,exprValName,'tokens');
            valName = valName{1}{1};
            vegRatio.dest = valName;
            vegRatio.ititl = titl;
            vegRatio.lib = libName;
            vegRatio.irecno = recNum;
            vegRatios.(vegRatio.dest) = vegRatio; 
        else
            % read like
            % ==[GLBLFITALL]0.2 0.3
            % ==[GLBLFDFIT]0.3 0.4
            % ==[GLBLDPFIT]0.5 0.6
            % ==[GLBLDPFITg2]0.65 0.7
            % ==[G2UMRBDA] 0.001 .002
            valTxt = ln(3:end); % skip '=='
            [s,e] = regexp(valTxt,exprValName);
            valName = valTxt(s+1:e-1);
            val = valTxt(e+1:end);
            val = textscan(val,'%f');
            val = val{1};
            vals.(valName) = val';
        end
    end
    
    if ~isempty(regexp(ln,'^BEGIN SETUP.*'))
        flg=0;
    end
    
end

numSpectra = 0;
% gid = 0; % group id
flg_g=1;
while flg_g
%     fprintf('%d\n',i);
    lnum = lnum+1;
    ln=fgetl(fid);
    if ~isempty(regexp(ln,'^END SETUP.*'))
        rawTexts{lnum} = ln;
        flg_g=0; % finish if reaching this line.
    elseif ~isempty(regexp(ln,'^group[ 0-9]+'))
        numSpectra = numSpectra + 1;
        smpl = sprintf('%s\n',ln);
        flg2 = true;
        %% read all the text in the smpl
        while (flg2)
            lnum = lnum+1;
            ln = fgetl(fid);
            rawTexts{lnum} = ln;
            smpl = sprintf('%s%s\n',smpl,ln);
            if strcmp(ln,['endaction'])
                flg2=false;
            end
        end
        %% form the text into title, diagnostic features, and not features
        smplspl = regexp(smpl,'\n','split');
        group = regexp(smplspl{1},' ','split');
        g_id = str2num(group{2});
        refList(numSpectra).g_id=g_id;
        j=7;
        while isempty(regexp(smplspl{j},'^SMALL:.*')) j=j+1; end
        irecLine = regexp(smplspl{j},' +','split'); % record id
        refList(numSpectra).irecno = str2num(irecLine{3});
        j=10;
        while isempty(regexp(smplspl{j},'^\\#=-=-=-=-=-=-=-=-=-=-=- TITLE=.*')) j=j+1; end
        titl = smplspl{j}; % title
        fprintf('%s\n',titl(32:end));
        refList(numSpectra).ititl = titl(32:end);
        j=13;
        while isempty(regexp(smplspl{j},'^output=.*$')) j=j+1; end
        while ~isempty(regexp(smplspl{j},exprCommentOut)) j=j+1; end
        outputbaseLine = regexp(smplspl{j+1},' +','split');
        refList(numSpectra).outputbase = outputbaseLine{1};
        j=13;
        while isempty(regexp(smplspl{j},'.*Number of features.*')) j=j+1; end
        d = smplspl{j};
        numFeatsAndNot = strread(d,'%d',2);
        numFeats = numFeatsAndNot(1);
        numNotFeats = numFeatsAndNot(2);
        % second read features;
        feats = [];
        idFeat=1;
        ii=1;
%             expr = '^\#\.*';
        exprFeat = '^[DWO]{1}w.*';
        flgFeat=1;
        while flgFeat
            row = ii+13;
    %         if ~isempty(regexp(smplspl{row+i},expr))
    %             
            if ~isempty(regexp(smplspl{row},exprFeat))
                feat = readFeatTetracorder(smplspl{row}); 
                fldList = fields(feat);
                for ifld=1:length(fldList)
                    feats(idFeat).(fldList{ifld}) = feat.(fldList{ifld});
                end
%                 feats = [feats {feat}];
                if idFeat==numFeats
                    flgFeat=0;
                end
                idFeat=idFeat+1;
            end
            ii=ii+1;
        end
        % third not features
        notFeats = [];
        if numNotFeats>0
            exprNOT = '^NOT.*$';
            flgNot=1;
            idNOTFeat=1;
            while flgNot
                row=ii+13;
                if ~isempty(regexp(smplspl{row},exprNOT))
                    notFeat = readNOTFeatTetracorder(smplspl{row});
                    fldList = fields(notFeat);
                    for ifld=1:length(fldList)
                        notFeats(idNOTFeat).(fldList{ifld}) = notFeat.(fldList{ifld});
                    end
%                     notFeats = [notFeats {notFeat}];
                    if idNOTFeat==numNotFeats
                        flgNot=0;
                    end
                    idNOTFeat=idNOTFeat+1;
                end
                ii=ii+1;
            end
        end
        %%
%             reference.ititl = titl;
        refList(numSpectra).desc = smpl;
        refList(numSpectra).feats = feats;
        refList(numSpectra).notFeats = notFeats;
    elseif ~isempty(regexp(ln,exprCommentOut))
        continue;
    end
end
fclose(fid);

end


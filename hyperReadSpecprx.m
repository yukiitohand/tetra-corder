function [ rawSpectra,records ] = hyperReadSpecprx( filename,varargin )
%   hyperReadSpecprx reads USGS Specpr files. 
% 
% Usage
%   [ records, rawSpectra ] = hyperReadSpecpr( filename )
% Inputs
%   filename - Input filename
% Optional Parameters
%   'DESCRIPTION': whether to load 'description' or not {0,1},
%                  (default) 1
% Outputs
%   records - Individual records
%   rawSpectra - The raw spectra
%
% References
%   http://speclab.cr.usgs.gov/specpr-format.html.

% dbstop if error;
f = fopen(filename, 'r');

dscrptn = 1;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'DESCRIPTION'
                dscrptn = varargin{i+1};
            otherwise
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

if (f == -1)
    error(sprintf('Failed to open file: %s', filename));
end

% Ignore the first record.
r = uint32(fread(f, 1536, 'uint8'));

firstTime = 1;
records = {};
spectra = [];
rawSpectra = {};
numRawSpectra = 0;
numRecords = 0;

done = 0;
rec_no = 0;
while (not(done))
    rec_no = rec_no+1; % added by Yuki 06/27/2017
    r = uint32(fread(f, 1536/4, 'uint32', 'ieee-be'));
    if (length(r) == 0)
        break;
    end
    r = swapbytes(r);
    r = typecast(r, 'uint8');
    % First two bits of file.  I am making this verbose here so it is clear what I
    % am doing.
    firstTwoBits = dec2bin(bitand(r(4), 3));
    firstTwoBits = sprintf('%02s',firstTwoBits);
    % added by Yuki Itoh 06/27/2017
    
    %  Parse first two bits.
    % edited to use strcmp (by Yuki Itoh 06/27/2017)
    if strcmp(firstTwoBits,'10')
        % This is a text record.
        % not skip (06/27/2017 Yuki Itoh)
        record = [];
        data = [];
        record.ititl = char(r(5:44)).';
        record.usernm = char(r(45:52)).';
        record.itxtpt = swapbytes(typecast(r(53:56), 'int32'));
        record.itxtch = swapbytes(typecast(r(57:60), 'int32'));
        itext = char(r(61:1536)).';
        record.itext = itext;
        numRecords = numRecords + 1;
        rec_no_parent = rec_no;
        records{rec_no_parent} = record;
    elseif strcmp(firstTwoBits,'00')
        % This is an actual (initial) data record.
        % modified by Yuki 07/10/2015
        % comment and move to the end of this clause
%         if (not(firstTime))
%             numRecords = numRecords+1;
%             records{record.irecno} = record;
%         end
        record = [];
        data = [];
        firstTime = 0;
        iband = int32(zeros(2, 1));
        record.ititl = char(r(5:44)).';
        record.usernm = char(r(45:52)).';
        iscta = typecast(r(53:56), 'int32');
        isctb = typecast(r(57:60), 'int32');
        jdatea = typecast(r(61:64), 'int32');
        jdateb = typecast(r(65:68), 'int32');
        istb = typecast(r(69:72), 'int32');
        isra = typecast(r(73:76), 'int32');
        isdec = typecast(r(77:80), 'int32');
        record.itchan = swapbytes(typecast(r(81:84), 'int32'));
        irmas = typecast(r(85:88), 'int32');
        revs = typecast(r(89:92), 'int32');
        iband(1) = typecast(r(93:96), 'int32');
        iband(2) = typecast(r(97:100), 'int32');
        record.irwav = swapbytes(typecast(r(101:104), 'int32'));
        record.irespt = swapbytes(typecast(r(105:108), 'int32'));
        record.irecno = swapbytes(typecast(r(109:112), 'int32'));
        record.itpntr = swapbytes(typecast(r(113:116), 'int32'));
        ihist = char(r(117:176)).';
        mhist = char(r(177:472)).';
        nruns = typecast(r(473:476), 'int32');
        siangl = typecast(r(477:480), 'int32');
        seangl = typecast(r(481:484), 'int32');
        sphase = typecast(r(485:488), 'int32');
        iwtrns = typecast(r(489:492), 'int32');
        itimch = typecast(r(493:496), 'int32');
        xnrm = typecast(r(497:500), 'int32');
        scatim = typecast(r(501:504), 'int32');
        timint = typecast(r(505:508), 'int32');
        tempd = typecast(r(509:512), 'int32');
        data = swapbytes(typecast(r(513:1536), 'single'));
        % Remove null data samples. Set to zero instead of -1.23e34.
        data(find(data < -1e34)) = 0;
        record.data = data;
        % added by Yuki 07/10/2015
        numRecords = numRecords+1;
        records{record.irecno} = record;
%         if record.irecno==22
%             fprintf('%d\n',numRecords)
%         end
    elseif strcmp(firstTwoBits,'01')
        % Continuation of data values.
        cData = swapbytes(typecast(r(5:1536), 'single')); 
        cData(find(cData < -1e34)) = 0;
        data = [data; cData];
        record.data = data;
        records{record.irecno} = record;
    elseif strcmp(firstTwoBits,'11')
        tData = char(r(5:1536))'; 
        itext = [itext tData];
        record.itext = itext;
        records{rec_no_parent} = record;
    end
end

% Convert to an array of signatures.
% Resample to model AVIRIS sensor
high = 2.40;
low = 0.4;
numBands = 224;
%d.data = sortrows(d.data, 1);
%[q, w, r ]= unique(d.data(:,1));
%d.data = d.data(w, :);
%lambda = d.data(:, 1);
%reflectance = d.data(:, 2);
s = length(records);
numSpectra = 0;
ititl_excpt = {'Bandpass','Wavelengths','Wavenumber','CRISM Waves JOINED MTR3 microns'};
for q=1:s
    if (isempty(records{q}))
        continue;
    end
    % added by Yuki 06/27/2017
    if ~isfield(records{q},'irecno')
        continue;
    end
    
    % added by Yuki 07/10/2015
    if (not(isempty(strfind(records{q}.ititl, 'errors to previous data'))))
        rawSpectra(numRawSpectra).errors = records{q}.data;
        continue;
    end
    if any(cellfun(@(x) ~isempty(regexp(records{q}.ititl,x,'Once')), ...
                 {'error bars to preceding','Placeholder for error bars'}))
        rawSpectra(numRawSpectra).errorbars = records{q}.data;
        continue;
    end 
    if (not(isempty(strfind(records{q}.ititl, 'FEATANL'))))
        rawSpectra(numRawSpectra).featanl = records{q}.data;
        continue;
    end
    if (records{q}.irwav == 0)
        continue;
    end
    
    if any(cellfun(@(x) ~isempty(regexp(records{q}.ititl,x,'Once')),ititl_excpt))
        continue;
    end
%     if (not(isempty(strfind(records{q}.ititl, 'error'))))
%         continue;
%     end
%     if (not(isempty(strfind(records{q}.ititl, 'Error'))))
%         continue;
%     end
%     if (not(isempty(strfind(records{q}.ititl, 'Bandpass'))))
%         continue;
%     end
%     if (~(isempty(strfind(records{q}.ititl, 'Wavelengths'))))
%         continue;
%     end
%     if (~(isempty(strfind(records{q}.ititl, 'Wavenumber'))))
%         continue;
%     end
    % Find wavelengths
    if (isempty(records{records{q}.irwav}))
        continue;
    end
    lambdas = records{records{q}.irwav}.data;
    spectrum = records{q}.data;
    
    if (length(lambdas) ~= length(spectrum))
        fprintf('Error %d !!!\n', q);
        continue;
    end
    
    
    numRawSpectra = numRawSpectra + 1;
    rawSpectra(numRawSpectra).irecno = records{q}.irecno; % added by Yuki 07/13/2015
    rawSpectra(numRawSpectra).name = records{q}.ititl;
    rawSpectra(numRawSpectra).ititl = records{q}.ititl;
    rawSpectra(numRawSpectra).wavelength = lambdas;
    rawSpectra(numRawSpectra).reflectance = spectrum;
    
    if dscrptn
        if records{q}.itpntr>0
            itext = records{records{q}.itpntr}.itext;
            itext = itext(1:records{records{q}.itpntr}.itxtch);
            [doc_format] = find_propValue(itext,'DOCUMENTATION_FORMAT');
            rawSpectra(numRawSpectra).description = itext;
            rawSpectra(numRawSpectra).documentation_format = doc_format;
        else
            rawSpectra(numRawSpectra).description = '';
            rawSpectra(numRawSpectra).documentation_format ='';
        end
    else
        rawSpectra(numRawSpectra).description = '';
        rawSpectra(numRawSpectra).documentation_format ='';
    end
    
end

return;

end


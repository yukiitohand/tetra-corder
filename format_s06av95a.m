function [ spcs_av95 ] = format_s06av95a( rawSpcs_av95, recs_av95, libtitlesfile )
% [ spcs_av95 ] = format_s06av95a( rawSpcs_av95, recs_av95, ftitles )
%   format s06av95a so that easy to use
% remove the padded data in each entry
% add 'resolution','channels', 'ititl' to fields of rawSpcs_av95

fid = fopen(libtitlesfile,'r');
ititls = [];
tline = fgetl(fid);
while ischar(tline)
    ititls = [ititls {tline}];
    tline = fgetl(fid);
end

fclose(fid);

bands = recs_av95{18};
resol = rawSpcs_av95(1);
spcs_av95 = rawSpcs_av95(2:end);

valid_channels = bands.data>0;
channel_mapper = bands.data(valid_channels);
resol = resol.reflectance(valid_channels);
% resol = resol(channel_mapper);

for i=1:length(spcs_av95)
    wavelength = spcs_av95(i).wavelength;
    wavelength = wavelength(valid_channels);
%     wavelengths = wavelengths(channel_mapper);
    reflectance = spcs_av95(i).reflectance;
    reflectance = reflectance(valid_channels);
%     reflectance = reflectance(channel_mapper);
    
    spcs_av95(i).wavelength = wavelength;
    spcs_av95(i).reflectance = reflectance;
    spcs_av95(i).resolution = resol;
    spcs_av95(i).channels = channel_mapper;
    spcs_av95(i).ititl = ititls{i};
end
    


end


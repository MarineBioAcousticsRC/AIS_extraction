% CINMS_B_HARPdbQuery
% November 24, 2021 (Happy Thanksgiving!)
%
%
%
% Vanessa ZoBell (adapted from CINMS_B_dbQuery.m by Sean Wiggins)
%
% HARPdb = HARP data summary
% effortString = name of the dataset effort
% siteString = name of the site
% offn = out file name, where you want it to be saved



HARPdb = readtable('C:\Users\HARP\Desktop\HARPdataSummary_20210126.csv');
offn = 'D:\Ch.3v2_SourceLevelModel\CINMS_B_depInfo211124.mat';


effortString = 'CINMS'; % effort name
siteString = 'B';   % site name

effortIdx = find(contains(table2cell(HARPdb(:, 1)),effortString));
data = HARPdb(effortIdx, :);
siteIdx = find(contains(table2cell(data(:, 1)), siteString));
data = data(siteIdx, :); 

lats = zeros(1, size(data, 1));
lons = zeros(1, size(data, 1));
names = cell(1, size(data, 1));
desc = cell(1, size(data, 1));
recTimes = zeros(size(data,1),2);
preAmp = cell(1,size(data,1));

% loop through each entry
for i = 1:size(data, 1)
    latdm = char(table2array(data(i, 5)));
    lat1 = str2double(extractBefore(latdm, "-"))
    lat2 = extractAfter(latdm, "-")
    lat2 = str2double(lat2(1:end-2))
    lat = dm2degrees([lat1, lat2])
    
    londm = char(table2array(data(i, 6)))
    lon1 = str2double(extractBefore(londm, "-"))
    lon2 = extractAfter(londm, "-")
    lon2 = str2double(lon2(1:end-2))
    lon = dm2degrees([lon1, lon2])

    lats(i) = lat;
    lons(i) = lon;
    names{i} = char(table2array(data(i, 1)));
    desc{i} = table2array(data(i, 7));
    preAmp{i} = data{i,3};
    %fprintf('%s\t\t%.4f\t\t%.4f\t\tz =\t%.0f\n',data{i,1},lat,lon,data{i,4});
    try 
        format = 'yyyy-mm-dd HH:MM:SS'

        recTimes(i,1) = datenum(append(string(table2array(data(i, 15))), ' ', string(table2array(data(i, 16)))));
        recTimes(i,2) = datenum(append(string(table2array(data(i, 17))), ' ', string(table2array(data(i, 18)))));
    catch ME
        fprintf('\tNo data start/end times: %s\n', ME.message);
    end
end


% list of deployments to exclude
exDeps = {
    'CINMS_B_30_0115'; % non standard deployment
    'CINMS_B_30_0130'; % non standard deployment
    'CINMS_B_30_0145'; % non standard deployment
    'CINMS_B_30_03';   % non standard deployment
    'CINMS_B_30_0515'; % non standard deployment
    'CINMS_B_30_0530'; % non standard deployment
    'CINMS_B_30_0545'; % non standard deployment
    'CINMS_B_32';      % bad hydrophone
    };

% exclude deployments before saving query
fprintf('Excluding deployments:\n');
for exi = 1:length(exDeps) 
    fprintf('\t%s\n',exDeps{exi});
    rmi = find(strcmp(names,exDeps{exi}));
    desc(rmi) = [];
    lats(rmi) = [];
    lons(rmi) = [];
    names(rmi) = [];
    recTimes(rmi,:) = [];
    preAmp(rmi) = [];    
end

save(offn,'lats','lons','names','desc','recTimes','preAmp');


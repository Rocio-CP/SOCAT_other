clc
clear all


% Set paths
% Path of original data
datadir = ['/Users/rpr061/Dropbox/BCDC_DataProducts/SOCAT/SOCATv7/',...
    'Data/received_by_mail/Finnmaid/'];

% Working directory (local)
workdir = ['/Users/rpr061/Documents/scratch/'];


%% Create a big file and calculate how many files will result
%% from splitting when the sensor changes;
%%
% Create the big file

 templistoffiles=dir([datadir,'**/*.xlsx']);
        for f=1:numel(templistoffiles);
            % dir does not add the trailing slash in the folder field
            fullpathfile=[templistoffiles(f).folder, '/',...
                templistoffiles(f).name];
            copyfile(fullpathfile, [workdir]);
            clear fullpathfile
        end
clear templistoffiles

cd(workdir)
   templistoffiles=dir([workdir,'./*.xlsx']);  
    % Import excel data and append to cell variable datamerged
    for f=1:numel(templistoffiles);
    [numdata, header, raw]= xlsread(templistoffiles(f).name);
    % For 2017_Month_5_zero_to_calibration_gas_concentration_LOS_GATOS_1.xlsx
    % it reads 30119 lines into raw, vs 8749 into numdata
    % trim the end of the raw matrix (which is only nans)
    % Little workaround to prevent it
    if length(raw)>(length(numdata)+1);
        raw1=raw;
        raw=raw1(1:length(numdata)+1,:);
    end
    datamerged1{f,1}=numdata;
    headermerged1{f,1}=header(1,:);
    sensormerged1{f,1}=raw(2:end, 16);
    clear numdata header raw*
    end

% Un-nest
datamerged=vertcat(datamerged1{:});
headermerged=vertcat(headermerged1{:});
sensormerged=vertcat(sensormerged1{:});

% Create "seconds" column, from datenum (column 1)
[yt,mt,dt,ht,mit,st]=datevec(datamerged(:,1));

% Order data by timestamp
[s,si]=sort(datamerged(:,1));
datamerged_sorted=datamerged(si,:);
sensormerged_sorted=sensormerged(si,:);
secmerged_sorted=st(si);

% Save variable seconds to append to excel file
expocode=['34FM2018'];

% clear templistoffiles *merged* *t s si
save([expocode,'.mat']);

% All seconds are integers as given from datenum

%% Find when a new sensor starts 
% Assign numerical codes to sensors, register first day of each
clc; clear all; close all
load('34FM2018.mat');

for ind=1:length(sensormerged_sorted);
if strcmp(sensormerged_sorted{ind},'LICOR');
sensorcode(ind,1)=1;
elseif strcmp(sensormerged_sorted{ind},'LOS GATOS');
sensorcode(ind,1)=2;
end
end

sensorcode_difference=sensorcode(1:end-1)-sensorcode(2:end);
newsensor=[1;find(sensorcode_difference~=0)+1];

% Write into text file
 fid=fopen([expocode,'_changesensor.txt'],'w');

% Variables names
fprintf(fid, ['Date \t Sensor \n']);

% Data
for d=1:numel(newsensor);
    fprintf(fid,...
        '%s \t %s  \n',...
        datestr(datamerged_sorted(newsensor(d))),...
        sensormerged_sorted{newsensor(d)});

end
fclose(fid)


% Split files

headerline=[headermerged{1,:},{'sec'}];
newsensor_end=[newsensor;size(datamerged_sorted,1)+1];

for ind=1:length(newsensor_end)-1;
    expocodefull=[expocode,...
        num2str(datamerged_sorted(newsensor_end(ind),3),'%02d'),...
     num2str(datamerged_sorted(newsensor_end(ind),4),'%02d')];
 
 fid=fopen([expocodefull,'.txt'],'w');
% 4-line header
fprintf(fid,['Expocode: ',expocodefull,'\n']);
fprintf(fid, 'Ship name: Finnmaid\n');
fprintf(fid, 'PIs: Rehder, G.; Glockzin, M.\n');
fprintf(fid, 'Vessel type: Ship\n');

% Variables names
fprintf(fid,[repmat('%s\t',1,16),'%s\n'], headerline{:});

% Data
for d=newsensor_end(ind):newsensor_end(ind+1)-1;
    fprintf(fid,...
        '%s\t%i\t%i\t%i\t%i\t%i\t%f\t%f\t%f\t%f\t%s\t%s\t%f\t%f\t%s\t%s\t%i\t\n',...
        num2str(datamerged_sorted(d,1),[0,9]),...
        datamerged_sorted(d,2:10),...
        num2str(datamerged_sorted(d,11),[0,9]),...
        num2str(datamerged_sorted(d,12),[0,9]),...
        datamerged_sorted(d,13:14),...
        num2str(datamerged_sorted(d,15),[0,9]),...
        sensormerged_sorted{d},secmerged_sorted(d));
end

fclose(fid);
   
end

%% Check xCO2 from April-September (lines 46120 to 183938) and see if there
%% are full transects below xCO2=393

aprsepLG=datamerged_sorted(46120:183938,:);
sensor_aprsepLG=sensormerged_sorted(46120:183938,:);
sec_aprsepLG=secmerged_sorted(46120:183938,:);

indbelow=aprsepLG(:,12)<=393.0;
indover=aprsepLG(:,12)>393.0;

datebelow=nan(size(indbelow));
datebelow(indbelow)=aprsepLG(indbelow,1);
xco2below=nan(size(indbelow));
xco2below(indbelow)=aprsepLG(indbelow,8);

dateover=nan(size(indover));
dateover(indover)=aprsepLG(indover,1);
xco2over=nan(size(indover));
xco2over(indover)=aprsepLG(indover,8);

figure
hold on
plot(datebelow, xco2below, '-b');
plot(dateover, xco2over, '-r');

datetick('x');
xlabel('date');
ylabel('latitude');

%%
% Find visually the chunk of transects below the threshold
% indices within aprsepLG!!!!
lowco2_startind=4723;
lowco2_endind=17322;


max(aprsepLG(lowco2_startind:lowco2_endind, 12))

figure
scatter(aprsepLG(lowco2_startind:lowco2_endind, 7),...
    aprsepLG(lowco2_startind:lowco2_endind, 8),...
    10,...
    aprsepLG(lowco2_startind:lowco2_endind, 12),...
    'f');

figure
scatter(aprsepLG(lowco2_startind:lowco2_endind, 1),...
    aprsepLG(lowco2_startind:lowco2_endind, 8),...
    10,...
    aprsepLG(lowco2_startind:lowco2_endind, 12),...
    'f');
datetick('x')
colorbar
xlabel('date');
ylabel('latitude');


%% Split 34FM20170411 into 34FM20170411, 34FM20170416, 34FM20170429
% Save 34FM20170411 as 34FM20170411_long.txt
copyfile('34FM20170411.txt', '34FM20170411_long.txt');

splitindices=[1,lowco2_startind, lowco2_endind+1, size(aprsepLG,1)+1];

for ind=1:length(splitindices)-1;
    expocodefull=[expocode,...
        num2str(aprsepLG(splitindices(ind),3),'%02d'),...
     num2str(aprsepLG(splitindices(ind),4),'%02d')];
 
 fid=fopen([expocodefull,'.txt'],'w');
% 4-line header
fprintf(fid,['Expocode: ',expocodefull,'\n']);
fprintf(fid, 'Ship name: Finnmaid\n');
fprintf(fid, 'PIs: Rehder, G.; Glockzin, M.\n');
fprintf(fid, 'Vessel type: Ship\n');

% Variables names
fprintf(fid,[repmat('%s\t',1,16),'%s\n'], headerline{:});

% Data
for d=splitindices(ind):splitindices(ind+1)-1;
    fprintf(fid,...
        '%s\t%i\t%i\t%i\t%i\t%i\t%f\t%f\t%f\t%f\t%s\t%s\t%f\t%f\t%s\t%s\t%i\t\n',...
        num2str(aprsepLG(d,1),[0,9]),...
        aprsepLG(d,2:10),...
        num2str(aprsepLG(d,11),[0,9]),...
        num2str(aprsepLG(d,12),[0,9]),...
        aprsepLG(d,13:14),...
        num2str(aprsepLG(d,15),[0,9]),...
        sensor_aprsepLG{d},sec_aprsepLG(d));
end

fclose(fid);
   
end

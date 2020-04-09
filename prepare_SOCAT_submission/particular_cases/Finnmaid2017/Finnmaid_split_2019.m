clc
clear all


% Set paths
% Path to data (workspace)
datadir = ['/Users/rpr061/Dropbox/BCDC_DataProducts/SOCAT/SOCATv7/',...
    'Data/received_by_mail/Finnmaid/workspace/'];
cd(datadir)

%% Data merged manually
% Import data
% Initialize variables.
filename = 'Finnmaid2018.txt';
delimiter = '\t';
startRow = 2;

% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
% Open the text file.
fileID = fopen(filename,'r');
% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
    'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false,...
    'EndOfLine', '\r\n');
% Close the text file.
fclose(fileID);
% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end
% Split data into numeric and string columns.
rawNumericColumns = raw(:, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]);
rawStringColumns = string(raw(:, [16,17]));
% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
for catIdx = [1,2]
    idx = (rawStringColumns(:, catIdx) == "<undefined>");
    rawStringColumns(idx, catIdx) = "";
end
% Create output variable
Finnmaid2018 = table;
Finnmaid2018.datenum = cell2mat(rawNumericColumns(:, 1));
Finnmaid2018.year = cell2mat(rawNumericColumns(:, 2));
Finnmaid2018.month = cell2mat(rawNumericColumns(:, 3));
Finnmaid2018.day = cell2mat(rawNumericColumns(:, 4));
Finnmaid2018.hour = cell2mat(rawNumericColumns(:, 5));
Finnmaid2018.min = cell2mat(rawNumericColumns(:, 6));
Finnmaid2018.LongitudeE = cell2mat(rawNumericColumns(:, 7));
Finnmaid2018.LatitudeN = cell2mat(rawNumericColumns(:, 8));
Finnmaid2018.TinsituC = cell2mat(rawNumericColumns(:, 9));
Finnmaid2018.Salpsu = cell2mat(rawNumericColumns(:, 10));
Finnmaid2018.patmhPa = cell2mat(rawNumericColumns(:, 11));
Finnmaid2018.xCO2_dryppm = cell2mat(rawNumericColumns(:, 12));
Finnmaid2018.TEQC = cell2mat(rawNumericColumns(:, 13));
Finnmaid2018.H2Oppt = cell2mat(rawNumericColumns(:, 14));
Finnmaid2018.pCO2_insituatm = cell2mat(rawNumericColumns(:, 15));
Finnmaid2018.pCO2_Line = categorical(rawStringColumns(:, 1));
Finnmaid2018.Flag = categorical(rawStringColumns(:, 2));
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw ...
    col numericData rawData row regexstr result numbers ...
    invalidThousandsSeparator thousandsRegExp rawNumericColumns ...
    rawStringColumns R catIdx idx;
%% Order chronologically
Finnmaid2018_chr = sortrows(Finnmaid2018,'datenum');

% Create "seconds" column, from datenum (column 1)
[yt,mt,dt,ht,mit,st]=datevec(Finnmaid2018_chr.datenum);
Finnmaid2018_chr.sec = floor(st);

expocode=['34FM2018'];
% clear templistoffiles *merged* *t s si
save([expocode,'.mat']);

% All seconds are integers as given from datenum

%% Find when a new sensor starts 
% Assign numerical codes to sensors, register first day of each
clc; clear all; close all
load('34FM2018.mat');


for ind=1:length(Finnmaid2018_chr.pCO2_Line);
if Finnmaid2018_chr.pCO2_Line(ind)=='LICOR';
sensorcode(ind,1)=1;
elseif Finnmaid2018_chr.pCO2_Line(ind)=='LOS GATOS';
sensorcode(ind,1)=2;
end
end
%
sensorcode_difference=sensorcode(2:end)-sensorcode(1:end-1);
newsensor=[1;find(sensorcode_difference~=0)+1];
newsensor_start=[newsensor;size(Finnmaid2018_chr,1)+1];

% Check data over gas standards
% 10.05.2017-16.04.2018 = 411.30 ppm CO2, 
% 17.04.-09.10.2018 = 409.48 ppm CO2,  
% 10.10.-17.12.2018 = 407.51 ppm CO2

% Plot assuming 410
figure
scatter(Finnmaid2018_chr.datenum, Finnmaid2018_chr.pCO2_insituatm,1,Finnmaid2018_chr.pCO2_Line)
colormap(jet)
hold on
plot([min(Finnmaid2018_chr.datenum),max(Finnmaid2018_chr.datenum)],[410,410], 'k')
plot([min(Finnmaid2018_chr.datenum),max(Finnmaid2018_chr.datenum)],[410*1.2,410*1.2], '--k')
datetick('x')
saveas(gcf,'Finnmaid2018_sensors','png')

% Split additionally by time gap (>5 days), and roughly 1st September
datedifference = Finnmaid2018_chr.datenum(2:end)-...
    Finnmaid2018_chr.datenum(1:end-1);
newdategap = find(abs(datedifference)>=5)+1;

% Split in August 2018 to allow some LOS GATOS data (summer) to get a
% better flag
pco2worseind=107432; % 21-Aug-2018 15:32:24 

% split by salinity comment
for ind=1:length(Finnmaid2018_chr.pCO2_Line);
if Finnmaid2018_chr.Flag(ind)=='ok';
flagcode(ind,1)=1;
else
flagcode(ind,1)=2;
end
end
%
flagcode_difference=flagcode(2:end)-flagcode(1:end-1);
newflag=[1;find(flagcode_difference~=0)+1];
newflag_start=[newflag;size(Finnmaid2018_chr,1)+1];

splitind=sort(vertcat(newsensor_start,newdategap,pco2worseind,newflag_start))

%
for i=1:length(splitind)-1;
    dumdatasets(splitind(i):splitind(i+1)-1)=i;
end
figure
scatter(Finnmaid2018_chr.datenum, Finnmaid2018_chr.pCO2_insituatm,1,dumdatasets)
datetick('x')
saveas(gcf,'Finnmaid2018_datasets','png')

% Split
%
% headerline=Finnmaid2018_chr.Properties.VariableNames;
for ind=1:length(splitind)-1;
    expocodefull=[expocode,...
        num2str(Finnmaid2018_chr.month(splitind(ind)),'%02d'),...
     num2str(Finnmaid2018_chr.day(splitind(ind)),'%02d')];

 writetable(Finnmaid2018_chr(splitind(ind):splitind(ind+1)-1,:),...
    [expocodefull,'data.txt'],'Delimiter', '\t');

 fid=fopen([expocodefull,'header.txt'],'w');
fprintf(fid,['Expocode: ',expocodefull,'\n']);
fprintf(fid, 'Ship name: Finnmaid\n');
fprintf(fid, 'PIs: Rehder, G.; Glockzin, M.\n');
fprintf(fid, 'Vessel type: Ship\n');
fclose(fid)

system(['cat ',expocodefull,'header.txt ',expocodefull,'data.txt >',expocodefull,'.txt'])
system(['rm ',expocodefull,'header.txt ',expocodefull,'data.txt'])
end



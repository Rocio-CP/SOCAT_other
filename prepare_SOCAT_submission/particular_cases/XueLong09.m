clc
clear all


% Set paths
% Path of original data
datadir = ['/Users/rpr061/Dropbox/SOCATv6/Data/received_by_mail/',...
    'Suqing Xu/work_space/'];

% Working directory (local)
workdir = ['/Users/rpr061/Dropbox/SOCATv6/Data/received_by_mail/',...
    'Suqing Xu/work_space/'];

cd(workdir)

%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/rpr061/Dropbox/SOCATv6/Data/received_by_mail/Suqing Xu/work_space/26th-CHINARE_2018SOCAT.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2018/01/31 17:24:21

% Initialize variables.
filename = '/Users/rpr061/Dropbox/SOCATv6/Data/received_by_mail/Suqing Xu/work_space/26th-CHINARE_2018SOCAT.csv';
delimiter = ',';
startRow = 2;

% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

% Close the text file.
fclose(fileID);

% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,5,6,7,8,9,10,11]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using the
% specified date format.
try
    dates{4} = datetime(dataArray{4}, 'Format', 'HH:mm:ss', 'InputFormat', 'HH:mm:ss');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{4} = cellfun(@(x) x(2:end-1), dataArray{4}, 'UniformOutput', false);
        dates{4} = datetime(dataArray{4}, 'Format', 'HH:mm:ss', 'InputFormat', 'HH:mm:ss');
    catch
        dates{4} = repmat(datetime([NaN NaN NaN]), size(dataArray{4}));
    end
end

anyBlankDates = cellfun(@isempty, dataArray{4});
anyInvalidDates = isnan(dates{4}.Hour) - anyBlankDates;
dates = dates(:,4);

% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [2,5,6,7,8,9,10,11]);
rawCellColumns = raw(:, [1,3]);


% Allocate imported array to column variable names
CruiseID = rawCellColumns(:, 1);
JD_GMT = cell2mat(rawNumericColumns(:, 1));
DATE_UTC__ddmmyyyy = rawCellColumns(:, 2);
TIME_UTC_hhmmss = dates{:, 1};
longitudedecdegE = cell2mat(rawNumericColumns(:, 2));
latitudedecdegN = cell2mat(rawNumericColumns(:, 3));
fCO2recuatm = cell2mat(rawNumericColumns(:, 4));
GVCO2umolmol = cell2mat(rawNumericColumns(:, 5));
PPPPhPa = cell2mat(rawNumericColumns(:, 6));
SSTdegC = cell2mat(rawNumericColumns(:, 7));
SAL_permil = cell2mat(rawNumericColumns(:, 8));

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% TIME_UTC_hhmmss=datenum(TIME_UTC_hhmmss);


% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me dates blankDates anyBlankDates invalidDates anyInvalidDates rawNumericColumns rawCellColumns;
%% Create datenum column and order by datenum
date_vector=datevec(DATE_UTC__ddmmyyyy, 'ddmmyyyy');
time_vector=datevec(TIME_UTC_hhmmss);
datetime_vector=[date_vector(:,1:3),time_vector(:,4:6)];
datetimenumber=datenum(datetime_vector);
% Sorting indices
[s,si]=sort(datetimenumber);


variables={'CruiseID','JD_GMT','DATE_UTC__ddmmyyyy','TIME_UTC_hhmmss',...
    'longitudedecdegE','latitudedecdegN','fCO2recuatm','GVCO2umolmol',...
    'PPPPhPa','SSTdegC','SAL_permil'};

for v=1:length(variables);
    eval([variables{v},'=',variables{v}, '(si);']);
end

%% Write file
%  fid=fopen(['76XL20091101.txt'],'w');
% 
% % Variables names
% fprintf(fid,[repmat('%s\t',1,10),'%s\n'], variables{:});
% 
% % Data
% for d=1:length(CruiseID);
%     fprintf(fid,...
%         '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
%         eval([variables{1},'{d}']),...
%         num2str(eval([variables{2},'(d)']),[0,9]),...
%         eval([variables{3},'{d}']),...
%         eval([variables{4},'(d)']),...
%         num2str(eval([variables{5},'(d)']),[0,2]),...
%         num2str(eval([variables{6},'(d)']),[0,2]),...
%         num2str(eval([variables{7},'(d)']),[0,4]),...
%         num2str(eval([variables{8},'(d)']),[0,2]),...
%         num2str(eval([variables{9},'(d)']),[0,2]),...
%         num2str(eval([variables{10},'(d)']),[0,2]),...
%         num2str(eval([variables{11},'(d)']),[0,2]));
% end
% 
% fclose(fid);
   
%% Data had duplicate seconds (on top of not being in chronological order)
% Run Camilla script + add seconds + re-write the file

tempartisec=importdata('artificial_seconds.txt', '\t',1);
artsecs=tempartisec.data(:,4);
TIME_UTC_hhmmss=TIME_UTC_hhmmss + seconds(artsecs);


 fid=fopen(['76XL20091101.txt'],'w');

% Variables names
fprintf(fid,[repmat('%s\t',1,10),'%s\n'], variables{:});

% Data
for d=1:length(CruiseID);
    fprintf(fid,...
        '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
        eval([variables{1},'{d}']),...
        num2str(eval([variables{2},'(d)']),[0,9]),...
        eval([variables{3},'{d}']),...
        eval([variables{4},'(d)']),...
        num2str(eval([variables{5},'(d)']),[0,2]),...
        num2str(eval([variables{6},'(d)']),[0,2]),...
        num2str(eval([variables{7},'(d)']),[0,4]),...
        num2str(eval([variables{8},'(d)']),[0,2]),...
        num2str(eval([variables{9},'(d)']),[0,2]),...
        num2str(eval([variables{10},'(d)']),[0,2]),...
        num2str(eval([variables{11},'(d)']),[0,2]));
end

fclose(fid);

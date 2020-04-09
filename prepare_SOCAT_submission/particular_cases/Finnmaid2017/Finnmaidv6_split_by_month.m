clc
clear all


% Set paths
% Path of original data
datadir = ['/Users/rpr061/Dropbox/SOCATv6/Data/', ...
'received_by_mail/Michael Glockzin/original_data/', ...
'SOCAT_pCO2_Data_2017/'];

% Working directory (local)
workdir = ['/Users/rpr061/Documents/DATAMANAGEMENT/SOCAT/',...
    'Test_area/Finnmaid v6/'];


%% --- MERGE PER MONTH; PROBLEMS WRITING DATENUM INTO TEXT FILE ---
% Copy files to working directory, by month

cd(workdir)
% Create 12 folders, for the 12 months of the year (data only from 2017!!)
% At the end, delete the empty folders
for m=1:12; mkdir(['Month_', num2str(m)]); end

% Copy files into their respective folders
for m=1:12;
    templistoffiles=dir([datadir,'**/*Month_',num2str(m),'*.xlsx']);
    if ~isempty(templistoffiles);
        for f=1:numel(templistoffiles);
            % dir does not add the trailing slash in the folder field
            fullpathfile=[templistoffiles(f).folder, '/',...
                templistoffiles(f).name];
            copyfile(fullpathfile, [workdir,'Month_',num2str(m)]);
            clear fullpathfile
        end
    end
    clear templistoffiles
end

% Remove empty folders; create "existingmonth" vector for future use
existingmonth=nan(1,12);
for m=1:12;
    if numel(dir(['Month_',num2str(m)]))>2;
        existingmonth(m)=m;
    else
        rmdir(['Month_',num2str(m)]);
    end
end
existingmonth=existingmonth(~isnan(existingmonth));

%% Merge data in one single file, order by timestamp and 
%% save in tab-delimited format

% Merge data
for em=(existingmonth);
    cd([workdir, 'Month_',num2str(em)]);
    templistoffiles=dir('*.xlsx');
    
    % Import excel data and append to cell variable datamerged
    for f=1:numel(templistoffiles);
    [numdata, header, raw]= xlsread(templistoffiles(f).name);
    datamerged{f,1}=numdata;
    headermerged{f,1}=header(1,:);
    sensormerged{f,1}=raw(2:end, 16);
    clear numdata header raw
    end

% Un-nest
datamerged=vertcat(datamerged{:});
headermerged=vertcat(headermerged{:});
sensormerged=vertcat(sensormerged{:});

% Create "seconds" column, from datenum (column 1)
[yt,mt,dt,ht,mit,st]=datevec(datamerged(:,1));

% Order data by timestamp
[s,si]=sort(datamerged(:,1));
datamerged_sorted=datamerged(si,:);
sensormerged_sorted=sensormerged{si,:};
secmerged_sorted=st(si);

% Save variable seconds to append to excel file
expocode=['34FM2017',num2str(datamerged_sorted(1,3),'%02d'),...
     num2str(datamerged_sorted(1,4),'%02d')];
fid=fopen([expocode,'_seconds.txt'], 'w');
fprintf(fid,'%d\n',secmerged_sorted)
fclose(fid)

clear templistoffiles *merged* *t s si
cd(workdir)
end 
%% Write to tab-delimited .txt file
% % Get expocode:
% expocode=['34FM2017',num2str(datamerged(1,3),'%02d'),...
%     num2str(datamerged(1,4),'%02d')];
% % Header line
% headerline=[headermerged{1,:},{'sec'}];
% 
% % Open file and write
% fid=fopen([expocode,'.txt'],'w');
% % 4-line header
% fprintf(fid,['Expocode: ',expocode,'\n']);
% fprintf(fid, 'Ship name: Finnmaid\n');
% fprintf(fid, 'PIs: Rehder, G.; Glockzin, M.\n');
% fprintf(fid, 'Vessel type: Ship\n\n');
% 
% % Variables names
% fprint(fid, [headerline, '\n']);
% 
% % Data
% for d=1:numel(sensormerged_sorted);
%     fprintf(fid,...
%         '%f \t   \n',...
%         datamerged_sorted(d),sensormerged_sorted{d},secmerged_sorted(f));
% 
% 
% fclose(fid)
% 
% end
% 
% end
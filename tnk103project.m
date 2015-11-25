% This script is an example of how to get dynamic parameters from the MMS
% database.

%% Setup
clear all
clc
close all
% 
% 
% % Adding a path to the top folder.
addpath(genpath('H:\TNK103\'),'-end');
% % 
import core.*               %Core classes

% Setting the enviroment (i.e loading all jar files)
% We do not wanna set the enviroment if it is allready set.
try
    Time(); % This is just to see if the import was successful.
catch
    setEnviroment
end

    % Importing all java classes that will be used.
    import java.lang.*          %String classes
    import java.util.*          %Wrapper classes
    import core.*               %Core classes
    import matrix.*             %Matrix classes
    import netconfig.*          %Network clases
    import bAE.*               %Output data classes not needed in this example
    import highwaycommon.*      %Parameter classes
    %import highwayflowmodel.*  %Flow model classes not needed in this example
    %import highway.*           %Highway classes not needed in this example

    % Setting the network id and configuration id.
    NETWORKID = 50;
    CONFIGURATIONID = 15001;

    core.Monitor.set_db_env('tal_local') 
    core.Monitor.set_prog_name('mms_matlab')
    core.Monitor.set_nid(NETWORKID);
    core.Monitor.set_cid(CONFIGURATIONID);


% Kan behövas
% fundamentalDiagramObject = datatypes.FundamentalDiagramParameters(network, CONFIGURATIONID);

% Creating a network object.
network = Network();


% linksInNetwork = fundamentalDiagramObject.getAvalibleAreas;
% f = fundamentalDiagramObject.readFromDatabaseAsTable(linksInNetwork(1));


%% getSensorData - do a function 
sensorIdArray = [244 243 239 238 236 235 231 230 229 227 226 225 224 223 222 221];

startTime = Time.newTimeFromBerkeleyDateTime(2013,03,21,8,0,0,0);
endTime = Time.newTimeFromBerkeleyDateTime(2013,03,21,10,0,0,0);

for i = 1:size(sensorIdArray,2)
sensorId = Integer(sensorIdArray(i));
sensorData = output.SensorOutput.getSensorOutput(network,sensorId,startTime,endTime);
sensorData2 = sensorData.speed .* 3.6;

% If the sendorData from a specific sensor is larger or smaller than the
% number of sensorData from the previous sensors.
if i~= 1 && size(sensorData2,1) < size(sensorDataArray,1)
sensorDataArray = sensorDataArray(1:size(sensorData2,1),:);

elseif i~= 1 && size(sensorData2,1) > size(sensorDataArray,1)
sensorData2 = sensorData2(1:size(sensorDataArray,1));
end
    
sensorDataArray(:,i) = sensorData2;
end
%%

numberOfCells = 0;
cellSize = 0;
lengthStretch = 0;
linkIdArray = [11269 14136 6189 8568 15256 9150 38698 9160 71687 9198];
numberOfTimeSteps = size(sensorDataArray,1);
numberOfSensors = size(sensorIdArray,2);

for j = linkIdArray    
link = network.getLinkWithID(j);
numberOfCells(end+1) = link.getNbCells;
cellSize(end+1) = link.getLength / numberOfCells(end);
lengthStretch = lengthStretch + link.getLength;
end

numberOfCells = numberOfCells(2:end);
cellSize = cellSize(2:end);
totalNumberOfCells = sum(numberOfCells);

sensor = network.getRadarSensors;

sensorArray = 0;
for k=1:size(sensor,1)
sensorArray(end+1) = sensor(k).ID;
end
% sensorArray consists of all the sensor's ID in network 50
sensorArray = sensorArray(2:end);

sensorOffset = 0;
indexArray=0;
for m = sensorIdArray
index = find(sensorArray == m);
sensorOffset(end+1) = sensor(index).offset;
indexArray(end+1)=index;
end
% The offset to the sensor's location of the link 
sensorOffset = sensorOffset(2:end);
indexArray = indexArray(2:end);
% Get the 

% sensorDataCellArray = cell(size(linkIdArray),1)

% Initialize cellSpeed which consists of the speed for each cell in each
% link 
for i = 1:size(linkIdArray,2)
cellSpeed{i} = zeros(numberOfCells(i),1);
end

% sensorInCell = zeros(totalNumberOfCells,1);

temp = NaN(totalNumberOfCells, numberOfTimeSteps);


for n=1:numberOfSensors
currentNumberOfCells = 0;
% size(sensorIdArray,2)

    link=sensor(indexArray(n)).link.id;
% index is the segment number (1-10)
    index = find(linkIdArray == link);

for i=(index-1):-1:1
   currentNumberOfCells = currentNumberOfCells + numberOfCells(i);
end
    
    cellWithSensor=ceil(sensorOffset(n)/cellSize(index));
% If there is a sensor located in the cell, the element is set to 1.  
    temp(currentNumberOfCells+cellWithSensor,:)=sensorDataArray(:,n);

end

% figure(1)

% temp=[rows=cells, columns=timesteps]
plotHeatMap(temp);

function = plotHeatMap(temp)
load('mycmap','cm')
imagesc(temp);
colormap(cm)
colorbar
end
 
%% Spara ny colomap: %%
% 1. Kör följande i m-fil.
%   colormap ('jet')
%   title('speed contour plot')
%   imagesc(temp);
%   colorbar;
% 2. Öppna colormapeditor från kommandofönstret och ändra till önskad
% layout
% 3. Spara layoten i egen variabel från kommandofönstret: 
% cm=colormap
% 4. Spara ner cm i en mat-fil
% save mycmap cm
% 
%%
 
%% Sparas endast för om vi vill använda cell arrays
% % cellSpeed includes index number of arrays. Each array is
% % cellWithSensor for each index (cell)
%      c=cellSpeed{index};
% % Insert the "xxxdata" on place cellWithSensor in array c and then insert the uppdated
% % array c in cellSpeed
%      c(cellWithSensor,1)=sensorDataArray(1,1);
%      cellSpeed{index}=c;
%%

%tagit bort saker…






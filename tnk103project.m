% This script is an example of how to get dynamic parameters from the MMS
% database.

%% Setup
clear all
clc
close all
%
%
% % Adding a path to the top folder.
%       addpath(genpath('H:\TNK103\'),'-end');
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
import bAE.*                %Output data classes not needed in this example
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

% Creating a network object.
network = Network();

%% Declare which sensors and links that are to be used and the selected start and end time.
sensorIdArray = [244 243 239 238 236 235 231 230 229 227 226 225 224 223 222 221];
linkIdArray = [11269 14136 6189 8568 15256 9150 38698 9160 71687 9198];

%%

numberOfLinks = size(linkIdArray,2);

% 2013 mars: monday=4,11,18 tuesday=

firstDay = 7;
numberOfDays = 1;
numberOfWeeks = 1;

for day = 1:numberOfDays
    
    for week = 1:numberOfWeeks
        
        date = firstDay-1+day+(week-1)*7;
        %     date = 21;
        startTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,6,30,59,59);
        endTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,9,30,0,0);
        
        
        %% get all the sensors' speed and flow for each timestep
        [sensorSpeedArray,sensorFlowArray, numberOfTimeSteps,numberOfSensors,sensorData]=getSensorData(network,sensorIdArray,startTime,endTime);
        %%
        
        %% get cell attributes
        [numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray);
        %%
        
        %% create the
        [sensorCellSpeedArray, sensorCellTravelTimesArray,indexArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray);
        %%
        % spara för varje vecka
        sensorCellSpeedArrayWeek(:,:,week) = sensorCellSpeedArray;
        
        
        %% plot heat maps of stretch speeds and travel times
%         h=figure(date);
%         plotHeatMap(sensorCellSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'date');
                               
%         filename1 = sprintf('H:\\TNK103\\plots\\%d', date)
%         print(h,'-dpng',filename1)
        %                 figure(date)
        %                 plotHeatMap(sensorCellTravelTimesArray,startTime, endTime, numberOfTimeSteps,'date');
        %%
    end
    
    %%      calculate mean of e.g. Thursdays
    sensorCellMeanSpeedArray = nanmean(sensorCellSpeedArrayWeek,3);
%          h=figure(1)
%          plotHeatMap(sensorCellMeanSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'Thursdays');
%          print(h,'-dpng','H:\TNK103\plots\thursdayMean.png')
    %%
    
end

% %% algorithm 1 - radar sensors, only space fill
% [sensorAllCellsSpeedArray, sensorAllCellsTravelTimesArray] = algorithm1(network,sensorCellSpeedArray,numberOfTimeSteps,totalNumberOfCells,indexArray,linkIdArray,numberOfCells,cellSize);
% h=figure(1)
% plotHeatMap(sensorAllCellsSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps, 'Algorithm 1: Only space fill');
% print(h,'-dpng','H:\TNK103\plots\algorithm1For7mars.png')
% %%
% 
% %% algorithm 2 - radar sensors, spatiotemporal interpolation
% h=figure(2)
estimatedSpeedAlg2 = algorithm2(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
[travelTimesArray]=plotHeatMap(estimatedSpeedAlg2.*3.6,startTime, endTime, numberOfTimeSteps,cellSizeAll, 'Algorithm 2: Spatiotemporal Interpolation');
% print(h,'-dpng','H:\TNK103\plots\algorithm2For7mars.png')
% %%
travelTimesArray'

%% algorithm 3 - radar sensors, adaptive smoothing method
% h=figure(3)
% estimatedSpeedAlg3 = algorithm3(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
% plotHeatMap(estimatedSpeedAlg3.*3.6,startTime, endTime, numberOfTimeSteps,cellSizeAll, 'Algorithm 3: Adaptive Smoothing Method');
% print(h,'-dpng','H:\TNK103\plots\algorithm3For7mars.png')
%%
% hold on
% NumOfIntervals = 10;
% % var 5:e minut
% steplength = 5;
% start_time = 1;
% hej = travelTimesInterval(estimatedSpeedAlg3.*3.6, start_time, NumOfIntervals, steplength, cellSizeAll)
% plot(hej)

% plot(hej')

% hej = travelTimesInterval(estimatedSpeedAlg2, 1, NumOfIntervals, steplength, cellSizeAll);



%% difference between arrays
%     sensorCellSpeedArrayDay(:,:,day);

%     ett=sensorCellSpeedArrayWeek(:,:,1);
%     tva=sensorCellSpeedArrayWeek(:,:,2);
%     tva=sensorCellSpeedArrayWeek(:,:,3);
%
%     diff = abs(sensorCellSpeedArrayWeek(:,:,1)-sensorCellSpeedArrayWeek(:,:,2)).*3.6;
%     figure(1)
%     plotHeatMap(diff,startTime, endTime, numberOfTimeSteps);
%
%     meanOfDifference = mean(nonzeros(diff));
%%

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
% % sensorDataCellArray = cell(size(linkIdArray),1)
%
% % Initialize cellSpeed which consists of the speed for each cell in each
% % link
% for i = 1:size(linkIdArray,2)
% cellSpeed{i} = zeros(numberOfCells(i),1);
% end
% % cellSpeed includes index number of arrays. Each array is
% % cellWithSensor for each index (cell)
%      c=cellSpeed{index};
% % Insert the "xxxdata" on place cellWithSensor in array c and then insert the uppdated
% % array c in cellSpeed
%      c(cellWithSensor,1)=sensorDataArray(1,1);
%      cellSpeed{index}=c;
%%






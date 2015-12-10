% This script is an example of how to get dynamic parameters from the MMS
% database.

%% Setup
% clear all
clc
close all
%
%
% % Adding a path to the top folder.
%       addpath(genpath('../'),'-end');
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

% stepLength is what interval the vehicles are to be simulated thorugh the
% stretch, in minutes
steplength = 5;

% the preferred time step (in minutes) between the ticks on the x-axis
% timeStep = 30;
firstCell = 9;
%%

% numberOfLinks is the total number of links of the stretch
numberOfLinks = size(linkIdArray,2);

% 2013 march: mondays=4,11,18, tuesdays=5,12,19, wednesdays=6,13,20,
% thursdays=7,14,21, fridays=8,15,22
firstDay = 21;
% numberOfDays is the preferred number of days and numberOfWeeks is 
% the preferred number of weeks 
numberOfDays = 1;
numberOfWeeks = 1;

for day = 1:numberOfDays
    
    for week = 1:numberOfWeeks
        
        date = firstDay-1+day+(week-1)*7;
      
        startTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,6,30,59,59);
        endTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,9,30,0,0);

        %% get all the sensors' speed and flow for each minute between startTime and endTime
        [sensorSpeedArray,sensorFlowArray, numberOfTimeSteps,numberOfSensors,sensorData]=getSensorData(network,sensorIdArray,startTime,endTime);
        %%
        
        %% get the cell attributes 
        [numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray);
        %%
        
        %% create sensorCellSpeedArray with the speed from the radar sensors and sensorCellTravelTimesArray with the travel time in each cell where there are a sensor
        [sensorCellSpeedArray, sensorCellTravelTimesArray,indexArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray);
        %%

        % save the sensorCellSpeedArray for each week
        sensorCellSpeedArrayWeek(:,:,week) = sensorCellSpeedArray;
        
        
        %% plot heat maps of the raw sensor data: the speeds of the stretch, for each date
%         h=figure(date);
%         plotHeatMap(sensorCellSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'date');                  
%         filename1 = sprintf('H:\\TNK103\\plots\\%d', date)
%         print(h,'-dpng',filename1)
        %%
    end
    
    %%      calculate mean speed of the stretch for one day, e.g. Thursdays
%     sensorCellMeanSpeedArray = nanmean(sensorCellSpeedArrayWeek,3);
%          h=figure(100)
%          plotHeatMap(sensorCellMeanSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'Thursdays mean');
%          print(h,'-dpng','H:\TNK103\plots\thursdayMean.png')
    %%
    
end

%% Algorithm 1: radar sensors - only space fill
estimatedSpeedAlg1 = algorithm1(network,sensorCellSpeedArray,numberOfTimeSteps,totalNumberOfCells,indexArray,linkIdArray,numberOfCells,cellSize);
% BEHÖVER INTE RETURNERA DENNA? ->sensorAllCellsTravelTimesArray
h=figure(1);
plotHeatMap(estimatedSpeedAlg1.*3.6,startTime, endTime, numberOfTimeSteps, 'Algorithm 1: Radar sensors - only space fill');
% print(h,'-dpng','H:\TNK103\plots\algorithm1For21mars.png')

% travelTimesArray is the travel time for the stretch between cell 9-50.
% RÄKNA UT TRAVEL TIMES FÖR SEKTIONVIS OCKSÅ HÄR?
[plotTrajectoriesArray,travelTimesArray] = travelTimesInterval(estimatedSpeedAlg2, steplength, cellSizeAll, numberOfTimeSteps);
figure(11)
%  GÖR EN FUNCTION FÖR ATT PLOTTA TRAJECTORIES SNYGGT?
plot(plotTrajectoriesArray')
% plot the travelTimes at different start times
figure(21)
plotTravelTimesDifferentStartTimes(travelTimesArray,startTime,endTime, steplength);
% plot(travelTimesArray)
%%

%% Algorithm 2: radar sensors - Isotropic Smoothing Method
estimatedSpeedAlg2 = algorithm2(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
h=figure(2);
plotHeatMap(estimatedSpeedAlg2.*3.6,startTime, endTime, numberOfTimeSteps, 'Algorithm 2: Radar sensors - Isotropic Smoothing Method');
% print(h,'-dpng','H:\TNK103\plots\algorithm2For21mars.png')
%%

%% Algorithm 3: radar sensors- Adaptive Smoothing Method
estimatedSpeedAlg3 = algorithm3(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
h=figure(3);
plotHeatMap(estimatedSpeedAlg3.*3.6,startTime, endTime, numberOfTimeSteps, 'Algorithm 3:  Radar sensors - Adaptive Smoothing Method');
% print(h,'-dpng','H:\TNK103\plots\algorithm3For21mars.png')
%%

%% Algorithm 4: GPS data - to use in data fusion
load('cellSpeedAggregatedTime')
estimatedSpeedAlg4 = algorithm4(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
h=figure(4);
plotHeatMap(estimatedSpeedAlg4,startTime, endTime, numberOfTimeSteps, 'Algorithm 4: GPS data - to use in data fusion');
% print(h,'-dpng','H:\TNK103\plots\algorithm4For21mars.png')

%%

%% Algorithm 5: GPS data - to use standalone
load('cellSpeedAggregatedTime')
estimatedSpeedAlg5 = algorithm5(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
h=figure(5);
plotHeatMap(estimatedSpeedAlg5,startTime, endTime, numberOfTimeSteps, 'Algorithm 5: GPS data - to use standalone');
% print(h,'-dpng','H:\TNK103\plots\algorithm5For21mars.png')

[plotTrajectoriesArray,travelTimesArray] = travelTimesInterval(estimatedSpeedAlg5, steplength, cellSizeAll, numberOfTimeSteps);
figure(51)
plot(plotTrajectoriesArray')
% figure(51)
% Måste fylla i cell 50 för att kunna jämföra travel times..
% plotTravelTimesDifferentStartTimes(travelTimesArray,startTime,endTime, steplength);
%%

% Algorithm 6: Data fusion for algorithm 2 (radar sensor data) and algorithm 4 (GPS data)

% estimatedSpeedAlg2
% estimatedSpeedAlg4

% h=figure(6);
% plotHeatMap(estimatedSpeedAlg6,startTime, endTime, numberOfTimeSteps, 'Algorithm 6: Data fusion for algorithm 2 (radar sensor data) and algorithm 4 (GPS data)');
% print(h,'-dpng','H:\TNK103\plots\algorithm6For21mars.png')
 
%
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
                        %figure(date)
        %                plotHeatMap(sensorCellSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'date');
        
        %                 figure(date)
        %                 plotHeatMap(sensorCellTravelTimesArray,startTime, endTime, numberOfTimeSteps,'date');
        %%
    end
    
    %%      calculate mean of e.g. Thursdays
    sensorCellMeanSpeedArray = nanmean(sensorCellSpeedArrayWeek,3);
    %     h=figure(1)
    %     plotHeatMap(sensorCellMeanSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'Thursdays');
    %     print(h,'-dpng','H:\TNK103\plots\thursdayMean.png')
    %%
    
end

%% algorithm 1 - radar sensors, only space fill
[sensorAllCellsSpeedArray, sensorAllCellsTravelTimesArray] = algorithm1(network,sensorCellSpeedArray,numberOfTimeSteps,totalNumberOfCells,indexArray,linkIdArray,numberOfCells,cellSize);
%figure(1)
%plotHeatMap(sensorAllCellsSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps, 'Algorithm 1: Only space fill');
%%

%% algorithm 2 - radar sensors, spatiotemporal interpolation
figure(2)
estimatedSpeedAlg2 = algorithm2(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
plotHeatMap(estimatedSpeedAlg2.*3.6,startTime, endTime, numberOfTimeSteps, 'Algorithm 2: Spatiotemporal Interpolation');
%%
%travelTime = trajectory(estimatedSpeed, cellSizeAll, startTime);
NumOfIntervals = 10;
steplength = 5;
hej = travelTimesInterval(estimatedSpeedAlg2, steplength, cellSizeAll, numberOfTimeSteps);

[tt, cells] = getTTFromBluetooth(195, network, starTime, endTime);

figure(3)
plot(hej')

%Mickes lekstuga
x = 1:size(hej, 2);
hej1 = polyfit(x,hej(1,:),2);

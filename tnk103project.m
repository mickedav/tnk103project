% This script is an example of how to get dynamic parameters from the MMS
% database.

%% Setup
clear all
clc
close all
%
%
% % Adding a path to the top folder.
%   addpath(genpath('H:\TNK103\'),'-end');
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

firstDay = 4;
numberOfDays = 1;
numberOfWeeks = 1;

 for day = 1:numberOfDays
    
%      for week = 1:numberOfWeeks
        
%         date = firstDay-1+day+(week-1)*7
date = 21;
        
        %% Declare which sensors and links that are to be used and the selected start and end time.
        sensorIdArray = [244 243 239 238 236 235 231 230 229 227 226 225 224 223 222 221];
        linkIdArray = [11269 14136 6189 8568 15256 9150 38698 9160 71687 9198];
        startTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,6,0,0,0);
        endTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,10,0,0,0);
        %%
        
        %% get all the sensors' speed and flow for each timestep
        [sensorSpeedArray,sensorFlowArray, numberOfTimeSteps,numberOfSensors]=getSensorData(network,sensorIdArray,startTime,endTime);
        %%
        
        %% get cell attributes
        [numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray);
        %%
        
        %% create the
        [sensorCellSpeedArray, sensorCellTravelTimesArray,indexArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray);
        %%
        % spara f�r varje vecka
%         sensorCellSpeedArrayWeek(week,:,:) = sensorCellSpeedArray;
        
        %% plot heat maps of stretch speeds and travel times
            figure(day)
            plotHeatMap(sensorCellSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps);
        % figure(2)
        % plotHeatMap(sensorCellTravelTimesArray,startTime, endTime, numberOfTimeSteps);
        %%
    end
    
    
    %    r�kna fram medelv�rde f�r day, spara i 3D matrix
    %    sensorCellSpeedArrayDay(day,:,:)
    
    
% end

%% algoritm 1 - only for radar sensors
[sensorAllCellsSpeedArray, sensorAllCellsTravelTimesArray] = algoritmSensorStepwiseFill(network,sensorCellSpeedArray,numberOfTimeSteps,totalNumberOfCells,indexArray,linkIdArray,numberOfCells,cellSize);
%%
%



%% Spara ny colomap: %%
% 1. K�r f�ljande i m-fil.
%   colormap ('jet')
%   title('speed contour plot')
%   imagesc(temp);
%   colorbar;
% 2. �ppna colormapeditor fr�n kommandof�nstret och �ndra till �nskad
% layout
% 3. Spara layoten i egen variabel fr�n kommandof�nstret:
% cm=colormap
% 4. Spara ner cm i en mat-fil
% save mycmap cm
%
%%

%% Sparas endast f�r om vi vill anv�nda cell arrays
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







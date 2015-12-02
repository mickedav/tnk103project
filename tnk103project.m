% This script is an example of how to get dynamic parameters from the MMS
% database.

%% Setup
clear all
clc
close all
%
%
% % Adding a path to the top folder.
%      addpath(genpath('H:\TNK103\'),'-end');
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

firstDay = 4;
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
        [numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray);
        %%
        
        %% create the
        [sensorCellSpeedArray, sensorCellTravelTimesArray,indexArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray);
        %%
        % spara för varje vecka
        sensorCellSpeedArrayWeek(:,:,week) = sensorCellSpeedArray;
        
        
        %% plot heat maps of stretch speeds and travel times
        %                 figure(date)
        %                 plotHeatMap(sensorCellSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'date');
        
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

%% algoritm 1 - only for radar sensors
[sensorAllCellsSpeedArray, sensorAllCellsTravelTimesArray] = algoritmSensorStepwiseFill(network,sensorCellSpeedArray,numberOfTimeSteps,totalNumberOfCells,indexArray,linkIdArray,numberOfCells,cellSize);
% figure(date)
% plotHeatMap(sensorAllCellsSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps);
%%

%% START OF ALGORTIHM 2
% fill lengthFromStartHalf with the length from start to half of the cell
% for each cell
% fill lengthFromStartReal with the length from start to the end of the
% cell for each cell

% indexSensorArray consists of each sensor's cell number
sensorCellSpeedArray(isnan(sensorCellSpeedArray)) = 0;
indexSensorArray = find(sensorCellSpeedArray(:,1));

lengthFromStartHalf(1) = cellSize(1)/2;
lengthFromStartReal(1) = cellSize(1);
for i=2:totalNumberOfCells
    currentNumberOfCells = 0;
    index = 0;
    for j=1:numberOfLinks
        currentNumberOfCells =  currentNumberOfCells + numberOfCells(j);
        index = index + 1;
        %         break if cell t is on link number index
        if (i/currentNumberOfCells) <=1
            lengthFromStartHalf(i) = lengthFromStartReal(end) + cellSize(index)./2;
            lengthFromStartReal(i) = lengthFromStartReal(end) + cellSize(index);
            break;
        end
    end
end

% fill lengthBetweenSensors with the distance (meters) between two sensors
for i=2:(numberOfSensors-1)
    distanceBetweenSensors(i-1) = lengthFromStartHalf(indexSensorArray(i))-lengthFromStartHalf(indexSensorArray(i-1));
end

% average distance between two sensors
averageDistanceSensor = mean(distanceBetweenSensors);

%%
% sigma is calculated as half of the average distance between two sensors
sigma = averageDistanceSensor/2;
% tau is set to half of the aggregated interval (1 min)
tau = 0.5;
%%

% %  ------------ FORTSÄTT HÄR -----------------
% for t=numberOfTimeSteps
    
    % loop through all the sensors
    for i=2:(numberOfSensors-1)
        sensor1 = indexSensorArray(i-1);
        sensor2 = indexSensorArray(i);
        
        % if the two sensors are not in neighboring cells, no estimation will be
        % done
        if sensor1+1 ~= sensor2
            
            % for the first cell after the first sensor to the last cell before the
            % next sensor, t.ex. cell 10-11
            for cell=(sensor1+1):(sensor2-1)
                
                % loop for two sensors at the time
                % x is the position in the middle on the cell we want to estimate the speed
                % in
                x = lengthFromStartHalf(cell);
                x1 = lengthFromStartHalf(sensor1);
                x2 = lengthFromStartHalf(sensor2);
                t = 2;
                t1 = t-1;
                t2 = t+1;
                
                N(cell,2) = exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau))) + exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)));
                sumNv(cell,2) = exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau)))*sensorCellSpeedArray(sensor1,t1) + exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)))*sensorCellSpeedArray(sensor2,t2);
                
            end
        end
        sumNv(cell,2)/N(cell,2)
%            estimatedSpeed = sensorCellSpeedArray;
%            estimatedSpeed 
        
    end
% end


%% END OF ALGORTIHM 2

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







% This script is an example of how to get dynamic parameters from the MMS
% database.

%% Setup
clear all
clc
close all
%
%
% % Adding a path to the top folder.
%     addpath(genpath('H:\TNK103\'),'-end');
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
% NumOfIntervals = 10;
% stepLength is what interval the vehicles are to be simulated thorugh the
% stretch, in minutes
steplength = 5;
% the preferred time step (in minutes) between the ticks on the x-axis
% timeStep = 30;

% the stretch will start from cell number 9
firstCell = 9;
%%

numberOfLinks = size(linkIdArray,2);

% 2013 mars: monday=4,11,18 tuesday=

firstDay = 21;
numberOfDays = 1;
numberOfWeeks = 1;

for day = 1:numberOfDays
    
    for week = 1:numberOfWeeks
        
        date = firstDay-1+day+(week-1)*7;
        % date = 21;
        startTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,6,30,59,59);
        endTime = Time.newTimeFromBerkeleyDateTime(2013,03,date,9,30,0,0);
        
        
        %% get all the sensors' speed and flow for each timestep
        [sensorSpeedArray,sensorFlowArray, numberOfTimeSteps,numberOfSensors,sensorData]=getSensorData(network,sensorIdArray,startTime,endTime);
        %%
        
        %% get cell attributes
        [numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray);
        %%
        
        %% create the speed and travel time for each cell, based on the sensor data for that specific cell
        [sensorCellSpeedArray, sensorCellTravelTimesArray,indexArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray);
        %%
        % spara för varje vecka
        sensorCellSpeedArrayWeek(:,:,week) = sensorCellSpeedArray;
        
        
        %% plot heat maps of stretch speeds and travel times
        %         h=figure(date);
        %         plotHeatMap(sensorCellSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'date');
        
        %         filename1 = sprintf('H:\\TNK103\\plots\\%d', date)
        %         print(h,'-dpng',filename1)
        %         figure(date)
        %         plotHeatMap(sensorCellTravelTimesArray,startTime, endTime, numberOfTimeSteps,'date');
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
% plotHeatMap(estimatedSpeedAlg2.*3.6,startTime, endTime, numberOfTimeSteps,cellSizeAll, 'Algorithm 2: Spatiotemporal Interpolation');
% print(h,'-dpng','H:\TNK103\plots\algorithm2For7mars.png')
% %%

% hej is an "array with trajectories" and travelTimesArray is the travel
% time for the stretch between cell 9-50.
% [hej,travelTimesArray] = travelTimesInterval(estimatedSpeedAlg2, steplength, cellSizeAll, numberOfTimeSteps);
%
% %%
% figure(3)
% plot(hej')
% %%
%
% %%
% % plot the travelTimes at different start times
% figure(4)
% plotTravelTimesDifferentStartTimes(travelTimesArray,startTime,endTime, steplength);
% %%

%% Algorithm 4 - for GPS data
load('cellSpeedAggregatedTime')

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


%%
% % sigma is calculated as half of the average distance between two sensors
% sigma = averageDistanceSensor/2;
% tau is set to half of the aggregated interval (1 min)
tau = 0.5;
%%

% cellSpeedAggregatedTime contains NaN-values and GPSCellSpeedArray
% contains zeros instead of NaN
GPSCellSpeedArray = cellSpeedAggregatedTime;
GPSCellSpeedArray(isnan(GPSCellSpeedArray)) = 0;

% Loop through all timesteps
for t=2:(numberOfTimeSteps-1)
    % (numberOfTimeSteps-1)
    y1 = 1; y2 = 1;
    % Loop through all cells from cell 9
    for cell=firstCell:totalNumberOfCells
        
        if isnan(cellSpeedAggregatedTime(cell,t))
            
            % x is the position in the middle on the cell we want to estimate the speed
            % in
            x = lengthFromStartHalf(cell);
            t1 = t+1;
            t2 = t-1;
            
            %             loop for finding x1
            for i=(cell-1):-1:1
                
                if GPSCellSpeedArray(i,t1)== 0 && isnan(cellSpeedAggregatedTime(i,t1))
                    %  if there are no measurement in the cell -> do not use
                    %  any value
                    %                     GPSCellSpeedArray(i,t1)=0;
                    x1 = 0;
                    y1 = 0;
                    cellGPS1 = i;
                    
                else
                    %   if there is a measured or estimated speed that is greater than zero ->
                    %   use this value
                    % x1 is the distance to the closest prevois data point
                    % cellGPS1 is the cell number where the closest prevois data point is
                    % located
                    x1 = lengthFromStartHalf(i);
                    cellGPS1 = i;
                    if abs(x-x1) > 1000
                        % if the distance between the data points is
                        % larger than 1 km -> do not use any value
                        %                         GPSCellSpeedArray(i,t1)=0;
                        y1 = 0;
                    end
                    
                    break;
                    
                end
                
            end
            
            
            %             loop for finding x2
            for i=(cell+1):totalNumberOfCells
                
                if GPSCellSpeedArray(i,t2)== 0 && isnan(cellSpeedAggregatedTime(i,t2))
                    %  if there are no measurement in the cell -> do not use
                    %  any value
                    %                     GPSCellSpeedArray(i,t2)=0;
                    x2 = 0;
                    y2 = 0;
                    cellGPS2 = i;
                    
                else
                    %   if there is a measured or estimated speed that is greater than zero ->
                    %   use this value
                    % x2 is the distance to the closest prevois data point
                    % cellGPS2 is the cell number where the closest prevois data point is
                    % located
                    x2 = lengthFromStartHalf(i);
                    cellGPS2 = i;
                    
                    if abs(x-x2) > 1000
                        % if the distance between the data points is
                        % larger than 1 km -> do not use any value
                        %                          GPSCellSpeedArray(i,t2)=0;
                        y2 = 0;
                    end
                    
                    break;
                    
                end
                
            end
            
            % sigma is calculated as half of the distance between the two data points
            % are used to estimate the speed in the cell
            if x1 == 0
                sigma = abs(x-x2)/2;
                y1 = 0;
            elseif x2  == 0
                sigma = abs(x-x1)/2;
                y2 = 0;
            else
                sigma = abs(x1-x2)/2;
            end
            
            %             if
            if y1==0 && y2 ==0
               GPSCellSpeedArray(cell,t)=GPSCellSpeedArray(cell-1,t);
            else
                
                N = y1*exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau))) + y2*exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)));
                sumNv = y1*exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau)))*GPSCellSpeedArray(cellGPS1,t1) + y2*exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)))*GPSCellSpeedArray(cellGPS2,t2);
                GPSCellSpeedArray(cell,t)=sumNv/N;
            end
            
            
            %           % loop for two sensors at the time
            
            %                 x1 = lengthFromStartHalf(sensor1);
            %                 x2 = lengthFromStartHalf(sensor2);
            %                 t2 = t-1;
            %                 t1 = t+1;
            
        end
        
        
    end
    
end
 plotHeatMap(GPSCellSpeedArray,startTime, endTime, numberOfTimeSteps, 'Algorithm 4: GPS data only');

%%

%% algorithm 3 - radar sensors, adaptive smoothing method
% h=figure(3)
% estimatedSpeedAlg3 = algorithm3(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
% plotHeatMap(estimatedSpeedAlg3.*3.6,startTime, endTime, numberOfTimeSteps, 'Algorithm 3: Adaptive Smoothing Method');
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






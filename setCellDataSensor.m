function [sensorCellSpeedArray, sensorCellTravelTimesArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray)

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

% sensorInCell = zeros(totalNumberOfCells,1);

sensorCellSpeedArray = zeros(totalNumberOfCells, numberOfTimeSteps);
sensorCellTravelTimesArray = zeros(totalNumberOfCells,numberOfTimeSteps);

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
% If there is a sensor located in the cell, the element is set to speed.
    sensorCellSpeedArray(currentNumberOfCells+cellWithSensor,:)=sensorSpeedArray(:,n);
% travel times is given in seconds
    sensorCellTravelTimesArray(currentNumberOfCells+cellWithSensor,:)=cellSize(index)./sensorSpeedArray(:,n);
end


end
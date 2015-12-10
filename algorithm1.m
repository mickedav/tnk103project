function [sensorAllCellsSpeedArray] = algorithm1(network,sensorCellSpeedArray,numberOfTimeSteps,totalNumberOfCells,indexArray,linkIdArray,numberOfCells,cellSize)
% sensorAllCellsTravelTimesArray
sensor = network.getRadarSensors;

sensorCellSpeedArray(isnan(sensorCellSpeedArray)) = 0;
sensorAllCellsSpeedArray=sensorCellSpeedArray;
indexSensorArray = find(sensorCellSpeedArray(:,1));

% fill sensorAllCellsSpeedArray
for j=1:numberOfTimeSteps
    for k = 2:size(indexSensorArray,1)
        indexDifference = (indexSensorArray(k)-indexSensorArray(k-1));
        speedDifference=(sensorCellSpeedArray(indexSensorArray(k),j)-sensorCellSpeedArray(indexSensorArray(k-1),j))/indexDifference;
        
        for i = 1:(indexDifference-1)
            sensorAllCellsSpeedArray(indexSensorArray(k-1)+i,j) = sensorCellSpeedArray(indexSensorArray(k-1),j) + i*speedDifference;
        end
    end
end

% do not calculate the travel times for cells before the first sensor
for t=indexSensorArray(1):totalNumberOfCells
    currentNumberOfCells = 0;
    index = 0;
   
    for i=1:size(numberOfCells,2)
        currentNumberOfCells =  currentNumberOfCells + numberOfCells(i);
        index = index + 1;
%         break if cell t is on link number index
        if (t/currentNumberOfCells) <=1
            
            break;
            
        end
        
    end
    
%     sensorAllCellsTravelTimesArray(t,:) = cellSize(index)./sensorAllCellsSpeedArray(t,:);
end

end
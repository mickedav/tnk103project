function [sensorAllCellsSpeedArray, sensorAllCellsTravelTimesArray] = algoritmSensorStepwiseFill(network,sensorCellSpeedArray,numberOfTimeSteps,totalNumberOfCells,indexArray,linkIdArray)

sensor = network.getRadarSensors;

sensorAllCellsSpeedArray = sensorCellSpeedArray;
indexSensorArray = find(sensorCellSpeedArray(:,1));

for j=1:numberOfTimeSteps
    
    for k = 2:size(indexSensorArray,1)
        indexDifference = (indexSensorArray(k)-indexSensorArray(k-1));
        speedDifference=(sensorCellSpeedArray(indexSensorArray(k),j)-sensorCellSpeedArray(indexSensorArray(k-1),j))/indexDifference;
        
        for i = 1:(indexDifference-1)
            sensorAllCellsSpeedArray(indexSensorArray(k-1)+i,j) = sensorCellSpeedArray(indexSensorArray(k-1),j) + i*speedDifference;
        end
    end
end



% % % % % % % FIXA HÄR 
% % link=sensor(25).link.id
% 
% % do not calculate the travel times for cells before the first sensor
% for t=indexSensorArray(1):totalNumberOfCells
% % indexSensorArray(t+1-indexSensorArray(1))
%     link=sensor(indexArray(indexSensorArray(t+1-indexSensorArray(1)))).link.id
% % index is the segment number (1-10)
%     index = find(linkIdArray == link);
%     
%     sensorAllCellsTravelTimesArray = cellSize(index)./sensorCellSpeedArray(:,t);
% end

end
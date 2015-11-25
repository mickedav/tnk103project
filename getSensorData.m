function [sensorSpeedArray,sensorFlowArray,numberOfTimeSteps,numberOfSensors] = getSensorData(network,sensorIdArray,startTime,endTime)
import java.lang.*
import core.*    

for i = 1:size(sensorIdArray,2)
sensorId = Integer(sensorIdArray(i));
sensorData = output.SensorOutput.getSensorOutput(network,sensorId,startTime,endTime);
sensorDataSpeed = sensorData.speed;
sensorDataFlow = sensorData.flow;

% If the sendorData from a specific sensor is larger or smaller than the
% number of sensorData from the previous sensors.
if i~= 1 && size(sensorDataSpeed,1) < size(sensorSpeedArray,1)
sensorSpeedArray = sensorSpeedArray(1:size(sensorDataSpeed,1),:);
sensorFlowArray = sensorFlowArray(1:size(sensorDataSpeed,1),:);

elseif i~= 1 && size(sensorDataSpeed,1) > size(sensorSpeedArray,1)
sensorDataSpeed = sensorDataSpeed(1:size(sensorSpeedArray,1));
sensorDataFlow  = sensorDataFlow (1:size(sensorFlowArray,1));
end
    
sensorSpeedArray(:,i) = sensorDataSpeed;
sensorFlowArray(:,i) = sensorDataFlow;
end

numberOfTimeSteps = size(sensorSpeedArray,1);
numberOfSensors = size(sensorIdArray,2);

end
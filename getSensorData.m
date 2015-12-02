function [sensorSpeedArray,sensorFlowArray,numberOfTimeSteps,numberOfSensors,sensorData] = getSensorData(network,sensorIdArray,startTime,endTime)
import java.lang.*
import core.*

% calculate the startminute in minutes after midnight
startTimeString=matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(startTime);
[Y, M, D, H, MN, S] = datevec(startTimeString);
startMinute = H*60+MN+1;

endTimeString=matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(endTime);
[Y, M, D, H, MN, S] = datevec(endTimeString);
endMinute = H*60+MN+1;

numberOfTimeSteps = endMinute - startMinute;
numberOfSensors = size(sensorIdArray,2);

sensorSpeedArray = NaN(numberOfTimeSteps,numberOfSensors);
sensorFlowArray = NaN(numberOfTimeSteps,numberOfSensors);

for i = 1:numberOfSensors
    sensorId = Integer(sensorIdArray(i));
    sensorData = output.SensorOutput.getSensorOutput(network,sensorId,startTime,endTime);
    sensorDataSpeed = sensorData.speed;
    sensorDataFlow = sensorData.flow;
    
    numberOfRealTimeSteps = size(sensorDataFlow,1);
    
    for t = 1:numberOfRealTimeSteps
        sensorTimeStamp=sensorData.timestamps;
        timeStamp=matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(sensorTimeStamp(t));
        [Y, M, D, H, MN, S] = datevec(timeStamp);
        minute = H*60+MN - startMinute+1;
        
        sensorSpeedArray(minute,i) = sensorDataSpeed(t);
        sensorFlowArray(minute,i) = sensorDataFlow(t);
        
        
        
    end
 
    % DO NOT NEED ANYMORE, HOPEFULLY
    %     % If the sendorData from a specific sensor is larger or smaller than the
    %     % number of sensorData from the previous sensors.
    %     if i~= 1 && size(sensorDataSpeed,1) < size(sensorSpeedArray,1)
    %         sensorSpeedArray = sensorSpeedArray(1:size(sensorDataSpeed,1),:);
    %         sensorFlowArray = sensorFlowArray(1:size(sensorDataSpeed,1),:);
    %
    %     elseif i~= 1 && size(sensorDataSpeed,1) > size(sensorSpeedArray,1)
    %         sensorDataSpeed = sensorDataSpeed(1:size(sensorSpeedArray,1));
    %         sensorDataFlow  = sensorDataFlow (1:size(sensorFlowArray,1));
    %     end
    
    %     sensorSpeedArray(:,i) = sensorDataSpeed;
    %     sensorFlowArray(:,i) = sensorDataFlow;
end

end
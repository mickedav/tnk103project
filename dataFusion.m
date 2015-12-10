function[estimatedSpeedFusion]= dataFusion(numberOfTimeSteps,firstCell,totalNumberOfCells,estimatedSpeedAlg3,estimatedSpeedAlg6)

for t=1:numberOfTimeSteps
    for cell=firstCell:totalNumberOfCells
        
        % if there are no estimate for GPS-data, all weight put on estimate for the
        % sensor data
        if isnan(estimatedSpeedAlg6(cell,t))
       
            estimatedSpeedFusion(cell,t) = estimatedSpeedAlg3(cell,t);
        elseif cell<=19
            weightSensor = 0.9;
            weightGPS = 1-weightSensor;
            estimatedSpeedFusion(cell,t) = weightSensor.*estimatedSpeedAlg3(cell,t)+weightGPS.*estimatedSpeedAlg6(cell,t);
        else
            weightSensor = 0.7;
            weightGPS = 1-weightSensor;
            estimatedSpeedFusion(cell,t) = weightSensor.*estimatedSpeedAlg3(cell,t)+weightGPS.*estimatedSpeedAlg6(cell,t);
        end
        
    end
end
end
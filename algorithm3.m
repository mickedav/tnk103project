function [estimatedSpeed]=algorithm3(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells)
% tau is set to half of the aggregated interval (1 min)
tau = 0.5;
% propagation velocity for free flow and congested situations, in m/s
cfree = 70/3.6;
ccong = -20/3.6;
% Vc is the threshold between free and congested traffic and deltaV is the
% transition width around Vc
Vc = 50/3.6;
deltaV = 10/3.6;
%%
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

estimatedSpeed = sensorCellSpeedArray;
for t=2:(numberOfTimeSteps-1)
    
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
                t2 = t-1;
                t1 = t+1;
                
                Nfree = exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/cfree))/tau))) + exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/cfree))/tau)));
                Ncong = exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/ccong))/tau))) + exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/ccong))/tau)));
                sumNvfree = exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/cfree))/tau)))*sensorCellSpeedArray(sensor1,t1) + exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/cfree))/tau)))*sensorCellSpeedArray(sensor2,t2);
                sumNvcong = exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/ccong))/tau)))*sensorCellSpeedArray(sensor1,t1) + exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/ccong))/tau)))*sensorCellSpeedArray(sensor2,t2);
                Vfree = sumNvfree/Nfree;
                Vcong = sumNvcong/Ncong;

                Vstar = min(Vfree,Vcong);
                
%                 weight between the two speed fields 
                weight = 0.5*(1+tanh((Vc-Vstar)/deltaV));

                estimatedSpeed(cell,t)=weight*Vcong+(1-weight)*Vfree;
            end
        end
        
    end
end
end
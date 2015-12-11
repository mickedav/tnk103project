function [GPSCellSpeedArray]=algorithm5(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell)

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

% tau is set to half of the aggregated interval (1 min)
tau = 0.5;

% cellSpeedAggregatedTime contains NaN-values and GPSCellSpeedArray
% contains zeros instead of NaN
GPSCellSpeedArray = cellSpeedAggregatedTime;
GPSCellSpeedArray(isnan(GPSCellSpeedArray)) = 0;

% Loop through all timesteps
for t=2:(numberOfTimeSteps-1)
    
    % Loop through all cells from cell 9
    for cell=firstCell:(totalNumberOfCells)
        
        if isnan(cellSpeedAggregatedTime(cell,t))
            noMeasure1 = 1; noMeasure2 = 1; tooLong1 = 1; tooLong2 = 1;
            % x is the position in the middle on the cell we want to estimate the speed
            % in
            x = lengthFromStartHalf(cell);
            t1 = t+1;
            t2 = t-1;
            
            % loop for finding x1
            for i=(cell-1):-1:1
                
                if GPSCellSpeedArray(i,t1)== 0 && isnan(cellSpeedAggregatedTime(i,t1))
                    %  if there are no measurement in the cell -> do not use
                    %  any value
                    %  GPSCellSpeedArray(i,t1)=0;
                    x1 = 0;
                    noMeasure1 = 0;
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
                        % GPSCellSpeedArray(i,t1)=0;
                        tooLong1 = 0;
                    end
                    
                    break;
                    
                end
                
            end
            
            
            % loop for finding x2
            for i=(cell+1):totalNumberOfCells
                
                if GPSCellSpeedArray(i,t2)== 0 && isnan(cellSpeedAggregatedTime(i,t2))
                    %  if there are no measurement in the cell -> do not use
                    %  any value
                    %                     GPSCellSpeedArray(i,t2)=0;
                    x2 = 0;
                    noMeasure2 = 0;
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
                        tooLong2 = 0;
                    end
                    
                    break;
                    
                end
                
            end
            
            % sigma is calculated as half of the distance between the two data points
            % are used to estimate the speed in the cell
            if noMeasure1 == 0 || tooLong1 == 0
                sigma = abs(x-x2)/2;
            elseif  noMeasure2 == 0 || tooLong2 == 0
                sigma = abs(x-x1)/2;
            else
                sigma = abs(x1-x2)/2;
            end
            
            % if the measurements are too far away (> 1 km) or no
            % measurements in the neigboring time periods -> set the speed
            % to the closest measurement/estimated speed in the same time
            % period
            if (noMeasure1 == 0 || tooLong1 ==0) && (noMeasure2 == 0 || tooLong2 == 0)
                
                %                 if noMeasure1 == 0 || tooLong1 ==0
                %                GPSCellSpeedArray(cell,t)=GPSCellSpeedArray(cell+1,t);
                
                %                 elseif noMeasure2 == 0 || tooLong2 == 0
                GPSCellSpeedArray(cell,t)=GPSCellSpeedArray(cell-1,t);
                %                 if cell == 40
                
                %                 if t==42
                %                    GPSCellSpeedArray(cell-1,t)
                %             GPSCellSpeedArray(50,42)
                %                 end
                %                 end
                
                %                 end
                
            else
                
                y1 = noMeasure1*tooLong1;
                y2 = noMeasure2*tooLong2;
                
                N = y1*exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau))) + y2*exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)));
                sumNv = y1*exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau)))*GPSCellSpeedArray(cellGPS1,t1) + y2*exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)))*GPSCellSpeedArray(cellGPS2,t2);
                GPSCellSpeedArray(cell,t)=sumNv/N;
            end

            
        end
        
        
    end
    
end


% fill the first time step with the values from the second time step
for i=1:totalNumberOfCells
    if GPSCellSpeedArray(i,1) == 0
        GPSCellSpeedArray(i,1) =GPSCellSpeedArray(i,2);
    end
end

% fill the last time step with the values from the previous time step
for i=1:totalNumberOfCells
    if GPSCellSpeedArray(i,numberOfTimeSteps) == 0
        GPSCellSpeedArray(i,numberOfTimeSteps) =GPSCellSpeedArray(i,numberOfTimeSteps-1);
    end
end

% fill the last cell with values from previous cell
if GPSCellSpeedArray(totalNumberOfCells,:)==0
    GPSCellSpeedArray(totalNumberOfCells,:)=GPSCellSpeedArray(totalNumberOfCells-1,:);
end

% removes values from cell 1-8
GPSCellSpeedArray(1:8,:)=0;


end
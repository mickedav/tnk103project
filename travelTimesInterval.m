function [hej, travelTimesArray] = travelTimesInterval(temp, steplength, cellSizeAll, numberOfTimeSteps, startCell, endCell, startOffset, endOffset)
startOffset
endOffset
if nargin <= 4
    startCell = 9;
    endCell = 50;
    startOffset = 0;
    endOffset = 0;
end
start_time = 1;
numberOfSeconds = numberOfTimeSteps*60;
NumOfIntervals = numberOfTimeSteps/steplength;
%NumOfIntervals = 10;

intervals = 1;
%travelTime(NumOfIntervals);
h = endCell*ones(NumOfIntervals, numberOfSeconds);
maxTT = 0;

startTimeSec = 0;

while intervals < NumOfIntervals
    
    if startTimeSec == 0
        startTimeSec = 1;
    else
        startTimeSec = startTimeSec + steplength*60;
    end
    
    travelTime = trajectory(temp, cellSizeAll, start_time, startCell, endCell, startOffset, endOffset);
    
    if size(travelTime,2) + startTimeSec > maxTT
        maxTT = size(travelTime,2) + startTimeSec;
        
        if travelTime(end)== endCell
            travelTimesArray(intervals) = size(travelTime,2);
        end
    end
    
    for i = startTimeSec:(size(travelTime,2) + startTimeSec-1)
        h(intervals,i) = travelTime(i-startTimeSec+1);
    end
    
    intervals = intervals + 1;
    start_time = start_time + steplength;
end

hej = h(:,1:maxTT);

for i = 1:NumOfIntervals
    for j = 1:maxTT
        
        if hej(i,j) == 50;
            hej(i,j) = 0;
        else
            break;
        end
    end
end

end
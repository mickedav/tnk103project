function [hej] = travelTimesInterval(temp, start_time, NumOfIntervals, steplength, cellSizeAll)

intervals = 1;
%travelTime(NumOfIntervals);
h = 50*ones(NumOfIntervals, 10800);
maxTT = 0;



startTimeSec = 0;

while intervals <= NumOfIntervals
    
    if startTimeSec == 0
        startTimeSec = 1;
    else
        startTimeSec = startTimeSec + steplength*60
    end
    
    travelTime = trajectory(temp, cellSizeAll, start_time);
    
    if size(travelTime,2) + startTimeSec > maxTT
        maxTT = size(travelTime,2) + startTimeSec;
    end
    
    for i = startTimeSec:(size(travelTime,2) + startTimeSec-1)
        h(intervals,i) = travelTime(i-startTimeSec+1);
    end
    
    intervals = intervals + 1;
    start_time = start_time + steplength;
end

hej = h(:, 1:maxTT);

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
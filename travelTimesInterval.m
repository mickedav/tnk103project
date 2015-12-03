function [hej] = travelTimesInterval(temp, start_time, NumOfIntervals, steplength, cellSizeAll)

intervals = 1;
%travelTime(NumOfIntervals);
h = 50*ones(NumOfIntervals, 7200);
maxTT = 0;
startTimeSec = start_time*60;

while intervals <= NumOfIntervals
    
    travelTime = trajectory(temp, cellSizeAll, start_time);

    if size(travelTime,2) > maxTT
       maxTT = size(travelTime,2);
    end
    
    for i = 1:size(travelTime,2)
       h(intervals,i) = travelTime(i);
    end
    
    intervals = intervals + 1;
    start_time = start_time + steplength;
end

hej = h(:, 1:maxTT);

end
function [traject] = trajectory(cellSpeed, cellSizeAll, start_time, startCell, endCell)

if(startCell == NaN)
    startCell = 9;
end

if(endCell == NaN)
    endCell = 50;
end

if(startCell > endCell)
    'Start Cell is bigger than end Cell, start set to 9 and end set to 50'
    startCell = 9;
    startCell = 50;
end

currCell = startCell;


%don't know if this is correct, maybe not if the start time is more than 1
%hour after the first time in the plot
%minute = start_time.getMinute;

minute = start_time;
second = 1;
%second = start_time.getSecond;
totSecond = 1;
traject = 0;
deltaDist = 0;

cellSpeed(isnan(cellSpeed)) = 0; 

while (currCell < endCell) && (minute < size(cellSpeed,2))
    
    currSpeed = cellSpeed(currCell,minute);
  
    %travelled dist during 1 second
    %rewrite km/h to m/s (IS THIS NEEDED???) (*1 since one second)
    deltaDist = deltaDist + (currSpeed)/3.6
    
    if deltaDist > cellSizeAll(currCell)
        %move on to the next cell
        deltaDist = 0;
        currCell = currCell + 1;
    end
    
    if second > 60
        %one minute has passed
        minute = minute + 1;
        second = 1;
    end
    
    traject(totSecond) = currCell;
    %check next second
    second = second + 1;
    totSecond = totSecond + 1;
end

end


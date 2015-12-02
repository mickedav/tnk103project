function [data] = trajectory(cellSpeed, cellSizeAll)

currCell = 1;
minute = 1;
second = 1;
data = 0;
deltaDist = 0;

while currCell < size(cellSizeAll,2)
     
     
        currSpeed = cellSpeed(currCell,minute)
        length = cellSizeAll(currCell);
        %travelled dist during 1 second
        deltaDist = deltaDist + currSpeed/3.6
             
        if deltaDist > cellSizeAll(currCell)
            %still in the same cell
            deltaDist = 0;
            currCell = currCell + 1
        end
        
        if second > 60
           minute = minute +1;
           second = 1;            
        end        
          
          data(second) = currCell;
          second = second + 1;
          
end
end


function [cellSpeed2, endSec] = setCellSpeedDay(intData, doubleData, timeStampData, linkIdArray, network, analyst, row)
import netconfig.*

[numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray);
startSec = min(timeStampData(:,1));
endSec = 7200 + 3600;
clear K
K = NaN(row,totalNumberOfCells,endSec);
hej = 1;

for i = 1:row
    A = NaN(1,endSec);
    timeStampData(i,2)
    a = Spot(network.getLinkWithID(intData(i,1)), doubleData(i,1), -1);
    b = Spot(network.getLinkWithID(intData(i,2)), doubleData(i,2), -1);
    
    travelTime = intData(i,3);
    try
        route = analyst.extractRoute(a,b);
        route.getRouteLength;
        v = (route.getRouteLength/travelTime)*3.6;
        
        startCell = getCellId(a, linkIdArray, numberOfCells, cellSize);
        endCell = getCellId(b, linkIdArray, numberOfCells, cellSize);
        getTaxiSpeed = setCellSpeedTaxi(startCell, endCell, v, totalNumberOfCells);

        A(1,timeStampData(i,1):timeStampData(i,2))= v;
    catch
        A(1,timeStampData(i,1):timeStampData(i,2))= NaN;
    end
    
    
    for k = 1:totalNumberOfCells
        if ~isnan(getTaxiSpeed(k))
            K(i,k,:) = A;
        end
    end
end
k = K;

for i = 1:endSec
    for j = 1:totalNumberOfCells
    	cellSpeed(i,j) = nanmean(k(:,j,i));
    end
end
for i = 60:60:endSec - 60
    for j = 1:totalNumberOfCells
        cellSpeed2(i/60, j) = nanmean(cellSpeed(i:i+59,j));
    end
end
cellSpeed2 = cellSpeed2';

end
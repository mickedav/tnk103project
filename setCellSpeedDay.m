function [cellSpeed2, endSec] = setCellSpeedDay(intData, doubleData, timeStampData, linkIdArray, network, analyst, row)
import netconfig.*

[numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray);

startSec = min(timeStampData(:,1));
%endSec = max(timeStampData(:,2));
endSec = 7260;

K = NaN(row,50,endSec);
hej = 1;

for i = 1:row
    A = NaN(1,endSec);
    
    a = Spot(network.getLinkWithID(intData(i,1)), doubleData(i,1), -1);
    b = Spot(network.getLinkWithID(intData(i,2)), doubleData(i,2), -1);
    
    travelTime = intData(i,3);
    try
        route = analyst.extractRoute(a,b);
        route.getRouteLength;
        v = (route.getRouteLength/travelTime)*3.6;
        
        startCell = getCellId(a, linkIdArray, numberOfCells, cellSize);
        endCell = getCellId(b, linkIdArray, numberOfCells, cellSize);
        
        kaka = setCellSpeedTaxi(startCell, endCell, v, totalNumberOfCells);

        A(1,timeStampData(i,1):timeStampData(i,2))= v;
    catch
        A(1,timeStampData(i,1):timeStampData(i,2))= NaN;
    end
    
    
    for apa = 1:50
        if ~isnan(kaka(apa))
            hej = hej + 1;
            K(i,apa,:) = A;
        end
    end
end
k = K;

for i = 1:endSec
    for j = 1:50
    	cellSpeed(i,j) = nanmean(k(:,j,i));
    end
end
for i = 60:60:endSec - 60
    i/60
    for j = 1:50
        cellSpeed2(i/60, j) = nanmean(cellSpeed(i:i+59,j));
    end
end
size(cellSpeed(:,1))
cellSpeed2 = cellSpeed2';

end
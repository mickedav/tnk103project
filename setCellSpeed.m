function [k, endSec, teori] = setCellSpeed(intData, doubleData, timeStampData, linkIdArray, network, analyst, row)
import netconfig.*

[numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray);

startSec = min(timeStampData(:,1));
endSec = max(timeStampData(:,2))

K = NaN(row,50,endSec);
hej = 1;

for i = 1:row
    A = NaN(1,max(timeStampData(:,2)));
    
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
        
        teori(i,:) = kaka;
        
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
end
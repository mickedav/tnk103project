function [cellSpeedAgregated, cellSpeed, endSec, totalNumberOfCells] = setCellSpeedDay(intData, doubleData, timeStampData, linkIdArray, network, analyst, row)

% Imports
import netconfig.*

% Create cellmap using provided network.
[numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray);

% endSec can be passed in function, just to lazy ATM
endSec = 10860;

% Create matrix in which CellSpeeds are stored, fill with NaN to make it
% possible to create NaNmean.
cellSpeedTemp = NaN(row,totalNumberOfCells,endSec);

for i = 1:row
    
    % Create array were speeds for each time step is stored
    A = NaN(1,endSec);
    
    % Create spots used to find Taxi route, also get TravelTime for this route
    a = Spot(network.getLinkWithID(intData(i,1)), doubleData(i,1), -1);
    b = Spot(network.getLinkWithID(intData(i,2)), doubleData(i,2), -1);
    travelTime = intData(i,3);
    
    % Try extracting Taxi Route. If fail, no data is added to cellSpeeds
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
    
    % Fill
    for k = 1:totalNumberOfCells
        if ~isnan(getTaxiSpeed(k))
            cellSpeedTemp(i,k,:) = A;
        end
    end
end

% for i = 1:endSec
%     for j = 1:totalNumberOfCells
%         cellSpeed22(i,j) = nanmean(cellSpeedTemp(:,j,i));
%     end
% end

cellSpeed = squeeze(nanmean(cellSpeedTemp,1));

for i = 60:60:endSec - 60
    for j = 1:totalNumberOfCells
        cellSpeedAgregated(i/60,j) = nanmean(cellSpeed(j,i:i+59));
    end
end

cellSpeedAgregated = cellSpeedAgregated';

end
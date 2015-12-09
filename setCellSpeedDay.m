function [cellSpeedAggregatedTime, cellSpeed, endSec, totalNumberOfCells,  cellSizeAll] = setCellSpeedDay(intData, doubleData, timeStampData, linkIdArray, network, analyst, row)

% Imports
import core.*
import netconfig.*

% Create cellmap using provided network.
[numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray);

% endSec can be passed in function, just to lazy ATM
endSec = 10860;

% Create matrix in which CellSpeeds are stored, fill with NaN to make it
% possible to create NaNmean.
cellSpeedTemp = cell(totalNumberOfCells,endSec);
positions = [];
for i = 1:row
    %tick = Time();
    % Create array were speeds for each time step is stored
    %A = NaN(1,endSec);
    
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
        %getTaxiSpeed = setCellSpeedTaxi(startCell, endCell, v, totalNumberOfCells);
        %A(1,timeStampData(i,1):timeStampData(i,2))= v;
        tempPositions = ones(((endCell-startCell+1)*(timeStampData(i,2)-timeStampData(i,1)+1)),2);
        row = 1;
        for j = startCell:endCell
            for k = timeStampData(i,1):timeStampData(i,2)
                cellSpeedTemp{j,k} = [cellSpeedTemp{j,k} v];
                tempPositions(row,:) = [j k];
                row = row+ 1;
            end
        end
        positions = [positions;tempPositions];
    catch
        %A(1,timeStampData(i,1):timeStampData(i,2))= NaN;
    end
     %tock= Time();
     %fprintf('\t\tExtracted Taxi route, took %f seconds.\n',tock.secondsSince(tick));
%     tick2 = Time();
%     % Fill
%     for k = 1:totalNumberOfCells
%         if ~isnan(getTaxiSpeed(k))
%             cellSpeedTemp(i,k,:) = A; 
%         end
%     end
%     tock = Time();
%     fprintf('\t\tFilling cells with speed. %d, took %f seconds.\n',i,tock.secondsSince(tick2));
%     fprintf('\tTaxi route %d done, took %f seconds.\n',i,tock.secondsSince(tick1));
end

% for i = 1:endSec
%     for j = 1:totalNumberOfCells
%         cellSpeed(i,j) = nanmean(cellSpeedTemp(:,j,i));
%     end
% end
%tick = Time();

%cellSpeed = squeeze(nanmean(cellSpeedTemp,1));

cellSpeed = nan(totalNumberOfCells,endSec);
for i = 1:size(positions,1)
    index = positions(i,:);
    cellSpeed(index(1,1),index(1,2)) = nanmean(cellSpeedTemp{index(1,1),index(1,2)});
end

cellSpeedAggregatedTime = aggregateTime(cellSpeed, endSec, totalNumberOfCells);

%tock = Time();
%fprintf('\tAggregating time to minutes, took %f seconds.\n',tock.secondsSince(tick));


end
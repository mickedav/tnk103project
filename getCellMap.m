function [numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray)

numberOfCells = 0;
cellSize = 0;
lengthStretch = 0;
cellSizeAll = 0;

for j = linkIdArray
    link = network.getLinkWithID(j);
    numberOfCells(end+1) = link.getNbCells;
    cellSize(end+1) = link.getLength / numberOfCells(end);
    lengthStretch = lengthStretch + link.getLength;
end
numberOfCells = numberOfCells(2:end);
cellSize = cellSize(2:end);
totalNumberOfCells = sum(numberOfCells);

curr = 1;
for i = numberOfCells
    for j = 1:i
        cellSizeAll(end+1) = cellSize(curr);  
    end
    curr = curr + 1;
end
cellSizeAll = cellSizeAll(2:end);
end
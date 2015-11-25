function [numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray)

    numberOfCells = 0;
    cellSize = 0;
    lengthStretch = 0;

  
    for j = linkIdArray    
        link = network.getLinkWithID(j);
        numberOfCells(end+1) = link.getNbCells;
        cellSize(end+1) = link.getLength / numberOfCells(end);
        lengthStretch = lengthStretch + link.getLength;
    end
    numberOfCells = numberOfCells(2:end);
    cellSize = cellSize(2:end);
    totalNumberOfCells = sum(numberOfCells);
end
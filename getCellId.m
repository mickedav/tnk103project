function [startCell] = getCellId(Spot, linkIdArray, numberOfCells,  cellSize)

    currentNumberOfCells = 0;
    % size(sensorIdArray,2)


    % index is the segment number (1-10)
    index = find(linkIdArray == Spot.link.id);
    
    for i=(index-1):-1:1
        currentNumberOfCells = currentNumberOfCells + numberOfCells(i);
    end
    
    startCellOnLink = ceil(Spot.offset/cellSize(index));
    startCell = currentNumberOfCells + startCellOnLink;   

end
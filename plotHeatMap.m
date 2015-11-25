function [] = plotHeatMap(temp,startTime,endTime, numberOfTimeSteps)
% to use this function, the array temp needs to be an array of size[rows=numberOfcells, columns=numberOfTimesteps]
firstHour = startTime.getHour
firstMin = startTime.getMinute
endHour = endTime.getHour
load('mycmap','cm')
imagesc(temp);
colormap(cm)
colorbar
ax = gca;
% set(ax,'XTick',[1 2 3])

timeStepsArray = zeros(numberOfTimeSteps,1)
timeStepsArray(1)=firstHour
% x=[8 9 10]
%  x = linspace(firstHour,endHour,numberOfTimeSteps/30 + 1);
  
%     set(ax,'XTick',x)
    % Create a sample plot
%     plot(x, (1:length(x)).^2);
%     datetick('x', 'HH:MM PM')

end
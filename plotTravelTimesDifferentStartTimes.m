function []  = plotTravelTimesDifferentStartTimes(travelTimesArray,startTime,endTime,steplength)

numberOfTimeSteps = size(travelTimesArray,2);

% convert travel times from seconds to minutes
travelTimesArray = travelTimesArray./60;

% make the startTime and endTime to the strings
startTimeString = matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(startTime);
endTimeString =  matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(endTime);

formatOut = 'HH:MM';
startTimeNum = datenum(datestr(startTimeString,formatOut));
endTimeNum = datenum(datestr(endTimeString,formatOut));
%
% steplength = 15;
% determine how many ticks that the x-axis is going to have
 ticks = numberOfTimeSteps/steplength + 1;
% ticks = 6;
% ticks = numberOfTimeSteps/timeStep + 1;
%  ticks = size(travelTimesArray,2)+1;

% defines the ticks between startTime and endTime
xDataNum = linspace(startTimeNum,endTimeNum,ticks);

% convert xDataNum to a string cell array xDataStr with element on the
% format 'HH:MM'
xDataStr = cell(ticks,1);
for i=1:(ticks)
    xDataStr{i} =[datestr(xDataNum(i),formatOut)];
end

plot(travelTimesArray)
% 
% % set the tick labels on the x-axis
set(gca,'XLim',[0 numberOfTimeSteps])
set(gca,'XTick',[0:steplength:numberOfTimeSteps])
set(gca,'XTickLabel',xDataStr)



title('Travel time at different start times')
xlabel('start time')
ylabel('minutes')

end
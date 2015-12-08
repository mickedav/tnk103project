% Adding a path to the top folder.
%addpath(genpath('H:\TNK103\KOD'),'-end');
clear all
import core.*               %Core classes

% Setting the enviroment (i.e loading all jar files)
% We do not wanna set the enviroment if it is allready set.
try
    Time(); % This is just to see if the import was successful.
catch
    setEnviroment
end

% Importing all java classes that will be used.
import java.lang.*          %String classes
import java.util.*          %Wrapper classes
import core.*               %Core classes
import netconfig.*          %Network clases
import util.*
import bAE.*                %Output data classes not needed in this example
%import highwayflowmodel.*  %Flow model classes not needed in this example
%import highway.*           %Highway classes not needed in this example

% Setting the network id and configuration id.
NETWORKID = 50;
CONFIGURATIONID = 15001;
linkIdArray = [11269 14136 6189 8568 15256 9150 38698 9160 71687 9198];

start_TimeStamp = Time.newTimeFromBerkeleyDateTime(2013,03,4,6,30,59,59);
end_TimeStamp = Time.newTimeFromBerkeleyDateTime(2013,03,4,9,30,0,0);


startDay = start_TimeStamp.getDayOfMonth;
startHour = start_TimeStamp.getHour;
startMinute = start_TimeStamp.getMinute;

endDay = end_TimeStamp.getDayOfMonth;
endHour = end_TimeStamp.getHour;
endMinute = end_TimeStamp.getMinute;


startTimeStampString = char(start_TimeStamp.toString);
startTimeStampString = ['''' startTimeStampString ''''];
endTimeStampString = char(end_TimeStamp.toString);
endTimeStampString = ['''' endTimeStampString ''''];
numberOfTimeStepsTemp = TimeInterval(start_TimeStamp, end_TimeStamp);
numberOfTimeSteps = numberOfTimeStepsTemp.get_time_interval_duration;

query = ['SELECT * FROM bluetooth.aggregated_traveltime '...
'INNER JOIN bluetooth.route '...
'ON bluetooth.aggregated_traveltime.fk_id = bluetooth.route.id '...
['WHERE (bluetooth.aggregated_traveltime.date BETWEEN ' startTimeStampString ' AND ' endTimeStampString ') ']...
'AND bluetooth.aggregated_traveltime.fk_aggregation_period = 5 '... 
'AND (bluetooth.route.name = ''from E4S 64.970 to E4S 64.090'' OR bluetooth.route.name = ''from E4S 64.090 to E4S 63.580'' '... 
'OR bluetooth.route.name = ''from E4S 63.580 to E4S 63.040''  OR bluetooth.route.name = ''from E4S 63.040 to E4S 62.220'' '... 
'OR bluetooth.route.name = ''from E4S 62.220 to E4S 61.395'' OR bluetooth.route.name = ''from E4S 62.220 to E4S 61.395'' '... 
'OR bluetooth.route.name = ''from E4S 60.645 to E4S 60.060'') '...
'ORDER BY bluetooth.aggregated_traveltime.fk_id, bluetooth.aggregated_traveltime.date']

%%Create Network
core.Monitor.set_db_env('tal_local')
core.Monitor.set_prog_name('mms_matlab')
core.Monitor.set_nid(NETWORKID);
core.Monitor.set_cid(CONFIGURATIONID);
network = Network();
dbr = DatabaseReader();
analyst = util.NetworkAnalysis(network);

query = String(query);
dbr.psCreate(String('test'),query);
dbr.psQuery(String('test'));


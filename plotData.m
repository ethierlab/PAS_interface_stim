function plotData(src,event)
    persistent tempData;
    persistent tempTimeStamps;
    if(isempty(tempData))
         tempData = [];
         tempTimeStamps = [];
     end
     tempData = [tempData;event.Data];
     tempTimeStamps = [tempTimeStamps;event.TimeStamps];
     plot(tempTimeStamps,tempData);
end
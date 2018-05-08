%% Création d'une session
dev=daq.getDevices;
ven=daq.getVendors;
ses=daq.createSession('ni');
%% Création d'une session daq pour acquérir de façon continue les EMG
d=daq.getDevices;
v=daq.getVendors;
s=daq.createSession('ni');
%params
s.Rate=2000;
s.IsContinuous=true;
ai0=addAnalogInputChannel(s,'Dev1','ai0','Voltage'); %Le Dev1 est le nom du daq
ai1=addAnalogInputChannel(s,'Dev1','ai1','Voltage');
ai2=addAnalogInputChannel(s,'Dev1','ai2','Voltage');
%fid1 = fopen('log.bin','w');
lh1 = addlistener(s,'DataAvailable',@plotData);
%ll = addlistener(s,'DataAvailable',@(src, event)logData(src, event, fid1));
s.NotifyWhenDataAvailableExceeds = 200; %s.Rate/s.Notify=freq de display
s.startBackground(); 
while lh1>=5.5 && lh1<=4.5
    StimManuel(1);
    break
end
%% Session afin de faire des triggers manuels
StimManuel(t);
%% Stop s
stop(s);
delete(lh);
delete(l1);
fclose(fid1);

%%
fid2 = fopen('log.bin','r');
[data,count] = fread(fid2,[3,inf],'double');
fclose(fid2);

%%
t = data(1,:);
ch = data(2:3,:);
plot(t, ch);
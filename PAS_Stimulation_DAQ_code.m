function stim_control = PAS_Stimulation_DAQ_code(GUI_h)
%% Creation of a session-based interface with the NI DAQ

d=daq.getDevices;
v=daq.getVendors;
s=daq.createSession('ni');

%% Load the parameters
params = GUI_h.params;
GUI_h.params = [];

%% Initialisation

reset_gui_counters(GUI_h);
experiment_start=tic;
experiment_start_time = datetime('now');
disp('Experiment started!')

% structure to save all results, as well as experimental parameters
 data_emg_PAS = struct(...
    'params'            ,params,...
    'session_time'      ,experiment_start_time,...
    'num_stim'          ,zeros(size(params.trial_type)),...
    'pulses_gen'        ,{{}},...
    'emg_data'          ,{{}},...
    'session_time'      ,experiment_start_time,...
    'results'           ,[]...
    );

temp_emg_buffer    = [nan nan]; % [time force], first row is oldest data
trial_emg_buffer   = [nan nan];
trial_started      = false;
post_trial_pause   = false;
pause_duration     = 0;
numb_pulses_done   = 0;
pulse_counter      = 0;
last_pulse         = toc(experiment_start);
stop_button        = set(GUI_h.stop_button,'userdata',0);
stim_type_button   = set(GUI_h.uibuttongroup3);

% Adding the input channels of NI DAQ
s.Rate=params.fsampling;
lenght_output_TRIG=s.Rate*params.output_trig_time;
s.IsContinuous=true;
ai0=addAnalogInputChannel(s,'Dev1','ai0','Voltage'); %Le Dev1 est le nom du daq
ai1=addAnalogInputChannel(s,'Dev1','ai1','Voltage');
ai2=addAnalogInputChannel(s,'Dev1','ai2','Voltage');
ai3=addAnalogInputChannel(s,'Dev1','ai3','Voltage'); 

%% Program loop

while  toc(experiment_start)<params.duration_max || ~get(GUI_h.stop_button,'userdata') || nb_pulses_delivered==params.nb_pulses
        time_now     = toc(experiment_start);
        time_rec_bef = time_now-experiment_start;
        temp_emg_buffer = [temp_emg_buffer(time_rec_bef-temp_emg_buffer(:,1)<=1.5,:); time_rec_bef ai0 ai1 ai2 ai3];
        
   % Code pour choisir le type de stimulation avec le groupe de boutons. On
   % prépare les signals de trigger à envoyer au AM-systems. 
        if stim_type == get(handles.radiobuttoncortex,'string')
            ao0=addAnalogOutputChannel(s,'Dev1','ao0','Voltage'); %Cortex
            data0 = linspace(5,5,lenght_output_TRIG)';
            trig1 = queueOutputData(s,data0);
            pause(trig1);
        elseif stim_type == get(handles.radiobuttonmuscle,'string')
            ao1=addAnalogOutputChannel(s,'Dev1','ao1','Voltage'); %Muscle
            data1 = linspace(5,5,lenght_output_TRIG)';
            trig2 = queueOutputData(s,data1);
            pause(trig2);
        elseif stim_type == get(handles.radiobuttoncm,'string')
            ao0=addAnalogOutputChannel(s,'Dev1','ao0','Voltage'); %Cortex
            ao1=addAnalogOutputChannel(s,'Dev1','ao1','Voltage'); %Muscle
            data0 = linspace(5,5,lenght_output_TRIG)';
            data1 = linspace(5,5,lenght_output_TRIG)';
            trig3 = queueOutputData(s,[data0 data1]);
            pause(trig3);
        elseif stim_type == get(handles.radiobuttonauto,'string')
            ao0=addAnalogOutputChannel(s,'Dev1','ao0','Voltage'); %Cortex
            ao1=addAnalogOutputChannel(s,'Dev1','ao1','Voltage'); %Muscle
            data0 = linspace(5,5,lenght_output_TRIG)';
            data1 = linspace(5,5,lenght_output_TRIG)';
            trig4 = queueOutputData(s,[data0 data1]);
            pause(trig4);
        else
            disp('No type of stimulation selected')
        end

        % Ajout du listener sert à enregistrer toutes les données, ce n'est
        % pas le buffer mais un complément nécessaire pour faire
        % fonctionner l'acquisition.
        lh_buff_cont=addlistener(s,'DataAvailable',@DataEMGbuff);
        s.NotifyWhenDataAvailableExceeds = params.refresh_ratio; %s.Rate/s.Notify=freq de display;
        s.startBackground(); % Départ des enregistrements en background
        
    % Manual Stimulation
        EMG_response_data={};
        if Man_stim == true && stim_type == get(handles.radiobuttoncortex,'string')
            resume(trig1)
            EMG_response_data=temp_emg_buffer; % Remplir le buffer et le sauvegarder selon les valeurs dans le ui
        elseif Man_stim == true && stim_type == get(handles.radiobuttonmuscle,'string')
            resume(trig2)
        elseif Man_stim == true && stim_type == get(handles.radiobuttoncm,'string')
            resume(trig3)
        elseif Man_stim == true && stim_type == get(handles.radiobuttonauto,'string')
            %if temp_emg_buffer<= VALEUR MAX  %partie automatisé
            disp('Not configured yet')
        end
        
    % Plot EMG on ui
       lh_buff_plot=addlistener(s,'DataAvailable',@plotData);
end


end

        

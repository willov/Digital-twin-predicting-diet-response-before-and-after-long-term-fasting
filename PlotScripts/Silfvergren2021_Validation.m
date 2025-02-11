%% Create Mex och Assign params
modelName = 'ModelSimpleMetabolismFast';
model = IQMmodel([modelName '.txt']);
IQMmakeMEXmodel(model);

modelNameO = 'ModelSimpleMetabolismFastO';
model = IQMmodel([modelNameO '.txt']);
IQMmakeMEXmodel(model);


time = linspace(0,11500,11501);
time2 = [time, fliplr(time)];
disp (' ')
disp('--- The fit is visually studied ---')
disp(' ')

p1 = table();
p1.pNames = IQMparameters(model);
p2 = p1;

savePlots = 0;
c = 'r';

if c == 'r'
    model = str2func(modelNameO);
else
    model = str2func(modelName);
end

%% P1 Fasting intervention
load('Silfvergren2021_ParamHealthyCalibratedP1');

[row column] = size(Silfvergren2021_ParamHealthyCalibratedp1);
clear optimizedParamTemp2

body_information = [1 , 0, 178, 84 ];  % female, male, height, weight
meal_information = [1, 0, 0, 0];

for i = 1:row
    optimizedParamTemp  = Silfvergren2021_ParamHealthyCalibratedp1(i,1:(column-1));
    optimizedParamTemp  = log(optimizedParamTemp);
    cost                = Silfvergren2021_costfunction(Silfvergren2021_data.p1_glucoseCalibrated,Silfvergren2021_data.time,time,optimizedParamTemp,modelName,body_information,meal_information,190);
    optimizedParamTemp  = exp(optimizedParamTemp);
    optimizedParamTemp(column) = cost;
    optimizedParamTemp2(i,:)   = optimizedParamTemp;
end
Silfvergren2021_ParamHealthyCalibratedp1 = sortrows(optimizedParamTemp2,column);

for i = 1:row
    optimizedParamTemp = Silfvergren2021_ParamHealthyCalibratedp1(i,1:(column-1));
    
    try
        sim = model(time,[],optimizedParamTemp);
    catch error
    end
    
    if i == 1
        p1.fasting = optimizedParamTemp';
        simBest = sim;
    end
    
    if i == 1
        maxG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
    else
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = max(maxG2,maxG1);
        minG2 = min(minG2,minG1);
    end
    
end

MaxP1 = maxG2;
MinP1 = minG2;

figure(1)
set(gcf, 'Name', "Glucose fasting participant 1", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,1,2],'ytick',[0,2,3,4,5,6,7],'FontSize', 70,'fontname','Arial')
yP1    = [MaxP1', fliplr(MinP1')];
fill(time2/1440-5.33,yP1,c,'FaceAlpha',0.2,'EdgeAlpha',0);
plot(time/1440-5.33, simBest.variablevalues(:,ismember(simBest.variables,'G'))/18,[c '-.'],'LineWidth',LineWidthValue);
plot(Silfvergren2021_data.time(1:3)/1440-5.33,Silfvergren2021_data.p1_glucoseCalibrated(1:3),'kx','MarkerSize',80,'LineWidth',10)
plot(Silfvergren2021_data.time(1:190)/1440-5.33,Silfvergren2021_data.p1_glucoseCalibrated(1:190),'k.','MarkerSize',80)
ylabel({'Plasma glucose' ; '(mM)'},'FontSmoothing','on','fontname','Arial');
xlabel("Time (days)",'FontSmoothing','on','fontname','Arial');
xlim([0 2])
ylim([3 6])
%hold off

%% P2 fasted
load('Silfvergren2021_ParamHealthyCalibratedP2');

[row column] = size(Silfvergren2021_ParamHealthyCalibratedp2);
clear optimizedParamTemp2

% P2
body_information = [0 , 1, 180, 87 ];  % female, male, height, weight
meal_information = [1, 0, 0, 0];

for i = 1:row
    optimizedParamTemp  = Silfvergren2021_ParamHealthyCalibratedp2(i,1:(column-1));
    optimizedParamTemp  = log(optimizedParamTemp);
    cost                = Silfvergren2021_costfunction(Silfvergren2021_data.p2_glucose,Silfvergren2021_data.time,time,optimizedParamTemp,modelName,body_information,meal_information,190);
    optimizedParamTemp  = exp(optimizedParamTemp);
    optimizedParamTemp(column) = cost;
    optimizedParamTemp2(i,:)   = optimizedParamTemp;
end
Silfvergren2021_ParamHealthyCalibratedp2 = sortrows(optimizedParamTemp2,column);

for i = 1:row
    optimizedParamTemp = Silfvergren2021_ParamHealthyCalibratedp2(i,1:(column-1));
    
    try
        sim = model(time,[],optimizedParamTemp);
    catch error
    end
    
    if i == 1
        p2.fasting = optimizedParamTemp';

        reactions = array2table(sim.reactionvalues, 'variablenames',sim.reactions);
        variables = array2table(sim.variablevalues, 'variablenames',sim.variables);
        states = array2table(sim.statevalues, 'variablenames',sim.states);
        sim_obj_fasted = struct();
        sim_obj_fasted.parameters = p2;
        sim_obj_fasted.reactions = reactions;
        sim_obj_fasted.variables = variables;
        sim_obj_fasted.states = states;
        sim_obj_fasted.time = sim.time';
        simBest = sim;
    end
    
    if i == 1
        maxG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
    else
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = max(maxG2,maxG1);
        minG2 = min(minG2,minG1);
    end

end
MaxP2 = maxG2;
MinP2 = minG2;

%
figure(2)
set(gcf, 'Name', "Glucose fasting participant 2", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,1,2],'ytick',[0,2,3,4,5,6,7],'FontSize', 70,'fontname','Arial')%,'FontSmoothing','on')
yP2    = [MaxP2', fliplr(MinP2')];
fill(time2/1440-5.33,yP2,c,'FaceAlpha',0.2,'EdgeAlpha',0);
plot(time/1440-5.33, simBest.variablevalues(:,ismember(simBest.variables,'G'))/18,[c '-.'],'LineWidth',LineWidthValue);
plot(Silfvergren2021_data.time(2:4)/1440-5.33,Silfvergren2021_data.p2_glucose(2:4),'kx','MarkerSize',80,'LineWidth',10)
plot(Silfvergren2021_data.time(2:190)/1440-5.33,Silfvergren2021_data.p2_glucose(2:190),'k.','MarkerSize',80)
ylabel({'Plasma glucose' ; '(mM)'},'FontSmoothing','on','fontname','Arial');
xlabel("Time (days)",'FontSmoothing','on','fontname','Arial');
xlim([0 2])
ylim([3 6])
%hold off

%% Meals
%% fed p1
load('Silfvergren2021_ParamP1fedCalibrated');
% Silfvergren2021_ParamP1fedCalibrated = Silfvergren2021_ParamHealthyCalibratedp1;
[row column] = size(Silfvergren2021_ParamP1fedCalibrated);
clear optimizedParamTemp2

% P1
body_information = [1 , 0, 178, 84 ];  % female, male, height, weight
meal_information = [3, 0, 2.6, 25.55];

for i = 1:row
    optimizedParamTemp  = Silfvergren2021_ParamP1fedCalibrated(i,1:(column-1));
    optimizedParamTemp  = log(optimizedParamTemp);
    cost                = Silfvergren2021_costfunction(Silfvergren2021_data.value_fed_p1(1:34),Silfvergren2021_data.time_fed_p1(1:34),time,optimizedParamTemp,modelName,body_information,meal_information,34);
    optimizedParamTemp  = exp(optimizedParamTemp);
    optimizedParamTemp(column) = cost;
    optimizedParamTemp2(i,:)   = optimizedParamTemp;
end
Silfvergren2021_ParamP1fedCalibrated = sortrows(optimizedParamTemp2,column);

for i = 1:row
    optimizedParamTemp = Silfvergren2021_ParamP1fedCalibrated(i,1:(column-1));
    
    sim = model(time,[],optimizedParamTemp);
    
    if i == 1
        p1.fed = optimizedParamTemp';
        simBest = sim;
    end
    
    if i == 1
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
    else
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = max(maxG2,maxG1);
        minG2 = min(minG2,minG1);
    end
    
end
MaxP1 = maxG2;
MinP1 = minG2;


% Plot p1
figure(3)
set(gcf, 'Name', "Glucose fed participant 1", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,2,4,5,6],'ytick',[0,1,2,3,4,5,6,7,8,10],'FontSize', 70,'fontname','Arial')%,'FontSmoothing','on')
yP1 = [MaxP1', fliplr(MinP1')];
fill((time2-7680)/60,yP1,c,'FaceAlpha',0.2,'EdgeAlpha',0);
plot((time-7680)/60, simBest.variablevalues(:,ismember(simBest.variables,'G'))/18,[c '-.'],'LineWidth',LineWidthValue);
xlabel("Time (h)",'FontSmoothing','on','fontname','Arial');
ylabel({'Plasma glucose' ; '(mM)'},'FontSmoothing','on','fontname','Arial');
plot((Silfvergren2021_data.time_fed_p1(1:2)-7680)/60,Silfvergren2021_data.value_fed_p1(1:2),'kx','MarkerSize',80,'LineWidth',10)
plot((Silfvergren2021_data.time_fed_p1-7680)/60,Silfvergren2021_data.value_fed_p1,'k.','MarkerSize',80)
line([0 0.05], [3 3],'Color','k','LineWidth',12);
xlim([-0.1 4])
ylim([3 6])
%hold off

%% fed p2
load('Silfvergren2021_ParamP2fedCalibrated');

[row column] = size(Silfvergren2021_ParamP2fedCalibrated);
clear optimizedParamTemp2

% P2
body_information = [0 , 1, 180, 87 ];  % female, male, height, weight
meal_information = [3, 0, 2.6, 25.55];

for i = 1:row
    optimizedParamTemp  = Silfvergren2021_ParamP2fedCalibrated(i,1:(column-1));
    optimizedParamTemp  = log(optimizedParamTemp);
    cost                = Silfvergren2021_costfunction(Silfvergren2021_data.value_fed_p2(1:21),Silfvergren2021_data.time_fed_p2(1:21),time,optimizedParamTemp,modelName,body_information,meal_information,21);
    optimizedParamTemp  = exp(optimizedParamTemp);
    optimizedParamTemp(column) = cost;
    optimizedParamTemp2(i,:)   = optimizedParamTemp;
end
Silfvergren2021_ParamP2fedCalibrated = sortrows(optimizedParamTemp2,column);

for i = 1:row
    optimizedParamTemp = Silfvergren2021_ParamP2fedCalibrated(i,1:(column-1));
    if c == 'r'
        optimizedParamTemp(102:105) = body_information;
    end
    try
        sim = model(time,[],optimizedParamTemp);
    catch error
        disp(getReport(err))
    end
    
    if i == 1
        p2.fed = optimizedParamTemp';

        reactions = array2table(sim.reactionvalues, 'variablenames',sim.reactions);
        variables = array2table(sim.variablevalues, 'variablenames',sim.variables);
        states = array2table(sim.statevalues, 'variablenames',sim.states);
        sim_obj_fed = struct();
        sim_obj_fed.parameters = p2;
        sim_obj_fed.reactions = reactions;
        sim_obj_fed.variables = variables;
        sim_obj_fed.states = states;
        sim_obj_fed.time = sim.time';

        simBest = sim;
    end
    
    if i == 1
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
    else
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = max(maxG2,maxG1);
        minG2 = min(minG2,minG1);
    end
    
end
MaxP1 = maxG2;
MinP1 = minG2;

% Plot p2
figure(4)
set(gcf, 'Name', "Glucose fed participant 2", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,2,4,5,6],'ytick',[0,1,2,3,4,5,6,7,8,10],'FontSize', 70,'fontname','Arial')%,'FontSmoothing','on')
yP1    = [MaxP1', fliplr(MinP1')];
fill((time2-7680)/60,yP1,c,'FaceAlpha',0.2,'EdgeAlpha',0);
plot((time-7680)/60, simBest.variablevalues(:,ismember(simBest.variables,'G'))/18,[c '-.'],'LineWidth',LineWidthValue);
xlabel("Time (h)",'FontSmoothing','on','fontname','Arial');
ylabel({'Plasma glucose' ; '(mM)'},'FontSmoothing','on','fontname','Arial');
plot((Silfvergren2021_data.time_fed_p2(1:2)-7680)/60,Silfvergren2021_data.value_fed_p2(1:2),'kx','MarkerSize',80,'LineWidth',10)
plot((Silfvergren2021_data.time_fed_p2-7680)/60,Silfvergren2021_data.value_fed_p2,'k.','MarkerSize',80)
line([0 0.05], [3 3],'Color','k','LineWidth',12);
xlim([-0.1 4])
ylim([3, 6])
%hold off

%% unfed p1
load('Silfvergren2021_ParamP1unfedCalibrated');
% Silfvergren2021_ParamP1unfedCalibrated(:,1:109) = Silfvergren2021_ParamHealthyCalibratedp1(1:12,1:109);
[row column] = size(Silfvergren2021_ParamP1unfedCalibrated);
clear optimizedParamTemp2

% P1
body_information = [1 , 0, 178, 84 ];  % female, male, height, weight
meal_information = [3, 0, 2.6, 25.55];

for i = 1:row
    optimizedParamTemp  = Silfvergren2021_ParamP1unfedCalibrated(i,1:(column-1));
    optimizedParamTemp  = log(optimizedParamTemp);
    cost                = Silfvergren2021_costfunction(Silfvergren2021_data.Value_fasted_p1(1:59),Silfvergren2021_data.time_fastedStart_p1(1:59),time,optimizedParamTemp,modelName,body_information,meal_information,59);
    optimizedParamTemp  = exp(optimizedParamTemp);
    optimizedParamTemp(column) = cost;
    optimizedParamTemp2(i,:)   = optimizedParamTemp;
end
Silfvergren2021_ParamP1unfedCalibrated = sortrows(optimizedParamTemp2,column);

for i = 1:row
    optimizedParamTemp = Silfvergren2021_ParamP1unfedCalibrated(i,1:(column-1));
    
    try
        sim = model(time,[],optimizedParamTemp);
    catch error
    end
    
    if i == 1
                p1.unfed = optimizedParamTemp';
        simBest = sim;
    end
    
    if i == 1
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
    else
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = max(maxG2,maxG1);
        minG2 = min(minG2,minG1);
    end
      
end
MaxP1 = maxG2;
MinP1 = minG2;

% Plot p1
figure(5)
set(gcf, 'Name', "Glucose unfed participant 1", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,2,4,5,6],'ytick',[2,4,6],'FontSize', 70,'fontname','Arial')%,'FontSmoothing','on')
yP1    = [MaxP1', fliplr(MinP1')];
fill((time2-10560)/60,yP1,c,'FaceAlpha',0.2,'EdgeAlpha',0);
plot((time-10560)/60, simBest.variablevalues(:,ismember(simBest.variables,'G'))/18,[c '-.'],'LineWidth',LineWidthValue);
xlabel("Time (h)",'FontSmoothing','on','fontname','Arial');
ylabel({'Plasma glucose' ; '(mM)'},'FontSmoothing','on','fontname','Arial');
plot((Silfvergren2021_data.time_fastedStart_p1(1:2)-10560)/60,Silfvergren2021_data.Value_fasted_p1(1:2),'kx','MarkerSize',80,'LineWidth',10)
plot((Silfvergren2021_data.time_fastedStart_p1-10560)/60,Silfvergren2021_data.Value_fasted_p1,'k.','MarkerSize',80)
line([0.2 0.25], [2 2],'Color','k','LineWidth',12);
xlim([-0.1 4])
ylim([2, 6])
%hold off


%% unfed p2
load('Silfvergren2021_ParamP2unfedCalibrated');

[row column] = size(Silfvergren2021_ParamP2unfedCalibrated);
clear optimizedParamTemp2
% P2
body_information = [0 , 1, 180, 87 ];  % female, male, height, weight
meal_information = [3, 0, 2.6, 25.55];

for i = 1:row
    optimizedParamTemp  = Silfvergren2021_ParamP2unfedCalibrated(i,1:(column-1));
    optimizedParamTemp  = log(optimizedParamTemp);
    cost                = Silfvergren2021_costfunction(Silfvergren2021_data.Value_fasted_p2(1:44),Silfvergren2021_data.time_fastedStart_p2(1:44),time,optimizedParamTemp,modelName,body_information,meal_information,44);
    optimizedParamTemp  = exp(optimizedParamTemp);
    optimizedParamTemp(column) = cost;
    optimizedParamTemp2(i,:)   = optimizedParamTemp;
end
Silfvergren2021_ParamP2unfedCalibrated = sortrows(optimizedParamTemp2,column);

for i = 1:row
    optimizedParamTemp = Silfvergren2021_ParamP2unfedCalibrated(i,1:(column-1));
    if c == 'r'
        optimizedParamTemp(102:105) = body_information;
    end

    sim = model(time,[],optimizedParamTemp);
    
    if i == 1
        p2.unfed = optimizedParamTemp';

        reactions = array2table(sim.reactionvalues, 'variablenames',sim.reactions);
        variables = array2table(sim.variablevalues, 'variablenames',sim.variables);
        states = array2table(sim.statevalues, 'variablenames',sim.states);
        sim_obj_unfed = struct();
        sim_obj_unfed.parameters = p2;
        sim_obj_unfed.reactions = reactions;
        sim_obj_unfed.variables = variables;
        sim_obj_unfed.states = states;
        sim_obj_unfed.time = sim.time';

        simBest = sim;
    end
    
    if i == 1
        maxG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG2 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
    else
        maxG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        minG1 = sim.variablevalues(:,ismember(sim.variables,'G'))/18;
        maxG2 = max(maxG2,maxG1);
        minG2 = min(minG2,minG1);
    end
    
    if i == 1
        maxGNG2 = sim.reactionvalues(:,ismember(sim.reactions,'Gluconeogenesis'));
        minGNG2 = sim.reactionvalues(:,ismember(sim.reactions,'Gluconeogenesis'));
    else
        maxGNG1 = sim.reactionvalues(:,ismember(sim.reactions,'Gluconeogenesis'));
        minGNG1 = sim.reactionvalues(:,ismember(sim.reactions,'Gluconeogenesis'));
        maxGNG2 = max(maxGNG2,maxGNG1);
        minGNG2 = min(minGNG2,minGNG1);
    end
    
    if i == 1
        maxPT2 = sim.reactionvalues(:,ismember(sim.reactions,'PyruvateTranslocase'));
        minPT2 = sim.reactionvalues(:,ismember(sim.reactions,'PyruvateTranslocase'));
    else
        maxPT1 = sim.reactionvalues(:,ismember(sim.reactions,'PyruvateTranslocase'));
        minPT1 = sim.reactionvalues(:,ismember(sim.reactions,'PyruvateTranslocase'));
        maxPT2 = max(maxPT2,maxPT1);
        minPT2 = min(minPT2,minPT1);
    end
    
%     if i == 1
%         maxaaLiver2 = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'));
%         minaaLiver2 = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'));
%     else
%         maxaaLiver1 = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'));
%         minaaLiver1 = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'));
%         maxaaLiver2 = max(maxaaLiver2,maxaaLiver1);
%         minaaLiver2 = min(minaaLiver2,minaaLiver1);
%     end
%     
%     if i == 1
%         maxaaTransportation2 = sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
%         minaaTransportation2 = sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
%     else
%         maxaaTransportation1 = sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
%         minaaTransportation1 = sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
%         maxaaTransportation2 = max(maxaaTransportation2,maxaaTransportation1);
%         minaaTransportation2 = min(minaaTransportation2,minaaTransportation1);
%     end
%     
    if i == 1
        maxRatio = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'))./sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
        minRatio = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'))./sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
    else
        maxRatioT = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'))./sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
        minRatioT = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'))./sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
        maxRatio = max(maxRatio,maxRatioT);
        minRatio = min(minRatio,minRatioT);
    end
    
%     minRatio  = minaaLiver2./minaaTransportation2;
% maxRatio  = maxaaLiver2./maxaaTransportation2;

    if i == 1
        maxProteinDigestion2 = sim.reactionvalues(:,ismember(sim.reactions,'ProteinDigestion'));
        minProteinDigestion2 = sim.reactionvalues(:,ismember(sim.reactions,'ProteinDigestion'));
    else
        maxProteinDigestion1 = sim.reactionvalues(:,ismember(sim.reactions,'ProteinDigestion'));
        minProteinDigestion1 = sim.reactionvalues(:,ismember(sim.reactions,'ProteinDigestion'));
        maxProteinDigestion2 = max(maxProteinDigestion2,maxProteinDigestion1);
        minProteinDigestion2 = min(minProteinDigestion2,minProteinDigestion1);
    end
    
    
end

MaxP1 = maxG2;
MinP1 = minG2;

% Plot p2
figure(6)
set(gcf, 'Name', "Glucose unfed participant 2", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,2,4,5,6],'ytick',[2,4,6],'FontSize', 70,'fontname','Arial')%,'FontSmoothing','on')
yP1    = [MaxP1', fliplr(MinP1')];
fill((time2-10560)/60,yP1,c,'FaceAlpha',0.2,'EdgeAlpha',0);
plot((time-10560)/60, simBest.variablevalues(:,ismember(simBest.variables,'G'))/18,[c '-.'],'LineWidth',LineWidthValue);
xlabel("Time (h)",'FontSmoothing','on','fontname','Arial');
ylabel({'Plasma glucose' ; '(mM)'},'FontSmoothing','on','fontname','Arial');
plot((Silfvergren2021_data.time_fastedStart_p2(1:2)-10560)/60,Silfvergren2021_data.Value_fasted_p2(1:2),'kx','MarkerSize',80,'LineWidth',10)
plot((Silfvergren2021_data.time_fastedStart_p2-10560)/60,Silfvergren2021_data.Value_fasted_p2,'k.','MarkerSize',80)
line([0.2 0.25], [2 2],'Color','k','LineWidth',12);
xlim([-0.1 4])
ylim([2, 6])
%hold off

figure(7)
set(gcf, 'Name', "GNG unfed p2", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,1,2],'ytick',[0.2,0.6,1],'FontSize', 65,'fontname','Arial')
yP1    = [minGNG2', fliplr(maxGNG2')];
fill(time2/1440-5.33,yP1,c,'FaceAlpha',0.2,'EdgeAlpha',0);
line([0 0.05], [0.2 0.2],'Color','k','LineWidth',12);
line([2 2.05], [0.2 0.2],'Color','k','LineWidth',12);
plot(time/1440-5.33, simBest.reactionvalues(:,ismember(simBest.reactions,'Gluconeogenesis')),[c '-.'],'LineWidth',LineWidthValue);
ylabel({'Gluconeogenesis' ; '(mg/kg/min)'},'FontSmoothing','on','fontname','Arial');
xlabel("Time (days)",'FontSmoothing','on','fontname','Arial');
xlim([-0.1 2.5])
ylim([0.2 1])
%hold off

figure(8)
set(gcf, 'Name', "PyruvateTranslocase", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,1,2],'ytick',[8,9,10],'FontSize', 65,'fontname','Arial')
yP1    = [maxPT2', fliplr(minPT2')];
fill(time2/1440-5.33,yP1*1000,c,'FaceAlpha',0.2,'EdgeAlpha',0);
line([0 0.05], [8 8],'Color','k','LineWidth',12);
line([2 2.05], [8 8],'Color','k','LineWidth',12);
plot(time/1440-5.33, simBest.reactionvalues(:,ismember(simBest.reactions,'PyruvateTranslocase'))*1000,[c '-.'],'LineWidth',LineWidthValue);
ylabel({'Pyruvate from body' ; 'into liver (ug/kg/min)'},'FontSmoothing','on','fontname','Arial');
xlabel("Time (days)",'FontSmoothing','on','fontname','Arial');
xlim([-0.1 2.5])
ylim([8 10])
%hold off

figure(9)
set(gcf, 'Name', "digested AA ratio", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,1,2],'ytick',[0,50,100],'FontSize', 55,'fontname','Arial')
% minRatio  = minaaLiver2./minaaTransportation2;
% maxRatio  = maxaaLiver2./maxaaTransportation2;
bestRatio = sim.reactionvalues(:,ismember(sim.reactions,'aaIntoLiver_Meal'))./sim.reactionvalues(:,ismember(sim.reactions,'aaTransportation'));
yP1    = [minRatio', fliplr(maxRatio')];
fill(time2(2:end-1)/1440-5.33,yP1(2:end-1)*100,c,'FaceAlpha',0.2,'EdgeAlpha',0);
plot(time(2:end-1)/1440-5.33, bestRatio(2:end-1)*100,[c '-.'],'LineWidth',LineWidthValue);
line([0 0.05], [0 0],'Color','k','LineWidth',12);
line([2 2.05], [0 0],'Color','k','LineWidth',12);
ylabel({'Amino acids catabolized' ; 'into TCA or pyruvate (%)'},'FontSmoothing','on','fontname','Arial');
xlabel("Time (days)",'FontSmoothing','on','fontname','Arial');
xlim([-0.1 2.5])
ylim([0 100])
%hold off

figure(10)
set(gcf, 'Name', "Digestion of protein into AA", 'units', 'normalized', 'outerposition', [0 0 1 1])
hold on
a = gca;
set(a,'xtick',[0,1,2],'ytick',[0,1.5,3],'FontSize', 50,'fontname','Arial')
yP1    = [maxProteinDigestion2', fliplr(minProteinDigestion2')];
fill(time2/1440-5.33,yP1,c,'FaceAlpha',0.2,'EdgeAlpha',0);
line([0 0.05], [0 0],'Color','k','LineWidth',12);
line([2 2.05], [0 0],'Color','k','LineWidth',12);
plot(time/1440-5.33, sim.reactionvalues(:,ismember(sim.reactions,'ProteinDigestion')),[c '-.'],'LineWidth',LineWidthValue);
ylabel({'Release of amino acids from' ; 'ingested protein(mg/kg/min)'},'FontSmoothing','on','fontname','Arial');
xlabel("Time (days)",'FontSmoothing','on','fontname','Arial');
xlim([-0.1 2.5])
ylim([0 3])
%hold off

if savePlots
    for i = 1:10
        figure(i)
        figname = get(gcf,'name');
        savefig([num2str(i) '-' figname '.fig'])
        exportgraphics(figure(i), [num2str(i) '-' figname '.png'])
        exportgraphics(figure(i), [num2str(i) '-' figname '.pdf'])
    end
end
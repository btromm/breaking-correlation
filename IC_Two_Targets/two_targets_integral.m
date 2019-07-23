%% Breaking Correlation
% Two different Ca targets
% Integral Controller

clear;

numSim = 250;
cond = zeros(8, numSim);

x = xolotl.examples.BurstingNeuron_multiple('prefix', 'liu');

g0=1e-1+1e-1*rand(8,1);
x.set('*gbar',g0);
x.AB.Leak.gbar=3.1688*rand()+0.0159;
x.AB.Ca_target_1=7;
x.AB.Ca_target_2=7.25;
x.t_end = 10e5;
x.sim_dt = .1;
x.dt = 100;

x.AB.NaV.add('breaking-correlation/IntegralController_target1', 'tau_m', 666);
x.AB.CaT.add('breaking-correlation/IntegralController_target1', 'tau_m', 55555);
x.AB.CaS.add('breaking-correlation/IntegralController_target2', 'tau_m', 45454);
x.AB.ACurrent.add('breaking-correlation/IntegralController_target1', 'tau_m', 5000);
x.AB.KCa.add('breaking-correlation/IntegralController_target2', 'tau_m', 1250);
x.AB.Kd.add('breaking-correlation/IntegralController_target2', 'tau_m', 2000);
x.AB.HCurrent.add('breaking-correlation/IntegralController_target2', 'tau_m', 125000);

x.set('*tau_g',x.get('*tau_g')/10);

%% Integration

for i=1:numSim

    g0 = 1e-1+1e-1*rand(8,1);

    x.set('*gbar', g0)

    x.AB.Leak.gbar = 3.1688*rand()+0.0159;
    x.integrate;
    x.integrate;

    cond(:,i) = x.get('AB*gbar');
    corelib.textbar(i,numSim);
end


%% Plotting

figure()
sgtitle('Conductance densities')
for i=1:49
    if(i==1)
        subplot(7,7,1);
        scatter(cond(1,:), cond(2,:), 5, 'filled')
        ylabel('CaS');
    elseif(i==8)
        subplot(7,7,8);
        scatter(cond(1,:), cond(3,:), 5, 'filled');
        ylabel('CaT');
    elseif(i==9)
        subplot(7,7,9);
        scatter(cond(2,:), cond(3,:), 5, 'filled');
    elseif(i==15)
        subplot(7,7,15);
        scatter(cond(1,:), cond(4,:), 5, 'filled');
        ylabel('HCurrent')
    elseif(i==16)
        subplot(7,7,16);
        scatter(cond(2,:), cond(4,:), 5, 'filled');
    elseif(i==17)
        subplot(7,7,17);
        scatter(cond(3,:), cond(4,:), 5, 'filled');
    elseif(i==22)
        subplot(7,7,22);
        scatter(cond(1,:), cond(5,:), 5, 'filled');
        ylabel('KCa');
    elseif(i==23)
        subplot(7,7,23);
        scatter(cond(2,:), cond(5,:), 5, 'filled');
    elseif(i==24)
        subplot(7,7,24);
        scatter(cond(3,:), cond(5,:), 5, 'filled');
    elseif(i==25)
        subplot(7,7,25);
        scatter(cond(4,:), cond(5,:), 5, 'filled');
    elseif(i==29)
        subplot(7,7,29);
        scatter(cond(1,:), cond(6,:), 5, 'filled');
        ylabel('Kd')
    elseif(i==30)
        subplot(7,7,30);
        scatter(cond(2,:), cond(6,:), 5, 'filled');
    elseif(i==31)
        subplot(7,7,31);
        scatter(cond(3,:), cond(6,:), 5, 'filled');
    elseif(i==32)
        subplot(7,7,32);
        scatter(cond(4,:), cond(6,:), 5, 'filled');
    elseif(i==33)
        subplot(7,7,33);
        scatter(cond(5,:), cond(6,:), 5, 'filled');
    elseif(i==36)
        subplot(7,7,36);
        scatter(cond(1,:), cond(7,:), 5, 'filled');
        ylabel('Leak')
    elseif(i==37)
        subplot(7,7,37);
        scatter(cond(2,:), cond(7,:), 5, 'filled');
    elseif(i==38)
        subplot(7,7,38);
        scatter(cond(3,:), cond(7,:), 5, 'filled');
    elseif(i==39)
        subplot(7,7,39);
        scatter(cond(4,:), cond(7,:), 5, 'filled');
    elseif(i==40)
        subplot(7,7,40);
        scatter(cond(5,:), cond(7,:), 5, 'filled');
    elseif(i==41);
        subplot(7,7,41);
        scatter(cond(6,:), cond(7,:), 5, 'filled');
    elseif(i==43);
        subplot(7,7,43);
        scatter(cond(1,:), cond(8,:), 5, 'filled');
        ylabel('NaV')
        xlabel('ACurrent')
    elseif(i==44);
        subplot(7,7,44);
        scatter(cond(2,:), cond(8,:), 5, 'filled');
        xlabel('CaS')
    elseif(i==45);
        subplot(7,7,45);
        scatter(cond(3,:), cond(8,:), 5, 'filled');
        xlabel('CaT')
    elseif(i==46);
        subplot(7,7,46);
        scatter(cond(4,:), cond(8,:), 5, 'filled');
        xlabel('HCurrent')
    elseif(i==47)
        subplot(7,7,47);
        scatter(cond(5,:), cond(8,:), 5, 'filled');
        xlabel('KCa')
    elseif(i==48)
        subplot(7,7,48);
        scatter(cond(6,:), cond(8,:), 5, 'filled');
        xlabel('Kd')
    elseif(i==49)
        subplot(7,7,49);
        scatter(cond(7,:), cond(8,:), 5, 'filled');
        xlabel('Leak')
    end
end

%% Plot Conductance vs time & voltage trace

g0 =  1e-1+1e-1*rand(8,1); % random initial conditions
x.set('*gbar', g0)
x.AB.Leak.gbar = 3.1688*rand()+0.0159; %Leak maximal conductance

x.t_end = 5e6;
x.sim_dt = .1;
x.dt = 100;
[~,~,C] = x.integrate;

figure('outerposition',[300 300 900 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on

time = x.dt*(1:length(C))*1e-3;
plot(time,C(:,2:2:end));
set(gca,'XScale','log','YScale','log','YTick',[1e-2 1e0 1e2 1e4])
xlabel('Time (s)')
ylabel('g (uS/mm^2)')


subplot(2,1,2); hold on
x.dt = .1;
x.t_end = 1e3;
V = x.integrate;
time = x.dt*(1:length(V))*1e-3;
plot(time,V,'k')
set(gca,'YLim',[-80 50])
ylabel('V_m (mV)')
xlabel('Time (s)')
drawnow

figlib.pretty('PlotLineWidth',1.5,'LineWidth',1.5)

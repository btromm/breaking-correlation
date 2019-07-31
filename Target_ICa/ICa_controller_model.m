%% ICa target model
%{
7/29/19
Marder Lab

This model uses an integral controller which integrates toward a target calcium current (iCa_target)
Different controllers can be used to attempt to break correlations, this is done in the script
using O'Leary et al. 2014's IntegralController mechanism.
%}

%% Set Parameters for pure ICa Controller

close all;
clear all;

x=xolotl.examples.BurstingNeuron('prefix','prinz'); %initialize Prinz model


% Load in I_Ca controllers

x.AB.NaV.add('oleary/IntegralController');
x.AB.CaT.add('breaking-correlation/Target_ICa/ICaController');
x.AB.CaS.add('breaking-correlation/Target_ICa/ICaController');
x.AB.ACurrent.add('breaking-correlation/Target_ICa/ICaController');
x.AB.KCa.add('oleary/IntegralController');
x.AB.Kd.add('breaking-correlation/Target_ICa/ICaController');
x.AB.HCurrent.add('oleary/IntegralController');


%{
x.AB.NaV.add('oleary/IntegralController');
x.AB.CaT.add('oleary/IntegralController');
x.AB.CaS.add('oleary/IntegralController');
x.AB.ACurrent.add('oleary/IntegralController');
x.AB.KCa.add('oleary/IntegralController');
x.AB.Kd.add('oleary/IntegralController');
x.AB.HCurrent.add('oleary/IntegralController');
%}


% Set taus
x.set('*tau_m',5e5./x.get('*gbar'));
x.set('*tau_ICa', 3e3);

% Set target(s)
x.set('*iCa_target',-111);
x.AB.Ca_target=116;

% Add leak current and set random initial conditions
x.AB.add('Leak','E',-50);
g0=1e-1+1e-1*rand(8,1);
x.set('*gbar',g0);
g0 = 1e-1+1e-1*rand(7,1);
x.set('*Controller.m',g0);
x.AB.Leak.gbar=(1e-4/x.AB.A)+((1.99e-2/x.AB.A)*rand());

% Simulation parameters
x.t_end = 1e6;
x.sim_dt = .1;
x.dt = 100;
numSim = 100;

% Integrate model and pull out mRNA concentrations

[~,~,C] = x.integrate;


%% Plot voltage trace & mRNA concentrations vs time

figure('outerposition',[300 300 900 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on

time = x.dt*(1:length(C))*1e-3;
plot(time,C(:,2:2:end));
set(gca,'XScale','log','YScale','log','YTick',[1e-2 1e0 1e2 1e4])
xlabel('Time (s)')
ylabel('g (uS/mm^2)')

subplot(2,1,2); hold on
x.dt = .1;
x.t_end = 5e3;
V = x.integrate;
time = x.dt*(1:length(V))*1e-3;
plot(time,V,'k')
set(gca,'YLim',[-80 50])
ylabel('V_m (mV)')
xlabel('Time (s)')
drawnow

figlib.pretty('PlotLineWidth',1.5,'LineWidth',1.5)


%% Conductance correlations

% Simulation parameters
x.t_end = 1e6;
x.sim_dt = .1;
x.dt = 100;
numSim = 250;

% Integrate the model *numSim* number of times
for i=1:numSim

    g0 = 1e-1+1e-1*rand(8,1);
    x.set('*gbar', g0)
    g0 = 1e-1+1e-1*rand(7,1);
    x.set('*Controller.m',g0);
    x.AB.Leak.gbar=(1e-4/x.AB.A)+((1.99e-2/x.AB.A)*rand());

    x.integrate;
    cond(:,i) = x.get('AB*gbar');

    corelib.textbar(i,numSim);
end

% Plot Conductance Comparisons

c = lines;
idx = 1;
channels = x.AB.find('conductance');
N = length(channels);
ax = figlib.gridAxes(N);

for i = 1:N-1
        for j = i+1:N
                idx = idx + 1;
                ph(i,j) = scatter(ax(i,j),cond(i,:),cond(j,:),'MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerFaceAlpha',.2);
                if j < N
                        set(ax(i,j),'XColor','w')
                end

                if i > 1
                        set(ax(i,j),'YColor','w')
                end

                if j == N
                        xlabel(ax(i,j),channels{i})
                end

                if i == 1
                        ylabel(ax(i,j),channels{j})
                end

        end
end

figlib.pretty('PlotLineWidth',1)

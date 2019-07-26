%% Breaking Correlation
% ICa target model

clear all;

x = xolotl.examples.BurstingNeuron('prefix','prinz');
x.t_end = 5e3;
x.sim_dt = 0.1;
x.dt = 0.1;

%{
x.AB.NaV.add('oleary/IntegralController');
x.AB.CaT.add('oleary/IntegralController');
x.AB.CaS.add('oleary/IntegralController');
x.AB.ACurrent.add('oleary/IntegralController');
x.AB.KCa.add('oleary/IntegralController');
x.AB.Kd.add('oleary/IntegralController');
x.AB.HCurrent.add('oleary/IntegralController');

x.set('*tau_m',5000./ x.get('*gbar'));

%}

x.AB.add('Leak','E',-50,'gbar',1e-2);

%x.AB.Ca_target=115.5;

[V,Ca,M,I] = x.integrate;


%{
figure('outerposition',[300 300 900 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on

time = x.dt*(1:length(M))*1e-3;
plot(time,M(:,2:2:end));
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


%}

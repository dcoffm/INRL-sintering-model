
% Construct material
Al2O3 = SinterMaterial();
Al2O3.SD_sc = 7.7025e-7;
Al2O3.con = 8.44e7;
Al2O3.burger = 2.861e-10;
Al2O3.SD_D0 = 3.165e-26;
Al2O3.SD_dG = 3e5;
Al2O3.CS1 = 3.051e20;
Al2O3.CS2 = -4.236;

% Construct sinter model
C = SinterModel(Al2O3);
C.rho00 = 0.53;
C.rho0  = 0.587;
C.GS0   = 0.3e-6;
C.contactCurve = 0.9;

% Construct sinter fit
F = SinterFit(Al2O3);

% Experimental conditions:
rates = [5 10 20]; % °C/min
Tmax = 1525;
Tstart = 1000;
for i = 1:numel(rates)    
    fname = sprintf('alumina_%02ucpm.csv',rates(i));
    data_expt = readmatrix(fname);
    time_ramp = (Tmax-Tstart)/(rates(i)/60);
    C.rho_obs = data_expt(:,2);
    % C.grainsize_obs = ;  No grain size data from this experiment
    Tobs = data_expt(:,1);
    tobs = interp1([Tstart Tmax],[0 time_ramp],Tobs);
    C.tt_profile = [tobs Tobs];
    C.time_obs = tobs;
    C.T_obs = Tobs;
    F.runs(i) = copy(C);
    F.labels{i} = sprintf('%0.0f °C/min',rates(i));
end
F.fitMode = 1;
F.densPlot = 1;

% Initial guesses for parameters
F.seedAppend('mat.SD_D0',1.7e3)
F.seedAppend('mat.SD_dG',4.4e5)
F.seedAppend('mat.CS1',3e20)
F.seedAppend('mat.CS2',-4.236)
F.seedAppend('contactCurve',0.9,0.2,1)

% Run the fitting algorithm
F.Initialize();
F.Iterate(100);

% Examine sintering stress temperature dependence
colors = linspecer(numel(F.runs));
figure; hold on
for i =1:numel(rates)
    plot(F.runs(i).Temperature,F.runs(i).ES,'.','Color',colors(i,:));
    xlabel('Temperature (K)')
    ylabel('Stress (Pa)')
end
title('Critical stress model')

F.mat.ExportParams('Al2O3_MSC.mat');


% Construct material
ZrO2 = SinterMaterial();
ZrO2.SD_sc = 7.7025e-7;
ZrO2.con = 84400000;
ZrO2.burger = 3.54e-10;
ZrO2.SD_D0 = 1300000;
ZrO2.SD_dG = 460000;
ZrO2.CS1 = 4.989e54;
ZrO2.CS2 = -14.6;

% Construct sinter model & sinter fit
dat = readmatrix('1450.csv');
C = SinterModel(ZrO2);
C.time_obs      = dat(:,1)*60;    % Time [s]
C.rho_obs       = dat(:,2);       % Density [1]
C.grainsize_obs = dat(:,3);       % Grain size [m]
C.rho0 = C.rho_obs(1);
C.GS0  = C.grainsize_obs(1);
C.tt_profile = [C.time_obs; 1450*ones(size(C.time_obs))]';
F = SinterFit(ZrO2);
F.runs(1) = copy(C);

% Fit isothermal grain size data
F.fitMode = 0;
F.mat.SD_dG = 0; % Isothermal = prefactor only
F.seedAppend('mat.SD_D0',1.7e-10,1e-20,1);
F.Initialize(); % Constructs the plot
F.Iterate(30);  % Iterates the Nelder-Mead algorithm

% Fit isothermal density data
F.fitMode = 1;
F.seedClear();
F.mat.CS2 = 0;
F.seedAppend('mat.CS1',2.02e7,0,1e10);
F.seedAppend('contactCurve',0.8,0,1);
F.Initialize();
F.Iterate(100);

% Save/load material parameters or the whole sintering model like so:
F.mat.ExportParams('ZrO2.mat');
testZrO2 = SinterMaterial();
testZrO2.ImportParams('ZrO2.mat');

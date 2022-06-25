
% Materials properties (e.g. save/load from a *.mat file)
ZrO2.molar_volume = 0.000026;    % molar volume, [m^3/mol]
ZrO2.interface_energy = 1;       % interfacial energy, [J/m^2]
ZrO2.eta     = 0.5;              % work efficiency, taken as the activation volume/molar volume (eta in paper)
ZrO2.geo     = 10;               % geometric factor in mullins model: 30 deg=10, 45 deg=37, 7 deg ≈1
ZrO2.surf_con= ZrO2.molar_volume^(4/3);    % Surface concentration of defects
ZrO2.con     = 8.44e+7;          % Conversion factor from mol to atoms
ZrO2.burger  = 0.354e-9;         % Burgers vector, [m]
ZrO2.D0      = 1.3e6;            % Surface diffusivity pre-exponential, [m^2/s]
ZrO2.D_AE    = 460000;           % Surface diffusivity activation energy, [J/mol]

ZrO2.CS1     = 4.98942368100215e+54; % Critical stress constant 1 (??)
ZrO2.CS2     = -14.6;                % Critical stress exponent   (??)
% CS = CS1*T^CS2;

save('ZrO2.mat','ZrO2');
% load('ZrO2.mat'); % After the material has been defined/saved you can load it instead

% Properties of the powder compact
system.mat   = ZrO2;           % material properties
system.rho00 = 0.53;           % "no contact" density
system.rho0  = 0.60;           % density at starting time
system.GS0   = 2e-6;           % particle size at starting time
system.contact_curve = 0.803;  % an exponent defining the evolution of particle contact area vs total area with density
system.zeta   = 1;             % From paper, fraction of surface energy that goes to densification.

%{
% Example temperature profile: time (s), Temp (°C)
tt_profile =[    0,   24;
             18000, 1600;
             72000, 1600;
             90000,   24];
%}

% Densification for different sintering soak temperature with fixed time
%{-
Nmax = 1e6; % Maximum number of time steps to compute as a failsafe
H1 = figure; 
soaks = [1600 1700 1800 1900];
legend_str = {};
for i = 1:numel(soaks)
    tt_profile =[    0,   24;
             18000, soaks(i);
             72000, soaks(i);
             90000,   24];
    
    [time,density,grainsize] = sinter(system,tt_profile,1,Nmax);
    semilogy(density,grainsize*1e6)
    if i==1; hold on; box on; end
    legend_str{i} = sprintf('%u °C',soaks(i));
end
title('Sintering: Soak Temperature (5/15/5 hrs)')
xlabel('Density')
ylabel('Grain size (\mum)')
legend(legend_str,'Location','Southeast')
%}

%
% Densification for fixed temperature & time with different heating rates
%
%{-
Nmax = 1e6; % Maximum number of time steps to compute as a failsafe
H2 = figure; % sintering figure

soak = 1800;
rates = [1 10 100]/60; % degree/second  [°/min]/[60 seconds/min]
total_time = 2*soak/rates(1) + 1000000;
legend_str = {};
for i = 1:numel(rates)
    tt_profile =[    0,   24;
             soak/rates(i), soak;
             total_time-soak/rates(i), soak;
             total_time,   24];
    
    [time,density,grainsize] = sinter(system,tt_profile,[],Nmax);
    
    subplot(2,2,1)
    plot(tt_profile(:,1)/3600,tt_profile(:,2)); hold on
    xlabel('time (hr)')
    ylabel('Temperature (°C)')
    xlim([0 total_time/3600])
    
    subplot(2,2,3)
    plot(time/3600,grainsize*1e6); hold on
    xlabel('time (hr)')
    ylabel('Grain size (\mum)')
    xlim([0 total_time/3600])
    
    subplot(2,2,4)
    plot(time/3600,density); hold on
    xlabel('time (hr)')
    ylabel('Density')
    xlim([0 100])
    
    subplot(2,2,2)
    semilogy(density,grainsize*1e6)
    if i==1; hold on; box on; end
    xlabel('Density')
    ylabel('Grain size (\mum)')
    
    legend_str{i} = sprintf('%u °C/min',rates(i)*60);
end
legend(legend_str,'Location','Northwest')


% Similar grain size vs denisty plot but visualize time as a colormap
% (illustrates how most of the densification happens quickly for high heating rate)
%{-
Nmax = 1e6; % Maximum number of time steps to compute as a failsafe
H3 = figure;
total_time = 2*soak/rates(1)+1; % Slowest rate just touches soak temp before descending
for i = 1:numel(rates)
    tt_profile =[    0,   24;
             soak/rates(i), soak;
             total_time-soak/rates(i), soak;
             total_time,   24];
    
    [time,density,grainsize] = sinter(system,tt_profile,[],Nmax);
    
    % Plot one point for each hour
    %{
    mask = [];
    for hr = 1:floor(time(end)/3600)
        I = find((time/3600) > hr,1);
        mask = [mask I];
    end
    %}
    mask = 1:numel(time);
    scatter(density(mask),grainsize(mask)*1e6,10,time(mask)/3600,'.')
    h = gca;
    h.YScale = 'log';
    hold on
end
h = colorbar;
h.Label.String = 'Time (hrs)';
colormap hsv
box on;
xlabel('Density')
ylabel('Grain size (\mum)')
%}

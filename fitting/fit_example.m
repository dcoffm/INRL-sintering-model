
load ZrO2

% Initial seed values for parameters that are to be fit
dumbCritStress = 2.0210e+07;    % Critical stress 
dumbT = 1450+273;               % Approximate temperature of the collected data. (Not used to fit here.)
dumbD = 1.6936e-10;             % Surface diffusivity,  D = D_o*exp(-(D_AE)/(R*dumbT))
dumbN = 1.19;                   % Shape parameter for the contact curve

% Read experimental data
dat = readmatrix('1450.csv');
time_data = dat(:,1)*60;    % Time [s]
rho_data  = dat(:,2);       % Density [1]
GS_data   = dat(:,3);       % Grain size [m]

% Setup the input structure
system.mat   = ZrO2;           % Compact material properties
system.rho00 = 0.5;            % Compact "zero contact" density
system.rho0  = rho_data(1);    % Compact density at starting time
system.GS0   = GS_data(1);     % Compact particle size at starting time
system.zeta  = 1;              % From paper, fraction of surface energy that goes to densification.

% Modify variables involved with fitting:
system.mat.CS1 = dumbCritStress;
system.mat.CS2 = 0;
system.mat.D0 = dumbD;
system.mat.D_AE = 0;
system.contact_curve = dumbN;

%
% Fit the grain size data and calculate a diffusivity.
%
% Note that this may not extend far into the later stages, however a G^3 or G^4
% dependence is likely reasonable there too. In this case D is not a physical
% parameter for surface diffusion, just an effective coarsening rate constant.
% 

seed = dumbD;
input.system   = system;
input.tt_profile = [time_data, dumbT*ones(size(time_data))];
input.dt = 10;
input.Nmax = 1e5;
output_observed = {time_data,GS_data};

fhandle = @f_diffusivity;
ehandle = @e_diffusivity;
phandle = @p_diffusivity;  % set phandle argument to [] if you don't want the plot

simplex_its = 30;
diffusivity_fit = Simplex(seed,input,output_observed,fhandle,ehandle,phandle,simplex_its)

%
% Fit critical stress using the fitted D value
%
system.mat.D0 = diffusivity_fit;
input.system = system;
seed = [dumbCritStress, dumbN];

output_observed = {time_data,rho_data};
fhandle = @f_density;
ehandle = @e_density;
phandle = @p_density;

simplex_its = 100;
fits = Simplex(seed,input,output_observed,fhandle,ehandle,phandle,simplex_its);
critStress_fit = fits(1)
n_fit = fits(2)


% Plot grain size vs density
system.mat.CS1 = critStress_fit;
system.contact_curve = n_fit;
[time,rho_fit,grainsize_fit] = sinter(system,input.tt_profile,input.dt,input.Nmax);

figure; hold on;
plot(rho_data,GS_data*1e6,'k*')
plot(rho_fit,grainsize_fit*1e6,'r');
xlabel('Density'); xlim([rho_fit(1) 1])
ylabel('Grain size (\mum)');
legend({'Observed','Fit'},'Location','Northwest')
box on;

function [time,rho,grainsize] = sinter(system,tt_profile,dt,Nmax)

% Predicts the density and grain size evolution of a powder compact with properties defined in the 'system' struct,
% using the provided time/temperature profile 'tt_profile'

% dt - if supplied, fixes the time steps used. If empty [], a variable dt will be used based on the rates calculated
% Nmax - a maximum number of time steps to compute, after which the loop will stop regardless of completion.

% General constants
R = 8.31446261815324;   % gas constant
k = 1.380649e-23;       % boltzmann constant in Joules
avogadro= 6.0221409e23; % avogadros number

% Material properties
MV    = system.mat.molar_volume;        % molar volume, [m^3/mol]
gamma = system.mat.interface_energy;    % interfacial energy, [J/m^2]
eta   = system.mat.eta;                 % work efficiency, taken as the activation volume/molar volume (eta in paper)
geo   = system.mat.geo;                 % geometric factor in mullins model: 30 deg=10, 45 deg=37, 7 deg ~1
s_c   = system.mat.surf_con;            % surface concentration of defects
con   = system.mat.con;                 % conversion factor from mol to atoms
D0    = system.mat.D0;                  % surface diffusivity pre-exponential, [m^2/s]
D_AE  = system.mat.D_AE;                % surface diffusivity activation energy, [J/mol]
CS1   = system.mat.CS1;                 % critical stress constant (??)
CS2   = system.mat.CS2;                 % critical stress exponent (??)  CS = CS1*T^CS2;

% Other inputs
time_input = tt_profile(:,1);
T_input = tt_profile(:,2);
t0   = time_input(1);
GS0  = system.GS0;         % Initial grain size
rho0 = system.rho0;        % Initial density
rho00= system.rho0-0.01;   % "no contact" density
zeta = system.zeta;        % From paper, fraction of surface energy that goes to densification.
cc = system.contact_curve; % an exponent defining the evolution of particle contact area vs total area with density

% Initialize empty arrays
time        = NaN([Nmax 1]); % time (seconds)
rho         = NaN([Nmax 1]); % Density (unitless)
grainsize   = NaN([Nmax 1]); % Grain radius
A           = NaN([Nmax 1]); % Specific surface area

time(1) = t0;
rho (1) = rho0;
grainsize(1) = GS0;
A(1) = 3 *rho0*(1-contact_frac(rho0,rho00,cc))./GS0;

% The loop
i = 2; % iteration counter
Tstep = 2; % Track which step of the tt_profile we are on, to ensure we don't choose overly large time steps
dynamic_dt = isempty(dt);
if dynamic_dt
    dt = 10; % an initial value for time step
end
warn_step = false;
warn_CS   = false;

while i<Nmax && Tstep <= numel(T_input)
    
    time(i) = time(i-1) + dt;
    T = 273.15 + interp1(time_input,T_input, time(i-1) ); % Current temperature (K)
    D = D0 * exp(-(D_AE)/(R*T));               % Surface diffusivity
    CS = CS1*T^CS2;                            % Critical stress
    rate_con =((geo*D*gamma*s_c)/(con*R*T));   % Overall rate constant
    fac = zeta*gamma/CS/eta;                   % Factor coupling surface energy dissipation to densification
    
    if CS <= 0
        CS = 1;
        warn_CS = true;
    end
        
    % Avoid skipping over temperature changes with a large time step
    Tstepchange = false;
    dt_temp = dt;
    if time(i) > time_input(Tstep) && time(i-1) ~= time_input(Tstep)
        time(i) = time_input(Tstep);
        Tstep = Tstep + 1;
        dt = time(i) - time(i-1);
        Tstepchange = true;
    end
    
    rho_ = rho(i-1); % to save time indexing, "current" density
    
    drdt = (rate_con/4)*(GS0^4 + rate_con*(time(i)-time(1)) )^(-3/4);
    grainsize(i) = grainsize(i-1) + dt*drdt;
    [cf,dcf] = contact_frac(rho_,rho00,cc);
    A(i) = 3 * rho_ * (1-cf) / grainsize(i);
    
    drhodt = rho_*drdt/grainsize(i)*A(i)*fac;
    
    % Factor related to reduction in surface area from densification itself?
    temp = abs(1+ fac*3*rho_/grainsize(i)*((1-cf)- rho_*dcf )); 
    temp = 1; % Negate the factor; may not be well-behaved
    drhodt = drhodt/temp;
    rho(i) = rho_ + drhodt*dt;
    
    dt = dt_temp;    
    drho = drhodt*dt;
    dr   = drdt*dt;
    
    if dynamic_dt  % Assess time step appropriateness; if too large or small, choose a different dt and try again
        if drho > 1e-3 || dr > 1e-6
            dt = dt/2;
            i = i-1;
            
        elseif drho < 1e-6 && ~Tstepchange
            dt = dt*1.5;
            i = i+1;

        else % loop proceeds normally
            if rho(i)>1
                rho(i)=1;
            end
            i = i+1;
        end
    else % Otherwise, if dt is fixed, give a warning
        if drho > 1e-2; warn_step = true; end
        if rho(i)>1
            rho(i)=1;
        end
        i = i+1;
    end
end

if i==Nmax; warning('Maximum number of time steps reached without completion.'); end
if warn_step; warning('Densification >1e-2 per step occured.'); end
if warn_CS; warning('A negative critical stress value occured.'); end

% Trim any allocated but unused space before returning the results:
mask = ~isnan(time);
time = time(mask);
rho  = rho(mask);
grainsize = grainsize(mask);

% In case there are duplicated time steps:
[~,I,~] = unique(time);
time = time(I);
rho = rho(I);
grainsize = grainsize(I);

end
classdef SinterModel < ImportExport & handle_light & matlab.mixin.Copyable 
    
    properties
        
        mat (1,1) SinterMaterial % Material properties
        
        tt_profile  (:,2) double % time/temperature control points [s ;°C]
        time        (1,:) double % [s] time
        Temperature (1,:) double % [K] Temperature
        rho         (1,:) double % [1] Fractional Density
        grainsize   (1,:) double % [m] Grain diameter
        APV         (1,:) double % [/m] Specific area (area per volume)
        ES          (1,:) double % [Pa] Effective stress (critical * eta)

        rho0      (1,1) double = 0.60  % [1] Initial density
        rho00     (1,1) double = 0.50  % [1] "zero contact" density
        GS0       (1,1) double = 2.0e3 % [m] Initial grain size
        
        zeta         (1,:) double = 1.0 % Fraction of surface energy that goes to densification
        eta          (1,:) double = 0.5 %
        contactCurve (1,1) double = 0.8 % An exponent defining the evolution of particle contact area vs total area with density
                
        Nmax (1,1) double = 1e5 % maximum time steps
        dt   (1,1) double = 1  % time step size
        dynamic_dt (1,1) logical = 1; % Variable time step
                
        time_obs      (1,:) double % Observed parameters to fit against
        grainsize_obs (1,:) double 
        rho_obs       (1,:) double
        T_obs         (1,:) double
    end
    
    methods
        % Constructor
        function this = SinterModel(mat)
            this.mat = mat;
        end
                
        % Class-specific routines:
        function [value,derivative] = contact_frac(this,rho_)
            % This is a basic placeholder function to account for the change in free surface area with densification
            % Returns fraciton of particle boundary that is in contact (i.e. not a free surface) based on compact density (rho0 to 1).
            % The "infinitesimal contact" density (rho0) describes the intial compact in which particles have ~100% free surface

            value = real(((rho_-this.rho0)/(1-this.rho0)).^(1/this.contactCurve));
            if value>1; value = 1; end
            if value<0; value = 0; end
            if rho_== this.rho0
                rho_ = this.rho0+0.01; % Avoid a divide-by-zero for the derivative
            end
            derivative = value/this.contactCurve/(rho_-this.rho0);
        end
        
        function [time,grainsize,rho,APV,T,ES] = AllocateVecs(this)
            T = NaN([this.Nmax 1]);
            time = NaN([this.Nmax 1]);
            rho  = NaN([this.Nmax 1]);
            grainsize = NaN([this.Nmax 1]);
            APV = NaN([this.Nmax 1]);
            ES  = NaN([this.Nmax 1]);            
            rho(1) = this.rho0;
            grainsize(1) = this.GS0/2; % Diameter to radius, which is used internally
            APV(1) = 3 * this.rho0*(1-this.contact_frac(this.rho0))./this.GS0;
        end
        
        function this = trimNaN(this,time,grainsize,rho,APV,T,ES)
            mask = ~isnan(time);
            time = time(mask);
            rho  = rho(mask);
            grainsize = grainsize(mask)*2; % Back to diameter
            APV = APV(mask);
            T = T(mask);
            ES = ES(mask);            
            
            [~,I,~] = unique(time); % In case there are duplicated time steps
            this.time = time(I);
            this.rho = rho(I);
            this.grainsize = grainsize(I);
            this.APV = APV(I);
            this.Temperature = T(I);
            this.ES = ES(I);
        end
        
        % Runs the model on the current tt profile and material parameters
        function this = Sinter(this)
            
            % Apparently indexing into class structure is really slow,
            % so we'll work with local variables and write to class at the end
            [time,grainsize,rho,APV,T,ES] = AllocateVecs(this); 
            
            time_input = this.tt_profile(:,1);
            T_input = this.tt_profile(:,2);
            time(1) = time_input(1);
            T(1)    = 273.15 + T_input(1);
            
            i = 2; % Iteration counter
            Tstep = 2; % Track which control point we're on, avoid overly large time steps
            if this.dynamic_dt
                this.dt = 10;
            end
            warn_step = false;
            
            %gamma = this.mat.gamma_surf;
            %geo = this.mat.SD_geo;
            %s_c = this.mat.SD_sc;
            %con = this.mat.con;
            m = this.mat;
            Rconst = 8.31446261815324;
            
            while i<this.Nmax && Tstep <= numel(T_input)
                time(i) = time(i-1) + this.dt;
                T(i) = 273.15 + interp1(time_input,T_input, time(i-1) ); % Current temperature (K)
                
                D = m.Tval_DiffSurf(T(i));             % Surface diffusivity
                CS = m.Tval_critStress(T(i));          % Critical stress
                ES(i) = this.eta * CS;                 % Effective stress
                
                rate_con =((m.SD_geo*D*m.gamma_surf*m.SD_sc)/(m.con*Rconst*T(i)));   % Surface diffusion rate constant
                dedA = this.zeta*m.gamma_surf/ES(i);         % Factor coupling surface energy dissipation to densification

                % Avoid skipping over temperature changes with a large time step
                Tstepchange = false;
                dt_temp = this.dt;
                if time(i) > time_input(Tstep) && time(i-1) ~= time_input(Tstep)
                    time(i) = time_input(Tstep);
                    Tstep = Tstep + 1;
                    this.dt = time(i) - time(i-1);
                    Tstepchange = true;
                end

                rho_ = rho(i-1); % to save time indexing, "current" density
                drdt = (rate_con/4)*(this.GS0^4 + rate_con*(time(i)-time(1)) )^(-3/4);
                grainsize(i) = grainsize(i-1) + this.dt*drdt;
                [cf,dcf] = this.contact_frac(rho_);
                APV(i) = 3 * rho_ * (1-cf) / grainsize(i);

                drhodt = drdt*rho_/grainsize(i)*APV(i)*dedA;

                rho(i) = rho_ + drhodt*this.dt;                
                this.dt = dt_temp;
                drho = drhodt*this.dt;
                dr   = drdt*this.dt;

                if this.dynamic_dt  % Assess time step appropriateness; if too large or small, choose a different dt and try again
                    if drho > 1e-3 || dr > 1e-6
                        this.dt = this.dt/2;
                        i = i-1;
                        if i==1; i=2; end

                    elseif drho < 1e-5 && ~Tstepchange
                        this.dt = this.dt*1.5;
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
            
            if i==this.Nmax; warning('Maximum number of time steps reached without completion.'); end
            if warn_step; warning('Densification >1e-2 per step occured.'); end
            % Trim any allocated but unused space before returning the results:
            trimNaN(this,time,grainsize,rho,APV,T,ES);
        end
        
    end
    
end
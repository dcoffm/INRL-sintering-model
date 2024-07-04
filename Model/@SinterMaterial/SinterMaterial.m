classdef SinterMaterial < ImportExport
    
    properties
        
        % Material properties:
        unitCell (1,1) double = 0.5188% [nm] Useful for quickly estimating other values
        atVol  (1,1) double = 0.0349; % [nm3] for FCC, estimate as 0.25*a^3
        burger (1,1) double
        con (1,1) double % Conversion factor from mol to atom
        
        % Surface diffusion
        gamma_surf (1,1) double = 1.0 % [J/m2] Surface energy
        SD_D0   (1,1) double = 1       % [nm^2/s] Prefactor
        SD_dG   (1,1) double = 4.315   % [eV] Activation energy for diffusion hopping
        SD_geo  (1,1) double = 10      % [1] Geometric factor from mullins model  30 deg=10, 45 deg=37, 7 deg ~1
        SD_sc   (1,1) double = 1       % [nm^-2] Surface concentration of defects
        
        
        CS1 (1,1) double % Critcial stress constant 1
        CS2 (1,1) double % Critical stress constant 2
        
        
        % GB diffusion
        gamma_GB   (1,1) double = 0.5 % [J/m2] grain boundary energy
        GBD_thick(1,1) double = 1       % [nm] Thickness of diffusion channel
        GBD_dG   (1,1) double = 4.315   % [eV] Activation energy for diffusion hopping
        GBD_D0   (1,1) double = 1       % [nm^2/s] Prefactor
        GBD_B    (1,1) double = 1       % [nm^6/s] Composite term containing diffusivity, atomic volume, and diffusion channel thickness
        GBD_B0   (1,1) double = 1       % [nm^6/s] Composite term containing D0, atomic volume, and thickness
        
        % Nucleation:
        Nuc_burger (1,1) double = 0.35     % [nm] Climb component of densification-mediating GB dislocations
        Nuc_v0     (1,1) double = 7.557e-4 % [nm3]
        Nuc_valph  (1,1) double = 2.595e-3 % [/K]
        Nuc_S      (1,1) double = 2.033e-6 % [eV/K]
        Nuc_H      (1,1) double = 2.5      % [eV]
        Nuc_n0     (1,1) double = 1.8e5    % [Hz/nm]
        Nuc_A      (1,1) double = 0.6      % [eV] Composite of H - ST - kT ln(b*n0)
        
    end
    
    methods
        function this = SinterMaterial()

        end
        
        function CS = Tval_critStress(this,T)
            CS = this.CS1*T^this.CS2;
        end
        
        function D = Tval_DiffSurf(this,T)
            RT = T * 8.31446261815324;
            D = this.SD_D0 * exp(-this.SD_dG/RT);
        end
        
    end
    
end
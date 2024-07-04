classdef SinterMaterial < ImportExport
    
    properties
        
        % Material properties:
        burger (1,1) double % [m]
        con (1,1) double % Conversion factor from mol to atom
        
        % Surface diffusion
        gamma_surf (1,1) double = 1.0 % [J/m2] Surface energy
        SD_D0   (1,1) double = 1       % [m^2/s] Prefactor
        SD_dG   (1,1) double = 431500  % [J/mol] Activation energy for diffusion hopping
        SD_geo  (1,1) double = 10      % [1] Geometric factor from mullins model  30 deg=10, 45 deg=37, 7 deg ~1
        SD_sc   (1,1) double = 1       % [m^-2] Surface concentration of defects
        
        CS1 (1,1) double % Critcial stress constant 1
        CS2 (1,1) double % Critical stress constant 2
        
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
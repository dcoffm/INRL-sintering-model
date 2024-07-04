classdef SinterFit < Simplex & ImportExport
    
    properties
        
        runs (1,:) SinterModel   % Individual sintering experiments
        labels (1,:) cell % strings for legend
        
        mat (1,1) SinterMaterial % Material properties
        contactCurve (1,1) double = 0.8 % An exponent defining the evolution of particle contact area vs total area with density
        cutoffDens (1,1) double = 0.85; % (Not yet implemented) ignore error contributions from density above this value
        
        fitMode (1,1) double = 1   % 0 = Grain size data (surface diffusivity/coarsening)
                                   % 1 = Density data (critical stress)
                                   
        densPlot (1,1) double = 0  % 0 = density vs time
                                   % 1 = density vs grain size
    end
    
    methods
        function this = SinterFit(mat)
            this = this@Simplex();
            this.mat = mat;
        end
        
        this = RunModel(this)
        err  = RunError(this)
        this = InitializePlot(this)
        this = RefreshPlot(this)
        
        function this = InitializeModel(this)
            % nothing
        end
        
    end
    
end
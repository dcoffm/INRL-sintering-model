function TotalError = RunError(this)

    TotalError = 0;
    for i = 1:numel(this.runs)
        switch this.fitMode
            case 0 % Grain size
                gs_model = interp1(this.runs(i).time,this.runs(i).grainsize,this.runs(i).time_obs);
                TotalError = TotalError + mean(abs(gs_model -this.runs(i).grainsize_obs ));
            case 1 % Density
                dens_model = interp1(this.runs(i).time,this.runs(i).rho,this.runs(i).time_obs);
                TotalError = TotalError + mean(abs(dens_model -this.runs(i).rho_obs ));
        end
    end
    
    % Add error for exceeding parameter bounds
    boundErr = 1e3;
    for i = 1:numel(this.papp)
        TotalError = TotalError * (1 + boundErr*(this.papp(i) > this.SeedStruct(i).BoundUpper));
        TotalError = TotalError * (1 + boundErr*(this.papp(i) < this.SeedStruct(i).BoundLower));
    end
    
end
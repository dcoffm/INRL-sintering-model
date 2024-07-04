function this = RefreshPlot(this)

    % Density vs Time
    for i =1:numel(this.runs)
        switch this.fitMode
            case 0 % Grain size
                this.PlotHandles.model(i).XData = this.runs(i).time;
                this.PlotHandles.model(i).YData = this.runs(i).grainsize*1e6;
            case 1 % Density
                switch this.densPlot
                    case 0 % Density vs Time
                        this.PlotHandles.model(i).XData = this.runs(i).time;
                        this.PlotHandles.model(i).YData = this.runs(i).rho;
                    case 1 % Density vs Temperature
                        this.PlotHandles.model(i).XData = this.runs(i).Temperature-273.15;
                        this.PlotHandles.model(i).YData = this.runs(i).rho;
                end
        end
    end

    str = sprintf('Iteration:  %i\n',this.iteration);
    
    strLabels = pad({this.SeedStruct.Label});
    for i = 1:numel(this.papp)
        lbl = strrep(strLabels{i},'_',' ');
        str = [str sprintf('%s %+7.4e\n',lbl,this.papp(i)) ];
    end
    this.PlotHandles.text.String = str;
    drawnow;
    if this.pauseTime > 0; pause(this.pauseTime); end
end
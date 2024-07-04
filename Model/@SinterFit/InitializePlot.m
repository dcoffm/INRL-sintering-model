function this = InitializePlot(this)
    
    this.PlotHandles.figure = figure;
    this.PlotHandles.axis    = gca; hold on
    
    colors = linspecer(numel(this.runs));
    for i =1:numel(this.runs)
        switch this.fitMode
            case 0 % Grain size
                this.PlotHandles.obsv(i)  = plot(this.runs(i).time_obs,this.runs(i).grainsize_obs*1e6,'ko','DisplayName',this.labels{i});
                this.PlotHandles.model(i) = plot(this.runs(i).time,this.runs(i).grainsize*1e6,'r');
                ylabel('Grain size (um)')
                xlabel('time (s)')
            case 1 % Density
                switch this.densPlot
                    case 0
                        this.PlotHandles.obsv(i)  = plot(this.runs(i).time_obs,this.runs(i).rho_obs,'ko','DisplayName',this.labels{i});
                        this.PlotHandles.model(i) = plot(this.runs(i).time,this.runs(i).rho,'r');
                        ylabel('Fractional Density')
                        xlabel('time (s)')
                    case 1
                        this.PlotHandles.obsv(i)  = plot(this.runs(i).T_obs,this.runs(i).rho_obs,'*','Color',colors(i,:),'DisplayName',this.labels{i});
                        ylabel('Fractional Density')
                        xlabel('Temperature (°C)')
                        this.PlotHandles.model(i) = plot(this.runs(i).Temperature-273.15,this.runs(i).rho,'r');
                end
        end
    end
    %legend(this.labels,'location','southeast');
    legend(this.PlotHandles.obsv,'location','southeast')
    
    axis on
    this.PlotHandles.text = text(this.PlotHandles.axis,0.05,0.95,'.','Units','normalized','VerticalAlignment','top','FontName','Monospaced');
    this.RefreshPlot();
end
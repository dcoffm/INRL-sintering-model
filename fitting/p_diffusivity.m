function Handles = p_diffusivity(output,out_test,Handles)
    if isempty(Handles)
        Handles.figure = figure; hold on
        Handles.observed = plot(output{1},output{2}*1e6,'k*');
        Handles.model    = plot(out_test{1},out_test{2}*1e6,'r--');
        xlabel('time (s)');
        ylabel('Grain size (\mum)');
        xlim([output{1}(1) output{1}(end)]);
        ylim([output{2}(1) output{2}(end)*1e6]);
        box on
        title('Grain size evolution')
        legend({'Observed','Fit'},'Location','Southeast')
        drawnow;
    else
        Handles.model.YData = out_test{2}*1e6;
        title(sprintf('Iteration: %i\n"Diffusivity": %0.3e (m^2/s)',Handles.iter,Handles.seed(1) ))
        drawnow;
    end
end
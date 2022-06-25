function Handles = p_density(output,out_test,Handles)
    if isempty(Handles)
        Handles.figure = figure; hold on
        Handles.observed = plot(output{1},output{2},'k*');
        Handles.model    = plot(out_test{1},out_test{2},'r');
        xlabel('time (s)');
        ylabel('Density');
        xlim([output{1}(1) output{1}(end)]);
        ylim([output{2}(1) 1]);
        box on
        legend({'Observed','Fit'},'Location','Northwest')
        drawnow;
    else
        Handles.model.YData = out_test{2};
        title(sprintf('Iteration: %i\nCritical stress: %0.3e (Pa)\nContact curve: %0.3f',Handles.iter,Handles.seed(1),Handles.seed(2) ))
        drawnow;
    end
end
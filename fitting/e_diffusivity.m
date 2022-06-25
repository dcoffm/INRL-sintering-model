
function total_error = e_diffusivity(observed,test)
    time_data = observed{1};
    time_model = test{1};
    
    GS_data = observed{2};
    GS_model = test{2};
    
    error = ( interp1(time_model,GS_model,time_data) - GS_data ).^2;
    
    total_error=( sum(error).^0.5 ) ./ (mean(GS_model)*(numel(GS_data)^0.5) );
end
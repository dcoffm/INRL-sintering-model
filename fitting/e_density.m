
function total_error = e_density(observed,test)
    time_data = observed{1};
    time_model = test{1};
    
    rho_data = observed{2};
    rho_model = test{2};
    
    error = ( interp1(time_model,rho_model,time_data) - rho_data ).^2;
    
    total_error=( sum(error).^0.5 ) ./ (mean(rho_model)*(numel(rho_data)^0.5) );
end
function [value,derivative] = contact_frac(rho,rho0,n)
    % This is a basic placeholder function to account for the change in free surface area with densification
    % Returns fraciton of particle boundary that is in contact (i.e. not a free surface) based on compact density (0 to 1).
    % The "infinitesimal contact" density (rho0) describes the intial compact in which particles have ~100% free surface
    
    value = real(((rho-rho0)/(1-rho0)).^(1/n));
    if value>1; value = 1; end
    if value<0; value = 0; end
    
    if rho==rho0
        rho = rho0+0.01; % Avoid a divide-by-zero for the derivative
    end
    derivative = value/n/(rho-rho0);
end
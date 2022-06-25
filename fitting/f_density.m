
function output = f_density(seed,input)
    
    input.system.mat.CS1 = seed(1);
    input.system.contact_curve = seed(2);
    
    if seed(1) < 0
        time = input.tt_profile(:,1);
        rho = zeros(size(time));
    else
        [time,rho,~] = sinter(input.system,input.tt_profile,input.dt,input.Nmax);
    end
    output = {time, rho};
end
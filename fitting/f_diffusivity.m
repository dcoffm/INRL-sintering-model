
function output = f_diffusivity(seed,input)
    
    input.system.mat.D0 = seed; % Parameter we are fitting

    % Run the sintering model with the dumb values
    % Note: If a reasonable dumb value for critical stress hasn't been provided,
    %       this may not run properly even though the critical stress isn't used for fitting D here.
    [time,~,grainsize] = sinter(input.system,input.tt_profile,input.dt,input.Nmax);
    output = {time, grainsize};
end
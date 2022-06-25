
This is a matlab implementation of a sintering model based on interface nucleation rate limited densification.

## Use
The main function implementing the sintering model is the sinter() function, which predicts the density evolution of a powder compact, given a temperature profile and a set of system information including material properties and powder properties.

The temperature profile is provided as an Nx2 matrix of time (s) and temperatue (°C) points, e.g. [0,24; 3000, 500; ...] indicates an initial temperature of 24°C, rising to 500°C after 3000 seconds and so on. The system information is provided as a struct with the fields described in the function and illustrated in the heating_rate.m and fit_example.m files. The user can choose between a fixed or dynamic time step integration.

In addition to prediction, the model can be used to fit experimental data to extract material properites, as demonstrated in the fitting subfolder. In this example a simplex algorithm iteratively runs the model using varying parameter values. First it fits experimental grain size data to extract a diffusion constant, and then it fits density data to extract a critical stress and contact behavior. 
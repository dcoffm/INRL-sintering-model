This is a matlab implementation of a sintering model based on interface dislocation nucleation rate limited densification, which is described in the following papers:

https://doi.org/10.1016/j.actamat.2022.118448

This code uses an object-oriented approach, with the following classes:
- SinterMaterial
  - Contains intrinsic material properties such as surface diffusivity and critical stress
- SinterModel
  - Contains information about a single sintering trjectory, such as material, temperature profile, and powder size/density
- SinterFit
  - Contains one or more instances of SinterModel and attempts to fit (using the inherited Simplex class) the resuling sintering trajectory against experimentally measured sintering behavior

## Typical Use
To model the result of a particular powder subjected to a particular heating schedule, we first load or define the material, construct the SinterModel object, and then call its Sinter() function.

To fit material parameters from experimental data, we construct a SinterFit object with the experimental measurements and temperature profiles, provide initial guesses for the material parameters, and then iterate the fitting algorithm.

The temperature profile is provided as an Nx2 matrix of time (s) and temperatue (°C) points, e.g. [0,24; 3000, 500; ...] indicates an initial temperature of 24°C, rising to 500°C at 3000 seconds, and so on.

Examples of the fitting process, as well as predictive use, are shown in the test folder.
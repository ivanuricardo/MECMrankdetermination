# MECMrankdetermination

This code base contains code for the paper "Detecting Cointegrating Relations in Non-stationary Matrix-Valued Time Series" by Alain Hecq, Ivan Ricardo, and Ines Wilms.
Here you will find replication code for the simulations and most of the tables and figures in the main paper.
This is all possible using the [Julia Language](https://julialang.org/) and [DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/) package.
In short, this Github repository is a Julia project that holds all dependencies required to run the scripts in the paper.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:

   ```
   julia> using Pkg
   julia> Pkg.add("DrWatson") # install globally, for using `quickactivate`
   julia> Pkg.activate("path/to/this/project")
   julia> Pkg.instantiate()
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box, including correctly finding local paths.

You may notice that most scripts start with the commands:

```julia
using DrWatson
@quickactivate "MECMrankdetermination"
```

which auto-activate the project and enable local path handling from DrWatson.

## Simulations

Simulations are stored in the `/simulations/` folder.
The main simulation results with no short run dynamics are in the `/fourbythreemat/` folder.
Simulation results with short run dynamics are in the `/fourbythreematsr/` folder.

## Empirical Application

The empirical results may be reproduced by running the `/scripts/globalmecm.jl` file.
Scripts to reproduce the plots can be found under the `/plots/` directory.
The `/data/` directory contains the data used in the empirical application, obtained from the [OECD website](https://data-explorer.oecd.org/).

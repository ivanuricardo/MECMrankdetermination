using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, CommonFeatures, LinearAlgebra, Statistics

matdata = load(datadir("globaldata.jld2"), "matdata");

maxiters = 100
ϵ = 1e-02
p = 0
etaS = 1e-05

icranks = selectmecm(matdata; p, maxiters, ϵ, etaS)
aic = icranks.aic[1:4]
aicp = icranks.aic[end]
bic = icranks.bic[1:4]
bicp = icranks.bic[end]
hqc = icranks.hqc[1:4]
hqcp = icranks.hqc[end]
@info "AIC selects ranks $aic with $aicp lags."
@info "BIC selects ranks $bic with $bicp lags."
@info "HQ selects ranks $hqc with $hqcp lags."

using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, CommonFeatures, LinearAlgebra, Statistics

matdata = load(datadir("globaldata.jld2"), "matdata");

maxiter = 20000
ϵ = 1e-03
p = 1
etaS = 9e-09

icranks = selectmecm(matdata; p, maxiter, ϵ, etaS)
aic = icranks.aic[1:4]
aicp = icranks.aic[end]
bic = icranks.bic[1:4]
bicp = icranks.bic[end]
hqc = icranks.hqc[1:4]
hqcp = icranks.hqc[end]
@info "AIC selects ranks $aic with $aicp lags."
@info "BIC selects ranks $bic with $bicp lags."
@info "HQ selects ranks $hqc with $hqcp lags."

using Plots, Zygote
ranks = [1, 1]

res = mecm(matdata, ranks; p, maxiter, etaS, ϵ)
filter(!isnan, res.llist)
plot(filter(!isnan, res.llist))
plot(res.llist)

Σ1 = res.Σ1
Σ2 = res.Σ2

kron(Σ2, Σ1)

U4 = res.U4
U3 = res.U3

obs = size(matdata, 3)
facmat = fill(NaN, ranks[1], ranks[2], obs)
for i in 1:obs
    facmat[:, :, i] .= U3' * matdata[:, :, i] * U4
end
plot(tenmat(facmat, row=[1, 2])')
plot(facmat[1, :, :]')
plot(facmat[1, 2, :])

plot(tenmat(matdata, row=[1, 2])')
plot(matdata[3, :, :]')

using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, CommonFeatures, LinearAlgebra, Statistics

matdata = load(datadir("globaldata.jld2"), "matdata");

maxiter = 25
ϵ = 1e-02
p = 1
etaS = 3e-08

icranks = selectmecm(matdata; p, maxiter, ϵ, etaS)
aic = icranks.aicsel
bic = icranks.bicsel
hqc = icranks.hqcsel
@info "AIC selects ranks $aic"
@info "BIC selects ranks $bic"
@info "HQC selects ranks $hqc"

using Plots, Zygote
ranks = [1, 1]

res = mecm(matdata, ranks; p, maxiter=300000, etaS=3e-08, ϵ=1e-05)
filter(!isnan, res.llist)
plot(filter(!isnan, res.llist))

Σ1 = res.Σ1
Σ2 = res.Σ2

kron(Σ2, Σ1)

U1 = res.U1
U2 = res.U2
kron(U2, U1)

U4 = res.U4
U3 = res.U3

obs = size(matdata, 3)
facmat = fill(NaN, ranks[1], ranks[2], obs)
for i in 1:obs
    facmat[:, :, i] .= U3' * matdata[:, :, i] * U4
end
plot(tenmat(facmat, row=[1, 2])')


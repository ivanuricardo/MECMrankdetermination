using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, CommonFeatures, LinearAlgebra, Statistics, Latexify

matdata = load(datadir("globaldata.jld2"), "matdata");

maxiter = 200
ϵ = 1e-02
p = 1
etaS = 1e-09

icranks = selectmecm(matdata; p, maxiter, ϵ, etaS)
aic = icranks.aicsel
bic = icranks.bicsel
hqc = icranks.hqcsel
@info "AIC selects ranks $aic"
@info "BIC selects ranks $bic"
@info "HQC selects ranks $hqc"

using Plots, Zygote
ranks = [1, 1]

res = mecm(matdata, ranks; p, maxiter=300000, etaS=1e-09, ϵ=1e-04)
filter(!isnan, res.llist)
plot(filter(!isnan, res.llist))

D = latexify(round.(res.D, digits=3))

Σ1 = latexify(round.(res.Σ1, digits=3))
Σ2 = latexify(round.(res.Σ2, digits=3))

ϕ1 = latexify(round.(res.ϕ1, digits=3))
ϕ2 = latexify(round.(res.ϕ2, digits=3))

kron(res.Σ2, res.Σ1)
kron(res.ϕ2, res.ϕ1)

U1 = res.U1
U2 = res.U2
kron(U2, U1)

U3 = res.U3
U4 = res.U4
kron(U4, U3)

obs = size(matdata, 3)
facmat = fill(NaN, ranks[1], ranks[2], obs)
for i in 1:obs
    facmat[:, :, i] .= U3' * matdata[:, :, i] * U4
end
plot(tenmat(facmat, row=[1, 2])')
plot(facmat[3, 1, :])

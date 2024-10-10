using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, Statistics, Random, LinearAlgebra, CommonFeatures, ProgressBars
using Plots, DelimitedFiles, Latexify

Random.seed!(20241001)

sims = 1000
n = [4, 3]
ranks = [1, 1]

maxiter = 100
ϵ = 1e-01
p = 1
burnin = 100
matrixnorm = true

firstsmallic = fill(NaN, 3, sims)
firstmedic = fill(NaN, 3, sims)
secondsmallic = fill(NaN, 3, sims)
secondmedic = fill(NaN, 3, sims)

trueU1 = fill(NaN, n[1], ranks[1])
trueU2 = fill(NaN, n[2], ranks[2])
trueU3 = fill(NaN, n[1], ranks[1])
trueU4 = fill(NaN, n[2], ranks[2])
trueϕ1 = zeros(n[1], n[1])
trueϕ2 = zeros(n[2], n[2])

for i in 1:1000

    U1, U2, U3, U4, ϕ1, ϕ2 = generatemecmparams(n, ranks, genphi=true)

    # Check I(1)
    i1cond = mecmstable(U1, U2, U3, U4, ϕ1, ϕ2)
    if maximum(i1cond) < 0.9
        trueU1 .= U1
        trueU2 .= U2
        trueU3 .= U3
        trueU4 .= U4
        trueϕ1 .= ϕ1
        trueϕ2 .= ϕ2
        println("I(1) condition satisfied")
        break
    end
end
mecmstable(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2)

obs = 500
genmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, obs)
plot(genmecm.flatdata')

estranks = [1, 1]
results = mecm(genmecm.data, estranks; p=1, maxiter=1000, etaS=1e-06, ϵ=1e-02)
results.llist[1:findlast(!isnan, results.llist)]
startidx = 1
plot(results.llist[startidx:findlast(!isnan, results.llist)])
plot(results.fullgrads)

genmecm.Σ1
results.Σ1
norm(results.Σ1)
genmecm.Σ2
results.Σ2

kron(genmecm.Σ2, genmecm.Σ1)
kron(results.Σ2, results.Σ1)

results.U3
trueU3 / trueU3[1]

fac1 = fill(NaN, estranks[1], estranks[2], obs)
for i in 1:obs
    fac1[:, :, i] .= results.U3' * genmecm.data[:, :, i] * results.U4
end
plot(tenmat(fac1, row=[1, 2])')
plot(fac1[1, 2, :])


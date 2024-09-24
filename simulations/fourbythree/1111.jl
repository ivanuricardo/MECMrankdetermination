using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, Statistics, Random, LinearAlgebra, CommonFeatures, ProgressBars
using Plots

Random.seed!(20240925)

sims = 1000
n = [4, 3]
ranks = [1, 1]

maxiters = 50
ϵ = 1e-02
p = 0

smallaic = fill(NaN, 4, sims)
smallbic = fill(NaN, 4, sims)
smallhqc = fill(NaN, 4, sims)
medaic = fill(NaN, 4, sims)
medbic = fill(NaN, 4, sims)
medhqc = fill(NaN, 4, sims)

trueU1 = fill(NaN, n[1], ranks[1])
trueU2 = fill(NaN, n[2], ranks[2])
trueU3 = fill(NaN, n[1], ranks[1])
trueU4 = fill(NaN, n[2], ranks[2])
trueϕ1 = zeros(n[1], n[1])
trueϕ2 = zeros(n[2], n[2])
ct = 0

for i in 1:1000
    ct += 1

    U1, U2, U3, U4, ϕ1, ϕ2 = generatemecmparams(n, ranks, genphi=false)

    # Check I(1)
    i1cond = mecmstable(U1, U2, U3, U4, ϕ1, ϕ2)
    if maximum(i1cond) < 0.9
        trueU1 = U1
        trueU2 = U2
        trueU3 = U3
        trueU4 = U4
        println("I(1) condition satisfied")
        break
    end
end
mecmstable(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2)

smallobs = 100
medobs = 500
burnin = 100

smallmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, smallobs; burnin=burnin)
smalldata = smallmecm.mardata
smallloglike = smallmecm.ll

medmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, medobs; burnin=burnin)
meddata = medmecm.mardata
medloglike = medmecm.ll

aicsmall, bicsmall, hqcsmall = selectmecm(smalldata; p, maxiters, ϵ)
aicmed, bicmed, hqcmed = selectmecm(meddata; p, maxiters, ϵ)



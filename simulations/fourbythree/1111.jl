using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, Statistics, Random, LinearAlgebra, CommonFeatures, ProgressBars
using Plots

Random.seed!(20240925)

sims = 50
n = [4, 3]
ranks = [2, 2]

maxiters = 50
ϵ = 1e-02
p = 0

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

# smallobs = 100
medobs = 500
burnin = 100

for s in ProgressBar(1:sims)
    # smallmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, smallobs; burnin=burnin)
    # smalldata = smallmecm.mardata
    # smallloglike = smallmecm.ll

    # aicsmall, bicsmall, hqcsmall = selectmecm(smalldata; p, maxiters, ϵ)
    # firstsmallic[1, s] = aicsmall[1]
    # firstsmallic[2, s] = bicsmall[1]
    # firstsmallic[3, s] = hqcsmall[1]
    #
    # secondsmallic[1, s] = aicsmall[2]
    # secondsmallic[2, s] = bicsmall[2]
    # secondsmallic[3, s] = hqcsmall[2]

    medmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, medobs; snr=0.7)
    # df = randn(size(medmecm.data))

    aicmed, bicmed, hqcmed, ictable = selectmecm(medmecm.data; p=p, maxiters=300, ϵ=ϵ)
    firstmedic[1, s] = aicmed[1]
    firstmedic[2, s] = bicmed[1]
    firstmedic[3, s] = hqcmed[1]

    secondmedic[1, s] = aicmed[2]
    secondmedic[2, s] = bicmed[2]
    secondmedic[3, s] = hqcmed[2]
end

# xx = tenmat(medmecm.data, row=[1, 2]) * tenmat(medmecm.data, row=[1, 2])'
# plot(reverse(abs.(eigvals(xx ./ medobs))))

mean(firstmedic, dims=2)
mean(secondmedic, dims=2)

obs = 500
genmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, obs; burnin=burnin)
results = mecm(genmecm.data, [1, 1]; p=0, maxiter=500, etaS=1e-05, ϵ=1e-02)
results.llist[1:findlast(!isnan, results.llist)]
startidx = 1
plot(results.llist[startidx:findlast(!isnan, results.llist)])
plot(results.fullgrads)

results.U1 / results.U1[1]
trueU1 / trueU1

svdvals(results.U1)
svdvals(results.U2)
svdvals(results.U3)
svdvals(results.U4)

fac1 = fill(NaN, 1, 3, obs)
for i in 1:obs
    fac1[:, :, i] .= results.U3' * genmecm.data[:, :, i]
end
plot(tenmat(fac1, row=[1, 2])')





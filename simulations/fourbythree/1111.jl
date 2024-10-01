using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, Statistics, Random, LinearAlgebra, CommonFeatures, ProgressBars
using Plots

Random.seed!(20240928)

sims = 10
n = [4, 3]
ranks = [1, 1]

maxiters = 100
ϵ = 1e-02
p = 0
burnin = 100

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
    if 0.7 < maximum(i1cond) < 0.9
        trueU1 = U1
        trueU2 = U2
        trueU3 = U3
        trueU4 = U4
        println("I(1) condition satisfied")
        break
    end
end
mecmstable(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2)

# obs = 500
# genmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, obs; burnin=burnin)
# estranks = [1, 3]
# results = mecm(genmecm.data, estranks; p=0, maxiter=100, etaS=1e-03, ϵ=1e-02)
# results.llist[1:findlast(!isnan, results.llist)]
# startidx = 1
# plot(results.llist[startidx:findlast(!isnan, results.llist)])
# plot(results.fullgrads)
#
# results.U3 / results.U3[1]
# trueU3 / trueU3[1]
#
# fac1 = fill(NaN, estranks[1], estranks[2], obs)
# for i in 1:obs
#     fac1[:, :, i] .= results.U3' * genmecm.data[:, :, i] * results.U4
# end
# plot(tenmat(fac1, row=[1, 2])')
# plot(genmecm.flatdata')

################################################################################

smallobs = 100
medobs = 500
smallaic = fill(NaN, 2, sims)
smallbic = fill(NaN, 2, sims)
smallhqc = fill(NaN, 2, sims)
medaic = fill(NaN, 2, sims)
medbic = fill(NaN, 2, sims)
medhqc = fill(NaN, 2, sims)

for s in ProgressBar(1:sims)
    smallmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, smallobs; burnin=burnin)
    aicsmall, bicsmall, hqcsmall = selectmecm(smallmecm.data; p, maxiters, ϵ)
    # firstsmallic[1, s] = aicsmall[1]
    # firstsmallic[2, s] = bicsmall[1]
    # firstsmallic[3, s] = hqcsmall[1]
    #
    # secondsmallic[1, s] = aicsmall[2]
    # secondsmallic[2, s] = bicsmall[2]
    # secondsmallic[3, s] = hqcsmall[2]

    medmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, medobs; snr=0.7)
    aicmed, bicmed, hqcmed = selectmecm(medmecm.data; p, maxiters, ϵ=ϵ)

    smallaic[:, s] = aicsmall
    smallbic[:, s] = bicsmall
    smallhqc[:, s] = hqcsmall

    medaic[:, s] = aicmed
    medbic[:, s] = bicmed
    medhqc[:, s] = hqcmed

    # firstmedic[1, s] = aicmed[1]
    # firstmedic[2, s] = bicmed[1]
    # firstmedic[3, s] = hqcmed[1]
    #
    # secondmedic[1, s] = aicmed[2]
    # secondmedic[2, s] = bicmed[2]
    # secondmedic[3, s] = hqcmed[2]
end

smallaicstats = simstats(smallaic, ranks, sims)
smallbicstats = simstats(smallbic, ranks, sims)

medaicstats = simstats(medaic, ranks, sims)
medbicstats = simstats(medbic, ranks, sims)

avgrank = hcat(smallaicstats.avgrank, smallbicstats.avgrank,
    medaicstats.avgrank, medbicstats.avgrank)

stdrank = hcat(smallaicstats.stdrank, smallbicstats.stdrank,
    medaicstats.stdrank, medbicstats.stdrank)

lowerrank = hcat(smallaicstats.freqlow, smallbicstats.freqlow,
    medaicstats.freqlow, medbicstats.freqlow)

correctrank = hcat(smallaicstats.freqcorrect, smallbicstats.freqcorrect,
    medaicstats.freqcorrect, medbicstats.freqcorrect)

highrank = hcat(smallaicstats.freqhigh, smallbicstats.freqhigh,
    medaicstats.freqhigh, medbicstats.freqhigh)

results = vcat(avgrank, stdrank, lowerrank, correctrank, highrank)







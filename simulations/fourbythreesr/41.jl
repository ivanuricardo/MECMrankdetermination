using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, Statistics, Random, LinearAlgebra, CommonFeatures, ProgressBars
using Plots, DelimitedFiles, Latexify

Random.seed!(20241029)

sims = 1000
n = [4, 3]
ranks = [4, 1]

maxiter = 500
ϵ = 1e-02
p = 1
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

for i in 1:1e08

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

smallobs = 100
medobs = 250
smallaic = fill(NaN, 2, sims)
smallbic = fill(NaN, 2, sims)
smallhqc = fill(NaN, 2, sims)
medaic = fill(NaN, 2, sims)
medbic = fill(NaN, 2, sims)
medhqc = fill(NaN, 2, sims)

for s in ProgressBar(1:sims)
    mecmdata = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, medobs)
    smalldata = mecmdata.data[:, :, 1:smallobs]
    aicsmall, bicsmall, hqcsmall = selectmecm(smalldata; p, maxiter, ϵ)
    smallaic[:, s] = aicsmall
    smallbic[:, s] = bicsmall
    smallhqc[:, s] = hqcsmall

    aicmed, bicmed, hqcmed = selectmecm(mecmdata.data; p, maxiter, ϵ)
    medaic[:, s] = aicmed
    medbic[:, s] = bicmed
    medhqc[:, s] = hqcmed
end

smallaicstats = simstats(smallaic, ranks, sims)
smallbicstats = simstats(smallbic, ranks, sims)
smallhqcstats = simstats(smallhqc, ranks, sims)

medaicstats = simstats(medaic, ranks, sims)
medbicstats = simstats(medbic, ranks, sims)
medhqcstats = simstats(smallhqc, ranks, sims)

avgrank = hcat(smallaicstats.avgrank, smallbicstats.avgrank, smallhqcstats.avgrank,
    medaicstats.avgrank, medbicstats.avgrank, medhqcstats.avgrank)

stdrank = hcat(smallaicstats.stdrank, smallbicstats.stdrank, smallhqcstats.stdrank,
    medaicstats.stdrank, medbicstats.stdrank, medhqcstats.stdrank)

lowerrank = hcat(smallaicstats.freqlow, smallbicstats.freqlow, smallhqcstats.freqlow,
    medaicstats.freqlow, medbicstats.freqlow, medhqcstats.freqlow)

correctrank = hcat(smallaicstats.freqcorrect, smallbicstats.freqcorrect,
    smallhqcstats.freqcorrect, medaicstats.freqcorrect,
    medbicstats.freqcorrect, medhqcstats.freqcorrect)

highrank = hcat(smallaicstats.freqhigh, smallbicstats.freqhigh,
    smallhqcstats.freqhigh, medaicstats.freqhigh, medbicstats.freqhigh,
    medhqcstats.freqhigh)

results = vcat(avgrank, stdrank, lowerrank, correctrank, highrank)

latexmatrix = latexify(round.(results', digits=2))
filepath = "final.txt"
# Write the matrix to a file with a custom delimiter
open(filepath, "w") do file
    write(file, latexmatrix)
end

statmat = results'


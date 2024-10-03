using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, Statistics, Random, LinearAlgebra, CommonFeatures, ProgressBars
using Plots, DelimitedFiles, Latexify

Random.seed!(20241001)

sims = 10
n = [4, 3]
ranks = [1, 1]

maxiters = 100
ϵ = 1e-01
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

# obs = 500
# genmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, obs)
# plot(genmecm.flatdata')

# estranks = [1, 1]
# results = mecm(genmecm.data, estranks; p=0, maxiter=100, etaS=1e-04, ϵ=1e-02)
# results.llist[1:findlast(!isnan, results.llist)]
# startidx = 1
# plot(results.llist[startidx:findlast(!isnan, results.llist)])
# plot(results.fullgrads)
#
# results.U3 / results.U3[1:2, 1:2]
# trueU3 / trueU3[1]
#
# fac1 = fill(NaN, estranks[1], estranks[2], obs)
# for i in 1:obs
#     fac1[:, :, i] .= results.U3' * genmecm.data[:, :, i] * results.U4
# end
# plot(tenmat(fac1[], row=[1, 2])')
# plot(fac1[1, 2, :])

################################################################################

smallobs = 100
medobs = 500
smallaic = fill(NaN, 2, sims)
smallbic = fill(NaN, 2, sims)
smallhqc = fill(NaN, 2, sims)
medaic = fill(NaN, 2, sims)
medbic = fill(NaN, 2, sims)
medhqc = fill(NaN, 2, sims)
folder = "savedsims"

for s in ProgressBar(1:sims)
    smallmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, smallobs)
    aicsmall, bicsmall, hqcsmall = selectmecm(smallmecm.data; p, maxiters, ϵ)
    smallaic[:, s] = aicsmall
    smallbic[:, s] = bicsmall
    smallhqc[:, s] = hqcsmall

    medmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, medobs)
    aicmed, bicmed, hqcmed = selectmecm(medmecm.data; p, maxiters, ϵ)
    medaic[:, s] = aicmed
    medbic[:, s] = bicmed
    medhqc[:, s] = hqcmed

    smallaicpath = joinpath(pwd(), folder, "smallaic$s.csv")
    smallbicpath = joinpath(pwd(), folder, "smallbic$s.csv")
    medaicpath = joinpath(pwd(), folder, "medaic$s.csv")
    medbicpath = joinpath(pwd(), folder, "medbic$s.csv")
    if !isdir(folder)
        mkdir(folder)
    end
    writedlm(smallaicpath, smallaic, ',')
    writedlm(smallbicpath, smallbic, ',')
    writedlm(medaicpath, medaic, ',')
    writedlm(medbicpath, medbic, ',')
    GC.gc()
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

latexmatrix = latexify(round.(results', digits=2))
filepath = "final.txt"
# Write the matrix to a file with a custom delimiter
open(filepath, "w") do file
    write(file, latexmatrix)
end

statmat = results'

println("Average rank for small size (AIC): ", statmat[1, 1:2])
println("Average rank for small size (BIC): ", statmat[2, 1:2])

println("Average rank for medium size (AIC): ", statmat[3, 1:2])
println("Average rank for medium size (BIC): ", statmat[4, 1:2])

println("Std. Dev rank for small size (AIC): ", statmat[1, 3:4])
println("Std. Dev rank for small size (BIC): ", statmat[2, 3:4])

println("Std. Dev rank for medium size (AIC): ", statmat[3, 3:4])
println("Std. Dev rank for medium size (BIC): ", statmat[4, 3:4])

println("Freq. Correct for small size (AIC): ", statmat[1, 7:8])
println("Freq. Correct for small size (BIC): ", statmat[2, 7:8])

println("Freq. Correct for medium size (AIC): ", statmat[3, 7:8])
println("Freq. Correct for medium size (BIC): ", statmat[4, 7:8])


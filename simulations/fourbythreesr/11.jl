using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, Statistics, Random, LinearAlgebra, CommonFeatures, ProgressBars
using Plots, DelimitedFiles, Latexify, Zygote, Distributions

Random.seed!(20241001)

sims = 1000
n = [4, 3]
ranks = [1, 1]

maxiter = 100
ϵ = 1e-02
etaS = 1e-08
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

ranks = [1, 1]
mardata = genmecm.data

################################################################################

# U1, U2, U3, U4, D, ϕ1, ϕ2 = mecminit(mardata, ranks; p)
# N1, N2, obs = size(mardata)
#
# trackU1 = fill(NaN, maxiter)
# trackU2 = fill(NaN, maxiter)
# trackU3 = fill(NaN, maxiter)
# trackU4 = fill(NaN, maxiter)
# trackD = fill(NaN, maxiter)
# trackϕ1 = fill(NaN, maxiter)
# trackϕ2 = fill(NaN, maxiter)
# llist = fill(NaN, maxiter)
# Σ1 = rand(Wishart(N1, diagm(ones(N1))))
# Σ2 = rand(Wishart(N2, diagm(ones(N2))))
# oldobj = matobj(mardata, D, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2)
#
# iters = 0
#
# for k in 1:10
#     newΣ1 = rand(Wishart(N1, (0.1 * k) .* diagm(ones(N1))))
#     newΣ2 = rand(Wishart(N2, (0.1 * k) .* diagm(ones(N2))))
#     for _ in 1:10
#
#         ∇D = mecmsumres(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#         etaD = 1 / spectralradius((obs) * kron(inv(newΣ2), inv(newΣ1)))
#         D += etaD * ∇D
#
#         ∇U1 = U1grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#         hU1 = U1hessian(mardata, U2, U3, U4, Σ1, newΣ2)
#         etaU1 = 1 / spectralradius(hU1)
#         U1 += etaU1 * ∇U1
#
#         ∇U3 = U3grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#         hU3 = U3hessian(mardata, U1, U2, U4, newΣ1, newΣ2)
#         etaU3 = 1 / spectralradius(hU3)
#         U3 += etaU3 * ∇U3
#         U3 /= U3[1:ranks[1], 1:ranks[1]]
#
#         ∇newΣ1 = Σ1grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#         newΣ1unscaled = newΣ1 + etaS * ∇newΣ1
#         newΣ1 = newΣ1unscaled ./ norm(newΣ1unscaled)
#         # preΣ1 = Σ1 + etaS * ∇Σ1
#         # eΣ1 = eigen(preΣ1)
#         # Σ1 = eΣ1.vectors * diagm(max.(eΣ1.values, 0)) * eΣ1.vectors' + 1e-06I
#
#         ∇U2 = U2grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#         hU2 = U2hessian(mardata, U1, U3, U4, newΣ1, newΣ2)
#         etaU2 = 1 / spectralradius(hU2)
#         U2 += etaU2 * ∇U2
#
#         ∇U4 = U4grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#         hU4 = U4hessian(mardata, U1, U2, U3, newΣ1, newΣ2)
#         etaU4 = 1 / spectralradius(hU4)
#         U4 += etaU4 * ∇U4
#         U4 /= U4[1:ranks[2], 1:ranks[2]]
#
#         ∇newΣ2 = Σ2grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#         newΣ2 += etaS * ∇newΣ2
#         # preΣ2 = Σ2 + etaS * ∇Σ2
#         # eΣ2 = eigen(preΣ2)
#         # Σ2 = eΣ2.vectors * diagm(max.(eΣ2.values, 0)) * eΣ2.vectors' + 1e-06I
#
#         if p != 0
#             ∇ϕ1 = ϕ1grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#             hϕ1 = ϕ1hessian(mardata, ϕ2, newΣ1, newΣ2)
#             etaϕ1 = 1 / spectralradius(hϕ1)
#             ϕ1unscaled = ϕ1 + etaϕ1 * ∇ϕ1
#             ϕ1 = ϕ1unscaled ./ norm(ϕ1unscaled)
#
#             ∇ϕ2 = ϕ2grad(mardata, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2, D)
#             hϕ2 = ϕ2hessian(mardata, ϕ1, newΣ1, newΣ2)
#             etaϕ2 = 1 / spectralradius(hϕ2)
#             ϕ2 += etaϕ2 * ∇ϕ2
#         end
#     end
#     newobj = matobj(mardata, D, U1, U2, U3, U4, newΣ1, newΣ2, ϕ1, ϕ2)
#     if newobj > oldobj
#         Σ1 .= newΣ1
#         Σ2 .= newΣ2
#         oldobj = matobj(mardata, D, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2)
#     end
# end
#
# for s in 1:maxiter
#     iters += 1
#
#     ∇D = mecmsumres(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#     etaD = 1 / spectralradius((obs) * kron(inv(Σ2), inv(Σ1)))
#     D += etaD * ∇D
#     trackD[s] = etaD
#
#     ∇U1 = U1grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#     hU1 = U1hessian(mardata, U2, U3, U4, Σ1, Σ2)
#     etaU1 = 1 / spectralradius(hU1)
#     U1 += etaU1 * ∇U1
#     trackU1[s] = etaU1
#
#     ∇U3 = U3grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#     hU3 = U3hessian(mardata, U1, U2, U4, Σ1, Σ2)
#     etaU3 = 1 / spectralradius(hU3)
#     U3 += etaU3 * ∇U3
#     U3 /= U3[1:ranks[1], 1:ranks[1]]
#     trackU3[s] = etaU3
#
#     ∇Σ1 = Σ1grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#     Σ1unscaled = Σ1 + etaS * ∇Σ1
#     Σ1 = Σ1unscaled ./ norm(Σ1unscaled)
#     # preΣ1 = Σ1 + etaS * ∇Σ1
#     # eΣ1 = eigen(preΣ1)
#     # Σ1 = eΣ1.vectors * diagm(max.(eΣ1.values, 0)) * eΣ1.vectors' + 1e-06I
#
#     ∇U2 = U2grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#     hU2 = U2hessian(mardata, U1, U3, U4, Σ1, Σ2)
#     etaU2 = 1 / spectralradius(hU2)
#     U2 += etaU2 * ∇U2
#     trackU2[s] = etaU2
#
#     ∇U4 = U4grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#     hU4 = U4hessian(mardata, U1, U2, U3, Σ1, Σ2)
#     etaU4 = 1 / spectralradius(hU4)
#     U4 += etaU4 * ∇U4
#     U4 /= U4[1:ranks[2], 1:ranks[2]]
#     trackU4[s] = etaU4
#
#     ∇Σ2 = Σ2grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#     Σ2 += etaS * ∇Σ2
#     # preΣ2 = Σ2 + etaS * ∇Σ2
#     # eΣ2 = eigen(preΣ2)
#     # Σ2 = eΣ2.vectors * diagm(max.(eΣ2.values, 0)) * eΣ2.vectors' + 1e-06I
#
#     if p != 0
#         ∇ϕ1 = ϕ1grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#         hϕ1 = ϕ1hessian(mardata, ϕ2, Σ1, Σ2)
#         etaϕ1 = 1 / spectralradius(hϕ1)
#         ϕ1unscaled = ϕ1 + etaϕ1 * ∇ϕ1
#         ϕ1 = ϕ1unscaled ./ norm(ϕ1unscaled)
#         trackϕ1[s] = norm(∇ϕ1)
#
#         ∇ϕ2 = ϕ2grad(mardata, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2, D)
#         hϕ2 = ϕ2hessian(mardata, ϕ1, Σ1, Σ2)
#         etaϕ2 = 1 / spectralradius(hϕ2)
#         ϕ2 += etaϕ2 * ∇ϕ2
#         trackϕ2[s] = norm(∇ϕ2)
#     end
#     llist[s] = matobj(mardata, D, U1, U2, U3, U4, Σ1, Σ2, ϕ1, ϕ2)
#
#     if s > 1
#         ∇diff = abs(llist[s] - llist[s-1])
#         converged = (s == maxiter)
#
#         if (∇diff < ϵ) || converged
#             fullgrads = hcat(trackU1, trackU2, trackU3, trackU4, trackD)
#             converged = (!converged)
#             return (; U1, U2, U3, U4, D, Σ1, Σ2, ϕ1, ϕ2, iters, fullgrads, converged, llist)
#         end
#     end
# end

################################################################################

results = mecm(genmecm.data, ranks; p=1, maxiter=1000, etaS=1e-08, ϵ=1e-02)
results.llist[1:findlast(!isnan, results.llist)]
startidx = 1
plot(results.llist[startidx:findlast(!isnan, results.llist)])
plot(results.fullgrads)

results.Σ1
genmecm.Σ1
results.Σ2
genmecm.Σ2

kron(results.Σ2, results.Σ1)
kron(genmecm.Σ2, genmecm.Σ1)

results.U3 / results.U3[1]
trueU3 / trueU3[1]

fac1 = fill(NaN, ranks[1], ranks[2], obs)
for i in 1:obs
    fac1[:, :, i] .= results.U3' * genmecm.data[:, :, i] * results.U4
end
plot(tenmat(fac1, row=[1, 2])')
plot(fac1[1, 2, :])

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

Threads.@threads for s in ProgressBar(1:sims)
    smallmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, smallobs; matrixnorm)
    aicsmall, bicsmall, hqcsmall = selectmecm(smallmecm.data; p, maxiter, ϵ)
    smallaic[:, s] = aicsmall
    smallbic[:, s] = bicsmall
    smallhqc[:, s] = hqcsmall

    medmecm = generatemecmdata(trueU1, trueU2, trueU3, trueU4, trueϕ1, trueϕ2, medobs; matrixnorm)
    aicmed, bicmed, hqcmed = selectmecm(medmecm.data; p, maxiter, ϵ)
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

println("Average rank for small size (AIC): ", statmat[1, 1:2])
println("Average rank for small size (BIC): ", statmat[2, 1:2])
println("Average rank for small size (HQC): ", statmat[3, 1:2])

println("Average rank for medium size (AIC): ", statmat[4, 1:2])
println("Average rank for medium size (BIC): ", statmat[5, 1:2])
println("Average rank for medium size (HQC): ", statmat[6, 1:2])

println("Std. Dev rank for small size (AIC): ", statmat[1, 3:4])
println("Std. Dev rank for small size (BIC): ", statmat[2, 3:4])
println("Std. Dev rank for small size (HQC): ", statmat[3, 3:4])

println("Std. Dev rank for medium size (AIC): ", statmat[4, 3:4])
println("Std. Dev rank for medium size (BIC): ", statmat[5, 3:4])
println("Std. Dev rank for medium size (HQC): ", statmat[6, 3:4])

println("Freq. Correct for small size (AIC): ", statmat[1, 7:8])
println("Freq. Correct for small size (BIC): ", statmat[2, 7:8])
println("Freq. Correct for small size (HQC): ", statmat[3, 7:8])

println("Freq. Correct for medium size (AIC): ", statmat[4, 7:8])
println("Freq. Correct for medium size (BIC): ", statmat[5, 7:8])
println("Freq. Correct for medium size (HQC): ", statmat[6, 7:8])


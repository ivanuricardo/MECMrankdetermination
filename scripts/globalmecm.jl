using DrWatson
@quickactivate "MECMrankdetermination"
using CommonFeatures, Latexify

matdata = load(datadir("globaldata.jld2"), "matdata");

maxiter = 500
ϵ = 1e-02
p = 1
etaS = 1e-10

icranks = selectmecm(matdata; p, maxiter, ϵ, etaS)
aic = icranks.aicsel
bic = icranks.bicsel
@info "AIC selects ranks $aic"
@info "BIC selects ranks $bic"

ranks = [1, 1]
res = mecm(matdata, ranks; p, maxiter=300000, etaS=1e-08, ϵ=1e-04)

D = latexify(round.(res.D, digits=3))
Σ1 = latexify(round.(res.Σ1, digits=3))
Σ2 = latexify(round.(res.Σ2, digits=3))
ϕ1 = latexify(round.(res.ϕ1, digits=3))
ϕ2 = latexify(round.(res.ϕ2, digits=3))
U1 = latexify(round.(res.U1, digits=3))
U2 = latexify(round.(res.U2, digits=3))
U3 = latexify(round.(res.U3, digits=3))
U4 = latexify(round.(res.U4, digits=3))

println("Estimated D: \n$D")
println("\nEstimated Σ1: \n$Σ1")
println("\nEstimated Σ2: \n$Σ2")
println("\nEstimated ϕ1: \n$ϕ1")
println("\nEstimated ϕ2: \n$ϕ2")

println("\nEstimated U1: \n", round.(res.U1, digits=3))
println("\nEstimated U2: \n", round.(res.U2, digits=3))
println("\nEstimated U3: \n", round.(res.U3, digits=3))
println("\nEstimated U4: \n", round.(res.U4, digits=3))

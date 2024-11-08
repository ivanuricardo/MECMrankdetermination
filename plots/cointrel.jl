using DrWatson
@quickactivate "MECMrankdetermination"
using TensorToolbox, CommonFeatures, LinearAlgebra, Statistics, Makie, Dates
using CairoMakie

matdata = load(datadir("globaldata.jld2"), "matdata");
ranks = [1, 1]
res = mecm(matdata, ranks; p=1, maxiter=300000, etaS=1e-08, ϵ=1e-04)
plot(filter(!isnan, res.llist))

U4 = res.U4
U3 = res.U3

obs = size(matdata, 3)
facmat = fill(NaN, ranks[1], ranks[2], obs)
for i in 1:obs
    facmat[:, :, i] .= U3' * matdata[:, :, i] * U4
end

cointrelation = facmat[1, 1, :]

# Generate time axis from 1991 Q1 to 2019 Q4
start_year = 1991
end_year = 2019
quarters = 4 * (end_year - start_year + 1)
dates = [DateTime(start_year, 1, 1) + Month(3 * (i - 1)) for i in 1:quarters]

# Plot using Makie
fig = Figure(size=(900, 400));
# ax = Axis(fig[1, 1], title="Cointegrating Relation", xlabel="Date", ylabel="Value", ylabelvisible=false, xlabelvisible=false)
ax = Axis(fig[1, 1], title="Cointegrating Relation", xlabel="Date", ylabel="Value", titlesize=24, labelsize=18)

# Plot the cointegrating relation
lines!(ax, dates[1:obs], vec(cointrelation))

# Format x-axis to show years with quarters
xticks = [DateTime(y, 1, 1) for y in start_year:2:end_year]
ax.xticks = (xticks, string.(year.(xticks)))
# fig[2, :] = Legend(fig, ax; orientation=:horizontal, halign=:center, valign=:bottom, framevisible=false, labelsize=20)

# Display the plot
fig

using DrWatson
@quickactivate

using TensorToolbox, CommonFeatures, LinearAlgebra, Statistics, Makie, Dates
using CairoMakie

matdata = load(datadir("globaldata.jld2"), "matdata");

startdate = Date(1991, 1, 1)
enddate = Date(2019, 12, 31)

quarterlydates = collect(startdate:Dates.Quarter(1):enddate)
datetimes = DateTime.(string.(quarterlydates), "yyyy-mm-dd")
xticks = Dates.datetime2unix.(datetimes)
labels = Dates.format.(datetimes, "Y")
adjlabels = map(x -> x[3:end], labels)  # Takes only last 2 characters of year
adjlabels .= string.("'", adjlabels)
nolabels = fill("", length(adjlabels))

titlesize = 25
xlabsize = 13
xticksize = 13
ylabsize = 13
yticksize = 13
fontsize = 14
fig = Figure(backgroundcolor=:transparent, size=(800, 500));
qstep = 22
indicators = ["GDP", "PROD", "IR"]
countries = ["USA", "DEU", "FRA", "GBR"]
indposition = 6.2e8
counposition = 1.6e9

axgdp1 = Axis(fig[1, 1], xticks=(xticks[1:qstep:end], nolabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axgdp1, xticks, matdata[1, 1, :], label="IR")
text!(axgdp1, counposition, abs(maximum(matdata[1, 1, :])) + 0.15, text=countries[1], align=(:right, :top), fontsize=fontsize)
text!(axgdp1, indposition, 3.8, text=indicators[1], align=(:left, :bottom), fontsize=fontsize)
axgdp1.yticks = 4.0:0.15:4.80

for i in 2:4
    axgdp = Axis(fig[1, i], xticks=(xticks[1:qstep:end], nolabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
    lines!(axgdp, xticks, matdata[1, i, :], label="GDP")
    text!(axgdp, counposition, abs(maximum(matdata[1, i, :])) + 0.15, text=countries[i], align=(:right, :top), fontsize=fontsize)
    axgdp.yticks = 4.0:0.15:4.80
end

################################################################################

axprod1 = Axis(fig[2, 1], xticks=(xticks[1:qstep:end], nolabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axprod1, xticks, matdata[2, 1, :], label="PROD")
text!(axprod1, indposition, 4.02, text="PROD", align=(:left, :bottom), fontsize=fontsize)
axprod1.yticks = 4.10:0.15:4.80

axprod2 = Axis(fig[2, 2], xticks=(xticks[1:qstep:end], nolabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axprod2, xticks, matdata[2, 2, :], label="PROD")
axprod2.yticks = 4.10:0.15:4.80

axprod3 = Axis(fig[2, 3], xticks=(xticks[1:qstep:end], nolabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axprod3, xticks, matdata[2, 3, :], label="PROD")
axprod3.yticks = 4.10:0.15:4.80

axprod4 = Axis(fig[2, 4], xticks=(xticks[1:qstep:end], nolabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axprod4, xticks, matdata[2, 4, :], label="PROD")
axprod4.yticks = 4.10:0.15:4.80

################################################################################

axir1 = Axis(fig[3, 1], xticks=(xticks[1:qstep:end], adjlabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axir1, xticks, matdata[3, 1, :], label="GDP")
text!(axir1, indposition, 1.37, text="IR", align=(:left, :bottom), fontsize=fontsize)
axir1.yticks = 1.50:1.75:9.00

axir2 = Axis(fig[3, 2], xticks=(xticks[1:qstep:end], adjlabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axir2, xticks, matdata[3, 2, :], label="GDP")
axir2.yticks = 1.50:1.75:9.00

axir3 = Axis(fig[3, 3], xticks=(xticks[1:qstep:end], adjlabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axir3, xticks, matdata[3, 3, :], label="GDP")
axir3.yticks = 1.50:1.75:9.00

axir4 = Axis(fig[3, 4], xticks=(xticks[1:qstep:end], adjlabels[1:qstep:end]), titlesize=titlesize, xlabelsize=xlabsize, xticklabelsize=xticksize, ylabelsize=ylabsize, yticklabelsize=yticksize)
lines!(axir4, xticks, matdata[3, 4, :], label="GDP")
axir4.yticks = 1.50:1.75:9.00

fig

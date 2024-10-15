using DrWatson
@quickactivate

using CSV, DataFrames, JLD2
# using HypothesisTests, Plots, TensorToolbox

# function for difference of a country's data with optional log transformation
function cleancountry(country::String, df::DataFrame; logtransform::Bool=false, difftransform::Bool=false)
    country_data = filter(row -> row.Location == country, df)
    vals = logtransform ? log.(country_data.Value) : country_data.Value
    diffvalues = difftransform ? diff(vals) : vals
    return diffvalues
end

# function to compute fourth difference with log transformation
# fourthdiff(a::AbstractVector) = log.(a[5:end]) - log.(a[1:end-4])

countries = ["USA", "DEU", "FRA", "GBR"]

interestrate = CSV.read(datadir("ir.csv"), DataFrame)
gdp = CSV.read(datadir("gdp.csv"), DataFrame)
production = CSV.read(datadir("production.csv"), DataFrame)
cpi = CSV.read(datadir("cpi.csv"), DataFrame)

# matdata = fill(NaN, 3, 4, 96)
# for (i, country) in enumerate(countries)
#     matdata[1, i, :] = cleancountry(country, interestrate)[20:115]
# end
# for (i, country) in enumerate(countries)
#     matdata[2, i, :] = cleancountry(country, gdp, logtransform=true)[20:115]
# end
# for (i, country) in enumerate(countries)
#     matdata[3, i, :] = cleancountry(country, production, logtransform=true)[20:115]
# end

matdata = fill(NaN, 3, 4, 116)
for (i, country) in enumerate(countries)
    matdata[1, i, :] = cleancountry(country, interestrate)[1:116]
end
for (i, country) in enumerate(countries)
    matdata[2, i, :] = cleancountry(country, gdp, logtransform=true)[1:116]
end
for (i, country) in enumerate(countries)
    matdata[3, i, :] = cleancountry(country, production, logtransform=true)[1:116]
end

# CPI with fourth difference log transformation
# for (i, country) in enumerate(countries)
#     country_cpi = filter(row -> row.Location == country, cpi)
#     matdata[4, i, :] = country_cpi.Value[17:112]
# end

# vecdata = tenmat(matdata, row=[1, 2])
# plot(vecdata')
# plot(matdata[1, :, :]')
#
# pvals = fill(NaN, 12)
# for i in 1:12
#     adfresults = ADFTest(vecdata[i, :], :trend, 1)
#     pvals[i] = pvalue(adfresults)
# end
#
# below05 = pvals .< 0.05

# Save the processed data
save("./data/globaldata.jld2", Dict("matdata" => matdata))

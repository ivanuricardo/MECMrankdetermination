using DrWatson
@quickactivate

using CSV, DataFrames, JLD2, HypothesisTests

# function for difference of a country's data with optional log transformation
function diffcountry(country::String, df::DataFrame; logtransform::Bool=false)
    country_data = filter(row -> row.Location == country, df)
    values = logtransform ? log.(country_data.Value) : country_data.Value
    return diff(values)
end

# function to compute fourth difference with log transformation
fourthdiff(a::AbstractVector) = log.(a[5:end]) - log.(a[1:end-4])

countries = ["USA", "CAN", "DEU", "FRA", "GBR"]

interestrate = CSV.read(datadir("longir.csv"), DataFrame)
gdp = CSV.read(datadir("gdpextended.csv"), DataFrame)
prod = CSV.read(datadir("prodextended.csv"), DataFrame)
cpi = CSV.read(datadir("cpiextended.csv"), DataFrame)

matdata = fill(NaN, 4, 5, 96)

# interest rates with first difference
for (i, country) in enumerate(countries)
    matdata[1, i, :] = diffcountry(country, interestrate)[20:115]
end

# GDP with log difference
for (i, country) in enumerate(countries)
    matdata[2, i, :] = diffcountry(country, gdp, logtransform=true)[20:115]
end

# production with log difference
for (i, country) in enumerate(countries)
    matdata[3, i, :] = diffcountry(country, prod, logtransform=true)[20:115]
end

# CPI with fourth difference log transformation
for (i, country) in enumerate(countries)
    country_cpi = filter(row -> row.Location == country, cpi)
    matdata[4, i, :] = fourthdiff(country_cpi.Value)[17:112]
end

# Save the processed data
save("globaldata.jld2", Dict("matdata" => matdata))

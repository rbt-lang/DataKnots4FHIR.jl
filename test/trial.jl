#!/usr/bin/env julia

using DataKnots
using DataKnots4FHIR
using Dates
using IntervalSets
using JSON
using Pkg.Artifacts
using BenchmarkTools

folder = joinpath(artifact"synthea-79", "synthea-79", "CMS124v7", "numerator")
#folder = "/home/cce/synthea/output/2000"
bucket = []
for fname in readdir(folder)
    push!(bucket, JSON.parsefile(joinpath(folder, fname)))
end
db = convert(DataKnot, (bundle=bucket,))
@define MeasurePeriod = interval("[2018-01-01..2019-01-01)")
print("defining query...")
@time include(joinpath(@__DIR__, "../doc/src/cms124v7.jl"))
print("binding to QDM...")
@time q = @query bundle.QDM.{Numerator, Denominator, DenominatorExclusions}
print("assemble query...")
@time p = DataKnots.assemble(db, q) 
print("compiling........")
@time p(db)
print("again............")
@btime p(db) samples=5

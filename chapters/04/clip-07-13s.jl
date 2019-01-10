using StatisticalRethinking, CmdStan, StanMCMCChain
gr(size=(500,500));

ProjDir = rel_path("..", "scripts", "04")
cd(ProjDir)

howell1 = CSV.read(rel_path("..", "data", "Howell1.csv"), delim=';')
df = convert(DataFrame, howell1);

first(df, 5)

df2 = filter(row -> row[:age] >= 18, df);

density(df2[:height], lab="All heights", xlab="height [cm]", ylab="density")

female_df = filter(row -> row[:male] == 0, df2);
male_df = filter(row -> row[:male] == 1, df2);
first(male_df, 5)

density!(female_df[:height], lab="Female heights")
density!(male_df[:height], lab="Male heights")

d = JLD.load(joinpath(ProjDir, "m4.1s.jld"))

chn = MCMCChain.Chains(d["a3d"], names=d["names"])

describe(chn)

density(chn, lab="All heights", xlab="height [cm]", ylab="density")

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl


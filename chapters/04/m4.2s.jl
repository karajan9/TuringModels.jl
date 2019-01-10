using StatisticalRethinking, CmdStan, StanMCMCChain, JLD
gr(size=(500,500));

ProjDir = rel_path("..", "scripts", "04")
cd(ProjDir)

howell1 = CSV.read(rel_path("..", "data", "Howell1.csv"), delim=';')
df = convert(DataFrame, howell1);

df2 = filter(row -> row[:age] >= 18, df)
mean_height = mean(df2[:height])
df2[:height_c] = convert(Vector{Float64}, df2[:height]) .- mean_height
first(df2, 5)

max_height_c = maximum(df2[:height_c])
min_height_c = minimum(df2[:height_c])

heightsmodel = "
// Inferring a Rate
data {
  int N;
  real h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=$(min_height_c),upper=$(max_height_c)> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

stanmodel = Stanmodel(name="heights", monitors = ["mu", "sigma"],model=heightsmodel,
  output_format=:mcmcchain);

heightsdata = Dict("N" => length(df2[:height]), "h" => df2[:height_c]);

rc, chn, cnames = stan(stanmodel, heightsdata, ProjDir, diagnostics=false,
  CmdStanDir=CMDSTAN_HOME);

describe(chn)

JLD.save("m4.2s.jld",
  "range", chn.range,
  "a3d", chn.value,
  "names", chn.names,
  "chains", chn.chains)

d = JLD.load(joinpath(ProjDir, "m4.2s.jld"))

chn2 = MCMCChain.Chains(d["a3d"], names=d["names"])

describe(chn2)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl


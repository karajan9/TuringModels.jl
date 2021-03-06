using TuringModels, StatsFuns

Turing.setadbackend(:reverse_diff);
#nb Turing.turnprogress(false)

d = CSV.read(joinpath(@__DIR__, "..", "..", "data", "UCBadmit.csv"), delim=';');
size(d) # Should be 12x5

@model m_pois(admit, reject) = begin
   α₁ ~ Normal(0,100)
   α₂ ~ Normal(0,100)

   for i ∈ 1:length(admit)
       λₐ = exp(α₁)
       λᵣ = exp(α₂)
       admit[i] ~ Poisson(λₐ)
       reject[i] ~ Poisson(λᵣ)
   end
end;

chns = sample(m_pois(d[:, :admit], d[:, :reject]), Turing.NUTS(0.95), 1000);

# Rethinking/CmdStan result

m_10_yyt_result = "
    mean   sd 5.5% 94.5% n_eff Rhat
 a1 4.99 0.02 4.95  5.02  2201    1
 a2 5.44 0.02 5.41  5.47  2468    1
";

# Describe the draws

describe(chns)

# End of 10/m10.yyt.jl
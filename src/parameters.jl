mutable struct OBOPParameters
    gama
    max_generations
    population_size
    elite_size
    mutation_size
    function OBOPParameters(gama::Float64)
        # Max and Min population size
        population_max::Int64 = 1000
        population_min::Int64 = 50

        # Stop criterium
        max_generations::Int64 = convert(Int64, round(gama^(log(population_min) / log(gama) - population_max), digits=0))

        # Set elite size
        percentual_elite = 0.10 + ((1.0 / max_generations) * (0.25 - 0.10))
        elite_size = convert(Int64, round(population_max * percentual_elite, digits=0))

        # Set mutation size
        percentual_mutation = 0.05 + (1.0 - (1.0 / max_generations)) * (0.20 - 0.05)
        mutation_size = convert(Int64, round(population_max * percentual_mutation, digits=0))
        
        new(gama, max_generations, population_max, elite_size, mutation_size)
    end
end

function update_parameters!(generation::Int64, parameters::OBOPParameters)
    # population size: cooling annealing
    parameters.population_size = convert(Int64, round(( parameters.population_size * parameters.gama), digits=0))

    # Update elite size
    percentual_elite = 0.10 + ((generation / parameters.max_generations) * (0.25 - 0.10))
    parameters.elite_size = convert(Int64, round(parameters.population_size * percentual_elite, digits=0))

    # Update mutation size
    percentual_mutation = 0.05 + (1.0 - (generation / parameters.max_generations)) * (0.20 - 0.05)
    parameters.mutation_size = convert(Int64, round(parameters.population_size * percentual_mutation, digits=0))
end
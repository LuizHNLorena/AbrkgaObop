using DelimitedFiles

function read_matrix(dataset::String)::OBOPDataset
    C = readdlm(dataset,Int64)
    total_voters, total_itens = size(C)
    item_names = [string(i) for i in 1:total_itens]
    D = [C[i,j] - C[j,i] for i in 1:total_itens, j in 1:total_itens]
    interval_init = [i * (1/total_itens) for i in 0:total_itens-1]
    instance = OBOPDataset(dataset,
                           0,
                           total_itens,
                           item_names,
                           C,
                           D,
                           interval_init)
    return instance
end

function read_soc(dataset::String)::OBOPDataset
    instance = OBOPDataset(dataset, 
                           0, 
                           0, 
                           Array{String}(undef,0), 
                           Array{Int64}(undef,0,0),
                           Array{Int64}(undef,0,0),
                           Array{Float64}(undef,0))
    open(dataset) do file
        # Load total of itens
        instance.total_itens = parse(Int64,readline(file))
        # Load itens names
        for i in 1:instance.total_itens
            line = split(readline(file),",")
            push!(instance.item_names,strip(line[2]))
        end
        # Load total of ranks
        instance.total_voters = parse(Int64,split(readline(file),",")[3])
        # Create cumulative score matrix 
        instance.C = zeros(Int64,instance.total_itens,instance.total_itens)
        found, bucketID = false, 1
        rank = Array{Int64}(undef, instance.total_itens)
        for r in 1:instance.total_voters
            line = parse.(Int64,split(readline(file),','))
            total = line[begin]
            rank = line[begin+1:end]
            # Update C matrix
            for i in 1:instance.total_itens-1
                for j in i+1:instance.total_itens
                    instance.C[rank[i],rank[j]] += total
                    instance.C[rank[j],rank[i]] -= total
                end
            end
        end
        # Create D matrix
        instance.D = [instance.C[i,j] - instance.C[j,i] for i in 1:instance.total_itens, j in 1:instance.total_itens]
        # Create interval vector
        instance.interval_init = [i * (1/instance.total_itens) for i in 0:instance.total_itens-1]
    end
    return instance
end

function read_soi(dataset::String)::OBOPDataset
    instance = OBOPDataset(dataset, 
                           0, 
                           0, 
                           Array{String}(undef,0), 
                           Array{Int64}(undef,0,0),
                           Array{Int64}(undef,0,0),
                           Array{Float64}(undef,0))
    open(dataset) do file
        # Load total of itens
        instance.total_itens = parse(Int64,readline(file))
        # Load itens names
        for i in 1:instance.total_itens
            line = split(readline(file),",")
            push!(instance.item_names,strip(line[2]))
        end
        # Load total of ranks
        instance.total_voters = parse(Int64,split(readline(file),",")[3])
        # Create cumulative score matrix 
        instance.C = zeros(Int64,instance.total_itens,instance.total_itens)
        found, bucketID = false, 1
        rank = Array{Int64}(undef, instance.total_itens)
        for r in 1:instance.total_voters
            line = parse.(Int64,split(readline(file),','))
            total = line[begin]
            rank = line[begin+1:end]
            # Update C matrix
            for i in 1:size(rank,1)-1
                for j in i+1:size(rank,1)
                    instance.C[rank[i],rank[j]] += total
                    instance.C[rank[j],rank[i]] -= total
                end
            end
        end
        # Create D matrix
        instance.D = [instance.C[i,j] - instance.C[j,i] for i in 1:instance.total_itens, j in 1:instance.total_itens]
        # Create interval vector
        instance.interval_init = [i * (1/instance.total_itens) for i in 0:instance.total_itens-1]
    end
    return instance
end

function read_toc(dataset::String)::OBOPDataset
    instance = OBOPDataset(dataset, 
                           0, 
                           0, 
                           Array{String}(undef,0), 
                           Array{Int64}(undef,0,0),
                           Array{Int64}(undef,0,0),
                           Array{Float64}(undef,0))
    open(dataset) do file
        # Load total of itens
        instance.total_itens = parse(Int64,readline(file))
        # Load itens names
        for i in 1:instance.total_itens
            line = split(readline(file),",")
            push!(instance.item_names,strip(line[2]))
        end
        # Load total of ranks
        instance.total_voters = parse(Int64,split(readline(file),",")[3])
        # Create cumulative score matrix 
        instance.C = zeros(Int64,instance.total_itens,instance.total_itens)
        rank = Array{Int64}(undef, instance.total_itens)
        found, bucketID = false, 1
        for r in 1:instance.total_voters
            fill!(rank,0)
            line = split(readline(file),',')
            total = parse(Int64,line[begin])
            line = line[begin+1:end]
            found, bucketID = false, 1
            for l in line
                if l[begin] != '{' && l[end] != '}'
                    value = parse(Int64,l)
                    rank[value] = bucketID
                    if found == false
                        bucketID += 1
                    end
                else
                    if l[begin] == '{'
                        found = true
                        value = parse(Int64,l[begin+1:end])
                        rank[value] = bucketID
                    elseif l[end] == '}'
                        found = false
                        value = parse(Int64,l[begin:end-1])
                        rank[value] = bucketID
                        bucketID += 1
                    end
                end
            end
            # Update C matrix
            for i in 1:instance.total_itens-1
                for j in i+1:instance.total_itens
                    if rank[i] == rank[j]
                        instance.C[i,j] += total
                        instance.C[j,i] += total
                    elseif rank[i] < rank[j]
                        instance.C[i,j] += total
                        instance.C[j,i] -= total
                    else
                        instance.C[i,j] -= total
                        instance.C[j,i] += total
                    end
                end
            end
        end
        # Create D matrix
        instance.D = [instance.C[i,j] - instance.C[j,i] for i in 1:instance.total_itens, j in 1:instance.total_itens]
        # Create interval vector
        instance.interval_init = [i * (1/instance.total_itens) for i in 0:instance.total_itens-1]
    end
    return instance
end

function read_toi(dataset::String)::OBOPDataset
    instance = OBOPDataset(dataset, 
                           0, 
                           0, 
                           Array{String}(undef,0), 
                           Array{Int64}(undef,0,0),
                           Array{Int64}(undef,0,0),
                           Array{Float64}(undef,0))
    open(dataset) do file
        # Load total of itens
        instance.total_itens = parse(Int64,readline(file))
        # Load itens names
        for i in 1:instance.total_itens
            line = split(readline(file),",")
            push!(instance.item_names,strip(line[2]))
        end
        # Load total of ranks
        instance.total_voters = parse(Int64,split(readline(file),",")[3])
        # Create cumulative score matrix 
        instance.C = zeros(Int64,instance.total_itens,instance.total_itens)
        rank = Array{Int64}(undef, instance.total_itens)
        found, bucketID = false, 1
        for r in 1:instance.total_voters
            fill!(rank,0)
            line = split(readline(file),',')
            total = parse(Int64,line[begin])
            line = line[begin+1:end]
            found, bucketID = false, 1
            for l in line
                if l[begin] != '{' && l[end] != '}'
                    value = parse(Int64,l)
                    rank[value] = bucketID
                    if found == false
                        bucketID += 1
                    end
                else
                    if l[begin] == '{'
                        found = true
                        value = parse(Int64,l[begin+1:end])
                        rank[value] = bucketID
                    elseif l[end] == '}'
                        found = false
                        value = parse(Int64,l[begin:end-1])
                        rank[value] = bucketID
                        bucketID += 1
                    end
                end
            end
            # Update C matrix
            for i in 1:instance.total_itens-1
                for j in i+1:instance.total_itens
                    if rank[i] != 0 && rank[j] != 0
                        if rank[i] == rank[j]
                            instance.C[i,j] += total
                            instance.C[j,i] += total
                        elseif rank[i] < rank[j]
                            instance.C[i,j] += total
                            instance.C[j,i] -= total
                        else
                            instance.C[i,j] -= total
                            instance.C[j,i] += total
                        end
                    end
                end
            end
        end
        # Create D matrix
        instance.D = [instance.C[i,j] - instance.C[j,i] for i in 1:instance.total_itens, j in 1:instance.total_itens]
        # Create interval vector
        instance.interval_init = [i * (1/instance.total_itens) for i in 0:instance.total_itens-1]
    end
    return instance
end

"""
    read_dataset(dataset[, cost_matrix])

Read the `dataset` that can be either in Preflib.org formats or a pre-calculated Cumulative Cost Matrix. 
If `cost_matrix` is defined as `true` it will use the cost matrix as input, else it will infer the file type considering the
following Prelib formats:

- `.soc` (Strict Order - Complete List)
- `.soi` (Strict Order - Incomplete List)
- `.toc` (Order with Ties - Complete List)
- `.toi` (Order with Ties - Incomplete List)
"""
function read_dataset(dataset::String; cost_matrix::Bool=false)::OBOPDataset
    instance = nothing
    if cost_matrix
        instance = read_matrix(dataset)
    else
        file_type = dataset[end-2:end]
        if file_type == "soc"
            instance = read_soc(dataset)
        elseif file_type == "soi"
            instance = read_soi(dataset)
        elseif file_type == "toc"
            instance = read_toc(dataset)
        elseif file_type == "toi"
            instance = read_toi(dataset)
        end
    end
    return instance
end
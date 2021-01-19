function decoder!(item::Int64, buckets::Array{Int64,2}, keys::Array{Float64,2})
    @inbounds for i in 1:size(buckets, 1)
        if keys[i,item] < 0.0001
            buckets[i,item] = 1
        else
            buckets[i,item] = Int64(ceil(keys[i,item] * size(buckets, 1)))
        end
    end
end

function objective!(item::Int64, buckets::Array{Int64,2}, fitness::Array{Int64,1}, instance::OBOPDataset)
    fitness[item] = 0
    @inbounds for i in 1:size(instance.C, 1) - 1
        @inbounds for j in i + 1:size(instance.C, 1)
            if buckets[i,item] == buckets[j,item]
                fitness[item] += instance.C[i,j]
                fitness[item] += instance.C[j,i]
            else
                if buckets[i,item] < buckets[j,item]
                    fitness[item] += instance.C[i,j]
                    fitness[item] -= instance.C[j,i]
                else
                    fitness[item] -= instance.C[i,j]
                    fitness[item] += instance.C[j,i]
                end
            end
        end
    end
end

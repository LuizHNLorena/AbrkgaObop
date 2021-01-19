function create_bucket_order(bucket)
    groups = [[] for _ in 1:length(bucket)]
    for i in 1:length(bucket)
        push!(groups[bucket[i]], i)
    end
    
    last_id = sort(unique(bucket),rev=true)[1]
    
    stat_bucket = ""
    for i in 1:length(bucket)
        if size(groups[i],1) > 0
            for j in 1:size(groups[i],1)
                if j != size(groups[i],1)
                    stat_bucket *= " $(groups[i][j]) ,"                
                else
                    if i == last_id
                        stat_bucket *= " $(groups[i][j]) "
                    else
                        stat_bucket *= " $(groups[i][j]) |"
                    end
                end
            end
        end
    end
    return stat_bucket
end
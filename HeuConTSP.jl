
using StatsBase

function remove!(collection::AbstractVector, item)
    index = findfirst(isequal(item), collection)
    if index === nothing
      error("$item is not in collection $collection")
    else
      deleteat!(collection, index)
    end
end

function Cheapest_Insertion(dist, N)

    NR = Vector(1:N)
    NR_aux = deepcopy(NR)

    len_tour = 2                                    # length of initial tour
    tour = sample(NR, len_tour, replace=false)      # 2 initial nodes
    fo = 0                                          # objective function value

    for i in 1:len_tour
        ni = tour[i]
        if i == len_tour
            j = 1
        else
            j = i + 1
        end       
        nj = tour[j]
        fo += dist[ni, nj]
        remove!(NR, ni)
    end

    vk = 0
    min_vk, min_j = 0, 0, 0

    NMI = 1
    while NR != []
                      
        z_min = Inf                     # 'z' - cheapest insertion value
        size_NR = length(NR)
        for k in 1:size_NR
            vk = NR[k]

            size_tour = length(tour)
            for i in 1:size_tour
                vi = tour[i]
                if i == size_tour
                    j = 1
                else
                    j = i + 1
                end

                vj = tour[j]              
                z = dist[vi, vk] + dist[vk, vj] - dist[vi, vj]

                if z < z_min

                    z_min = z
                    min_j = j
                    min_vk = vk

                end
            end
        end

        insert!(tour, min_j, min_vk)
        fo += z_min
        remove!(NR, min_vk)

        NMI += 1
    end

    fo_total = fo

    return tour, fo_total

end

function TwoOpt(solucao, dist, fo)

    sol = deepcopy(solucao)

    n = length(sol)

    fo_LS = fo              # fo Local Search
    min_delta, delta = 0, 0
    epsilon = 0.01

    min_i, min_j = 0, 0  

    melhorou = true
    while (melhorou)       # 'Best Improvement' strategy
        melhorou = false
        min_delta = 0
        for i in 1:(n-2)
            for j in (i+2):n

                vi = sol[i]
                viP = sol[i+1]
                vj = sol[j]

                if j == n
                    vjP = sol[1]
                else
                    vjP = sol[j+1]
                end

                delta = - dist[vi,viP] - dist[vj,vjP] + dist[vi,vj] + dist[viP,vjP]

                if delta < (min_delta - epsilon)
                    melhorou = true
                    min_delta = delta
                    min_i, min_j = i, j

                end
            end
        end

        # Update tour with best move
        if (melhorou)

            sol = reverse(sol, min_i+1, min_j)
            fo_LS = fo_LS + min_delta

            min_delta = 0
        end

    end

    return sol, fo_LS 

end
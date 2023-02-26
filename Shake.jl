

function swap(s, dist, fo, N)                # Swap two nodes

    route = deepcopy(s)

    nodes = sample(route, N, replace=false)      # sample of 2 nodes

    i = nodes[1]
    j = nodes[2]

    aux_i = i
    if j < i
        i = j
        j = aux_i
    end

    vi = route[i]
    if i == N
        viP = route[1]
    else
        viP = route[i+1]
    end

    viM = 0
    if i == 1
        viM = route[N]
    else
        viM = route[i-1]
    end


    vj = route[j]
    vjP = 0
    if j == N
        vjP = route[1]
    else
        vjP = route[j+1]
    end

    vjM = 0
    if j == 1
        vjM = route[N]
    else
        vjM = route[j-1]
    end

    j_mod = j%N
    diff = j_mod - i

    deltaM, deltaP = 0, 0

    if diff == 1 || diff == (1-N)
        deltaM = - dist[viM, vi] - dist[vi, vj] - dist[vj, vjP]
        deltaP = dist[viM, vj] + dist[vj, vi] + dist[vi, vjP]

    elseif diff == -1
        deltaM = - dist[vi, viP] - dist[vi, vj] - dist[vjM, vj]
        deltaP = dist[vjM, vi] + dist[vi, vj] + dist[vj, viP]

    else
        deltaM = - dist[viM, vi] - dist[vi, viP] - dist[vjM, vj] - dist[vj, vjP]
        deltaP = dist[viM, vj] + dist[vj, viP] + dist[vjM, vi] + dist[vi, vjP]
    end

    fo = fo + deltaM + deltaP

    aux = vi
    route[i] = vj
    route[j] = aux

    return route, fo
end

function move(s, dist, fo, N)                # Shift node 'i' to 'j+1' position

    route = deepcopy(s)
    
    nodes = sample(route, N, replace=false)      # sample of 2 nodes

    i = nodes[1]
    j = nodes[2]

    j_mod = j%N

    while i == (j_mod+1)
        nodes = sample(route, N, replace=false)
        i = nodes[1]
        j = nodes[2]
        j_mod = j%N

    end

    vi = route[i]
    viP = 0
    if i == N
        viP = route[1]
    else
        viP = route[i+1]
    end

    viM = 0
    if i == 1
        viM = route[N]
    else
        viM = route[i-1]
    end

    vj = route[j]
    vjP = 0
    if j == N
        vjP = route[1]
    else
        vjP = route[j+1]
    end

    ## ------> FO update <----- ##
    deltaM = - dist[viM, vi] - dist[vi, viP] - dist[vj, vjP]
    deltaP = dist[viM, viP] + dist[vj, vi] + dist[vi, vjP]

    fo = fo + deltaM + deltaP

    ## ------> Route update <----- ##
    insert!(route, j+1, vi)
    if i < (j + 1)
        deleteat!(route, i)
    else
        deleteat!(route, i+1)
    end

    return route, fo
end

function perturbation(route, dist, fo, N, beta_min, beta_max)

    s = deepcopy(route)
    k = rand(beta_min:beta_max)

    changes = floor(N * k/100)

    s1 = Int64[]
    fo1 = Float64

    for i in 1:changes
        y = rand()
        if y <= 0.5
            s1, fo1 = swap(s, dist, fo, N)

        else
            s1, fo1 = move(s, dist, fo, N)

        end

        s = deepcopy(s1)
        fo = fo1
    end

    return s1, fo1
end


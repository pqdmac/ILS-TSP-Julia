
using CSV
using DataFrames
using StatsBase
using Random


include("HeuConTSP.jl")
include("ReadFile.jl")
include("Shake.jl")


ti = time()

function run_ILS(dist, N, beta_min, beta_max, maxIter, BKS)

    time2best = 0
    time2target = 0

    route, fo0 = Cheapest_Insertion(dist, N)

    s, fo = TwoOpt(route, dist, fo0)

    s1 = Int64[]
    s2 = Int64[]

    epsilon = 0.01
    Iter = 1

    while Iter <= maxIter
        
        s1, fo1 = perturbation(s, dist, fo, N, beta_min, beta_max)

        s2, fo2 = TwoOpt(s1, dist, fo1)
       
        if fo2 < (fo - epsilon)
            time2best = time()
            # println("\n############################ Iteration: $Iter")
            s = deepcopy(s2)
            fo = fo2

            # if fo < 1.01*BKS          # Uncomment to get 'ttt' value
            #     time2target = time()
            #     break
            # end

        end     

        Iter += 1

    end
    return fo, s, time2best, time2target

end


global ILS_results = DataFrame(Instancia = String[], BKS = Float64[], 
    Best_FO = Float64[], Mean_FO = Float64[], Worse_FO = Float64[], Best_RPD = Float64[],
    Mean_RPD = Float64[], Time_to_best_FO = Float64[], Mean_Time_to_best_FO = Float64[],
    Run_time_best_FO = Float64[], Mean_run_time = Float64[]
)

# datafile = "Instances\\list_40_instances_plus_BKS.txt"
datafile = "Instances\\list_20_instances_plus_BKS.txt"

inst, BKS = ReadBKS(datafile)

nr_files = length(BKS)
nr_runs = 50

println("Running...")
    
for i in 9:nr_files

    if i == 10
        break
    end

    fos = Float64[]
    rpds = Float64[]
    best_times = Float64[]
    times = Float64[]

    solutions = []

    instance_results = DataFrame(BKS = Float64[], FO_ILS = Float64[],  RPD_ILS = Float64[],
                Time_to_best_FO = Float64[], Time_to_target = Float64[], Total_time = Float64[])


    instance = inst[i]

    probname = instance[15:end-4]
    println("\nInstance:\t $probname")

    beta_min = 7            # min_perturbation
    beta_max = 35           # max_perturbation
    maxIter = 1000           # max iterations

    for r in 1:nr_runs

        initial_time_ILS = time()

        X, Y, dist, N = ReadData(instance)

        fo_ILS, sol_ILS, time2best, time2target  = run_ILS(dist, N, beta_min, beta_max, maxIter, BKS[i])

        final_time_ILS = time()
        time_ILS = round(final_time_ILS - initial_time_ILS, digits=2)
        rpd = round(100 * (fo_ILS - BKS[i])/BKS[i], digits = 2)

        time2best = round(time2best - initial_time_ILS, digits=2)

        time2target = round(time2target - initial_time_ILS, digits=2)
        # println("\ntime2target: $time2target")

        push!(instance_results, (BKS[i], fo_ILS, rpd, time2best, time2target, time_ILS))


        push!(solutions, sol_ILS)
        push!(fos, fo_ILS)
        push!(rpds, rpd)
        push!(best_times, time2best)
        push!(times, time_ILS)

    end

    println(instance_results)

    CSV.write("Results_per_instance/$probname.csv", instance_results)

    best_fo = minimum(fos)
    mean_fo = round(mean(fos), digits=2)
    worse_fo = maximum(fos)

    # Searching for an element in a 1D ARRAY 
    sch = best_fo  
    positionArray = indexin( sch, fos ) 

    best_sol = solutions[positionArray[1]]

    time2bestFO = best_times[positionArray[1]]
    mean_time2bestFO = round(mean(best_times), digits=2)

    run_time_best_FO = times[positionArray[1]]
    mean_run_time = round(mean(times), digits=2)

    total_time_best_fo = times[positionArray[1]]

    best_rpd = minimum(rpds)
    mean_rpd = round(mean(rpds), digits=2)


    Write_Data(probname, best_sol, best_fo, best_rpd, time2bestFO, total_time_best_fo)


    push!(ILS_results, (probname, BKS[i], best_fo, mean_fo, worse_fo, 
                        best_rpd, mean_rpd, time2bestFO, mean_time2bestFO,
                        run_time_best_FO, mean_run_time))
    CSV.write("ILS_results.csv", ILS_results)

end

println("\n")
println(ILS_results)
println("\n")
CSV.write("ILS_results.csv", ILS_results)

tf = time()
general_time = round(tf - ti, digits = 2)
println("\nTotal_run_time: $general_time")


# # ############################



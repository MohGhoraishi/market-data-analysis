module OrdinalPatterns

using Plots
using Bijections
using Combinatorics
using CSV, DataFrames

function rank_array(array::Vector) #function that ranks the elements of an array by size in an ascending order (If elements are repeated they are given consecutive ranks)
    #sortperm(array) gives the indices with which our array would be sorted (argsort() in numpy)
    #By calling the above function twice, an array of elements ranks is derived (we substract one from all elements of the rank so they start at 0)
    return sortperm(sortperm(array)).-1
end

function ordinal_pattern_map(d::Int) #function that creates a bidirectional map between the permutations of arrays of degree d and a unique number
    map = Bijection{Int, Vector}() #creates a bidirectional map between an Int and a Vector
    #Creates all possible permutations of the ordinal pattern of degree d and puts it in the array possibilities
    init_array = Int[] 
    for i in 1:d
        push!(init_array, i-1)
    end
    possibilities = collect(permutations(init_array, d))
    #A map is created assigining a unique number to each possible ordinal pattern for degree d
    for i in 1:factorial(d)
        map[i] = possibilities[i]
    end
    return map
end

function generate_ordinal_pattern(array::Vector, d::Int) #function that takes an array and the degree as input and returns an array of numbers representing the ordinal pattern
    num = length(array) - d + 1 #d-1 elements are lost
    new_array = zeros(Int,length(array)) 
    map = ordinal_pattern_map(d)
    #The loop selects a data window of size d from the initial array, then ranks the elements and finally matches it to the corresponding ordinal pattern number using the map
    #The indexes of the new data array where data is lost will remain zero to not disturb the timeseries
    for i in 1:num
        new_array[i+d-1] = map(rank_array(array[i:i+d-1]))
    end
    return new_array
end

function correlation_probability_matrix(array::Vector, d::Int) #function that creates a probability of correlation matrix between two consecutive patterns
    total_possible = factorial(d)
    mat = zeros(total_possible,total_possible)
    num = length(array)
    for i in 1:num-1
        mat[array[i], array[i+1]] += 1
    end
    return mat./(num-1)
end

function ordinal_pattern_matrix(mat, d) #function that takes a matrix and calculates the ordinal pattern of each column then returns a new matrix
    sizes = size(mat)
    newmat = zeros(Int, sizes[1], sizes[2])
    for i in 1:sizes[2]
        newmat[:,i] = OP.generate_ordinal_pattern(mat[:,i], d)
    end
    return newmat[d:end, :]
end

#TODO this function is work in progress and is only a visual test for the algorithm
function check_pattern_plot(array::Vector, d::Int, points::Int) #function that plots a comparative plot between the original array and the generated ordinal pattern of degree d
    sliced_array = array[end-points-d+1:end] #Sliced original array for faster computation
    ordinal_array = generate_ordinal_pattern(sliced_array, d)[d:end] #generates ordinal pattern but removes unwanted zeros
    map = ordinal_pattern_map(d)
    data_points = collect(1:d:points-d)
    x = collect(1:points)
    plt = plot(points, sliced_array, title = "Test comparative plot of the ordinal pattern", label = "Data")
    for i in data_points
        plt = plot!(x[i:i+d],map[ordinal_array[i]], label = false)
    end
    
end

end

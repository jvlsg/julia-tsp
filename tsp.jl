using JuMP, Cbc

#TODO Read Input from datasets

"""
nxn Matrix of ints or floats representing the distances between the nodes
"""
node_distances = [ [0,1] , [1,0] ]

node_number = size(node_distances)[1]


b = [-5;  10]
c = [ 1  2  5]


tsp_model = Model(with_optimizer(Cbc.Optimizer))

# para definir o tempo limite em segundos.
# set_time_limit_sec(tsp_model , <tempo>)

"""
Decision variable - binary nxn Matrix representing the edges taken between nodes
"""
@variable(tsp_model, edges_taken[1:node_number, 1:node_number], Bin)
@variable(tsp_model, u[1:node_number], integer=true)

fix(u[1], 0) # change the 1 for the position of initial node

"""
Min Sum ( node_distances[i][j] * edges_taken[i][j] for all nodes)
"""
@objective(tsp_model,Min, sum( map(*,node_distances,edges_taken) ) )

@constraints tsp_model begin
# TODO - Add constraints
    [i = 1:node_numbers] , sum(x[i,1:end .!=i]) == 1
    [i = 1:node_numbers] , sum(x[1:end .!=i,i]) == 1
    [i = 1:node_numbers , j= 2:node_numbers , i != j] , u[i] - u[j] + node_number*edges_taken[i,j] <= node_number-1
end

print(tsp_model)

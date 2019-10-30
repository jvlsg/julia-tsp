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

"""
Decision variable - binary nxn Matrix representing the edges taken between nodes
"""
@variable(tsp_model, edges_taken[1:node_number, 1:node_number], Bin)

"""
Min Sum ( node_distances[i][j] * edges_taken[i][j] for all nodes)
"""
@objective(tsp_model,Min, sum( map(*,node_distances,edges_taken) ) )

@constraints tsp_model begin
# TODO - Add constraints
end
    
print(tsp_model)

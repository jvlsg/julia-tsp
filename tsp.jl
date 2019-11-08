using JuMP, Cbc

#TODO Read Input from datasets

"""
nxn Matrix of ints or floats representing the distances between the nodes
"""
node_distances = []

node_number = size(node_distances)[1]

tsp_model = Model(with_optimizer(Cbc.Optimizer))

#Limits execution time
set_time_limit_sec(tsp_model , 1)

#Decision variable - binary nxn Matrix representing the edges taken between nodes
@variable(tsp_model, edges_taken[1:node_number, 1:node_number], Bin)
@variable(tsp_model, u[1:node_number], integer=true)

#Min Sum ( node_distances[i][j] * edges_taken[i][j] for all nodes)
@objective(tsp_model,Min, sum( map(*,node_distances,edges_taken) ) )

fix(u[1], 0) # change the 1 for the position of initial node

@constraints tsp_model begin
    [i= 1:node_number] , sum(edges_taken[i,1:end .!=i]) == 1
    [i= 1:node_number] , sum(edges_taken[1:end.!=i,i]) == 1
    [i = 1:node_number , j= 2:node_number , i != j] , u[j] >= u[i] + edges_taken[i,j] - node_number *(1-edges_taken[i,j])
end

#print(tsp_model)
optimize!(tsp_model)
print(edges_taken)
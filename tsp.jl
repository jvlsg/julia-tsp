using JuMP, Cbc, DelimitedFiles

function distances_from_coords(node_coords)
    
    node_number = size(node_coords,1)
    node_distances = zeros()
    
    for row in range(1,length=node_number)
        for column in range(1,length=node_number)
            #Applying Euclidean distance, http://www.math.uwaterloo.ca/tsp/world/countries.html#DJ
            node_distances[row,column] = sqrt(  
                Float32(node_coords[column,1]-node_coords[row,1])^2 + 
                Float32(node_coords[column,2]-node_coords[row,2])^2 )  
        end
    end

    return node_distances
end
"""
nxn Matrix of ints or floats representing the distances between the nodes
"""
node_coords = DelimitedFiles.readdlm("datasets/parsed_dj38.tsp",' ',Float32,'\n')


node_distances = [ 0  186 105 208 177 94 ;
187 0 89.8 223 255 254 ;
99.9 89 0  203 204 172 ;
206 220 203 0 377 295 ; 
168 251 201 376 0 156 ;
86.8 255 173  293 159  0]
readdlm()

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

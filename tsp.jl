using JuMP, Cbc, DelimitedFiles

function distances_from_coords(node_coords::Array{Float32,2})
    """
    Recieves a 2D array of the X,Y coordinates for each of the n nodes. 
    E.g.
    node_coords[node,1] : Latitude of the node

    Returns a n,n matrix of the euclidean distances between the nodes
    """
    node_number = size(node_coords,1)
    node_distances = zeros(node_number,node_number)
    for row in range(1,length=node_number)
        for column in range(1,length=node_number)
            #Applying Euclidean distance
            node_distances[row,column] = sqrt(  
                Float32(node_coords[column,1]-node_coords[row,1])^2 + 
                Float32(node_coords[column,2]-node_coords[row,2])^2 )  
        end
    end

    return node_distances
end

function tsp_main(args)
    """
    Use Cbc to calculate Travelling Salesperson solution for a given graph.
    Args: Filename of the parsed graph file. 
        The file should follow this standard 
        http://www.math.uwaterloo.ca/tsp/world/countries.html#DJ

    """

    node_coords = DelimitedFiles.readdlm(args[1],' ',Float32,'\n')
    
    """
    nxn Matrix of floats representing the distances between the nodes
    """
    node_distances = distances_from_coords(node_coords)

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
end

tsp_main(ARGS)
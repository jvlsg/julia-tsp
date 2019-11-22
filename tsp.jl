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

    tsp_model = Model(with_optimizer(Cbc.Optimizer , threads=4))

    #Limits execution time
    set_time_limit_sec(tsp_model , 7200)

    #Decision variable - binary nxn Matrix representing the edges taken between nodes
    @variable(tsp_model, edges_taken[1:node_number, 1:node_number], Bin)
	@variable(tsp_model,  0 <= u[1:node_number]  <= (node_number-1),Int)

    #Min Sum ( node_distances[i][j] * edges_taken[i][j] for all nodes)
    @objective(tsp_model,Min, sum( map(*,node_distances,edges_taken) ) )

    fix(u[1], 0,force=true) # change the 1 for the position of initial node

	for i in 1:node_number
		@constraint(tsp_model,sum(edges_taken[i,j] for j in 1:node_number if i != j ) == 1)
	end
	# Restrições para garantir a chegada em cada vértice
	for j in 1:node_number
		@constraint(tsp_model,sum(edges_taken[i,j] for i in 1:node_number if i != j) == 1)
	end
	for i in 1:node_number
		for j in 2:node_number
			if i != j
				@constraint(tsp_model,u[i] - u[j] + node_number * edges_taken[i,j] <= node_number - 1)
			end
		end
	end
	for i in 2:node_number
		@constraint(tsp_model, 0 <= u[i] <= node_number - 1)
	end

    optimize!(tsp_model)

	#Código para facilitar a impressão das cidades percorridas
	auxU = value.(u)
	ordem = zeros(UInt64 , (node_number,1))
	for i in 1:node_number
		ordem[Int64(round(auxU[i]+1))] = i
	end

	print("O valor do caminho otimo é: ")
	println(objective_value(tsp_model))
	print("A ordem dos pontos percorridos: ")
	for i in 1:node_number
		print(ordem[i])
		print(" ")
	end
end

tsp_main(ARGS)

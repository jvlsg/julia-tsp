using JuMP, Cbc, DelimitedFiles, Plots

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

function plot_result(uV::Array{Float64,1} , node_coords::Array{Float32,2})
	node_number = size(node_coords,1)
	x = zeros(node_number,1)
	y = zeros(node_number,1)
	for elements in range(1,length=node_number)
		x[Int(round(uV[elements]+1))] = node_coords[elements , 1];
		y[Int(round(uV[elements]+1))] = node_coords[elements , 2];
	end
	gr()
	plot(x,y, label="line")
	png("/tmp/aspng")
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
    #set_time_limit_sec(tsp_model , 1)

    #Decision variable - binary nxn Matrix representing the edges taken between nodes
    @variable(tsp_model, edges_taken[1:node_number, 1:node_number], Bin)
	@variable(tsp_model,  0 <= u[1:node_number]  <= (node_number-1),Int)

    #Min Sum ( node_distances[i][j] * edges_taken[i][j] for all nodes)
    @objective(tsp_model,Min, sum( map(*,node_distances,edges_taken) ) )

    fix(u[1], 0,force=true) # change the 1 for the position of initial node

    @constraints tsp_model begin
        [i= 1:node_number] , sum(edges_taken[i,1:end .!=i]) == 1
        [i= 1:node_number] , sum(edges_taken[1:end.!=i,i]) == 1
        [i = 1:node_number , j= 2:node_number , i != j] , u[j] >= u[i] + 1 * edges_taken[i,j] - node_number *(1-edges_taken[i,j])
    end

    #print(tsp_model)
    optimize!(tsp_model)
	print("resposta: ")
	println(objective_value(tsp_model))
	println("valor de u: ")
	println(value.(u))
	println("valor de u ordenado:")
	println(sort(value.(u)))
	#xV = value.(edges_taken)
	#a = 0.0
	#for i in range(1, length=node_number)
	#	for j in range(1 , length=node_number)
	#		if xV[i , j] == 1
	#			global a = a + node_distances[i , j]
	#		end
	#	end
	#end
    #print(edges_taken)
	vetU = value.(u)
	println(sort(vetU))
	#plot_result(vetU , node_coords)
end

tsp_main(ARGS)

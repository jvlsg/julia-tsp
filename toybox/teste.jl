using JuMP
using Cbc
# cria o modelo para a otimização linear, utiliza o cbc como solver
m = Model(with_optimizer(Cbc.Optimizer))

set_time_limit_sec(m , 1)

n = 6

# define as variaveis binárias xij e o u como inteiro
@variable(m , x[1:n , 1:n] , Bin)
@variable(m , u[1:n] , integer=true)

fix(u[1] , 0)

# cria o grafo de pesos para fazer conexão
y = zeros(Int64 , n , n)

# dados do exemplo do slide da prof(trabalho -  material auxiliar)
# é o exemplo das cidades que está logo depois do MTZ
y = [ 0  186 105 208 177 94 ;
     187 0 89.8 223 255 254 ;
     99.9 89 0  203 204 172 ;
     206 220 203 0 377 295 ; 
     168 251 201 376 0 156 ;
     86.8 255 173  293 159  0]

#for i in 1:5
#    for j in 1:5
#        y[i,j] = i+j
#    end
#end

# função objetiva
@objective(m , Min , sum(x.*y))


# constraint de que a soma de uma linha vai ser 1
@constraint(m , [i= 1:n] , sum(x[i,1:end .!=i]) == 1)
# constraint de que a soma de uma coluna vai ser 1
@constraint(m , [i= 1:n] , sum(x[1:end.!=i,i]) == 1)

# constraint do u
@constraint(m , [i = 1:n , j =2:n , i != j] , u[j] >= u[i] + x[i,j] - n *(1-x[i,j]))

#printa os dados do modelo
println(m)

# resolve e printa os resultados
optimize!(m)

uAux = value.(u)
xAux = value.(x)

for i in 1:n
    println("u$(i) $(uAux[i])")
end

print("\n\n Xij:\n")

for i in 1:n
    for j in 1:n
        print("$(xAux[i,j]) ")
    end
    println()
end


using JuMP, Cbc
A = [ –1   1  3; 1   3 –7]
b = [–5;  10]
c = [ 1  2  5]
(m, n) = size(A)
modelo = Model(with_optimizer(Cbc.Optimizer))
@variable(modelo, x[1:n] >= 0)
@objective(modelo, Max, sum(c[j]*x[j] for j=1:n))
@constraints modelo begin
    c1[i=1:m], sum(A[i,j]*x[j] for j=1:n) <= b[i]
    c2, x[1] <= 10
end
    
print(modelo)
optimize!(modelo)
println(“Função objetivo: ”, objective_value(modelo))
for j = 1:n
    println(“x[$j] = ”, value(x[j]))
end
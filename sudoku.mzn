include "all_different.mzn"; 

%definición de la matriz de entrada con valores fijos
array [1..9, 1..9] of var 1..9 : x;

%matriz de entrada (valores predefinidos donde 0 representa un valor vacío)
array [1..9, 1..9] of 0..9: input_grid;

%se fuerza a que las posiciones dadas en la entrada se mantengan
constraint forall(i in 1..9, j in 1..9) (
  input_grid[i, j] > 0 -> x[i, j] = input_grid[i, j]);

%restricción de filas
constraint forall (i in 1..9) (alldifferent(x[i, 1..9]));

%restricción de columnas
constraint forall (j in 1..9) (alldifferent(x[1..9, j]));

%restricción de bloques 3x3
constraint forall (i in 0..2, j in 0..2) (
  alldifferent([ x[3*i+k, 3*j+l] | k in 1..3, l in 1..3 ]));

%método de solución 1
solve satisfy;

%metodo de solución 2 (first_fail -> prioridad a la variable con menor dominio)
%solve :: int_search([x[i, j] | i in 1..9, j in 1..9], first_fail, indomain_min) satisfy;

%metodo de solución 3 (max_regret -> variable con la mayor diferencia entre los dos valores mas pequeños de su dominio)
%solve :: int_search([x[i, j] | i in 1..9, j in 1..9], max_regret, indomain_min) satisfy;

%se muestrá el tablero resultante
output [
  if j == 9 then
    show(x[i, j]) ++ "\n" 
  else
    show(x[i, j]) ++ " " 
  endif
  | i in 1..9, j in 1..9
];

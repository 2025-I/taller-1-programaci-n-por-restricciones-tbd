# Informe del taller: Taller 1: Modelamiento de CSP  
### Programación por restricciones
### Jorge Augusto Estacio (grupo tbd)  
## Punto 1: Modelado del Sudoku como un Problema de Satisfacción de Restricciones (CSP)
## Descripción del modelo CSP
### Variables
Cada celda en la cuadrícula es una variable representada como ```x[i, j]```, donde:
-  ```i``` indica la fila (1 a 9).
- ```j``` indica la columna (1 a 9).
- ```x[i, j]``` representa el número asignado a la celda.

### Dominios
Cada variable x[i, j] tiene un dominio de posibles valores:
- Si la celda está vacía, su dominio es ```{1,2,3,4,5,6,7,8,9}```.
- Si la celda tiene un número predefinido, su dominio es ese único número.

### Restricciones
Las restricciones del problema aseguran que no haya repeticiones en filas, columnas y bloques 3x3:

- **Restricción de filas:** Cada fila debe contener números únicos:
```
constraint forall (i in 1..9) (alldifferent(x[i, 1..9]));
```
- **Restricción de columnas:** Cada columna debe contener números únicos:
```
constraint forall (j in 1..9) (alldifferent(x[1..9, j]));
```
- **Restricción de bloques 3x3:** Cada bloque de 3x3 debe contener números únicos:
```
constraint forall (i in 0..2, j in 0..2) (
  alldifferent([ x[3*i+k, 3*j+l] | k in 1..3, l in 1..3 ]));
```
- **Restricción de valores iniciales:** Las celdas dadas en la entrada deben mantenerse fijas:
```
constraint forall(i in 1..9, j in 1..9) (
  input_grid[i, j] > 0 -> x[i, j] = input_grid[i, j]);
```
##  Implementación en MiniZinc
Teniendo en cuenta los parametors anterores, el código MiniZinc para resolver el Sudoku es el siguiente:
```
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
%solve satisfy;

%metodo de solución 2 (first_fail -> prioridad a la variable con menor dominio)
%solve :: int_search([x[i, j] | i in 1..9, j in 1..9], first_fail, indomain_min) satisfy;

%metodo de solución 3 (max_regret -> variable con la mayor diferencia entre los dos valores mas pequeños de su dominio)
solve :: int_search([x[i, j] | i in 1..9, j in 1..9], max_regret, indomain_min) satisfy;

%se muestrá el tablero resultante
output [
  if j == 9 then
    show(x[i, j]) ++ "\n" 
  else
    show(x[i, j]) ++ " " 
  endif
  | i in 1..9, j in 1..9
];

```
en conjunto con 3 archivos de entrada:
- tableroSudoku1.dzn (nivel intermedio)
- tableroSudoku2.dzn (nivel básico)
- tableroSudoku3.dzn (nivel avanzado)

## Estrategias de Distribución y Evaluación
En el caso de MiniZinc, este permite definir estrategias de distribución para mejorar la eficiencia en la búsqueda de soluciones. Se probaron tres enfoques:
##### Satisfy por defecto (sin estrategia explícita):
```
solve satisfy;
```
- **Ventaja:** Simplicidad
- **Desventaja**: Puede ser ineficiente en problemas mas complejos
##### Parametro first_fail (Estrategia de primero el menor):
```
solve :: int_search([x[i, j] | i in 1..9, j in 1..9], first_fail, indomain_min) satisfy;
```
- **Ventaja:** Reduce el espacio de búsqueda priorizando celdas con menos opciones.
- **Desventaja**: Posibilidad de mas demora en algunos tableros
##### Parametro max_regret (Estrategia de restricción aumentada):
```
solve :: int_search([x[i, j] | i in 1..9, j in 1..9], max_regret, indomain_min) satisfy;
```
- **Ventaja:**  Prioriza celdas con mayor impacto en restricciones.
- **Desventaja**: Mayor tiempo de procesamiento innecesario en tableros simples.
### Comparación de Resultados

| Estrategia            | Tiempo de Solución                 | Eficiencia |
| --------------------- | ---------------------------------- | ---------- |
| Default               | Lento en tableros difíciles        | Baja       |
| Primero el menor      | Rápido en la mayoría de casos      | Alta       |
| Restricción aumentada | Más eficiente en Sudokus difíciles | Media      |

### Comparativa con el modelo de solución con Gist
En este caso se hizo la prueba de solucionar el tablero No. 3 de dificultad avanzada, en lo cual nos dió los siguentes resultados:
- Estrategia default: Tiempo de solución de 2s 223msec.
![N|Solid](https://i.imgur.com/FVSeEvc.png)
- Esttrategia Primero el menor: Tiempo de solución de 364msec.
![N|Solid](https://i.imgur.com/mkGEe0o.png)
- Esttrategia Restricción aumentada: Tiempo de solución de 434msec.
![N|Solid](https://i.imgur.com/3ZTABYD.png)
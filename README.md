# CAFE_MACHINE

Descripción del circuito de una máquina de café que incluye ocho displays de siete segmentos.

## Funcionamiento

El precio del café es de 2 €, y la máquina acepta monedas de 0,50 €, 1 € y 2 €. El proceso de la dispensa de un café se lleva a cabo en los siguientes pasos:

 - La máquina inicialmente indica el precio del café en los displays.

 - El usuario pulsa el botón "Café" y luego introduce el dinero. Si se introduce el dinero antes de pulsar el botón, la máquina rechaza automáticamente cualquier moneda introducida sin mostrar mensaje alguno.

 - Conforme el usuario va introduciendo monedas, la máquina indica cuánto dinero se ha introducido. Si no se introduce ninguna moneda pasados 10 segundos desde ese momento, la máquina vuelve al estado inicial, mostrando el precio del café y siendo necesaria una nueva pulsación del botón Café.

 - A la vez que el usuario va introduciendo monedas, la máquina muestra el dinero total introducido. Cuando se hayan introducido 2 € o más, la máquina rechaza automáticamente cualquier moneda adicional introducida sin mostrar mensaje alguno, los displays parpadean durante 2 segundos indicando la cantidad de dinero total introducida y, en caso de haber vueltas, indica las vueltas totales durante 2 segundos y cada moneda devuelta, en mensajes que van cambiando cada 1 segundo.

 - Comienza la dispensa del café, hasta que finaliza volviendo la máquina al estado inicial tras 4 segundos.

 - Si el usuario pulsa el botón "Devolver" antes de que se hayan introducido 2 €, la máquina devuelve el dinero introducido indicando el dinero total devuelto y cada moneda devuelta de la misma forma que la indicada anteriormente, y luego vuelve al estado inicial.

 - Si un administrador pulsa en cualquier momento el botón "Reset", la máquina regresa al estado inicial pasados 3 segundos.

El circuito de la máquina de café se ha simulado empleando las siguientes entradas:

| Entrada | Descripción                               |
| ------- |------------------------------------------ |
| CLK     | Reloj interno del circuito                |
| NRST    | Reset, activo a nivel bajo                |
| cafe    | Botón "Café"                              |
| dev     | Botón "Devolver                           |
| i_50c   | Introducción de una moneda de 50 céntimos |
| i_1e    | Introducción de una moneda de 1 €         |
| i_2e    | Introducción de una moneda de 2 €         |

Para evitar que la introducción de una moneda cuente como más de una, ya sea porque un mecanismo detecta la moneda repetidas veces o símplemente existen rebotes, se ha aplicado un filtro que los elimina y genera un pulso de un único ciclo de reloj de duración en las señales internas o_50c, o_1e y o_2e.

Las salidas son las siguientes:

| Salidas  | Descripción                                                                                              |
| -------- | -------------------------------------------------------------------------------------------------------- |
| anodes   | Vector que contiene el ánodo común de cada display                                                       |
| cathodes | Vector que contiene los ánodos del display visualizado en cada momento                                   |
| coins    | Vector asociado a un color RGB que varía en función del estado en el que se encuentra la máquina de café |

Se cuenta con una máquina de estados, y esta a su vez una máquina de subestados

El circuito obedece a una máquina secuencial que obedece a una máquina de estados (se puede ver en el interior de la carpeta ``state_machine``) que cuenta con estados principales (los de la primera columna) y subestados (A0, A1, A2, A3, A4), dando lugar a los diferentes mensajes que puede mostrar la máquina de café con los ocho displays de siete segmentos (los de la segunda, tercera, cuarta y quinta columna).

| ESTADOS Y SUBESTADOS | A0        | A1              | A2            | A3           | COINS    | TIEMPO ENTRE SUBESTADOS |
| -------------------- | --------- | --------------- | ------------- | ------------ | -------- | ----------------------- |
| START_RESET          | CAFE 2E   | RESET! 3        | RESET! 2      | RESET! 1     | Azul     | 1 segundo               |
| CRE_000C             | CRE 0.00E | --------------- | ------------- |------------- | Amarillo | Siempre en A0           |
| CRE_050C             | CRE 0.50E | --------------- | ------------- |------------- | Amarillo | Siempre en A0           |
| CRE_100C             | CRE 1.00E | --------------- | ------------- |------------- | Amarillo | Siempre en A0           |
| CRE_150C             | CRE 1.50E | --------------- | ------------- |------------- | Amarillo | Siempre en A0           |
| CRE_200C             | CRE 2.00E |                 | CRE 2.00E     |              | Rojo     | 500 milisegundos        |
| CRE_250C             | CRE 2.50E |                 | CRE 2.50E     |              | Rojo     | 500 milisegundos        |
| CRE_300C             | CRE 3.00E |                 | CRE 3.00E     |              | Rojo     | 500 milisegundos        |
| CRE_350C             | CRE 3.50E |                 | CRE 3.50E     |              | Rojo     | 500 milisegundos        |
| DEV_050C_A           | DEV 0.50E | DEV 0.50E       | 0UD 1.00E     | 1UD 0.50E    | Rojo     | 1 segundo               |
| DEV_100C_A           | DEV 1.00E | DEV 1.00E       | 1UD 1.00E     | 0UD 0.50E    | Rojo     | 1 segundo               |
| DEV_150C_A           | DEV 1.50E | DEV 1.50E       | 1UD 1.00E     | 1UD 0.50E    | Rojo     | 1 segundo               |
| DEV_050C_B           | DEV 0.50E | DEV 0.50E       | 0UD 1.00E     | 1UD 0.50E    | Rojo     | 1 segundo               |
| DEV_100C_B           | DEV 1.00E | DEV 1.00E       | 1UD 1.00E     | 0UD 0.50E    | Rojo     | 1 segundo               |
| DEV_150C_B           | DEV 1.50E | DEV 1.50E       | 1UD 1.00E     | 1UD 0.50E    | Rojo     | 1 segundo               |
| WAIT_READY           | ESPERE 3  | ESPERE 2        | ESPERE 1      | ¡LISTO!      | Rojo     | 1 segundo               |

## Síntesis

Se ha usado Xilinx Vivado para realizar la síntesis del diseño, situado en la carpeta  ``design``.

## Simulación

Se adjunta un testbench y el resultado de una simulación de 30 segundos en la carpeta ``simulation``.

## Licencia

Este repositorio se distribuye bajo los términos de la licencia MIT, que se
encuentra en el archivo ``LICENSE.txt``.

# CAFE_MACHINE

Descripción del circuito de una máquina de café que incluye ocho displays de siete segmentos.

## Funcionamiento

El precio del café es de 2 €, y la máquina acepta monedas de 0,50 €, 1 € y 2 €. El proceso de la dispensa del café se lleva a cabo en los siguientes pasos:

 - La máquina inicialmente indica el precio del café en los displays.

 - El usuario pulsa el botón "Café" y luego introduce el dinero. Si se introducen monedas antes de pulsar el botón, la máquina las rechazará sin mostrar mensaje alguno. Si se pulsa el botón y no se introducen monedas en 10 segundos, la máquina regresará al estado inicial.

 - Conforme el usuario va introduciendo monedas, la máquina va indicando cuánto dinero se ha introducido.

 - Cuando se hayan introducido 2 € o más, la máquina rechazará automáticamente cualquier moneda adicional introducida sin mostrar mensaje alguno, los displays parpadearán durante 2 segundos indicando la cantidad de dinero introducida y, en caso de tener que dar vueltas, indicará las totales durante 2 segundos y luego la cantidad de cada tipo de moneda devuelta en mensajes que cambian cada 1 segundo.

 - Comienza la dispensa del café, hasta que finaliza regresando la máquina al estado inicial tras 4 segundos.

 - Si el usuario pulsa el botón "Devolver" antes de que se hayan introducido 2 €, la máquina devolverá el dinero introducido indicando el dinero total devuelto y cada moneda devuelta de la misma forma que la indicada anteriormente, y luego regresará al estado inicial.

 - Si un administrador de la máquina de café pulsa en cualquier momento el botón "Reset", la máquina regresará al estado inicial pasados 3 segundos.

El circuito de la máquina de café cuenta con las entradas que se muestran a continuación.

| Entrada | Descripción                               |
| ------- |------------------------------------------ |
| CLK     | Reloj interno del circuito                |
| NRST    | Botón "Reset", activo a nivel bajo        |
| cafe    | Botón "Café"                              |
| dev     | Botón "Devolver"                          |
| i_50c   | Introducción de una moneda de 50 céntimos |
| i_1e    | Introducción de una moneda de 1 €         |
| i_2e    | Introducción de una moneda de 2 €         |

Para evitar que la introducción de una moneda pueda contar como más de una, ya sea porque un mecanismo interno de la máquina de café pueda detectar la moneda repetidas veces o simplemente porque existen rebotes, se ha aplicado un filtro que los elimina y genera un pulso de un único ciclo de reloj de duración en las señales internas o_50c, o_1e y o_2e.

Se tienen a continuación las salidas del circuito de la máquina de café.

| Salidas  | Descripción                                                                                              |
| -------- | -------------------------------------------------------------------------------------------------------- |
| anodes   | Vector que contiene el ánodo común de cada display                                                       |
| cathodes | Vector que contiene los cátodos del display visualizado en cada momento                                  |
| coins    | Vector asociado a un color RGB que varía en función del estado en el que se encuentra la máquina de café |

El circuito obedece a una máquina de estados (se puede ver en el interior de la carpeta ``state_machine``) que cuenta con estados principales (los de la primera columna) que cambian al variar una entrada o una señal interna, y subestados (A0, A1, A2 y A3) que cambian pasado un tiempo (para ello se usan temporizadores que generan periódicamente un pulso de un único ciclo de reloj de duración), dando lugar a los diferentes mensajes (los de la segunda, tercera, cuarta y quinta columna) que puede mostrar la máquina de café con los ocho displays de siete segmentos (estos a su vez cuentan con una máquina de ocho estados, ya que los displays se multiplexan en el tiempo, cada 2 milisegundos, encendiendo uno solo en cada momento, pero haciendo que al ojo humano le parezca que todos están encendidos a la vez).

| ESTADOS     | A0        | A1          | A2          | A3          | COINS       | TIEMPO           |
| ----------- | --------- | ----------- | ----------- | ----------- | ----------- | ---------------- |
| START_RESET | CAFE 2E   | RESET! 3    | RESET! 2    | RESET! 1    | Azul        | 1 segundo        |
| CRE_000C    | CRE 0.00E | ----------- | ----------- | ----------- | Amarillo    | Siempre en A0    |
| CRE_050C    | CRE 0.50E | ----------- | ----------- | ----------- | Amarillo    | Siempre en A0    |
| CRE_100C    | CRE 1.00E | ----------- | ----------- | ----------- | Amarillo    | Siempre en A0    |
| CRE_150C    | CRE 1.50E | ----------- | ----------- | ----------- | Amarillo    | Siempre en A0    |
| CRE_200C    | CRE 2.00E |             | CRE 2.00E   |             | Rojo        | 500 milisegundos |
| CRE_250C    | CRE 2.50E |             | CRE 2.50E   |             | Rojo        | 500 milisegundos |
| CRE_300C    | CRE 3.00E |             | CRE 3.00E   |             | Rojo        | 500 milisegundos |
| CRE_350C    | CRE 3.50E |             | CRE 3.50E   |             | Rojo        | 500 milisegundos |
| DEV_050C_A  | DEV 0.50E | DEV 0.50E   | 0UD 1.00E   | 1UD 0.50E   | Rojo        | 1 segundo        |
| DEV_100C_A  | DEV 1.00E | DEV 1.00E   | 1UD 1.00E   | 0UD 0.50E   | Rojo        | 1 segundo        |
| DEV_150C_A  | DEV 1.50E | DEV 1.50E   | 1UD 1.00E   | 1UD 0.50E   | Rojo        | 1 segundo        |
| DEV_050C_B  | DEV 0.50E | DEV 0.50E   | 0UD 1.00E   | 1UD 0.50E   | Rojo        | 1 segundo        |
| DEV_100C_B  | DEV 1.00E | DEV 1.00E   | 1UD 1.00E   | 0UD 0.50E   | Rojo        | 1 segundo        |
| DEV_150C_B  | DEV 1.50E | DEV 1.50E   | 1UD 1.00E   | 1UD 0.50E   | Rojo        | 1 segundo        |
| WAIT_READY  | ESPERE 3  | ESPERE 2    | ESPERE 1    | ¡LISTO!     | Rojo        | 1 segundo        |

## Síntesis

Se ha usado Xilinx Vivado para realizar la síntesis del diseño, situado en el interior de la carpeta ``design``.

## Simulación

Se adjunta en el interior de la carpeta ``simulation`` un testbench y el resultado de una simulación de 30 segundos.

## Licencia

Este repositorio se distribuye bajo los términos de la licencia MIT, que se encuentra en el archivo ``LICENSE.txt``.

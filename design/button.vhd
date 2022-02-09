--------------------------------------------------------------------------------
-- BUTTON
--
-- - Subcircuito pulsador con un mecanismo antirrebotes que funciona generando
--   un pulso a nivel alto de un único ciclo de reloj de duración en la salida
--   "d_o" cuando se lee un nivel alto en la entrada "d_i", pero solo si se ha
--   leído en ella un nivel bajo en al menos las 6 últimas lecturas, teniendo en
--   cuenta que estas se realizan cuando se tiene un nivel alto en la entrada
--   "en", donde se han de leer periódicamente pulsos a nivel alto de un único
--   ciclo de reloj de duración, generados con un temporizador.
--
--------------------------------------------------------------------------------
-- Copyright (c) 2022 Jorge Botana Mtz. de Ibarreta
--
-- Este archivo se encuentra bajo los términos de la Licencia MIT. Debería
-- haberse proporcionado una copia de ella junto a este fichero. Si no es así,
-- se puede encontrar en el siguiente enlace:
--
--                                           https://opensource.org/licenses/MIT
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY button IS
	PORT(
		CLK  : IN  STD_LOGIC;
		NRST : IN  STD_LOGIC;
		en   : IN  STD_LOGIC;
		d_i  : IN  STD_LOGIC;
		d_o  : OUT STD_LOGIC
	);
END button;

ARCHITECTURE my_arch OF button IS

TYPE stages IS(
	S0, S1, S2, S3, S4, S5,
	READY, SHOT
);
SIGNAL curr_stage : stages := S0;
SIGNAL next_stage : stages := S0;

BEGIN

SYNCHRONIZATION:
PROCESS(CLK)
BEGIN
	IF(RISING_EDGE(CLK))THEN
		IF(NRST = '1')THEN
			curr_stage <= next_stage;
		ELSE
			curr_stage <= S0        ;
		END IF;
	END IF;
END PROCESS;

NEXT_STAGE_DECODE:
PROCESS(curr_stage, en, d_i)
BEGIN
	CASE curr_stage IS
		WHEN S0    =>
			IF(en = '1')THEN
				IF(d_i = '0')THEN
					next_stage <= S1        ;
				ELSE
					next_stage <= S0        ;
				END IF;
			ELSE
					next_stage <= curr_stage;
			END IF;
		WHEN S1    =>
			IF(en = '1')THEN
				IF(d_i = '0')THEN
					next_stage <= S2        ;
				ELSE
					next_stage <= S0        ;
				END IF;
			ELSE
					next_stage <= curr_stage;
			END IF;
		WHEN S2    =>
			IF(en = '1')THEN
				IF(d_i = '0')THEN
					next_stage <= S3        ;
				ELSE
					next_stage <= S0        ;
				END IF;
			ELSE
					next_stage <= curr_stage;
			END IF;
		WHEN S3    =>
			IF(en = '1')THEN
				IF(d_i = '0')THEN
					next_stage <= S4        ;
				ELSE
					next_stage <= S0        ;
				END IF;
			ELSE
					next_stage <= curr_stage;
			END IF;
		WHEN S4    =>
			IF(en = '1')THEN
				IF(d_i = '0')THEN
					next_stage <= S5        ;
				ELSE
					next_stage <= S0        ;
				END IF;
			ELSE
					next_stage <= curr_stage;
			END IF;
		WHEN S5    =>
			IF(en = '1')THEN
				IF(d_i = '0')THEN
					next_stage <= READY     ;
				ELSE
					next_stage <= S0        ;
				END IF;
			ELSE
					next_stage <= curr_stage;
			END IF;
		WHEN READY =>
			IF(en = '1')THEN
				IF(d_i = '1')THEN
					next_stage <= SHOT      ;
				ELSE
					next_stage <= curr_stage;
				END IF;
			ELSE
					next_stage <= curr_stage;
			END IF;
		WHEN SHOT  =>
					next_stage <= S0        ;
	END CASE;
END PROCESS;

OUTPUT_DECODE:
WITH curr_stage SELECT
	d_o  <= '1' WHEN SHOT  ,
	        '0' WHEN OTHERS;

END my_arch;

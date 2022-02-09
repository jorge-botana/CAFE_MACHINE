--------------------------------------------------------------------------------
-- TIMER
--
-- - Subcircuito temporizador que genera periódicamente un pulso a nivel alto de
--   un único ciclo de reloj de duración en la salida "d_o", mientras se lea un
--   nivel alto en la entrada "d_i".
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

ENTITY timer IS
	GENERIC(
		freq_MHz : INTEGER;
		delay_ms : INTEGER
	);
	PORT(
		CLK  : IN  STD_LOGIC;
		NRST : IN  STD_LOGIC;
		d_i  : IN  STD_LOGIC;
		d_o  : OUT STD_LOGIC
	);
END timer;

ARCHITECTURE my_arch OF timer IS

SIGNAL ctrl    : INTEGER :=                              0;
SIGNAL timeout : INTEGER := delay_ms * 1000 * freq_MHz - 1;

BEGIN

TIMING:
PROCESS(CLK)
BEGIN
	IF(RISING_EDGE(CLK))THEN
		IF(NRST = '1')THEN
			IF(d_i = '1')THEN
				IF(ctrl = timeout)THEN
					ctrl <=        0;
				ELSE
					ctrl <= ctrl + 1;
				END IF;
			ELSE
					ctrl <=        0;
			END IF;
		ELSE
					ctrl <=        0;
		END IF;
	END IF;
END PROCESS;
d_o <= '1' WHEN ctrl = timeout ELSE '0';

END my_arch;

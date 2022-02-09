--------------------------------------------------------------------------------
-- TESTBENCH
--
-- - Simulación del circuito de la máquina de café.
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

ENTITY testbench IS

END testbench;

ARCHITECTURE my_arch OF testbench IS

COMPONENT cafe_machine IS
	PORT(
		CLK      : IN  STD_LOGIC                   ;
		NRST     : IN  STD_LOGIC                   ;
		cafe     : IN  STD_LOGIC                   ;
		dev      : IN  STD_LOGIC                   ;
		i_50c    : IN  STD_LOGIC                   ;
		i_1e     : IN  STD_LOGIC                   ;
		i_2e     : IN  STD_LOGIC                   ;
		anodes   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		cathodes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		coins    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END COMPONENT;

CONSTANT period                            : TIME      :=           10 ns;

SIGNAL   CLK, cafe, dev, i_50c, i_1e, i_2e : STD_LOGIC :=             '0';
SIGNAL   NRST                              : STD_LOGIC :=             '1';
SIGNAL   anodes, cathodes                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL   coins                             : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

m_sim: cafe_machine
PORT MAP(
	CLK      => CLK     ,
	NRST     => NRST    ,
	cafe     => cafe    ,
	dev      => dev     ,
	i_50c    => i_50c   ,
	i_1e     => i_1e    ,
	i_2e     => i_2e    ,
	anodes   => anodes  ,
	cathodes => cathodes,
	coins    => coins
);

CLOCK:
PROCESS
BEGIN
	CLK <= '0';
	WAIT FOR period / 2;
	CLK <= '1';
	WAIT FOR period / 2;
END PROCESS;

STIMULUS:
PROCESS
BEGIN

	WAIT FOR  1 sec ;

						cafe  <= '1';
	WAIT FOR 500 ms ;
						cafe  <= '0';

	WAIT FOR  1 sec ;

						i_50c <= '1';
	WAIT FOR  10 ms ;
						i_50c <= '0';
	WAIT FOR  10 ms ;
						i_50c <= '1';
	WAIT FOR 460 ms ;
						i_50c <= '0';
	WAIT FOR  10 ms ;
						i_50c <= '1';
	WAIT FOR  10 ms ;
						i_50c <= '0';

	WAIT FOR   1 sec;

						i_2e  <= '1';
	WAIT FOR  10 ms ;
						i_2e  <= '0';
	WAIT FOR  10 ms ;
						i_2e  <= '1';
	WAIT FOR 460 ms ;
						i_2e  <= '0';
	WAIT FOR  10 ms ;
						i_2e  <= '1';
	WAIT FOR  10 ms ;
						i_2e  <= '0';

	WAIT FOR  10 sec;

						cafe  <= '1';
	WAIT FOR 500 ms ;
						cafe  <= '0';

	WAIT FOR  10 sec;

						cafe  <= '1';
	WAIT FOR 500 ms ;
						cafe  <= '0';

	WAIT FOR   1 sec;

						i_1e  <= '1';
	WAIT FOR  10 ms ;
						i_1e  <= '0';
	WAIT FOR  10 ms ;
						i_1e  <= '1';
	WAIT FOR 460 ms ;
						i_1e  <= '0';
	WAIT FOR  10 ms ;
						i_1e  <= '1';
	WAIT FOR  10 ms ;
						i_1e  <= '0';

	WAIT FOR   1 sec;

						dev   <= '1';
	WAIT FOR 500 ms ;
						dev   <= '0';

	WAIT FOR   1 sec;

						NRST  <= '0';
	WAIT FOR 500 ms ;
						NRST  <= '1';

	WAIT            ;

END PROCESS;

END my_arch;

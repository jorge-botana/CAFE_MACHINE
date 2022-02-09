--------------------------------------------------------------------------------
-- CAFE_MACHINE
--
-- - Circuito de la máquina de café.
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

ENTITY cafe_machine IS
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
END cafe_machine ;

ARCHITECTURE my_arch OF cafe_machine IS

COMPONENT button IS
	PORT(
		CLK  : IN  STD_LOGIC;
		NRST : IN  STD_LOGIC;
		en   : IN  STD_LOGIC;
		d_i  : IN  STD_LOGIC;
		d_o  : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT timer IS
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
END COMPONENT;

CONSTANT char_blank   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111";

CONSTANT char_exc     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01111101";
CONSTANT char_inv_exc : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111011";

CONSTANT char_0       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11000000";
CONSTANT char_0_dot   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000000";
CONSTANT char_1       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111001";
CONSTANT char_1_dot   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01111001";
CONSTANT char_2       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10100100";
CONSTANT char_2_dot   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00100100";
CONSTANT char_3       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10110000";
CONSTANT char_3_dot   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110000";
CONSTANT char_5       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10010010";

CONSTANT char_A       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10001000";
CONSTANT char_C       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11000110";
CONSTANT char_D       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10100001";
CONSTANT char_E       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10000110";
CONSTANT char_F       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10001110";
CONSTANT char_I       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001111";
CONSTANT char_L       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11000111";
CONSTANT char_P       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10001100";
CONSTANT char_R       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001100";
CONSTANT char_S       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10010010";
CONSTANT char_T       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10000111";
CONSTANT char_U       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11000001";
CONSTANT char_V       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11010001";

CONSTANT freq_MHz     : INTEGER                      :=        100;

CONSTANT t_2ms        : INTEGER                      :=          2;
CONSTANT t_500ms      : INTEGER                      :=        500;
CONSTANT t_1000ms     : INTEGER                      :=       1000;
CONSTANT t_2000ms     : INTEGER                      :=       2000;
CONSTANT t_4000ms     : INTEGER                      :=       4000;
CONSTANT t_10000ms    : INTEGER                      :=      10000;

SIGNAL   i_2ms        : STD_LOGIC                    :=        '1';
SIGNAL   o_2ms        : STD_LOGIC                    :=        '0';

SIGNAL   i_500ms      : STD_LOGIC                    :=        '0';
SIGNAL   o_500ms      : STD_LOGIC                    :=        '0';

SIGNAL   i_1000ms     : STD_LOGIC                    :=        '0';
SIGNAL   o_1000ms     : STD_LOGIC                    :=        '0';

SIGNAL   i_2000ms     : STD_LOGIC                    :=        '0';
SIGNAL   o_2000ms     : STD_LOGIC                    :=        '0';

SIGNAL   i_4000ms     : STD_LOGIC                    :=        '0';
SIGNAL   o_4000ms     : STD_LOGIC                    :=        '0';

SIGNAL   i_10000ms    : STD_LOGIC                    :=        '0';
SIGNAL   o_10000ms    : STD_LOGIC                    :=        '0';

SIGNAL   o_50c        : STD_LOGIC                    :=        '0';
SIGNAL   o_1e         : STD_LOGIC                    :=        '0';
SIGNAL   o_2e         : STD_LOGIC                    :=        '0';

TYPE main_states IS(
	START_RESET, CRE_000C  , CRE_050C  ,  CRE_100C  ,
	CRE_150C   , CRE_200C  , CRE_250C  ,  CRE_300C  ,
	CRE_350C   , DEV_050C_A, DEV_100C_A,  DEV_150C_A,
	DEV_050C_B , DEV_100C_B, DEV_150C_B,  WAIT_READY
);
SIGNAL curr_main_state : main_states := START_RESET;
SIGNAL next_main_state : main_states := START_RESET;

TYPE sub_states IS(
	A0, A1, A2, A3
);
SIGNAL curr_sub_state : sub_states := A0;
SIGNAL next_sub_state : sub_states := A0;

TYPE displays IS(
	D0, D1, D2, D3,
	D4, D5, D6, D7
);
SIGNAL curr_display : displays := D0;
SIGNAL next_display : displays := D0;

BEGIN

m_50c: button
PORT MAP(
	CLK  => CLK  ,
	NRST => NRST ,
	en   => o_2ms,
	d_i  => i_50c,
	d_o  => o_50c
);

m_1e: button
PORT MAP(
	CLK  => CLK  ,
	NRST => NRST ,
	en   => o_2ms,
	d_i  => i_1e ,
	d_o  => o_1e
);

m_2e: button
PORT MAP(
	CLK  => CLK  ,
	NRST => NRST ,
	en   => o_2ms,
	d_i  => i_2e ,
	d_o  => o_2e
);

m_2ms: timer
GENERIC MAP(
	freq_MHz => freq_MHz,
	delay_ms => t_2ms
)
PORT MAP(
	CLK  => CLK  ,
	NRST => NRST ,
	d_i  => i_2ms,
	d_o  => o_2ms
);

m_500ms: timer
GENERIC MAP(
	freq_MHz => freq_MHz,
	delay_ms => t_500ms
)
PORT MAP(
	CLK  => CLK    ,
	NRST => NRST   ,
	d_i  => i_500ms,
	d_o  => o_500ms
);
WITH curr_main_state SELECT
	i_500ms  <= '1' WHEN CRE_200C | CRE_250C | CRE_300C | CRE_350C,
	            '0' WHEN OTHERS;

m_1000ms: timer
GENERIC MAP(
	freq_MHz => freq_MHz,
	delay_ms => t_1000ms
)
PORT MAP(
	CLK  => CLK     ,
	NRST => NRST    ,
	d_i  => i_1000ms,
	d_o  => o_1000ms
);
WITH curr_main_state SELECT
	i_1000ms  <= '1' WHEN START_RESET | DEV_050C_A | DEV_050C_B | DEV_100C_A |
	                      DEV_100C_B  | DEV_150C_A | DEV_150C_B | WAIT_READY,
	             '0' WHEN OTHERS;

m_2000ms: timer
GENERIC MAP(
	freq_MHz => freq_MHz,
	delay_ms => t_2000ms
)
PORT MAP(
	CLK  => CLK     ,
	NRST => NRST    ,
	d_i  => i_2000ms,
	d_o  => o_2000ms
);
WITH curr_main_state SELECT
	i_2000ms  <= '1' WHEN CRE_200C | CRE_250C | CRE_300C | CRE_350C,
	             '0' WHEN OTHERS;

m_4000ms: timer
GENERIC MAP(
	freq_MHz => freq_MHz,
	delay_ms => t_4000ms
)
PORT MAP(
	CLK  => CLK     ,
	NRST => NRST    ,
	d_i  => i_4000ms,
	d_o  => o_4000ms
);
WITH curr_main_state SELECT
	i_4000ms  <= '1' WHEN DEV_050C_A | DEV_050C_B | DEV_100C_A | DEV_100C_B |
	                      DEV_150C_A | DEV_150C_B | WAIT_READY,
	             '0' WHEN OTHERS;

m_10000ms: timer
GENERIC MAP(
	freq_MHz => freq_MHz,
	delay_ms => t_10000ms
)
PORT MAP(
	CLK  => CLK      ,
	NRST => NRST     ,
	d_i  => i_10000ms,
	d_o  => o_10000ms
);
WITH curr_main_state SELECT
	i_10000ms <= '1' WHEN CRE_000C,
	             '0' WHEN OTHERS;

SYNCHRONIZATION:
PROCESS(CLK)
BEGIN
	IF(RISING_EDGE(CLK))THEN
		IF(NRST  = '1')THEN
				curr_main_state <= next_main_state;
				curr_sub_state  <= next_sub_state ;
			IF(o_2ms = '1')THEN
				curr_display    <= next_display   ;
			END IF;
		ELSE
				curr_main_state <= START_RESET    ;
				curr_sub_state  <= A1             ;
				curr_display    <= D0             ;
		END IF;
	END IF;
END PROCESS;

NEXT_MAIN_STATE_DECODE:
PROCESS(curr_main_state, curr_sub_state, cafe, dev,
        o_50c, o_1e, o_2e, o_2000ms, o_4000ms, o_10000ms)
BEGIN
	CASE curr_main_state IS
		WHEN START_RESET                          =>
			CASE curr_sub_state IS
				WHEN A0     =>
					IF   (cafe      = '1')THEN
						next_main_state <= CRE_000C       ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
				WHEN OTHERS =>
						next_main_state <= curr_main_state;
			END CASE;
		WHEN CRE_000C                             =>
					IF   (o_50c     = '1')THEN
						next_main_state <= CRE_050C       ;
					ELSIF(o_1e      = '1')THEN
						next_main_state <= CRE_100C       ;
					ELSIF(o_2e      = '1')THEN
						next_main_state <= CRE_200C       ;
					ELSIF(o_10000ms = '1')THEN
						next_main_state <= START_RESET    ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN CRE_050C                             =>
					IF   (o_50c     = '1')THEN
						next_main_state <= CRE_100C       ;
					ELSIF(o_1e      = '1')THEN
						next_main_state <= CRE_150C       ;
					ELSIF(o_2e      = '1')THEN
						next_main_state <= CRE_250C       ;
					ELSIF(dev       = '1')THEN
						next_main_state <= DEV_050C_A     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN CRE_100C                             =>
					IF   (o_50c     = '1')THEN
						next_main_state <= CRE_150C       ;
					ELSIF(o_1e      = '1')THEN
						next_main_state <= CRE_200C       ;
					ELSIF(o_2e      = '1')THEN
						next_main_state <= CRE_300C       ;
					ELSIF(dev       = '1')THEN
						next_main_state <= DEV_100C_A     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN CRE_150C                             =>
					IF   (o_50c     = '1')THEN
						next_main_state <= CRE_200C       ;
					ELSIF(o_1e      = '1')THEN
						next_main_state <= CRE_250C       ;
					ELSIF(o_2e      = '1')THEN
						next_main_state <= CRE_350C       ;
					ELSIF(dev       = '1')THEN
						next_main_state <= DEV_150C_A     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN CRE_200C                             =>
					IF   (o_2000ms  = '1')THEN
						next_main_state <= WAIT_READY     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN CRE_250C                             =>
					IF   (o_2000ms  = '1')THEN
						next_main_state <= DEV_050C_B     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN CRE_300C                             =>
					IF   (o_2000ms  = '1')THEN
						next_main_state <= DEV_100C_B     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN CRE_350C                             =>
					IF   (o_2000ms  = '1')THEN
						next_main_state <= DEV_150C_B     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN DEV_050C_A | DEV_100C_A | DEV_150C_A =>
					IF   (o_4000ms  = '1')THEN
						next_main_state <= START_RESET    ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN DEV_050C_B | DEV_100C_B | DEV_150C_B =>
					IF   (o_4000ms  = '1')THEN
						next_main_state <= WAIT_READY     ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
		WHEN WAIT_READY                           =>
					IF   (o_4000ms  = '1')THEN
						next_main_state <= START_RESET    ;
					ELSE
						next_main_state <= curr_main_state;
					END IF;
	END CASE;
END PROCESS;

NEXT_SUB_STATE_DECODE:
PROCESS(curr_main_state, curr_sub_state, o_500ms, o_1000ms)
BEGIN
	CASE curr_main_state IS
		WHEN START_RESET                               =>
			CASE curr_sub_state IS
				WHEN A0 =>
						next_sub_state  <= curr_sub_state;
				WHEN A1 =>
					IF(o_1000ms = '1')THEN
						next_sub_state  <= A2            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A2 =>
					IF(o_1000ms = '1')THEN
						next_sub_state  <= A3            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A3 =>
					IF(o_1000ms = '1')THEN
						next_sub_state  <= A0            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
			END CASE;
		WHEN CRE_200C | CRE_250C | CRE_300C | CRE_350C =>
			CASE curr_sub_state IS
				WHEN A0 =>
					IF(o_500ms = '1')THEN
						next_sub_state  <= A1            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A1 =>
					IF(o_500ms = '1')THEN
						next_sub_state  <= A2            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A2 =>
					IF(o_500ms = '1')THEN
						next_sub_state  <= A3            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A3 =>
					IF(o_500ms = '1')THEN
						next_sub_state  <= A0            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
			END CASE;
		WHEN DEV_050C_A | DEV_050C_B | DEV_100C_A | DEV_100C_B |
		     DEV_150C_A | DEV_150C_B | WAIT_READY      =>
			CASE curr_sub_state IS
				WHEN A0 =>
					IF(o_1000ms = '1')THEN
						next_sub_state  <= A1            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A1 =>
					IF(o_1000ms = '1')THEN
						next_sub_state  <= A2            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A2 =>
					IF(o_1000ms = '1')THEN
						next_sub_state  <= A3            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
				WHEN A3 =>
					IF(o_1000ms = '1')THEN
						next_sub_state  <= A0            ;
					ELSE
						next_sub_state  <= curr_sub_state;
					END IF;
			END CASE;
		WHEN OTHERS                                    =>
						next_sub_state  <= A0            ;
	END CASE;
END PROCESS;

NEXT_DISPLAY_DECODE:
WITH curr_display SELECT
	next_display <= D1 WHEN D0,
	                D2 WHEN D1,
	                D3 WHEN D2,
	                D4 WHEN D3,
	                D5 WHEN D4,
	                D6 WHEN D5,
	                D7 WHEN D6,
	                D0 WHEN D7;

OUTPUT_DECODE:
PROCESS(curr_main_state, curr_sub_state, curr_display, NRST)
BEGIN
	CASE curr_main_state IS
		WHEN START_RESET             =>
			CASE curr_sub_state IS
				WHEN A0      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_A      ;
						WHEN D2 => cathodes <= char_F      ;
						WHEN D3 => cathodes <= char_E      ;
						WHEN D4 => cathodes <= char_blank  ;
						WHEN D5 => cathodes <= char_blank  ;
						WHEN D6 => cathodes <= char_2      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A1      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_R      ;
						WHEN D1 => cathodes <= char_E      ;
						WHEN D2 => cathodes <= char_S      ;
						WHEN D3 => cathodes <= char_E      ;
						WHEN D4 => cathodes <= char_T      ;
						WHEN D5 => cathodes <= char_exc    ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_3      ;
					END CASE;
				WHEN A2      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_R      ;
						WHEN D1 => cathodes <= char_E      ;
						WHEN D2 => cathodes <= char_S      ;
						WHEN D3 => cathodes <= char_E      ;
						WHEN D4 => cathodes <= char_T      ;
						WHEN D5 => cathodes <= char_exc    ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_2      ;
					END CASE;
				WHEN A3      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_R      ;
						WHEN D1 => cathodes <= char_E      ;
						WHEN D2 => cathodes <= char_S      ;
						WHEN D3 => cathodes <= char_E      ;
						WHEN D4 => cathodes <= char_T      ;
						WHEN D5 => cathodes <= char_exc    ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_1      ;
					END CASE;
			END CASE;
		WHEN CRE_000C                =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_0_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
		WHEN CRE_050C                =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_0_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
		WHEN CRE_100C                =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_1_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
		WHEN CRE_150C                =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_1_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
		WHEN CRE_200C                =>
			CASE curr_sub_state IS
				WHEN A0 | A2 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_2_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A1 | A3 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_blank  ;
						WHEN D1 => cathodes <= char_blank  ;
						WHEN D2 => cathodes <= char_blank  ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_blank  ;
						WHEN D5 => cathodes <= char_blank  ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_blank  ;
					END CASE;
			END CASE;
		WHEN CRE_250C                =>
			CASE curr_sub_state IS
				WHEN A0 | A2 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_2_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A1 | A3 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_blank  ;
						WHEN D1 => cathodes <= char_blank  ;
						WHEN D2 => cathodes <= char_blank  ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_blank  ;
						WHEN D5 => cathodes <= char_blank  ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_blank  ;
					END CASE;
			END CASE;
		WHEN CRE_300C                =>
			CASE curr_sub_state IS
				WHEN A0 | A2 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_3_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A1 | A3 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_blank  ;
						WHEN D1 => cathodes <= char_blank  ;
						WHEN D2 => cathodes <= char_blank  ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_blank  ;
						WHEN D5 => cathodes <= char_blank  ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_blank  ;
					END CASE;
			END CASE;
		WHEN CRE_350C                =>
			CASE curr_sub_state IS
				WHEN A0 | A2 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_C      ;
						WHEN D1 => cathodes <= char_R      ;
						WHEN D2 => cathodes <= char_E      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_3_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A1 | A3 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_blank  ;
						WHEN D1 => cathodes <= char_blank  ;
						WHEN D2 => cathodes <= char_blank  ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_blank  ;
						WHEN D5 => cathodes <= char_blank  ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_blank  ;
					END CASE;
			END CASE;
		WHEN DEV_050C_A | DEV_050C_B =>
			CASE curr_sub_state IS
				WHEN A0 | A1 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_D      ;
						WHEN D1 => cathodes <= char_E      ;
						WHEN D2 => cathodes <= char_V      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_0_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A2      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_0      ;
						WHEN D1 => cathodes <= char_U      ;
						WHEN D2 => cathodes <= char_D      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_1_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A3      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_1      ;
						WHEN D1 => cathodes <= char_U      ;
						WHEN D2 => cathodes <= char_D      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_0_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
			END CASE;
		WHEN DEV_100C_A | DEV_100C_B =>
			CASE curr_sub_state IS
				WHEN A0 | A1 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_D      ;
						WHEN D1 => cathodes <= char_E      ;
						WHEN D2 => cathodes <= char_V      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_1_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A2      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_1      ;
						WHEN D1 => cathodes <= char_U      ;
						WHEN D2 => cathodes <= char_D      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_1_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A3      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_0      ;
						WHEN D1 => cathodes <= char_U      ;
						WHEN D2 => cathodes <= char_D      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_0_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
			END CASE;
		WHEN DEV_150C_A | DEV_150C_B =>
			CASE curr_sub_state IS
				WHEN A0 | A1 =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_D      ;
						WHEN D1 => cathodes <= char_E      ;
						WHEN D2 => cathodes <= char_V      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_1_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A2      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_1      ;
						WHEN D1 => cathodes <= char_U      ;
						WHEN D2 => cathodes <= char_D      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_1_dot  ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
				WHEN A3      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_1      ;
						WHEN D1 => cathodes <= char_U      ;
						WHEN D2 => cathodes <= char_D      ;
						WHEN D3 => cathodes <= char_blank  ;
						WHEN D4 => cathodes <= char_0_dot  ;
						WHEN D5 => cathodes <= char_5      ;
						WHEN D6 => cathodes <= char_0      ;
						WHEN D7 => cathodes <= char_E      ;
					END CASE;
			END CASE;
		WHEN WAIT_READY              =>
			CASE curr_sub_state IS
				WHEN A0      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_E      ;
						WHEN D1 => cathodes <= char_S      ;
						WHEN D2 => cathodes <= char_P      ;
						WHEN D3 => cathodes <= char_E      ;
						WHEN D4 => cathodes <= char_R      ;
						WHEN D5 => cathodes <= char_E      ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_3      ;
					END CASE;
				WHEN A1      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_E      ;
						WHEN D1 => cathodes <= char_S      ;
						WHEN D2 => cathodes <= char_P      ;
						WHEN D3 => cathodes <= char_E      ;
						WHEN D4 => cathodes <= char_R      ;
						WHEN D5 => cathodes <= char_E      ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_2      ;
					END CASE;
				WHEN A2      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_E      ;
						WHEN D1 => cathodes <= char_S      ;
						WHEN D2 => cathodes <= char_P      ;
						WHEN D3 => cathodes <= char_E      ;
						WHEN D4 => cathodes <= char_R      ;
						WHEN D5 => cathodes <= char_E      ;
						WHEN D6 => cathodes <= char_blank  ;
						WHEN D7 => cathodes <= char_1      ;
					END CASE;
				WHEN A3      =>
					CASE curr_display IS
						WHEN D0 => cathodes <= char_inv_exc;
						WHEN D1 => cathodes <= char_L      ;
						WHEN D2 => cathodes <= char_I      ;
						WHEN D3 => cathodes <= char_S      ;
						WHEN D4 => cathodes <= char_T      ;
						WHEN D5 => cathodes <= char_0      ;
						WHEN D6 => cathodes <= char_exc    ;
						WHEN D7 => cathodes <= char_blank  ;
					END CASE;
			END CASE;
	END CASE;
END PROCESS;
WITH curr_main_state SELECT
	coins <= "001" WHEN START_RESET                              ,
	         "110" WHEN CRE_000C | CRE_050C | CRE_100C | CRE_150C,
	         "100" WHEN OTHERS                                   ;
WITH curr_display SELECT
	anodes <= "01111111" WHEN D0,
	          "10111111" WHEN D1,
	          "11011111" WHEN D2,
	          "11101111" WHEN D3,
	          "11110111" WHEN D4,
	          "11111011" WHEN D5,
	          "11111101" WHEN D6,
	          "11111110" WHEN D7;

END my_arch;

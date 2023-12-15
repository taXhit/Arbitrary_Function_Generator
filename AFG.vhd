-- integrates all the different components together and loops through the lookup table to generate the desired waveform.

library work;
use work.pkg.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity AFG is
	port (Rx,clk, reset : in std_logic;
			outp : out std_logic_vector (7 downto 0));
end entity AFG;

architecture bhv of AFG is
	component clkdiv is
		port (clk_out : out std_logic;
				lim : in integer;
				clk_50, resetn : in std_logic);
	end component;

	component store_lt is
		port(str_in : in std_logic_vector(7 downto 0);
		clk,reset : in std_logic; 
		lt : buffer arr;
		count : out integer; 
		state: out std_logic);
	end component;
	
	component MB is
		port( Rx:in std_logic;
		clk_50M:in std_logic; 
		reset1:in std_logic;
		LED: out std_logic_vector(7 downto 0);
		resetin: out std_logic);
	end component;
	signal clk_inter, pulse, state: std_logic;
	signal data_bytes: std_logic_vector(7 downto 0);
	signal count: integer;
	signal lut: arr;
	
begin
	MB1: MB
		port map(clk_50M=>clk,reset1=>reset,LED=>data_bytes,resetin=>pulse, Rx=>Rx);
	storelt: store_lt 
		port map(str_in=>data_bytes, clk=>pulse, lt=>lut, count=>count, state=>state,reset=>reset);
	clk1div: clkdiv 
		port map (clk_50 => clk, Resetn => reset, lim => count, Clk_out => clk_inter);
		
	lookuptable : process(clk_inter,state)
		variable cnt : integer := 0;
	begin
		if (clk_inter = '1' and clk_inter'event) then
			if(reset = '0') then
				if(cnt < 23) then
					cnt := cnt + 1;
				else 
					cnt := 0;
				end if;
			else
				cnt := 0;
			end if;
		end if;
		outp <= lut(cnt);
	end process lookuptable;
end bhv;

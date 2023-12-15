library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pkg is
  type arr is array (23 downto 0) of std_logic_vector (7 downto 0);
  type freq_arr is array (3 downto 0) of std_logic_vector (7 downto 0);
end package;

--package body pkg is
--end package body;


library work;
use work.pkg.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity store_lt is
	port(str_in : in std_logic_vector(7 downto 0);
		clk,reset : in std_logic; 
		lt : buffer arr;
		count : out integer; 
		state: out std_logic );
end entity store_lt;


architecture sarch of store_lt is
	signal i : INTEGER := 0;
	--signal count_temp : INTEGER := 0;
	signal lt_temp : arr:=(others=>"00000000");
	signal flt_temp : freq_arr:=(others=>"00000000");
	signal yu: std_logic_vector(31 downto 0);
	
	signal state1 : std_logic := '0';
begin
	p1:process(clk,reset,state1)
	begin	
	if (reset='1') then
		lt<=(others=>"00000000");
		lt_temp<=(others=>"00000000");
		flt_temp<=(others=>"00000000");
		state1<='0';
	else
		if(clk'event and clk='1'and state1='0') then
			if (i<24) then
				lt_temp(i)<=str_in;
			elsif (i=28) then
				yu<= flt_temp(3) & flt_temp(2) & flt_temp(1) & flt_temp(0);
				--count<=to_integer(unsigned(yu));
				lt<=lt_temp;
				state1<='1';
			else
				flt_temp(27-i)<=str_in;
			end if;
			i<=i+1;
		end if;
		end if;
	end process;
	count<=to_integer(unsigned(yu));
	state<=state1;
end sarch;


			
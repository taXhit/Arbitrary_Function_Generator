
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY clkdiv is
port (clk_out : out std_logic;
		lim : in integer;
		clk_50, resetn : in std_logic);
end ENTITY;

ARCHITECTURE rch OF clkdiv is
signal out_ck : std_logic := '0';
begin
process(clk_50,resetn)
variable count : integer := 0;
begin
if (resetn='1') then
	count := 1;
	out_ck <= '0';
else
	if(clk_50 = '1' and clk_50'event) then
		if ((count)<lim) then
			count := count+1;
		else
			out_ck <= not out_ck;
			count := 1;
		end if;
	end if;
end if;
end process;
clk_out <= out_ck;
end rch;
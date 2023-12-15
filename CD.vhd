library ieee;
use ieee.std_logic_1164.all;
entity CD is
port (
clk_50M,reset:in std_logic;
clk_out1:buffer Std_logic
) ;
end CD;
architecture a1 of CD is
signal num:integer:=0;
begin

divider1 : process(clk_50M,reset)
variable count1:integer:=1;

begin

if (reset='1') then
	clk_out1<='0';
else
	if (clk_50M='1' and clk_50M'event) then
		count1:=count1+1;

		if (count1>652) then --50megaHz/4*9600
		clk_out1<=not(clk_out1);
		count1:=1;
		end if;
	end if;
end if;
end process; 


end a1 ; 
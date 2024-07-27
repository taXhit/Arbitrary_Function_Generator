-- Converting the bit-by-bit data transmitted by UART into bytes

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MB is
port( Rx:in std_logic; clk_50M:in std_logic; reset1:in std_logic; LED: out std_logic_vector(7 downto 0);resetin: out std_logic);
end MB;

architecture bhv of MB is
component CD is
	port (
clk_50M,reset:in std_logic;
clk_out1:buffer Std_logic
) ;
end component;
signal sampler:integer range 0 to 1:=0;
signal clk_sampler:std_logic;
signal Data : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
signal bit_count : integer range 0 to 9 := 0;
signal reset:std_logic:='0';
begin

CD1: CD port map(clk_50M=>clk_50M,clk_out1=>clk_sampler,reset=>reset1);
process(clk_sampler,Rx,reset1,reset)
begin
if (reset1='1') then
	sampler<=0;
	for i in 0 to 9 loop 
	Data(i)<='0';
	end loop;
	bit_count<=0;
	LED<=Data(8 downto 1);
else
if (reset='1') then
	sampler<=0;
	for i in 0 to 9 loop 
	Data(i)<='0';
	end loop;
	bit_count<=0;
	reset<='0' after 10us;
	
else
	if (clk_sampler'event and clk_sampler='1') then
		if (Rx='0' and sampler=0 and bit_count=0) then
			sampler<=1;
		elsif(sampler=1 and bit_count<9) then
			Data(bit_count)<=Rx;
			bit_count<=bit_count+1;
			sampler<=0;
		elsif (bit_count = 9) then
			LED<=Data(8 downto 1);
			reset<='1';
		elsif(sampler=0 and bit_count>0 and bit_count<9) then
			sampler<=1;
		end if;
	end if;
end if;
end if;
end process;
resetin<=reset;
end bhv;

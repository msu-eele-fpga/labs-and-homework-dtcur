library ieee;
use ieee.std_logic_1164.all;


entity one_pulse is
	port ( 
		clk	: in std_ulogic;
		rst	: in std_ulogic;
		input	: in std_ulogic;
		pulse	: out std_ulogic
	);
end entity one_pulse;


architecture pulse of one_pulse is
	-- Create internal latching signal for when no more inputs are allowed
	signal Latch : std_ulogic := '0';
	
begin
	pulse_control : process (clk, rst, input)
	begin
		if rising_edge(clk) then
			if latch = '0' and input = '1' then 
				pulse <= '1'; 
				latch <= '1';
			elsif latch = '1' then
				pulse  <= '0';
			elsif input = '0' then 
				latch <= '0';
				pulse <= '0';
			end if;
		end if;

		if rst = '1' then 
			Latch <= '0';
		end if;
	end process;
end architecture; 

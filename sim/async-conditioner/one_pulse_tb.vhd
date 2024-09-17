-- Bring in the IEEE libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--Bring in the class libraries
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;


entity one_pulse_tb is 
end entity one_pulse_tb;



architecture testbench of one_pulse_tb is
	--Release the kraken! IE the one pulse
	
	component one_pulse is 
		port ( 
			clk	: in std_ulogic;
			rst	: in std_ulogic;
			input	: in std_ulogic;
			pulse	: out std_ulogic
		);

	end component one_pulse;


	--Test bench verification signals:
	signal clk_tb 	: std_ulogic := '0';
	signal input_tb	: std_ulogic := '0';	
	signal rst_tb	: std_ulogic := '1';
	signal pulse_tb : std_ulogic := '0';

		
begin
	-- Create TB clock signal
	clk_tb <= not clk_tb after CLK_PERIOD / 2;
	
	stimuli_and_checker : process is
	begin
			
end architecture;



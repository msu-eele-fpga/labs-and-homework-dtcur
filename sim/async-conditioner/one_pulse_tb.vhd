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
	-- Create the one pulse duv	
	duv : component one_pulse
		port map (
		clk => clk_tb,
		rst => rst_tb,
		input => input_tb,
		pulse => pulse_tb
		);
		
	-- Create TB clock signal
	clk_tb <= not clk_tb after CLK_PERIOD / 2;
	
	stimuli_and_checker : process is
	begin
		-- Start low for a while holding reset for 10 clock cycles
		wait_for_clock_edges(clk_tb, 10);
		-- Wait fo clock peroid then change
		wait for CLK_PERIOD / 2;
		
		rst_tb <= '0';
		
		-- Test no input and reset off to make sure no pulse
		wait_for_clock_edges(clk_tb, 5);


		-- Set Input high for two clock pulses and ensure it maps to pulse for one pulse
		input_tb <= '1';
		wait_for_clock_edges(clk_tb, 2);
		input_tb <= '0';
		wait_for_clock_edges(clk_tb, 3);

		--Set input low in the middle of a clock pulse
		wait_for_clock_edge(clk_tb);
		wait for CLK_PERIOD / 4;
		input_tb <= '1';
		wait_for_clock_edges(clk_tb, 2);
		wait for CLK_PERIOD / 4;
		input_tb <= '0';
		wait_for_clock_edges(clk_tb, 5);
		
		std.env.finish;

	end process;
end architecture;



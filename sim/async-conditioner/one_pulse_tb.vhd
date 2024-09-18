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
	--Expected pulse signal for verification
	variable pulse_expected : std_logic := '0';
	
	begin
		
		
		-- Start low input with high reset, ensure reset test passes. 
		print("========================================================================");
		print("Testing reset condition");
		print("========================================================================");
		rst_tb <= '1';
		pulse_expected := '0';
		assert_eq(pulse_tb, pulse_expected, "While held in reset");
		wait_for_clock_edges(clk_tb, 5);
		---Test input during reset, ensure input rejection.
		print("     Test: Input while reset");
		wait_for_clock_edge(clk_tb);
		rst_tb <= '1';
		input_tb <= '1';
		pulse_expected := '0';
		assert_eq(pulse_tb, pulse_expected, "While held in reset with input");
		wait_for_clock_edges(clk_tb, 5);
		
		input_tb <= '0'; --Reset input testbench before next test
		wait_for_clock_edges(clk_tb, 2); -- Delay before starting next test
		
		-- Test for idle case ie if there is no input for multiple clock cycles but not reset		
		print("========================================================================");
		print("Testing idle condition");
		print("========================================================================");
		wait for CLK_PERIOD/2; --Wait before disabling reset
		rst_tb <= '0';
		pulse_expected := '0';
		print("     Test: Idle state");
		wait_for_clock_edges(clk_tb, 5);
		assert_eq(pulse_tb, pulse_expected, "Idle no input, no reset");

		-- Test set input high for two clock cycles and verify pulse only triggers for one pulse
		print("======================================================================");
		print("Testing input response");
		print("======================================================================");
		print("    Test: No input change before pulse");
		pulse_expected := '0';
		input_tb <= '0';
		assert_eq(pulse_tb, pulse_expected, "Idle no input before input");
		wait_for_clock_edges(clk_tb, 2);
		input_tb <= '1';
		pulse_expected := '1';
		print("    Test: Input creates a high output");
		wait for CLK_PERIOD;
		assert_eq(pulse_tb, pulse_expected, "Pulse goes high at expected time");	
		wait_for_clock_edges(clk_tb, 2);
		input_tb <= '0';
		wait_for_clock_edges(clk_tb, 3);
		wait for CLK_PERIOD;
		print("    Test: Pulse goes low after one clock cycle");
		pulse_expected := '0';
		assert_eq(pulse_tb, pulse_expected, "Pulse goes low at expected time");

		--Test setting input low during a pulse 
		print("==================================================================");
		print("Testing pulse does not change if input changes during pulse");
		print("==================================================================");
		wait_for_clock_edge(clk_tb);
		input_tb <= '1';
		pulse_expected := '1';
		wait for CLK_PERIOD + CLK_PERIOD / 4;
		input_tb <= '0';
		wait for CLK_PERIOD / 4;
		assert_eq(pulse_tb, pulse_expected, "Pulse stays high when input changes during pulse");
		wait_for_clock_edges(clk_tb,2);

		--Delay for a few clock cycles with reset asserted before ending
		rst_tb <= '1';
		wait_for_clock_edges(clk_tb, 4);
		std.env.finish;

	end process;
end architecture;



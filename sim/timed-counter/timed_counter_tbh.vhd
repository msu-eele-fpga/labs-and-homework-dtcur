--Required packages
--Must be compiled with 2008 VHDL standard
library ieee;
use ieee.std_logic_1164.all;
-- Class packages
use work.print_pkg.all;
use work.assert_pkg.all;

--Test bench package for delays
use work.tb_pkg.all;


-- Timed counter entity

entity timed_counter_tb is
end entity timed_counter_tb;

architecture testbench of timed_counter_tb is

	--Bring in timed_counter component 
	--Pass in the time delays as specified in tb_pkg
	component timed_counter is
		generic ( 
			clk_period : time;
			count_time : time
		);
		port (
			clk	: in std_ulogic;
			enable	: in boolean;
			done	: out boolean

		);
	end component timed_counter;
	
	--Craete TB signals for verification
	signal clk_tb : std_ulogic := '0';

	signal enable_100ns_tb	: boolean := false;
	signal done_100ns_tb	: boolean;

	constant HUNDRED_NS 	: time := 100 ns;
	
	--Check for the appropriate done flag procedure
	procedure predict_counter_done (
		constant count_time	: in time;
		signal enable		: in boolean;
		signal done		: in boolean;
		constant count_itr	: in natural
		) is
		
	begin 
		if enable then 
			if count_itr < (count_time / CLK_PERIOD) then 
				assert_false(done, "Counter not done");
			else
				assert_true(done, "Counter is done");
			end if;
		else 
			assert_false(done, "Counter not enabled");
		end if;

	end procedure predict_counter_done;

begin
	dut_100ns_counter : component timed_counter
		generic map (
			clk_period => CLK_PERIOD,
			count_time => HUNDRED_NS
			)
		port map (
			clk => clk_tb,
			enable => enable_100ns_tb,
			done => done_100ns_tb
			);

		clk_tb <= not clk_tb after CLK_PERIOD / 2;

		stimuli_and_checker : process is
		begin
		--Test 100 ns timer when enabled
			print("Testing 100 ns timer: enabled");
			wait_for_clock_edge(clk_tb);
			enable_100ns_tb <= true; 

			--Loop for the number of clock cycles that is equal to the timer period

			for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
				wait_for_clock_edge(clk_tb);
				-- Test for correct done output
			       predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);	
			end loop;

			--Add additional test cases as needed

			std.env.finish;

		end process stimuli_and_checker;

end architecture testbench;


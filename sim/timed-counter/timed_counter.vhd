library ieee;
use ieee.std_logic_1164.all;
--Use the package created for this homework
use work.tb_pkg.all;



entity timed_counter is
	generic ( 
		clk_period	: time;
		count_time	: time
	);
	port (
		clk	: in std_ulogic;
		enable	: in boolean;
		done	: out boolean
	);

end entity timed_counter;

architecture counter_arch of timed_counter is
	constant COUNTER_LIMIT	: integer := clk_period / count_time;
	signal	 counter	: integer range 0 to COUNTER_LIMIT := 0;

begin
	proc_timed_counter : process(clk, enable)

	begin
		if rising_edge(clk) and enable then
			-- If running then increase counter by one
			counter <= counter + 1;
			-- If counter has exceeded or is equal to the COUNTER_LIMIT
			-- stop counting and assert done and reset counter
			-- If enable is still true this will continue to count
			if counter >= COUNTER_LIMIT then 
				done <= true;
				counter <= 0;
			else
			-- If still counting assert done as false
				done <= false;
			end if;
		else
			-- Reachable only if not enabled, in which case assert done as false
			done <= false;
		end if;
	end process;

end architecture counter_arch;

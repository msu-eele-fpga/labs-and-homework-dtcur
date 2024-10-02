library ieee;
use ieee.std_logic_1164.all;



entity timed_counter is
	generic ( 
		clk_period	: time;
		count_time	: time
	);
	port (
		clk	: in std_ulogic;
		enable	: in std_ulogic;
		done	: out boolean
	);

end entity timed_counter;

architecture counter_arch of timed_counter is
	constant COUNTER_LIMIT	: integer :=  (count_time / clk_period) -1;
	signal	 counter	: integer range 0 to COUNTER_LIMIT := 0;

begin
	proc_timed_counter : process(clk, enable)

	begin
	if(enable = '1') then 
		if rising_edge(clk) then
				-- If counter has exceeded or is equal to the COUNTER_LIMIT
				-- stop counting and assert done and reset counter
				-- If enable is still true this will continue to count
				if counter >= COUNTER_LIMIT then 
					done <= true;
					counter <= 0;
				else
					-- If still counting assert done as false
					counter <= counter + 1;
					done <= false;
				end if;
		end if;
	else
		counter <= 0;
		--done <= false;
	end if;
	end process;

end architecture counter_arch;

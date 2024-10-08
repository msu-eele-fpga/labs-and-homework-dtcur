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

entity clock_divider_tb is
end entity clock_divider_tb;

architecture testbench of clock_divider_tb is

  --Bring in clock_divider component 
  --Pass in the time delays as specified in tb_pkg
  component clock_divider is
    generic (
      clk_period : time;
      count_time : time
    );
    port (
      clk    : in std_ulogic;
      enable : in boolean;
      done   : out boolean

    );
  end component clock_divider;

  --Craete TB signals for verification
  signal clk_tb : std_ulogic := '0';

  signal enable_100ns_tb : boolean := false;
  signal done_100ns_tb   : boolean;
  signal enable_240ns_tb : boolean := false;
  signal done_240ns_tb   : boolean;

  constant HUNDRED_NS   : time := 100 ns;
  constant TWOFOURTY_NS : time := 240 ns;

  --Check for the appropriate done flag procedure
  procedure predict_counter_done (
    constant count_time : in time;
    signal enable       : in boolean;
    signal done         : in boolean;
    constant count_itr  : in natural
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
  -- 100 ns counter DUT
  dut_100ns_counter : component clock_divider
    generic map(
      clk_period => CLK_PERIOD,
      count_time => HUNDRED_NS
    )
    port map(
      clk    => clk_tb,
      enable => enable_100ns_tb,
      done   => done_100ns_tb
    );
    -- 240 ns counter DUT -> Used for testing generics work on different times
    dut_240ns_counter : component clock_divider
      generic map(
        clk_period => CLK_PERIOD,
        count_time => TWOFOURTY_NS
      )
      port map(
        clk    => clk_tb,
        enable => enable_240ns_tb,
        done   => done_240ns_tb
      );
      clk_tb <= not clk_tb after CLK_PERIOD / 2;

      stimuli_and_checker_100ns : process is
      begin

        --Test 100 ns timer when enabled test case #1
        print("Testing 100 ns timer: enabled");
        wait_for_clock_edge(clk_tb);
        enable_100ns_tb <= true;

        --Loop for the number of clock cycles that is equal to the timer period

        for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
          wait_for_clock_edge(clk_tb);
          -- Test for correct done output
          predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
        end loop;

        -- End test #1
        if done_100ns_tb then
          enable_100ns_tb <= false;
        end if;

        -- Test condition #2 set enable low for two close cycles and ensure done is not asserted properly
        wait_for_clock_edge(clk_tb);
        enable_100ns_tb <= false;
        wait_for_clock_edge(clk_tb);
        enable_100ns_tb <= false;

        -- Test for two consecutive timer counts test case #3
        print("Testing 100 ns timer: enabled, nested loops");
        wait_for_clock_edge(clk_tb);
        enable_100ns_tb <= true;

        for y in 0 to 2 loop
          for x in 0 to (HUNDRED_NS / CLK_PERIOD) loop
            wait_for_clock_edge(clk_tb);
            --Test for correct done flag 
            predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, x);
          end loop;
        end loop;
        enable_100ns_tb <= false;
      end process stimuli_and_checker_100ns;

      --Test DUT #2 240 ns
      stimuli_and_checker_240ns : process is
      begin

        --Test 100 ns timer when enabled test case #1
        print("Testing 240 ns timer: enabled");
        wait_for_clock_edge(clk_tb);
        enable_240ns_tb <= true;

        --Loop for the number of clock cycles that is equal to the timer period

        for i in 0 to (TWOFOURTY_NS / CLK_PERIOD) loop
          wait_for_clock_edge(clk_tb);
          -- Test for correct done output
          predict_counter_done(TWOFOURTY_NS, enable_240ns_tb, done_240ns_tb, i);
        end loop;

        -- End test #1
        if done_240ns_tb then
          enable_240ns_tb <= false;
        end if;

        -- Test condition #2 set enable low for two close cycles and ensure done is not asserted properly
        wait_for_clock_edge(clk_tb);
        enable_240ns_tb <= false;
        wait_for_clock_edge(clk_tb);
        enable_240ns_tb <= false;

        -- Test for two consecutive timer counts test case #3
        print("Testing 240 ns timer: enabled, nested loops");
        wait_for_clock_edge(clk_tb);
        enable_240ns_tb <= true;

        for y in 0 to 2 loop
          for x in 0 to (TWOFOURTY_NS / CLK_PERIOD) loop
            wait_for_clock_edge(clk_tb);
            --Test for correct done flag 
            predict_counter_done(TWOFOURTY_NS, enable_240ns_tb, done_240ns_tb, x);
          end loop;
        end loop;
        --End simulation
        std.env.finish;

      end process stimuli_and_checker_240ns;

    end architecture testbench;

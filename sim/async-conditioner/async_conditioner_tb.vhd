-- Bring in the IEEE libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--Bring in the class libraries
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity async_conditioner_tb is
end entity async_conditioner_tb;

architecture testbench of async_conditioner_tb is
  component async_conditioner is
    port (
      clk          : in std_ulogic;
      rst          : in std_ulogic;
      button_press : in std_ulogic;
      button_pulse : out std_ulogic
    );
  end component;
  --Internal signals 
  signal bouncer_tb : std_ulogic := '0'; --Button input
  signal pulse_tb   : std_ulogic := '0'; --Output pulse
  signal clk_tb     : std_ulogic := '0';
  --Test bench verification signals:

  signal rst_tb : std_ulogic := '1';
  --Constants for bouncing from deboucer_tb.vhd from Trevor Vannoy 2024
  constant BOUNCE_PERIOD           : time    := 100 ns;
  constant DEBOUNCE_TIME_1us       : time    := 1000 ns;
  constant DEBOUNCE_CYCLES_1us     : natural := DEBOUNCE_TIME_1us / BOUNCE_PERIOD;
  constant DEBOUNCE_CLK_CYCLES_1US : natural := DEBOUNCE_TIME_1US / CLK_PERIOD;

  -- Bounce signal procedure from deboucer_tb.vhd from Trevor Vannoy 2024
  procedure bounce_signal (
    signal bounce          : out std_ulogic;
    constant BOUNCE_PERIOD : time;
    constant BOUNCE_CYCLES : natural;
    constant FINAL_VALUE   : std_ulogic
  ) is

    -- If BOUNCE_CYCLES is not an integer multiple of 4, the division
    -- operation will only return the integer part (i.e., perform a floor
    -- operation). Thus, we need to calculate how many cycles are remaining
    -- after waiting for 3 * BOUNCE_CYCLES_BY_4 BOUNCE_PERIODs. If BOUNCE_CYCLES
    -- is an integer multiple of 4, then REMAINING_CYCLES will be equal to
    -- BOUNCE_CYCLES_BY_4.
    constant BOUNCE_CYCLES_BY_4 : natural := BOUNCE_CYCLES / 4;
    constant REMAINING_CYCLES   : natural := BOUNCE_CYCLES - (3 * BOUNCE_CYCLES_BY_4);

  begin

    -- Toggle the bouncing input quickly for ~1/4 of the debounce time
    for i in 1 to BOUNCE_CYCLES_BY_4 loop
      bounce <= not bounce;
      wait for BOUNCE_PERIOD;
    end loop;

    -- Toggle the bouncing input slowly for ~1/2 of the debounce time
    for i in 1 to BOUNCE_CYCLES_BY_4 loop
      bounce <= not bounce;
      wait for 2 * BOUNCE_PERIOD;
    end loop;

    -- Settle at the final value for the rest of the debounce time
    bounce <= FINAL_VALUE;
    wait for REMAINING_CYCLES * BOUNCE_PERIOD;

  end procedure bounce_signal;

  --End bouce signal procedure from debouncer_tb.vhd from Trevor Vannoy 2024

begin

  duv : component async_conditioner
    port map
    (
      clk          => clk_tb,
      rst          => rst_tb,
      button_press => bouncer_tb,
      button_pulse => pulse_tb
    );
    -----Create clock
    clk_tb <= not clk_tb after CLK_PERIOD / 2;

    stimuli_and_checker : process is
      --Expected pulse signal for verification
      variable pulse_expected : std_logic := '0';
    begin
      ------------------------------------------------------------------------------------------------------------------
      -- Start low input with high reset, ensure reset test passes. 
      print("========================================================================");
      print("Testing reset condition");
      print("========================================================================");
      rst_tb <= '1';
      pulse_expected := '0';
      assert_eq(pulse_tb, pulse_expected, "While held in reset");
      wait_for_clock_edges(clk_tb, 5);
      -----------------------------------------------------------------------------------------------------------------
      ---Test input during reset, ensure input rejection.
      print("     Test: Input while reset");
      wait_for_clock_edge(clk_tb);
      rst_tb <= '1';
      pulse_expected := '0';
      bounce_signal(bouncer_tb, BOUNCE_PERIOD, DEBOUNCE_CYCLES_1us, '0');
      pulse_expected := '0';
      assert_eq(pulse_tb, pulse_expected, "While held in reset with input");
      wait_for_clock_edges(clk_tb, DEBOUNCE_CLK_CYCLES_1US);
      -----------------------------------------------------------------------------------------------------------------
      ---Test no input and no reset  
      wait_for_clock_edges(clk_tb, 2);
      print("     Test: No input while reset off");
      rst_tb <= '0';
      pulse_expected := '0';
      wait_for_clock_edges(clk_tb, 5); --Check for 5 clock pulses 
      assert_eq(pulse_tb, pulse_expected, "While no reset and no input");
      -----------------------------------------------------------------------------------------------------------------
      -- Test bounce over multiple clock cycles and verify pulse only triggers for one pulse
      print("======================================================================");
      print("Testing input response");
      print("======================================================================");
      print("    Test: No input change before pulse");
      pulse_expected := '0';
      bouncer_tb <= '0';
      assert_eq(pulse_tb, pulse_expected, "Idle no input before input");
      wait_for_clock_edges(clk_tb, 2);
      --Manual bouncing for checking for pulse timing
      wait for CLK_PERIOD / 4; --20ns/4 -> 5ns
      bouncer_tb <= '1';
      wait for clk_period / 2; --10ns
      bouncer_tb <= not bouncer_tb;
      wait for clk_period / 4; --5ns
      bouncer_tb <= not bouncer_tb;
      wait for clk_period; --20ns
      bouncer_tb <= not bouncer_tb;
      wait for clk_period;
      bouncer_tb <= not bouncer_tb;
      --Total wait so far for manual bouncing: 40ns
      wait for clK_period * 2; --Wait and aditional 40ns for pulse to start
      pulse_expected := '1';
      print("    Test: Input creates a high output");
      assert_eq(pulse_tb, pulse_expected, "Pulse goes high at expected time");
      wait_for_clock_edges(clk_tb, 2);
      bouncer_tb <= '0';
      wait_for_clock_edges(clk_tb, 3);
      wait for CLK_PERIOD;
      print("    Test: Pulse goes low after one clock cycle");
      pulse_expected := '0';
      assert_eq(pulse_tb, pulse_expected, "Pulse goes low at expected time");
      wait_for_clock_edges(clk_tb, 2); -- Delay before starting next test

      std.env.finish;
    end process;
  end architecture;
--EELE-467 Fall 2024 11/30/2024
--Drew Currie 
-- Homework 9 PWM controller

--This project creates a PWM signal

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pwm_controller is
  generic (
    CLK_PERIOD   : time    := 20 ns;
    W_PERIOD     : integer := 30;
    W_DUTY_CYCLE : integer := 11
  );

  port (
    clk : in std_logic;
    rst : in std_logic;
    --PWM repetition period in milliseconds
    --datatype (W.F)
    period     : in unsigned (W_PERIOD - 1 downto 0)    := (others => '0');
    duty_cycle : in unsigned(W_DUTY_CYCLE - 1 downto 0) := (others => '0');
    output     : out std_logic                          := '0'
  );
end entity pwm_controller;

architecture pwm_arch of pwm_controller is
  --Bring in timed counter as the delay system for the period and duty-cycle 
  component clock_divider
    generic (
      C_PERIOD : integer
    );
    port (
      count : in unsigned(C_PERIOD - 1 downto 0);
      clk   : in std_ulogic;
      rst   : in std_logic;
      done  : out std_logic
    );
  end component;

  --Unit conversion constant
  constant CLOCK_PULSE_PER_MS           : integer := 1 ms / CLK_PERIOD;
  constant LENGTH_OF_CLOCK_PULSE_PER_MS : integer := 15;
  --Signals to interface with counter
  signal period_done_counter     : std_logic;
  signal duty_cycle_done_counter : std_logic;
  signal duty_cycle_control      : std_logic := '1';
  --Calculate the length of the period in clock pulses
  signal period_clock_pulses     : unsigned (W_PERIOD + LENGTH_OF_CLOCK_PULSE_PER_MS downto 0);
  signal duty_cycle_clock_pulses : unsigned (W_PERIOD + W_DUTY_CYCLE + LENGTH_OF_CLOCK_PULSE_PER_MS downto 0);
begin
  --Assign values to internal registers
  period_clock_pulses     <= period * to_unsigned(CLOCK_PULSE_PER_MS, 16);
  duty_cycle_clock_pulses <= period * duty_cycle * to_unsigned(CLOCK_PULSE_PER_MS, 16);
  period_clock : clock_divider
  generic map(
    -- Set period width for the clock divider equal to the size of the 
    -- input calculation minus the fractional bits. In this case 24 fractional bits
    C_PERIOD => W_PERIOD + LENGTH_OF_CLOCK_PULSE_PER_MS - 24
  )
  port map(
    count => period_clock_pulses(W_PERIOD + LENGTH_OF_CLOCK_PULSE_PER_MS - 1 downto 24),
    clk   => clk,
    rst   => rst,
    done  => period_done_counter
  );

  duty_clock : clock_divider
  generic map(
    -- 26 bits minus 4 for 22 bits length of the max duty cycle. 
    -- Becomes two times the input length
    C_PERIOD => W_DUTY_CYCLE + LENGTH_OF_CLOCK_PULSE_PER_MS - 4
  )
  port map(
    count => duty_cycle_clock_pulses(W_DUTY_CYCLE + W_PERIOD + LENGTH_OF_CLOCK_PULSE_PER_MS - 1 downto 34),
    clk   => clk,
    rst   => duty_cycle_control,
    done  => duty_cycle_done_counter
  );

  proc_pwm_output : process (clk, rst, period_done_counter, duty_cycle_done_counter)
  begin
    if period_done_counter = '1' then
      output             <= '1';
      duty_cycle_control <= '0';
    end if;
    if duty_cycle_done_counter = '1' then
      output             <= '0';
      duty_cycle_control <= '1';
    end if;
  end process;
end architecture pwm_arch;

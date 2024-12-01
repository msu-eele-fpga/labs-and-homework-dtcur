--EELE-467 Fall 2024 11/30/2024
--Drew Currie 
-- Homework 9 PWM controller

--This project creates a PWM signal

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pwm_controller is
  generic (
    CLK_PERIOD : time := 20 ns
  );

  port (
    clk : in std_logic;
    rst : in std_logic;
    --PWM repetition period in milliseconds
    --datatype (W.F)
    period     : in unsigned(53 downto 0);
    duty_cycle : in unsigned(34 downto 0);
    output     : out std_logic
  );
end entity pwm_controller;

architecture pwm_arch of pwm_controller is
  --Signals to hold the period and duty cycles 
  --Split between whole number and fractional bits
  signal period_whole      : unsigned(29 downto 0);
  signal period_fractional : unsigned(23 downto 0);

  signal duty_cycle_whole      : unsigned(10 downto 0);
  signal duty_cycle_fractional : unsigned(23 downto 0);
  --Need some constants to convert from mS of input to number of clock cycles
  --Due to the DE10Nano clock being 20ns, the max precision is 21 fractional bits. 
  --This means truncation is required and resolution is limited. 

begin
  --Assign values to internal registers
  period_whole      <= period(53 downto 24);
  period_fractional <= period(23 downto 0);

  duty_cycle_whole      <= duty_cycle(34 downto 24);
  duty_cycle_fractional <= duty_cycle(23 downto 0);
  proc_pwm_test : process (clk, rst)
  begin
    if rising_edge(clk) then
      output <= '1';
    else
      output <= '0';
    end if;
  end process;
end architecture pwm_arch;

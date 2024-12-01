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
    period     : in unsigned;
    duty_cycle : in unsigned;
    output     : out std_logic
  );
end entity pwm_controller;

architecture pwm_arch of pwm_controller is
begin
  proc_pwm_test : process (clk, rst)
  begin
    if rising_edge(clk) then
      output <= '1';
    else
      output <= '0';
    end if;
  end process;
end architecture pwm_arch;

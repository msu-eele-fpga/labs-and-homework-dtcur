--Required packages
--Must be compiled with 2008 VHDL standard
library ieee;
use ieee.std_logic_1164.all;
--class packages
use work.print_pkg.all;
use work.assert_pkg.all;

--Test bench package for delays
use work.tb_pkg.all;
-- Timed counter entity

entity pwm_tb is
end entity pwm_tb;
architecture testbench of pwm_tb is
  --Bring in PWM generator component
  component pwm_controller is
    generic (
      CLK_PERIOD : time;
    )
    port (
      clk        : in std_logic;
      rst        : in std_logic;
      period     : in unsigned;
      duty_cycle : in unsigned;
      output     : out std_logic;
    )
  end entity pwm_controller;

  --Basic enable signals
  signal rst_tb       : std_logic := '1';
  signal clk_tb       : std_logic := '0';
  constant CLK_PERIOD : time      := 20 ns;
  --Interface signals
  signal duty_cycle_tb : unsigned := 1110;
  signal period_tb     : unsigned := 3024;
  signal pwm           : std_logic;
begin
  dut_pwm_controller : component pwm_controller
    generic map(
      CLK_PERIOD => 20ns
    )
    port map(
      clk        => clk_tb,
      rst        => rst_tb,
      period     => period_tb,
      duty_cycle => duty_cycle_tb,
      output     => pwm
    );
    --Create clock
    clk_tb <= not clk_tb after CLK_PERIOD/2;
  end architecture;

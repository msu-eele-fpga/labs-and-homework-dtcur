--Required packages
--Must be compiled with 2008 VHDL standard
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
      CLK_PERIOD : time
    );
    port (
      clk        : in std_logic;
      rst        : in std_logic;
      period     : in unsigned(53 downto 0);
      duty_cycle : in unsigned(34 downto 0);
      output     : out std_logic
    );
  end component pwm_controller;

  --Basic enable signals
  signal rst_tb       : std_logic := '1';
  signal clk_tb       : std_logic := '0';
  constant CLK_PERIOD : time      := 20 ns;
  --Interface signals
  signal period_tb     : unsigned(53 downto 0) := (28 downto 5 => "111100000011000100100111", others => '0');
  signal duty_cycle_tb : unsigned(34 downto 0) := (23 downto 5 => "1101100110011001101", others => '0');
  signal pwm_tb        : std_logic;
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
      output     => pwm_tb
    );
    --Create clock
    clk_tb <= not clk_tb after CLK_PERIOD/2;
    stimuli_and_checker_100ns : process is
    begin
      print("Testing basic IO");
      wait_for_clock_edge(clk_tb);
      rst_tb <= '0';

      wait_for_clock_edges(clk_tb, 10);
      print("Ending test");
      std.env.finish;
    end process;
  end architecture;

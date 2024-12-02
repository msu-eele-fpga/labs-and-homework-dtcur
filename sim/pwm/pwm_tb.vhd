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
      CLK_PERIOD   : time;
      W_PERIOD     : integer := 30;
      W_DUTY_CYCLE : integer := 11
    );
    port (
      clk        : in std_logic;
      rst        : in std_logic;
      period     : in unsigned(29 downto 0);
      duty_cycle : in unsigned(10 downto 0);
      output     : out std_logic
    );
  end component pwm_controller;

  --Basic enable signals
  signal rst_tb       : std_logic := '1';
  signal clk_tb       : std_logic := '0';
  constant CLK_PERIOD : time      := 20 ns;
  --Interface signals
  signal period_tb     : unsigned(29 downto 0) := (23 downto 22 => "01", others => '0');
  signal duty_cycle_tb : unsigned(10 downto 0) := (10 downto 9 => "01", others => '0');
  signal pwm_tb        : std_logic;
begin
  dut_pwm_controller : component pwm_controller
    generic map(
      CLK_PERIOD => 20 ns
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
      print("Testing at 0.25ms with 50% duty cycle");
      period_tb     <= (23 downto 22 => "01", others => '0');
      duty_cycle_tb <= (10 downto 9 => "01", others => '0');
      wait_for_clock_edge(clk_tb);
      rst_tb <= '0';
      --Get 4 periods in 
      wait_for_clock_edges(clk_tb, 12500 * 5);
      print("Ending test");
      rst_tb <= '1';
      ---------------------------------------------------------------------------------------
      print("Testing at 0.125ms with 25% duty cycle");
      period_tb     <= (22 downto 21 => "01", others => '0');
      duty_cycle_tb <= (9 downto 8 => "01", others => '0');
      wait_for_clock_edge(clk_tb);
      rst_tb <= '0';

      --Get 4 periods in 
      wait_for_clock_edges(clk_tb, 6250 * 5);
      print("Ending test");
      rst_tb <= '1';
      ---------------------------------------------------------------------------------------
      print("Testing at 0.5ms with 75% duty cycle");
      period_tb     <= (24 downto 23 => "01", others => '0');
      duty_cycle_tb <= (10 downto 8 => "011", others => '0');
      wait_for_clock_edge(clk_tb);
      rst_tb <= '0';

      --Get 4 periods in 
      wait_for_clock_edges(clk_tb, 25000 * 5);
      print("Ending test");
      rst_tb <= '1';
      std.env.finish;
    end process;
  end architecture;

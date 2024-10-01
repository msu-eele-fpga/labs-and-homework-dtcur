-- Bring in the IEEE libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--Bring in the class libraries
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;
entity led_patterns_tb is
end entity led_patterns_tb;

architecture testbench of led_patterns_tb is
  component led_patterns is
    generic (
      system_clock_period : time := 20 ns
    );
    port (
      clk             : in std_ulogic;
      rst             : in std_ulogic;
      push_button     : in std_ulogic;
      switches        : in std_ulogic_vector(3 downto 0);
      hps_led_control : in boolean;
      base_period     : in unsigned(7 downto 0);
      led_reg         : in std_ulogic_vector (7 downto 0);
      led             : out std_ulogic_vector(7 downto 0)
    );
  end component;

  --Testbench signals
  signal clk_tb         : std_ulogic                    := '0';
  signal rst_tb         : std_ulogic                    := '1';
  signal button_tb      : std_ulogic                    := '0';
  signal switches_tb    : std_ulogic_vector(3 downto 0) := "0000";
  signal base_period_tb : unsigned(7 downto 0)          := "00000010";
  signal leds_tb        : std_ulogic_vector(7 downto 0);

begin

  --Create the LED Pattern state machine
  duv : component led_patterns
    generic map(
      system_clock_period => CLK_PERIOD
    )
    port map(
      clk             => clk_tb,
      rst             => rst_tb,
      push_button     => button_tb,
      switches        => switches_tb(3 downto 0),
      hps_led_control => false,
      base_period     => base_period_tb(7 downto 0),
      led_reg         => "00000000",
      led             => leds_tb(7 downto 0)
    );

    clk_tb <= not clk_tb after CLK_PERIOD / 2;

    stimuli_and_checker : process is
    begin
      wait_for_clock_edges(clK_tb, 3);
      rst_tb <= '0';
      wait_for_clock_edges(clk_tb, 10);
      switches_tb(3 downto 0) <= "0000";
      button_tb               <= '1';
      wait_for_clock_edges(clk_tb, 1);
      button_tb <= '0';
      wait_for_clock_edges(clk_tb, 5E7);
      wait_for_clock_edges(clk_tb, 5E7);
      switches_tb(3 downto 0) <= "0001";
      button_tb               <= '1';
      wait_for_clock_edges(clk_tb, 1);
      button_tb <= '0';
      wait_for_clock_edges(clk_tb, 5E7);
      wait_for_clock_edges(clk_tb, 5E7);
      switches_tb(3 downto 0) <= "0010";
      button_tb               <= '1';
      wait_for_clock_edges(clk_tb, 1);
      button_tb <= '0';
      wait_for_clock_edges(clk_tb, 5E7);

      wait_for_clock_edges(clk_tb, 5E7);
      switches_tb(3 downto 0) <= "0011";
      button_tb               <= '1';
      wait_for_clock_edges(clk_tb, 1);
      button_tb <= '0';
      wait_for_clock_edges(clk_tb, 5E7);

      wait_for_clock_edges(clk_tb, 5E7);
      switches_tb(3 downto 0) <= "0100";
      button_tb <= '1';
      wait_for_clock_edges(clk_tb, 1);
      button_tb <= '0';
      wait_for_clock_edges(clk_tb, 5E7);

      wait_for_clock_edges(clk_tb, 5E7);
      rst_tb <= '1';
      wait_for_clock_edges(clk_tb, 10);

      std.env.finish;
    end process;
  end architecture;
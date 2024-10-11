library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_patterns_avalon is
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    -- avalon memory-mapped slave interface
    avs_read      : in std_logic;
    avs_write     : in std_logic;
    avs_address   : in std_logic_vector(1 downto 0);
    avs_readdata  : out std_logic_vector(31 downto 0);
    avs_writedata : in std_logic_vector(31 downto 0);
    -- external I/O; export to top-level
    push_button : in std_ulogic;
    switches    : in std_ulogic_vector(3 downto 0);
    led         : out std_ulogic_vector(7 downto 0)
  );

end entity led_patterns_avalon;
architecture led_paterns_avalon_arch of led_patterns_avalon is

  component led_patterns is
    port (
      clk             : in std_ulogic;
      rst             : in std_ulogic;
      push_button     : in std_ulogic;
      switches        : in std_ulogic_vector(3 downto 0);
      hps_led_control : in boolean;
      base_period     : in unsigned(7 downto 0);
      led_reg         : in std_logic_vector (7 downto 0);
      led             : out std_ulogic_vector(7 downto 0)
    );
  end component;
  --Registers needed:
  --1. hps_led_control
  --2. base_period
  --3. led_reg

  --hps_led_control register
  signal hps_led_control : std_logic_vector (31 downto 0);

  --base_period_register
  signal base_period_register : std_logic_vector(31 downto 0);

  --led_reg_register
  signal led_reg : std_logic_vector(31 downto 0);

begin
  LEDPatterns : component led_patterns
    port map(
      clk             => clk,
      rst             => rst,
      push_button     => push_button,
      switches        => switches,
      hps_led_control => false,
      base_period     => unsigned(base_period_register(7 downto 0)),
      led_reg         => led_reg(7 downto 0),
      led             => led
    );
    avalon_regsiter_read : process (clk)
    begin
      if (rising_edge(clk) and avs_read = '1') then
        case(avs_address) is
          when "00" => avs_readdata   <= led_reg;
          when "01" => avs_readdata   <= base_period_register;
          when "11" => avs_readdata   <= hps_led_control;
          when others => avs_readdata <= (others => '0');
        end case;
      end if;
    end process;

    avalon_regsiter_write : process (clk)
    begin
      if (rising_edge(clk) and avs_write = '1') then
        if rst = '1' then
          led_reg              <= "00000000000000000000000000000000";
          base_period_register <= "00000000000000000000000000010000";
          hps_led_control      <= "00000000000000000000000000000001";

        elsif rising_edge(clk) and avs_write = '1' then
          case(avs_address) is
            when "00"   => led_reg              <= avs_writedata(31 downto 0);
            when "01"   => base_period_register <= "00000000000000000000000000000000";
            when "11"   => hps_led_control      <= "00000000000000000000000000000000";
            when others => null;
          end case;
        end if;
      end if;
    end process;
  end architecture led_paterns_avalon_arch;
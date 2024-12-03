--EELE-467 Fall 2024 12/2/2024
--Drwe Currie
-- Homework 10 PWM RGB Controller

--This builds off of the PWM controller from HW-9 
-- Adding functionality with the Avalon HPS interface
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rgb_controller is
  port (
    --Basic input
    clk   : in std_logic;
    reset : in std_logic;
    --Avalon control signals
    avs_s1_write : in std_logic;
    avs_s1_read  : in std_logic;
    --Avalon bus addresses
    avs_s1_address : in std_logic_vector(1 downto 0);
    --Input avalon bus
    avs_s1_writedata : in std_logic_vector(31 downto 0);
    avs_s1_readdata  : out std_logic_vector(31 downto 0);
    --Output PWM signals
    red_output   : out std_logic;
    green_output : out std_logic;
    blue_output  : out std_logic
  );
end entity rgb_controller;

-- Bring in the PWM controller
architecture rbg_arch of rgb_controller is
  component pwm_controller
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
  end component;
  --One duty cycle register per pwm controller
  signal avs_red_duty_cycle   : unsigned (31 downto 0) := (others => '0');
  signal avs_green_duty_cycle : unsigned (31 downto 0) := (others => '0');
  signal avs_blue_duty_cycle  : unsigned (31 downto 0) := (9 => '1', others => '0');

  --One total PWM period
  signal avs_period : unsigned (31 downto 0) := (22 => '1', others => '0');
begin

  red_pwm_controller : pwm_controller
  generic map(
    CLK_PERIOD   => 20 ns,
    W_PERIOD     => 30,
    W_DUTY_CYCLE => 11
  )
  port map(
    clk        => clk,
    rst        => reset,
    period     => avs_period(29 downto 0),
    duty_cycle => avs_red_duty_cycle(10 downto 0),
    output     => red_output
  );
  green_pwm_controller : pwm_controller
  generic map(
    CLK_PERIOD   => 20 ns,
    W_PERIOD     => 30,
    W_DUTY_CYCLE => 11
  )
  port map(
    clk        => clk,
    rst        => reset,
    period     => avs_period(29 downto 0),
    duty_cycle => avs_green_duty_cycle(10 downto 0),
    output     => green_output
  );
  blue_pwm_controller : pwm_controller
  generic map(
    CLK_PERIOD   => 20 ns,
    W_PERIOD     => 30,
    W_DUTY_CYCLE => 11
  )
  port map(
    clk        => clk,
    rst        => reset,
    period     => avs_period(29 downto 0),
    duty_cycle => avs_blue_duty_cycle(10 downto 0),
    output     => blue_output
  );

  --- Avalon interface code
  avalon_register_read : process (clk)
  begin
    if rising_edge(clk) and avs_s1_read = '1' then
      case avs_s1_address is
        when "00" => avs_s1_readdata <= std_logic_vector(avs_period);
        when "01" => avs_s1_readdata <= std_logic_vector(avs_red_duty_cycle);
        when "10" => avs_s1_readdata <= std_logic_vector(avs_green_duty_cycle);
        when "11" => avs_s1_readdata <= std_logic_vector(avs_blue_duty_cycle);
      end case;
    end if;

  end process;
  avalon_register_write : process (clk, reset)
  begin
    if reset = '1' then
      avs_red_duty_cycle   <= x"00000000";
      avs_green_duty_cycle <= x"00000000";
      avs_blue_duty_cycle  <= x"00000000";
    elsif rising_edge(clk) and avs_s1_write = '1' then
      case avs_s1_address is
        when "00"   => avs_period           <= unsigned(avs_s1_writedata);
        when "01"   => avs_red_duty_cycle   <= unsigned(avs_s1_writedata);
        when "10"   => avs_green_duty_cycle <= unsigned(avs_s1_writedata);
        when "11"   => avs_blue_duty_cycle  <= unsigned(avs_s1_writedata);
        when others => null;
      end case;
    end if;
  end process;

end architecture rbg_arch;
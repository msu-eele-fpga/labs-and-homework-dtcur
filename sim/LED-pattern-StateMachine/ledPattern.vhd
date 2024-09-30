library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity led_patterns is
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
end entity;

architecture pattern of led_patterns is
  type State_Type is (idle, blinkSwitches, ledPatternOut);
  signal next_state, current_state : State_Type := idle;
  --Clock divider signals
  signal clock_enable_1s, clock_enable_baseRate : boolean;
  signal clock_divider_done, base_rate_done     : boolean;

  -- Base Rate calcualtion signals
  signal base_period_integer, base_period_fractional : integer;
  --LED mode integer
  signal LEDMode : integer;
  component clock_divider
    port (
      count  : in integer;
      clk    : in std_ulogic;
      enable : in boolean;
      done   : out boolean
    );
  end component;
begin

  --Bring switches value into an integer for switch case later
  LEDMode <= to_integer(unsigned(switches));

  base_period_integer <= to_integer(base_period(7 downto 0));
  --base_period_fractional <= to_integer((base_period(3 downto 0)) * 1E9);
  --base_period_fractional <= shift_left(unsigned(base_period(3 downto 0) * 1E9, base_period(3) * 2 + base_period(2) * 4 + base_period(1) * 8 + base_period(0) * 16));

  --Create clock dividers for 1 second and for slow blinking
  OneSecondDelay : clock_divider

  port map(
    count  => 1 * 1E9,
    clk    => clk,
    enable => clock_enable_1s,
    done   => clock_divider_done
  );
  BaseRate : clock_divider
  port map(
    count  => base_period_integer,
    clk    => clk,
    enable => clock_enable_baseRate,
    done   => base_rate_done
  );
  --Synchronous state memory for where to go. Changing this state is only allowed on a riseing edge of the clock
  STATE_MEMORY : process (clk, rst)
  begin
    if (rst = '1') then
      current_state <= idle;
      elsif (rising_edge(clk)) then
      current_state <= next_state;
    end if;
  end process;

  --Next state logic to control which state to move to from the current state 
  NEXT_STATE_LOGIC : process (current_state, switches, push_button)
  begin
    case (current_state) is
      when idle =>
        if (push_button = '1') then
          next_state <= blinkSwitches;
        else
          next_state <= idle;
        end if;
      when blinkSwitches =>
        --Go to next state after 1 second. This still needs developed
      when ledPatternOut =>
        if (push_button = '1') then
          next_state <= blinkSwitches;
        else
          next_state <= ledPatternOut;
        end if;
    end case;
  end process;

  --Ouput logic to both display the LED patterns and switches on button press
  OUTPUT_LOGIC : process (current_state, clock_divider_done, base_rate_done, rst)
  begin
    if (rst = '1') then
      led(7 downto 0) <= "00000000";
      elsif (rst = '0') then
      case(current_state) is
        when idle =>
        if (base_rate_done) then
          led(7) <= not led(7);
        end if;
        if (clock_enable_baseRate = false) then
          clock_enable_baseRate <= true;
        end if;
        when blinkSwitches =>
        if (base_rate_done) then
          led(7)          <= not led(7);
          led(6 downto 0) <= (others => '0');
          led(3 downto 0) <= switches(3 downto 0);
          elsif (clock_enable_baseRate = false) then
          clock_enable_baseRate <= true;
        end if;
        when ledPatternOut =>
        led(7 downto 0) <= not led(7 downto 0);
      end case;
    end if;
    case(LEDMode) is
      when 0 =>
      led(6 downto 0) <= "0000000";
      when 1 =>
      led(6 downto 0) <= "0000001";
      when 2 =>
      led(6 downto 0) <= "0000010";
      when 3 =>
      led(6 downto 0) <= "0000011";
      when 4 =>
      led(6 downto 0) <= "0000100";
      when 5 =>
      led(6 downto 0)                <= "0000101";
      when others => led(6 downto 0) <= "0000000";
    end case;
  end process;
end architecture;